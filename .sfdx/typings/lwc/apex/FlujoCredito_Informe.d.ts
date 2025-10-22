declare module "@salesforce/apex/FlujoCredito_Informe.ConsultaDatos" {
  export default function ConsultaDatos(): Promise<any>;
}
declare module "@salesforce/apex/FlujoCredito_Informe.GenerarProceso" {
  export default function GenerarProceso(param: {fechaInicio: any, fechaFin: any}): Promise<any>;
}
declare module "@salesforce/apex/FlujoCredito_Informe.VerificaBatch" {
  export default function VerificaBatch(param: {batchName: any}): Promise<any>;
}
