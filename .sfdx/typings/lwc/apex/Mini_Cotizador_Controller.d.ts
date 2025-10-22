declare module "@salesforce/apex/Mini_Cotizador_Controller.Inicio" {
  export default function Inicio(param: {pId: any, recordTypeid: any}): Promise<any>;
}
declare module "@salesforce/apex/Mini_Cotizador_Controller.procesarMonedaCambio" {
  export default function procesarMonedaCambio(param: {cotizacion: any, moneda: any}): Promise<any>;
}
declare module "@salesforce/apex/Mini_Cotizador_Controller.procesarProductoCambio" {
  export default function procesarProductoCambio(param: {cotizacion: any}): Promise<any>;
}
declare module "@salesforce/apex/Mini_Cotizador_Controller.procesarPorcentajePrima" {
  export default function procesarPorcentajePrima(param: {cotizacion: any}): Promise<any>;
}
declare module "@salesforce/apex/Mini_Cotizador_Controller.procesarComisionForma" {
  export default function procesarComisionForma(param: {cotizacion: any}): Promise<any>;
}
declare module "@salesforce/apex/Mini_Cotizador_Controller.procesarCambioTasa" {
  export default function procesarCambioTasa(param: {cotizacion: any}): Promise<any>;
}
declare module "@salesforce/apex/Mini_Cotizador_Controller.procesarCambioPoliza" {
  export default function procesarCambioPoliza(param: {cotizacion: any}): Promise<any>;
}
declare module "@salesforce/apex/Mini_Cotizador_Controller.guardarCotizacion" {
  export default function guardarCotizacion(param: {cotizacion: any}): Promise<any>;
}
declare module "@salesforce/apex/Mini_Cotizador_Controller.enviarACotizador" {
  export default function enviarACotizador(param: {cotizacion: any}): Promise<any>;
}
declare module "@salesforce/apex/Mini_Cotizador_Controller.sendPDFEmail" {
  export default function sendPDFEmail(param: {correo: any, cotizacionId: any}): Promise<any>;
}
declare module "@salesforce/apex/Mini_Cotizador_Controller.procesarMontoFinanciamientoFinal" {
  export default function procesarMontoFinanciamientoFinal(param: {cotizacion: any}): Promise<any>;
}
