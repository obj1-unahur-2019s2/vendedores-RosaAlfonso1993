class Vendedor{
	var property certificados = []
	
	method agregarCertificado(certi){
		certificados.add(certi)
	}
	
	method puedeTrabajarEn_(ciudad)
	
	method versatil(){
		return certificados.size() >= 3
		and certificados.any({cer => cer.sobreProductos()})
		and certificados.any({cer=> not cer.sobreProductos()})
	}
	
	method esFirme(){
		return certificados.sum({cer => cer.puntos()}) >= 30
	}
	
	method cantidadDePuntos(){
		return certificados.sum({cer => cer.puntos()})
	}
	
	method esInfluyente()
	
	method vendedorGenerico(){
		return certificados.any({cer => not cer.sobreProductos()})
	}
	
	method tieneAfinidad(centro){
		return self.puedeTrabajarEn_(centro.ciudad())
	}
	
	method esCandidato(centro){
		return self.versatil() and self.tieneAfinidad(centro)
	}
	
	method certificadosDeProductos(){
		return certificados.filter({cer => cer.sobreProductos()})
	}
	
	method personaFisica(){
		return true
	}
}



class VendedorFijo inherits Vendedor{
	const property ciudadVive // const solo da el get
	
	override method puedeTrabajarEn_(ciudad){
		return ciudad == self.ciudadVive()
	}
	
	override method esInfluyente(){
		return false
	}
}

class Viajante inherits Vendedor{
	var property provinciasHabilitadas = #{} //no estan ordenados, no hay primer o ultimo elemento
	
	override method puedeTrabajarEn_(ciudad){
		return provinciasHabilitadas.any({prov => prov == ciudad.provincia()})
	}
	
	override method esInfluyente(){
		return provinciasHabilitadas.sum({ciudad => ciudad.provincia().poblacion()}) >= 10000000
	}
}

class ComercioCorresponsal inherits Vendedor{
	var property ciudadesConSucursales = #{}
	
	override method puedeTrabajarEn_(ciudad){
		return ciudadesConSucursales.constains(ciudad)
	}
	
	method provinciasDeCiudad(){
		return ciudadesConSucursales.map({ciu => ciu.provincia()}).asSet()
	}
	override method esInfluyente(){
		return ciudadesConSucursales.size() >= 5
		or self.provinciasDeCiudad().size() >= 3
	}
	
	override method tieneAfinidad(centro){
		return super(centro) and ciudadesConSucursales.any({ciudad => not centro.puedeCubrir(ciudad)})	
	}
	
	override method personaFisica(){
		return false
	}
}

class CentroDeDistribucion{
	const property ciudad
	var property vendedores = []
	
	method agregarVendedor(vendedor){
		if(not vendedores.constains(vendedor)){
			vendedores.add(vendedor)
		}
		else{
			self.error("ya esta agregado el vendedor")
		}
	}
	
	method vendedorEstrella(){
		return vendedores.max({vendedor => vendedor.cantidadDePuntos()})
	}
	
	method puedeCubrir(city){
		return vendedores.any({vendedor => vendedor.puedeTrabajarEn_(city)})
	}
	
	method vendedoresGenericos(){
		return vendedores.filter({vendedor => vendedor.vendedorGenerico()}).asSet()
	}
	method vendedoresFirmes(){
		return vendedores.filter({vendedor => vendedor.esFirme()})
	}
	
	method esRobusto(){
		return self.vendedoresFirmes().size() >= 3
	}
	
	method agregarCertificacionDeCentro(pun, sP){
		vendedores.forEach({vendedor => vendedor.agregarCertificacion(new Certificado(puntos= pun, sobreProductos = sP))})
	}
}

class Ciudad{
	const property provincia
	
}
class Provincia{
	var property poblacion
}

class Certificado{
	var property puntos
	const property sobreProductos
}

class ClienteInseguro{
	method puedeSerAtendido(vendedor){
		return vendedor.versatil() and vendedor.esFirme()
	}
}
class ClienteDetallista{
	method puedeSerAtendido(vendedor){
		return vendedor.certificados().certificadosDeProductos().size() >= 3
	}
}
class ClienteHumanista{
	method puedeSerAtendido(vendedor){
		return vendedor.personaFisica()
	}
}