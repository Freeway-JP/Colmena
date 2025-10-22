declare module "@salesforce/apex/Cotizador_Cotizacion_Controller.Inicio" {
  export default function Inicio(param: {pId: any, Tipo: any, vlead: any, metodoCalculo: any}): Promise<any>;
}
declare module "@salesforce/apex/Cotizador_Cotizacion_Controller.tarjetasDependientes" {
  export default function tarjetasDependientes(param: {cId: any, tipo: any}): Promise<any>;
}
declare module "@salesforce/apex/Cotizador_Cotizacion_Controller.cambioProducto" {
  export default function cambioProducto(): Promise<any>;
}
declare module "@salesforce/apex/Cotizador_Cotizacion_Controller.LoadOptions" {
  export default function LoadOptions(param: {d: any}): Promise<any>;
}
declare module "@salesforce/apex/Cotizador_Cotizacion_Controller.LoadOptionsCPTR" {
  export default function LoadOptionsCPTR(param: {moneda: any}): Promise<any>;
}
declare module "@salesforce/apex/Cotizador_Cotizacion_Controller.LoadOptionsCPTT" {
  export default function LoadOptionsCPTT(): Promise<any>;
}
declare module "@salesforce/apex/Cotizador_Cotizacion_Controller.LoadOptionsMetodologias" {
  export default function LoadOptionsMetodologias(param: {d: any}): Promise<any>;
}
declare module "@salesforce/apex/Cotizador_Cotizacion_Controller.productoSeleccionado" {
  export default function productoSeleccionado(param: {c: any, list_Producto_Moneda_Tasa: any, list_Producto_Moneda_Tasa_Garantia: any, list_Producto_Moneda: any, d: any, tipo: any}): Promise<any>;
}
declare module "@salesforce/apex/Cotizador_Cotizacion_Controller.OpcionesCondEmpleo" {
  export default function OpcionesCondEmpleo(param: {esAsalarido: any}): Promise<any>;
}
declare module "@salesforce/apex/Cotizador_Cotizacion_Controller.ModificarCotizacion" {
  export default function ModificarCotizacion(param: {Id_Cotizador: any, tipo: any}): Promise<any>;
}
declare module "@salesforce/apex/Cotizador_Cotizacion_Controller.EliminarCotizacion" {
  export default function EliminarCotizacion(param: {Id_Cotizador: any}): Promise<any>;
}
declare module "@salesforce/apex/Cotizador_Cotizacion_Controller.NuevaCotizacion" {
  export default function NuevaCotizacion(param: {tipo: any}): Promise<any>;
}
declare module "@salesforce/apex/Cotizador_Cotizacion_Controller.CrearCaso" {
  export default function CrearCaso(param: {l: any, c: any, tipo: any}): Promise<any>;
}
declare module "@salesforce/apex/Cotizador_Cotizacion_Controller.GuardarCotizacion" {
  export default function GuardarCotizacion(param: {c: any, sl: any, lead_Id: any, tipo: any, dAdicional: any, nombreproducto: any, modoExpoMovil: any, dependientes: any}): Promise<any>;
}
declare module "@salesforce/apex/Cotizador_Cotizacion_Controller.enviarCotizacionPorEmail" {
  export default function enviarCotizacionPorEmail(param: {ids: any, campana_Id: any, lead_Id: any, Enviar_correo_a_usuario: any}): Promise<any>;
}
declare module "@salesforce/apex/Cotizador_Cotizacion_Controller.LlenadoDocumentos_Serv" {
  export default function LlenadoDocumentos_Serv(param: {l_id: any, c_id: any, tipo: any}): Promise<any>;
}
declare module "@salesforce/apex/Cotizador_Cotizacion_Controller.obtenerValoresCP" {
  export default function obtenerValoresCP(param: {ld: any, d: any}): Promise<any>;
}
declare module "@salesforce/apex/Cotizador_Cotizacion_Controller.LoadOptionsCasosParticulares" {
  export default function LoadOptionsCasosParticulares(): Promise<any>;
}
declare module "@salesforce/apex/Cotizador_Cotizacion_Controller.LoadOptionsTipoOperacion" {
  export default function LoadOptionsTipoOperacion(): Promise<any>;
}
declare module "@salesforce/apex/Cotizador_Cotizacion_Controller.getSolicitudesIV" {
  export default function getSolicitudesIV(param: {ld: any}): Promise<any>;
}
declare module "@salesforce/apex/Cotizador_Cotizacion_Controller.deleteSolicitud" {
  export default function deleteSolicitud(param: {sId: any}): Promise<any>;
}
declare module "@salesforce/apex/Cotizador_Cotizacion_Controller.reprocesarValidaciones" {
  export default function reprocesarValidaciones(param: {l: any, c: any}): Promise<any>;
}
declare module "@salesforce/apex/Cotizador_Cotizacion_Controller.borrarPasivos" {
  export default function borrarPasivos(param: {l: any, c: any}): Promise<any>;
}
declare module "@salesforce/apex/Cotizador_Cotizacion_Controller.VerificaCambioDeudores" {
  export default function VerificaCambioDeudores(param: {l: any, c: any}): Promise<any>;
}
declare module "@salesforce/apex/Cotizador_Cotizacion_Controller.consultaPasivos" {
  export default function consultaPasivos(param: {l: any, c: any}): Promise<any>;
}
declare module "@salesforce/apex/Cotizador_Cotizacion_Controller.Procesa_CapacidadPago_GuardarDatos" {
  export default function Procesa_CapacidadPago_GuardarDatos(param: {l: any, c: any, tipo: any, l_tarjetasDependientes: any}): Promise<any>;
}
declare module "@salesforce/apex/Cotizador_Cotizacion_Controller.Procesa_CapacidadPago_ProcesaMotor" {
  export default function Procesa_CapacidadPago_ProcesaMotor(param: {l: any, c: any, tipo: any}): Promise<any>;
}
declare module "@salesforce/apex/Cotizador_Cotizacion_Controller.actualizarBeneficiarios" {
  export default function actualizarBeneficiarios(param: {d: any}): Promise<any>;
}
