declare module "@salesforce/apex/VS_ValidateAccountController.getQuestions" {
  export default function getQuestions(param: {taskId: any, recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/VS_ValidateAccountController.validateQuestions" {
  export default function validateQuestions(param: {taskId: any, bearerToken: any, recordId: any, registry: any, IdSurvey: any, answersString: any}): Promise<any>;
}
declare module "@salesforce/apex/VS_ValidateAccountController.saveValidatedDateTime" {
  export default function saveValidatedDateTime(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/VS_ValidateAccountController.isCuentaProspecto" {
  export default function isCuentaProspecto(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/VS_ValidateAccountController.getAccountId" {
  export default function getAccountId(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/VS_ValidateAccountController.insertLogValidation" {
  export default function insertLogValidation(param: {taskId: any, status: any, messagge: any, type: any, idenType: any, idenNum: any}): Promise<any>;
}
