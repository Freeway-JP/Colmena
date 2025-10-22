declare module "@salesforce/apex/Cotizador_Corp_Pre_Analisis_Controller.Inicio" {
  export default function Inicio(param: {lead: any}): Promise<any>;
}
declare module "@salesforce/apex/Cotizador_Corp_Pre_Analisis_Controller.nuevaCotizacion" {
  export default function nuevaCotizacion(param: {index: any, leadId: any}): Promise<any>;
}
declare module "@salesforce/apex/Cotizador_Corp_Pre_Analisis_Controller.eliminarCotizacion" {
  export default function eliminarCotizacion(param: {cotizacion: any}): Promise<any>;
}
declare module "@salesforce/apex/Cotizador_Corp_Pre_Analisis_Controller.guardarCotizacion" {
  export default function guardarCotizacion(param: {cotizacion: any}): Promise<any>;
}
declare module "@salesforce/apex/Cotizador_Corp_Pre_Analisis_Controller.getNivelComplejidadOptions" {
  export default function getNivelComplejidadOptions(): Promise<any>;
}
declare module "@salesforce/apex/Cotizador_Corp_Pre_Analisis_Controller.getLeadFiles" {
  export default function getLeadFiles(param: {leadId: any, descriptionFilter: any}): Promise<any>;
}
declare module "@salesforce/apex/Cotizador_Corp_Pre_Analisis_Controller.updateFileDescription" {
  export default function updateFileDescription(param: {contentDocumentId: any, description: any}): Promise<any>;
}
declare module "@salesforce/apex/Cotizador_Corp_Pre_Analisis_Controller.deleteContentDocument" {
  export default function deleteContentDocument(param: {currentLeadId: any, description: any}): Promise<any>;
}
declare module "@salesforce/apex/Cotizador_Corp_Pre_Analisis_Controller.saveLead" {
  export default function saveLead(param: {lead: any}): Promise<any>;
}
declare module "@salesforce/apex/Cotizador_Corp_Pre_Analisis_Controller.getGerentesDisponibles" {
  export default function getGerentesDisponibles(): Promise<any>;
}
declare module "@salesforce/apex/Cotizador_Corp_Pre_Analisis_Controller.reasignarLead" {
  export default function reasignarLead(param: {leadId: any, newOwnerId: any, justificacion: any}): Promise<any>;
}
