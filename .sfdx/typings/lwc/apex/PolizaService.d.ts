declare module "@salesforce/apex/PolizaService.getPolizasLwc" {
  export default function getPolizasLwc(param: {identificacion: any}): Promise<any>;
}
declare module "@salesforce/apex/PolizaService.getPolicyNumbers" {
  export default function getPolicyNumbers(param: {identificacion: any}): Promise<any>;
}
declare module "@salesforce/apex/PolizaService.getPolizaDetalle" {
  export default function getPolizaDetalle(param: {policyNumber: any, identificacion: any}): Promise<any>;
}
