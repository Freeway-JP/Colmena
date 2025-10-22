declare module "@salesforce/apex/VS_ValidacionOTPController.getAccountInfoWithAccountId" {
  export default function getAccountInfoWithAccountId(param: {accountId: any}): Promise<any>;
}
declare module "@salesforce/apex/VS_ValidacionOTPController.getAccountInfo" {
  export default function getAccountInfo(param: {taskId: any}): Promise<any>;
}
declare module "@salesforce/apex/VS_ValidacionOTPController.getAccountInfoFromContact" {
  export default function getAccountInfoFromContact(param: {taskId: any}): Promise<any>;
}
declare module "@salesforce/apex/VS_ValidacionOTPController.callRegistraduriaAndUpdateAccount" {
  export default function callRegistraduriaAndUpdateAccount(param: {taskId: any, acc: any, isContactToValidate: any}): Promise<any>;
}
declare module "@salesforce/apex/VS_ValidacionOTPController.sendOPTCode" {
  export default function sendOPTCode(param: {taskId: any, acc: any}): Promise<any>;
}
declare module "@salesforce/apex/VS_ValidacionOTPController.validateSendedOPTCode" {
  export default function validateSendedOPTCode(param: {taskId: any, acc: any, otpCode: any, vRegistry: any, tranId: any}): Promise<any>;
}
declare module "@salesforce/apex/VS_ValidacionOTPController.saveValidatedDateInAccount" {
  export default function saveValidatedDateInAccount(param: {acc: any}): Promise<any>;
}
declare module "@salesforce/apex/VS_ValidacionOTPController.getAccountInfoBeneficiario" {
  export default function getAccountInfoBeneficiario(param: {taskId: any}): Promise<any>;
}
declare module "@salesforce/apex/VS_ValidacionOTPController.savePolicy" {
  export default function savePolicy(param: {taskId: any, policyId: any}): Promise<any>;
}
declare module "@salesforce/apex/VS_ValidacionOTPController.saveLogValidation" {
  export default function saveLogValidation(param: {taskId: any, response: any, type: any, idenType: any, idenNum: any}): Promise<any>;
}
declare module "@salesforce/apex/VS_ValidacionOTPController.insertLogValidation" {
  export default function insertLogValidation(param: {taskId: any, status: any, messagge: any, type: any, idenType: any, idenNum: any}): Promise<any>;
}
