public with sharing class UploadDocumentsController {
    @AuraEnabled
    public static void createDocumentLink(String contentDocumentId, String linkedEntityId) {
        try {
            ContentDocumentLink link = new ContentDocumentLink();
            link.ContentDocumentId = contentDocumentId;
            link.LinkedEntityId = linkedEntityId;
            link.ShareType = 'I'; // 'I' para Internal Users
            link.Visibility = 'AllUsers'; // Cambia esto si necesitas otro nivel de visibilidad
            insert link;
        } catch (Exception e) {
            throw new AuraHandledException('Error al asociar el archivo: ' + e.getMessage());
        }
    }
}