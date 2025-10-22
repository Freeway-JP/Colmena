declare module "@salesforce/apex/GetDataReport.getData" {
  export default function getData(param: {objectAPIName: any, customLimit: any, filtro: any, fechaIni: any, fechaFin: any}): Promise<any>;
}
declare module "@salesforce/apex/GetDataReport.getProductos" {
  export default function getProductos(): Promise<any>;
}
declare module "@salesforce/apex/GetDataReport.CrearReporteEnviar" {
  export default function CrearReporteEnviar(param: {objectAPIName: any, customLimit: any, filtro: any, fechaIni: any, fechaFin: any}): Promise<any>;
}
