declare module "@salesforce/apex/ABCAnalysisAndCollectionModules.userAuthorization" {
  export default function userAuthorization(): Promise<any>;
}
declare module "@salesforce/apex/ABCAnalysisAndCollectionModules.getCasesRelatedToCustomer" {
  export default function getCasesRelatedToCustomer(param: {analysisId: any, dateFlag: any}): Promise<any>;
}
declare module "@salesforce/apex/ABCAnalysisAndCollectionModules.getCasesRelatedToABCAnalysis" {
  export default function getCasesRelatedToABCAnalysis(param: {analysisId: any}): Promise<any>;
}
declare module "@salesforce/apex/ABCAnalysisAndCollectionModules.getNewCasesRelatedToABCAnalysis" {
  export default function getNewCasesRelatedToABCAnalysis(param: {analysisId: any}): Promise<any>;
}
declare module "@salesforce/apex/ABCAnalysisAndCollectionModules.updateRelatedCases" {
  export default function updateRelatedCases(param: {registers: any, action: any, analysisId: any, isNew: any}): Promise<any>;
}
