@isTest
private class getContactListOptionsTest {
    
    @testSetup
    static void setupTestData() {
        RecordType rt = [SELECT Id FROM RecordType WHERE DeveloperName = 'CS_Juridico' LIMIT 1];
        EconomicActivity__c actividad = new EconomicActivity__c();
        actividad.Name = '1454201';
        actividad.RiskClass__c = '1';
        actividad.Code768__c = '1454201';
        actividad.Nicho__c = '005';
        actividad.Prevention_Niche__c = 'Comercio';
        insert actividad;
        
        Account acc = new Account();
        acc.Name = 'Account Test';
        acc.Fecha_Ultima_Validacion_Cliente__c = DateTime.now();
        acc.CC_Tipo_de_Cuenta__c = 'Cuenta Prospecto';
        acc.EconomicActivity__c = actividad.id;
        acc.AverageMonthlyDependentContributions__c = 10000;
        acc.AverageIndependentMoContribution__c	 = 10000;
        acc.RecordTypeId = rt.Id;
        insert acc;
        
        // Crear contactos asociados a la cuenta
        Contact contact1 = new Contact(
            FirstName = 'Test',
            LastName = 'Uno',
            Email = 'test1@example.com',
            AccountId = acc.Id
        );
        
        Contact contact2 = new Contact(
            FirstName = 'Test',
            LastName = 'Dos',
            Email = 'test2@example.com',
            AccountId = acc.Id
        );

        insert new List<Contact>{ contact1, contact2 };
    }
    
    @isTest
    static void testSelectOptions() {
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        System.assertNotEquals(null, testAccount, 'No se encontró la cuenta de prueba');

        Map<String, Object> inputMap = new Map<String, Object>();
        inputMap.put('AccountId', testAccount.Id);
        
        Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> args = new Map<String, Object>();
        args.put('input', inputMap);
        args.put('output', outputMap);

        getContactListOptions instance = new getContactListOptions();
        
        Test.startTest();
        Object result = instance.call('SelectOptions', args);
        Test.stopTest();

        System.assertNotEquals(null, result, 'El resultado no debe ser nulo');
        
        List<Map<String, Object>> options = (List<Map<String, Object>>) result;
        System.assertEquals(2, options.size(), 'Debe haber exactamente 2 opciones en la lista');
        List<String> expectedEmails = new List<String>{'test1@example.com', 'test2@example.com'};
        List<String> expectedNames = new List<String>{'Test Uno', 'Test Dos'};
        for (Map<String, Object> option : options) {
            System.assert(expectedEmails.contains((String) option.get('name')), 'El email debe estar en la lista esperada');
            System.assert(expectedNames.contains((String) option.get('value')), 'El nombre debe estar en la lista esperada');
        }
    }
}