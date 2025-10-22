declare module "@salesforce/apex/MiniQuoteController.Inicio" {
  export default function Inicio(param: {pId: any, recordTypeid: any}): Promise<any>;
}
declare module "@salesforce/apex/MiniQuoteController.procesarMonedaCambio" {
  export default function procesarMonedaCambio(param: {cotizacion: any, moneda: any}): Promise<any>;
}
declare module "@salesforce/apex/MiniQuoteController.procesarProductoCambio" {
  export default function procesarProductoCambio(param: {cotizacion: any}): Promise<any>;
}
declare module "@salesforce/apex/MiniQuoteController.procesarPorcentajePrima" {
  export default function procesarPorcentajePrima(param: {cotizacion: any}): Promise<any>;
}
declare module "@salesforce/apex/MiniQuoteController.procesarComisionForma" {
  export default function procesarComisionForma(param: {cotizacion: any}): Promise<any>;
}
declare module "@salesforce/apex/MiniQuoteController.procesarCambioTasa" {
  export default function procesarCambioTasa(param: {cotizacion: any}): Promise<any>;
}
declare module "@salesforce/apex/MiniQuoteController.procesarCambioPoliza" {
  export default function procesarCambioPoliza(param: {cotizacion: any}): Promise<any>;
}
declare module "@salesforce/apex/MiniQuoteController.guardarCotizacion" {
  export default function guardarCotizacion(param: {cotizacion: any}): Promise<any>;
}
declare module "@salesforce/apex/MiniQuoteController.enviarACotizador" {
  export default function enviarACotizador(param: {cotizacion: any}): Promise<any>;
}
declare module "@salesforce/apex/MiniQuoteController.sendPDFEmail" {
  export default function sendPDFEmail(param: {correo: any, cotizacionId: any}): Promise<any>;
}
