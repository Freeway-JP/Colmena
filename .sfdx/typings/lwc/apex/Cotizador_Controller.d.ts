declare module "@salesforce/apex/Cotizador_Controller.Inicio" {
  export default function Inicio(param: {pId: any, recordTypeid: any, miniCotizadorId: any}): Promise<any>;
}
declare module "@salesforce/apex/Cotizador_Controller.ConsultaLead" {
  export default function ConsultaLead(param: {vid: any}): Promise<any>;
}
declare module "@salesforce/apex/Cotizador_Controller.Guardar" {
  export default function Guardar(param: {lead: any, c: any, tipo: any, miniCotizadorId: any, representantesLegales: any, codeudores: any, contactosEmpresa: any}): Promise<any>;
}
declare module "@salesforce/apex/Cotizador_Controller.GuardarComentario" {
  export default function GuardarComentario(param: {lead_id: any, comentario: any}): Promise<any>;
}
declare module "@salesforce/apex/Cotizador_Controller.volverIntentar" {
  export default function volverIntentar(param: {lead_id: any}): Promise<any>;
}
declare module "@salesforce/apex/Cotizador_Controller.casosRelacionados" {
  export default function casosRelacionados(param: {identificacion: any}): Promise<any>;
}
declare module "@salesforce/apex/Cotizador_Controller.VerificarMotorResultados" {
  export default function VerificarMotorResultados(param: {isRefresh: any, lead_id: any}): Promise<any>;
}
declare module "@salesforce/apex/Cotizador_Controller.getDependentMap" {
  export default function getDependentMap(param: {ObjectName: any, contrfieldApiName: any, depfieldApiName: any}): Promise<any>;
}
declare module "@salesforce/apex/Cotizador_Controller.LoadOptionsCorporativo" {
  export default function LoadOptionsCorporativo(param: {d: any}): Promise<any>;
}
declare module "@salesforce/apex/Cotizador_Controller.LoadOptionsPyme" {
  export default function LoadOptionsPyme(param: {d: any}): Promise<any>;
}
declare module "@salesforce/apex/Cotizador_Controller.actualizarRepresentantes" {
  export default function actualizarRepresentantes(param: {representantes: any, tipoRepresentante: any}): Promise<any>;
}
declare module "@salesforce/apex/Cotizador_Controller.actualizarCodeudores" {
  export default function actualizarCodeudores(param: {codeudores: any, cantidadCodeudores: any}): Promise<any>;
}
declare module "@salesforce/apex/Cotizador_Controller.LoadOptionsBonoVivienda" {
  export default function LoadOptionsBonoVivienda(param: {d: any}): Promise<any>;
}
declare module "@salesforce/apex/Cotizador_Controller.LoadOptionsCasosParticulares" {
  export default function LoadOptionsCasosParticulares(param: {d: any}): Promise<any>;
}
declare module "@salesforce/apex/Cotizador_Controller.ActualizarDatosProducto" {
  export default function ActualizarDatosProducto(param: {nombreproducto: any}): Promise<any>;
}
declare module "@salesforce/apex/Cotizador_Controller.reprocesarValidaciones" {
  export default function reprocesarValidaciones(param: {leadId: any}): Promise<any>;
}
declare module "@salesforce/apex/Cotizador_Controller.manageEnviarEscritorio" {
  export default function manageEnviarEscritorio(param: {leadId: any, momento: any}): Promise<any>;
}
