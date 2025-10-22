declare module "@salesforce/apex/VS_FinancialDataController.getAccountId" {
  export default function getAccountId(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/VS_FinancialDataController.getInfo" {
  export default function getInfo(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/VS_FinancialDataController.getInfoFromCase" {
  export default function getInfoFromCase(param: {caseId: any}): Promise<any>;
}
declare module "@salesforce/apex/VS_FinancialDataController.getInfoFromTask" {
  export default function getInfoFromTask(param: {taskId: any}): Promise<any>;
}
declare module "@salesforce/apex/VS_FinancialDataController.getInfoFromAccount" {
  export default function getInfoFromAccount(param: {accountId: any}): Promise<any>;
}
declare module "@salesforce/apex/VS_FinancialDataController.saveFinancialAccount" {
  export default function saveFinancialAccount(param: {accountNumber: any, bank: any, accountType: any, accountId: any, isNewAccount: any, userId: any}): Promise<any>;
}
