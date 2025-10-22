declare module "@salesforce/apex/RelatedListCarpetasController.getCarpetas" {
  export default function getCarpetas(param: {IdCaso: any}): Promise<any>;
}
declare module "@salesforce/apex/RelatedListCarpetasController.getSubCarpetas" {
  export default function getSubCarpetas(param: {IdCarpeta: any}): Promise<any>;
}
declare module "@salesforce/apex/RelatedListCarpetasController.getCarpSeguros" {
  export default function getCarpSeguros(param: {IdCaso: any}): Promise<any>;
}
declare module "@salesforce/apex/RelatedListCarpetasController.getRecordNotification" {
  export default function getRecordNotification(param: {idOrdenServicio: any}): Promise<any>;
}
