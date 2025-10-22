@IsTest
private class getVersionsUploadedTest {
    @testSetup
    static void setup() {
        // Crear una cuenta de prueba
        Account account = new Account(Name = 'Test Account');
        insert account;

        // Crear un ContentVersion (esto también crea un ContentDocument automáticamente)
        ContentVersion testVersion = new ContentVersion(
            Title = 'Test Document',
            PathOnClient = 'TestDocument.pdf',
            VersionData = Blob.valueOf('Test content for the document'),
            DocumentTypeQuoting__c='RUT'
        );
        insert testVersion;

        // Recuperar el ContentDocument creado
        ContentDocument testDocument = [SELECT Id FROM ContentDocument WHERE Id IN (SELECT ContentDocumentId FROM ContentVersion WHERE Id = :testVersion.Id) LIMIT 1];

        // Crear un ContentDocumentLink asociado a la cuenta
        ContentDocumentLink testDocumentLink = new ContentDocumentLink(
            LinkedEntityId = account.Id,
            ContentDocumentId = testDocument.Id,
            ShareType = 'I'
        );
        insert testDocumentLink;
        System.debug('CUENTA UNO: ' + account.id + ' NAME:  '+ account.Name);
    }

    @IsTest
    static void testCallWithValidMethod() {
        // Recuperar la cuenta creada
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
		System.debug('CUENTA UNO: ' + testAccount.id );
        // Preparar argumentos
        Map<String, Object> args = new Map<String, Object>{
            'input' => new Map<String, Object>{ 'arguments' => new List<Object> { testAccount.Id } },
            'output' => new Map<String, Object>(),
            'options' => new Map<String, Object>()
        };
		
        // Probar el método "call" con un método válido
        Test.startTest();
        getVersionsUploaded testClass = new getVersionsUploaded();
        Object result = testClass.call('getVersions', args);
        Test.stopTest();
		
        // Validaciones
        System.assert(result != null, 'El método debe retornar un resultado');
        Map<String, Object> output = (Map<String, Object>)args.get('output');
        System.assert(output.containsKey('result'), 'El output debe contener la clave "result"');
        List<Object> resultList = (List<Object>) output.get('result');
        System.assert(resultList.size() > 0, 'La lista de resultados no debe estar vacía');
    }

    @IsTest
    static void testCallWithInvalidMethod() {
        // Preparar argumentos
        Map<String, Object> args = new Map<String, Object>{
            'input' => new Map<String, Object>{ 'arguments' => new List<Object> { 'InvalidAccountId' } },
            'output' => new Map<String, Object>(),
            'options' => new Map<String, Object>()
        };

        // Probar el método "call" con un método inválido
        Test.startTest();
        getVersionsUploaded testClass = new getVersionsUploaded();
        Object result = testClass.call('invalidMethod', args);
        Test.stopTest();

        // Validaciones
        System.assert(result == null, 'El método debe retornar null para un método inválido');
    }
}