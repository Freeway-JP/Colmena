declare module "@salesforce/apex/ControlContable_Controller.Data_General" {
  export default function Data_General(param: {vid_CasoFC: any, vorigen: any, vtab_option: any}): Promise<any>;
}
declare module "@salesforce/apex/ControlContable_Controller.Guardar_Datos" {
  export default function Guardar_Datos(param: {v_cf_Id: any, v_c_Id: any, v_dat_c_cf: any, v_origen: any}): Promise<any>;
}
declare module "@salesforce/apex/ControlContable_Controller.Actualizar_HojaLiquidacionOp" {
  export default function Actualizar_HojaLiquidacionOp(param: {vid_CasoFC: any}): Promise<any>;
}
declare module "@salesforce/apex/ControlContable_Controller.attachPDF" {
  export default function attachPDF(param: {vid_CasoFC: any, vorigen: any, nombre_subcarpeta: any}): Promise<any>;
}
declare module "@salesforce/apex/ControlContable_Controller.GetCedula" {
  export default function GetCedula(param: {Label: any}): Promise<any>;
}
declare module "@salesforce/apex/ControlContable_Controller.GetUsuarioAprob" {
  export default function GetUsuarioAprob(param: {Label: any}): Promise<any>;
}
