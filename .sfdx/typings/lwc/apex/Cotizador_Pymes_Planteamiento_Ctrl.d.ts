declare module "@salesforce/apex/Cotizador_Pymes_Planteamiento_Ctrl.Inicio" {
  export default function Inicio(param: {lead: any}): Promise<any>;
}
declare module "@salesforce/apex/Cotizador_Pymes_Planteamiento_Ctrl.cargarEstado" {
  export default function cargarEstado(param: {cgId: any, estado: any, justificacion: any, lead: any}): Promise<any>;
}
declare module "@salesforce/apex/Cotizador_Pymes_Planteamiento_Ctrl.cargarComentario" {
  export default function cargarComentario(param: {cgId: any, comentario: any}): Promise<any>;
}
declare module "@salesforce/apex/Cotizador_Pymes_Planteamiento_Ctrl.cargarActividades" {
  export default function cargarActividades(param: {LeadInfo: any}): Promise<any>;
}
declare module "@salesforce/apex/Cotizador_Pymes_Planteamiento_Ctrl.procesarProductos" {
  export default function procesarProductos(param: {categoria: any, tamano: any, financiamiento: any, moneda: any}): Promise<any>;
}
declare module "@salesforce/apex/Cotizador_Pymes_Planteamiento_Ctrl.procesarProductosUnicos" {
  export default function procesarProductosUnicos(param: {categoria: any}): Promise<any>;
}
declare module "@salesforce/apex/Cotizador_Pymes_Planteamiento_Ctrl.procesarProductoFondeo" {
  export default function procesarProductoFondeo(param: {categoria: any, tamano: any, financiamiento: any, moneda: any, fondeo: any}): Promise<any>;
}
declare module "@salesforce/apex/Cotizador_Pymes_Planteamiento_Ctrl.procesarTasas" {
  export default function procesarTasas(param: {producto: any, moneda: any}): Promise<any>;
}
declare module "@salesforce/apex/Cotizador_Pymes_Planteamiento_Ctrl.procesarComisionFormalizacion" {
  export default function procesarComisionFormalizacion(param: {monto: any, porcentaje: any}): Promise<any>;
}
declare module "@salesforce/apex/Cotizador_Pymes_Planteamiento_Ctrl.enviarInformeCredito" {
  export default function enviarInformeCredito(param: {destinatarios: any, conCopia: any, LeadInfo: any, cuotas: any}): Promise<any>;
}
declare module "@salesforce/apex/Cotizador_Pymes_Planteamiento_Ctrl.nuevaCotizacion" {
  export default function nuevaCotizacion(param: {index: any, leadId: any}): Promise<any>;
}
declare module "@salesforce/apex/Cotizador_Pymes_Planteamiento_Ctrl.guardarCotizacion" {
  export default function guardarCotizacion(param: {cotizacion: any}): Promise<any>;
}
declare module "@salesforce/apex/Cotizador_Pymes_Planteamiento_Ctrl.eliminarCotizacion" {
  export default function eliminarCotizacion(param: {cotizacion: any}): Promise<any>;
}
declare module "@salesforce/apex/Cotizador_Pymes_Planteamiento_Ctrl.calculoDeCuota" {
  export default function calculoDeCuota(param: {monto: any, tasa: any, plazo: any, moneda: any, frecuencia: any}): Promise<any>;
}
declare module "@salesforce/apex/Cotizador_Pymes_Planteamiento_Ctrl.calcularHonorariosRango" {
  export default function calcularHonorariosRango(param: {monto: any, acto_notarial: any, matrizHonorarios: any, matrizTimbres: any, matrizTimbreAbogados: any}): Promise<any>;
}
