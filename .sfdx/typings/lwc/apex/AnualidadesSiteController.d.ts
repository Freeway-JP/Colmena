declare module "@salesforce/apex/AnualidadesSiteController.getTiposIdentificacion" {
  export default function getTiposIdentificacion(): Promise<any>;
}
declare module "@salesforce/apex/AnualidadesSiteController.getTiposTarjeta" {
  export default function getTiposTarjeta(): Promise<any>;
}
declare module "@salesforce/apex/AnualidadesSiteController.getAcountByTipoeIdentificacion" {
  export default function getAcountByTipoeIdentificacion(param: {tipo: any, identificacion: any}): Promise<any>;
}
declare module "@salesforce/apex/AnualidadesSiteController.validaIban" {
  export default function validaIban(param: {iban: any}): Promise<any>;
}
declare module "@salesforce/apex/AnualidadesSiteController.SaveRecord" {
  export default function SaveRecord(param: {casoData: any, DatosColaborador: any}): Promise<any>;
}
