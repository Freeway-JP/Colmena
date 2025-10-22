declare module "@salesforce/apex/Cotizador_Pymes_Prefactibilidad_Ctrl.getProductosPyme" {
  export default function getProductosPyme(): Promise<any>;
}
declare module "@salesforce/apex/Cotizador_Pymes_Prefactibilidad_Ctrl.descartarLead" {
  export default function descartarLead(param: {leadId: any, motivo: any}): Promise<any>;
}
declare module "@salesforce/apex/Cotizador_Pymes_Prefactibilidad_Ctrl.getProductosGuardados" {
  export default function getProductosGuardados(param: {leadId: any}): Promise<any>;
}
declare module "@salesforce/apex/Cotizador_Pymes_Prefactibilidad_Ctrl.guardarPrefactibilidad" {
  export default function guardarPrefactibilidad(param: {datos_lead: any, productosJSON: any}): Promise<any>;
}
