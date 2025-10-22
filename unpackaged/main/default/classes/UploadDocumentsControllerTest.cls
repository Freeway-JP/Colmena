@isTest
private class UploadDocumentsControllerTest {
    
    @isTest
    static void testCreateDocumentLink() {
        // Crear datos de prueba
        ContentVersion ver = new ContentVersion();
        ver.PathOnClient = 'Test Document.txt';
        ver.VersionData = Blob.valueOf('Test Content');
        insert ver;

        // Obtener ContentDocumentId
        ContentVersion cVer = [SELECT ContentDocumentId, Id FROM ContentVersion WHERE Id = :ver.Id LIMIT 1];
        String doc = cVer.ContentDocumentId;

        // Crear un objeto de prueba (puedes reemplazarlo con un objeto real que uses en tu sistema)
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        // Ejecutar el método
        Test.startTest();
        UploadDocumentsController.createDocumentLink(doc, acc.Id);
        Test.stopTest();

        // Verificar que el ContentDocumentLink se haya creado
        ContentDocumentLink link = [SELECT Id, ContentDocumentId, LinkedEntityId, ShareType, Visibility 
                                    FROM ContentDocumentLink 
                                    WHERE ContentDocumentId = :doc AND LinkedEntityId = :acc.Id LIMIT 1];

        System.assertNotEquals(null, link, 'ContentDocumentLink no se creó');
        System.assertEquals('I', link.ShareType, 'ShareType no es correcto');
        System.assertEquals('AllUsers', link.Visibility, 'Visibility no es correcta');
    }
}