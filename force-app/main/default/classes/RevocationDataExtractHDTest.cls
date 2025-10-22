@IsTest
private class RevocationDataExtractHDTest {

    @TestSetup
    static void setup() {
        // Create test Individual
        Individual testIndividual = new Individual(
            FirstName = 'Juan',
            MiddleName = 'Carlos',
            LastName = 'Perez',
            Suffix = 'Jr.',
            CS_TipoIdentificacion__c = '1',
            CS_NumeroIdentificacion__c = '123456789'
        );
        insert testIndividual;

        // Create test BusinessBrands
        List<BusinessBrand> brands = new List<BusinessBrand>{
            new BusinessBrand(Name = 'Vida'),
            new BusinessBrand(Name = 'ARL')
        };
        insert brands;

        // Create test DataUsePurposes
        List<DataUsePurpose> purposes = new List<DataUsePurpose>{
            new DataUsePurpose(Name = 'Cliente'),
            new DataUsePurpose(Name = 'Prospecto'),
            new DataUsePurpose(Name = 'Cliente Representante Legal'),
            new DataUsePurpose(Name = 'Gestión Cartera-2300'),
            new DataUsePurpose(Name = 'Ofrecimiento Comercial-2300')
        };
        insert purposes;

        // Create test Account
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        // Create test ContactPoints
        List<ContactPointPhone> contactPoints = new List<ContactPointPhone>{
            new ContactPointPhone(ParentId = testIndividual.Id, TelephoneNumber = '3001234567'),
            new ContactPointPhone(ParentId = testIndividual.Id, TelephoneNumber = '3001234568'),
            new ContactPointPhone(ParentId = testIndividual.Id, TelephoneNumber = '3001234569'),
            new ContactPointPhone(ParentId = testIndividual.Id, TelephoneNumber = '3001234570')
        };
        insert contactPoints;

        // Create test EngagementChannelTypes
        List<EngagementChannelType> channels = new List<EngagementChannelType>{
            new EngagementChannelType(Name = 'celular'),
            new EngagementChannelType(Name = 'correo electrónico'),
            new EngagementChannelType(Name = 'mensaje de texto'),
            new EngagementChannelType(Name = 'WhatsApp')
        };
        insert channels;

        // Create test PartyConsents
        List<PartyConsent> partyConsents = new List<PartyConsent>{
            new PartyConsent(
                Name = 'PC - 001 - Vida - Cliente',
                PartyId = testIndividual.Id,
                CaptureDate = DateTime.now(),
                Process__c = 'Venta',
                Origin__c = 'No aplica',
                ChannelType__c = 'Telefónico',
                BusinessCoverage__c = 'Transversal',
                CollectionMethodType__c = 'Salesforce',
                IdentityValidationNoData__c = false,
                CS_IdentificationType__c = '1',
                CS_IdentificationNumber__c = '123456789',
                BusinessBrandId = brands[0].Id,
                DataUsePurposeId = purposes[0].Id,
                AccountId__c = testAccount.Id,
                AuthorizationChannel__c = 'Linea Efectiva outbound (Telemercadeo)',
                MedicalHistory__c = true,
                DataMarketing__c = true,
                GeneralDataMarketing__c = true,
                GeneralProcessingData__c = true,
                Email__c = 'test@example.com',
                Phone__c = '3001234567',
                PrivacyConsentStatus = 'OptIn'
            ),
            new PartyConsent(
                Name = 'PC - 002 - ARL - Cliente',
                PartyId = testIndividual.Id,
                CaptureDate = DateTime.now(),
                BusinessBrandId = brands[1].Id,
                DataUsePurposeId = purposes[0].Id,
                AccountId__c = testAccount.Id,
                GeneralProcessingData__c = true,
                PrivacyConsentStatus = 'OptIn'
            )
        };
        insert partyConsents;

        // Create test ContactPointConsents
        List<ContactPointConsent> contactConsents = new List<ContactPointConsent>{
            new ContactPointConsent(
                Name = 'CPC - 001 - Vida - Cliente',
                ContactPointId = contactPoints[0].Id,
                CaptureDate = DateTime.now(),
                BusinessBrandId = brands[0].Id,
                DataUsePurpose__c = 'Cliente',
                EngagementChannelTypeId = channels[0].Id,
                Approved__c = true,
                DataUsePurposeId = purposes[3].Id,
                AccountId__c = testAccount.Id,
                PrivacyConsentStatus = 'OptIn'
            ),
            new ContactPointConsent(
                Name = 'CPC - 002 - Vida - Cliente',
                ContactPointId = contactPoints[1].Id,
                CaptureDate = DateTime.now(),
                BusinessBrandId = brands[0].Id,
                DataUsePurpose__c = 'Cliente',
                EngagementChannelTypeId = channels[1].Id,
                Approved__c = true,
                DataUsePurposeId = purposes[4].Id,
                AccountId__c = testAccount.Id,
                PrivacyConsentStatus = 'OptIn'
            ),
            new ContactPointConsent(
                Name = 'CPC - 003 - Vida - Cliente',
                ContactPointId = contactPoints[2].Id,
                BusinessBrandId = brands[0].Id,
                DataUsePurpose__c = 'Cliente',
                EngagementChannelTypeId = channels[2].Id,
                Approved__c = false,
                DataUsePurposeId = purposes[3].Id,
                AccountId__c = testAccount.Id,
                PrivacyConsentStatus = 'OptIn'
            ),
            new ContactPointConsent(
                Name = 'CPC - 004 - Vida - Cliente',
                ContactPointId = contactPoints[3].Id,
                BusinessBrandId = brands[0].Id,
                DataUsePurpose__c = 'Cliente',
                EngagementChannelTypeId = channels[3].Id,
                Approved__c = true,
                DataUsePurposeId = purposes[4].Id,
                AccountId__c = testAccount.Id,
                PrivacyConsentStatus = 'OptIn'
            )
        };
        insert contactConsents;
    }

    @IsTest
    static void testCall_GetActiveConsents_Success() {
        Individual testIndividual = [SELECT Id FROM Individual LIMIT 1];
        Map<String, Object> args = new Map<String, Object>{
            'input' => new Map<String, Object>{'partyId' => testIndividual.Id},
            'output' => new Map<String, Object>(),
            'options' => new Map<String, Object>()
        };

        Test.startTest();
        RevocationDataExtractHD extractor = new RevocationDataExtractHD();
        Object result = extractor.call('getActiveConsents', args);
        Test.stopTest();

        Map<String, Object> output = (Map<String, Object>) args.get('output');
        System.assertEquals(true, result);
        System.assert(output.containsKey('groupedConsents'));
        System.assertEquals(false, output.containsKey('error'));
    }

    @IsTest
    static void testCall_InvalidAction() {
        Individual testIndividual = [SELECT Id FROM Individual LIMIT 1];
        Map<String, Object> args = new Map<String, Object>{
            'input' => new Map<String, Object>{'partyId' => testIndividual.Id},
            'output' => new Map<String, Object>(),
            'options' => new Map<String, Object>()
        };

        Test.startTest();
        RevocationDataExtractHD extractor = new RevocationDataExtractHD();
        Object result = extractor.call('invalidAction', args);
        Test.stopTest();

        System.assertEquals(false, result);
    }

    @IsTest
    static void testInvokeMethod_GetActiveConsents() {
        Individual testIndividual = [SELECT Id FROM Individual LIMIT 1];
        Map<String, Object> inputMap = new Map<String, Object>{'partyId' => testIndividual.Id};
        Map<String, Object> outMap = new Map<String, Object>();

        Test.startTest();
        RevocationDataExtractHD extractor = new RevocationDataExtractHD();
        Boolean result = extractor.invokeMethod('getActiveConsents', inputMap, outMap, new Map<String, Object>());
        Test.stopTest();

        System.assertEquals(true, result);
        System.assert(outMap.containsKey('groupedConsents'));
    }

    @IsTest
    static void testInvokeMethod_WithNullPartyId() {
        Map<String, Object> inputMap = new Map<String, Object>{'partyId' => null};
        Map<String, Object> outMap = new Map<String, Object>();

        Test.startTest();
        RevocationDataExtractHD extractor = new RevocationDataExtractHD();
        Boolean result = extractor.invokeMethod('getActiveConsents', inputMap, outMap, new Map<String, Object>());
        Test.stopTest();

        // With null partyId, queries return empty lists, so method succeeds with empty results
        System.assertEquals(true, result);
        System.assert(outMap.containsKey('groupedConsents'));
        List<Object> groupedConsents = (List<Object>) outMap.get('groupedConsents');
        System.assertEquals(0, groupedConsents.size());
    }

    @IsTest
    static void testInvokeMethod_WithInvalidMethodName() {
        Individual testIndividual = [SELECT Id FROM Individual LIMIT 1];
        Map<String, Object> inputMap = new Map<String, Object>{'partyId' => testIndividual.Id};
        Map<String, Object> outMap = new Map<String, Object>();

        Test.startTest();
        RevocationDataExtractHD extractor = new RevocationDataExtractHD();
        Boolean result = extractor.invokeMethod('invalidMethod', inputMap, outMap, new Map<String, Object>());
        Test.stopTest();

        // Invalid method name should return false
        System.assertEquals(false, result);
    }

    @IsTest
    static void testGetData_Success() {
        Individual testIndividual = [SELECT Id FROM Individual LIMIT 1];
        Map<String, Object> outMap = new Map<String, Object>();

        Test.startTest();
        RevocationDataExtractHD extractor = new RevocationDataExtractHD();
        extractor.getData(testIndividual.Id, outMap);
        Test.stopTest();

        System.assert(outMap.containsKey('groupedConsents'));
        List<Object> groupedConsents = (List<Object>) outMap.get('groupedConsents');
        System.assertNotEquals(0, groupedConsents.size());
    }

    @IsTest
    static void testGetData_NoConsents() {
        Individual newIndividual = new Individual(
            FirstName = 'Test',
            LastName = 'NoConsents',
            CS_TipoIdentificacion__c = '1',
            CS_NumeroIdentificacion__c = '999999999'
        );
        insert newIndividual;

        Map<String, Object> outMap = new Map<String, Object>();

        Test.startTest();
        RevocationDataExtractHD extractor = new RevocationDataExtractHD();
        extractor.getData(newIndividual.Id, outMap);
        Test.stopTest();

        System.assert(outMap.containsKey('groupedConsents'));
        List<Object> groupedConsents = (List<Object>) outMap.get('groupedConsents');
        System.assertEquals(0, groupedConsents.size());
    }

    @IsTest
    static void testGroupConsentsByEntity_ProspectoPurpose() {
        Individual testIndividual = [SELECT Id FROM Individual LIMIT 1];
        DataUsePurpose prospectoPurpose = [SELECT Id FROM DataUsePurpose WHERE Name = 'Prospecto' LIMIT 1];
        BusinessBrand vidaBrand = [SELECT Id FROM BusinessBrand WHERE Name = 'Vida' LIMIT 1];
        Account testAccount = [SELECT Id FROM Account LIMIT 1];

        PartyConsent pc = new PartyConsent(
            Name = 'PC - 003 - Vida - Prospecto',
            PartyId = testIndividual.Id,
            CaptureDate = DateTime.now(),
            CS_IdentificationType__c = '1',
            CS_IdentificationNumber__c = '111111111',
            BusinessBrandId = vidaBrand.Id,
            DataUsePurposeId = prospectoPurpose.Id,
            AccountId__c = testAccount.Id,
            PrivacyConsentStatus = 'OptIn'
        );
        insert pc;

        Map<String, Object> outMap = new Map<String, Object>();

        Test.startTest();
        RevocationDataExtractHD extractor = new RevocationDataExtractHD();
        extractor.getData(testIndividual.Id, outMap);
        Test.stopTest();

        System.assert(outMap.containsKey('groupedConsents'));
    }

    @IsTest
    static void testGroupConsentsByEntity_RepresentanteLegalPurpose() {
        Individual testIndividual = [SELECT Id FROM Individual LIMIT 1];
        DataUsePurpose repLegalPurpose = [SELECT Id FROM DataUsePurpose WHERE Name = 'Cliente Representante Legal' LIMIT 1];
        BusinessBrand vidaBrand = [SELECT Id FROM BusinessBrand WHERE Name = 'Vida' LIMIT 1];
        Account testAccount = [SELECT Id FROM Account LIMIT 1];

        PartyConsent pc = new PartyConsent(
            Name = 'PC - 004 - Vida - RepLegal',
            PartyId = testIndividual.Id,
            CaptureDate = DateTime.now(),
            CS_IdentificationType_Emp__c = '3',
            CS_IdentificationNumber_Emp__c = '900123456',
            BusinessBrandId = vidaBrand.Id,
            DataUsePurposeId = repLegalPurpose.Id,
            AccountId__c = testAccount.Id,
            PrivacyConsentStatus = 'OptIn'
        );
        insert pc;

        Map<String, Object> outMap = new Map<String, Object>();

        Test.startTest();
        RevocationDataExtractHD extractor = new RevocationDataExtractHD();
        extractor.getData(testIndividual.Id, outMap);
        Test.stopTest();

        System.assert(outMap.containsKey('groupedConsents'));
    }

    @IsTest
    static void testMergeContactPointConsents() {
        Individual testIndividual = [SELECT Id FROM Individual LIMIT 1];
        Map<String, Object> outMap = new Map<String, Object>();

        Test.startTest();
        RevocationDataExtractHD extractor = new RevocationDataExtractHD();
        extractor.getData(testIndividual.Id, outMap);
        Test.stopTest();

        System.assert(outMap.containsKey('groupedConsents'));
        List<Object> groupedConsents = (List<Object>) outMap.get('groupedConsents');
        System.assertNotEquals(0, groupedConsents.size());
    }

    @IsTest
    static void testPartyConsent_WithoutBusinessBrand() {
        Individual testIndividual = [SELECT Id FROM Individual LIMIT 1];
        DataUsePurpose clientePurpose = [SELECT Id FROM DataUsePurpose WHERE Name = 'Cliente' LIMIT 1];
        Account testAccount = [SELECT Id FROM Account LIMIT 1];

        PartyConsent pc = new PartyConsent(
            Name = 'PC - 005 - NoBrand - Cliente',
            PartyId = testIndividual.Id,
            CaptureDate = DateTime.now(),
            DataUsePurposeId = clientePurpose.Id,
            AccountId__c = testAccount.Id,
            PrivacyConsentStatus = 'OptIn'
        );
        insert pc;

        Map<String, Object> outMap = new Map<String, Object>();

        Test.startTest();
        RevocationDataExtractHD extractor = new RevocationDataExtractHD();
        extractor.getData(testIndividual.Id, outMap);
        Test.stopTest();

        System.assert(outMap.containsKey('groupedConsents'));
    }

    @IsTest
    static void testContactPointConsent_WithoutMatchingPartyConsent() {
        Individual newIndividual = new Individual(
            FirstName = 'Test',
            LastName = 'Orphan',
            CS_TipoIdentificacion__c = '1',
            CS_NumeroIdentificacion__c = '888888888'
        );
        insert newIndividual;

        BusinessBrand vidaBrand = [SELECT Id FROM BusinessBrand WHERE Name = 'Vida' LIMIT 1];
        DataUsePurpose gestionCartera = [SELECT Id FROM DataUsePurpose WHERE Name = 'Gestión Cartera-2300' LIMIT 1];
        EngagementChannelType celular = [SELECT Id FROM EngagementChannelType WHERE Name = 'celular' LIMIT 1];
        Account testAccount = [SELECT Id FROM Account LIMIT 1];

        // Create ContactPoint for the orphan ContactPointConsent
        ContactPointPhone orphanContactPoint = new ContactPointPhone(
            ParentId = newIndividual.Id,
            TelephoneNumber = '3009999999'
        );
        insert orphanContactPoint;

        ContactPointConsent cpc = new ContactPointConsent(
            Name = 'CPC - 999 - Orphan - Cliente',
            ContactPointId = orphanContactPoint.Id,
            BusinessBrandId = vidaBrand.Id,
            DataUsePurpose__c = 'Cliente',
            EngagementChannelTypeId = celular.Id,
            Approved__c = true,
            DataUsePurposeId = gestionCartera.Id,
            AccountId__c = testAccount.Id,
            PrivacyConsentStatus = 'OptIn'
        );
        insert cpc;

        Map<String, Object> outMap = new Map<String, Object>();

        Test.startTest();
        RevocationDataExtractHD extractor = new RevocationDataExtractHD();
        extractor.getData(newIndividual.Id, outMap);
        Test.stopTest();

        System.assert(outMap.containsKey('groupedConsents'));
        List<Object> groupedConsents = (List<Object>) outMap.get('groupedConsents');
        System.assertEquals(0, groupedConsents.size());
    }

    @IsTest
    static void testInvalidNameFormat() {
        Individual testIndividual = [SELECT Id FROM Individual LIMIT 1];
        DataUsePurpose clientePurpose = [SELECT Id FROM DataUsePurpose WHERE Name = 'Cliente' LIMIT 1];
        BusinessBrand vidaBrand = [SELECT Id FROM BusinessBrand WHERE Name = 'Vida' LIMIT 1];
        Account testAccount = [SELECT Id FROM Account LIMIT 1];

        PartyConsent pc = new PartyConsent(
            Name = 'InvalidFormat',
            PartyId = testIndividual.Id,
            DataUsePurposeId = clientePurpose.Id,
            BusinessBrandId = vidaBrand.Id,
            AccountId__c = testAccount.Id,
            PrivacyConsentStatus = 'OptIn'
        );
        insert pc;

        Map<String, Object> outMap = new Map<String, Object>();

        Test.startTest();
        RevocationDataExtractHD extractor = new RevocationDataExtractHD();
        extractor.getData(testIndividual.Id, outMap);
        Test.stopTest();

        System.assert(outMap.containsKey('groupedConsents'));
    }
}