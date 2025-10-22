declare module "@salesforce/apex/FileUploadImprovedHelper.getKey" {
  export default function getKey(): Promise<any>;
}
declare module "@salesforce/apex/FileUploadImprovedHelper.encrypt" {
  export default function encrypt(param: {recordId: any, encodedKey: any}): Promise<any>;
}
declare module "@salesforce/apex/FileUploadImprovedHelper.createContentVers" {
  export default function createContentVers(param: {fileNames: any, encodedRecordId: any}): Promise<any>;
}
declare module "@salesforce/apex/FileUploadImprovedHelper.appendDataToContentVersion" {
  export default function appendDataToContentVersion(param: {versionId: any, base64Data: any}): Promise<any>;
}
declare module "@salesforce/apex/FileUploadImprovedHelper.createContentDocLink" {
  export default function createContentDocLink(param: {versIds: any, encodedKey: any, visibleToAllUsers: any}): Promise<any>;
}
declare module "@salesforce/apex/FileUploadImprovedHelper.updateFileName" {
  export default function updateFileName(param: {versIds: any, fileName: any}): Promise<any>;
}
declare module "@salesforce/apex/FileUploadImprovedHelper.deleteContentDoc" {
  export default function deleteContentDoc(param: {versId: any}): Promise<any>;
}
declare module "@salesforce/apex/FileUploadImprovedHelper.getExistingFiles" {
  export default function getExistingFiles(param: {recordId: any}): Promise<any>;
}
