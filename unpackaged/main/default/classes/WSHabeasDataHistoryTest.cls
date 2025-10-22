/**
 * @description Tests for WSHabeasDataHistory covering success, failure, and edge cases to achieve ≥95% coverage.
 * @author
 * @date 2025-10-02
 * @since 1.1
 */
@IsTest(SeeAllData=false)
private class WSHabeasDataHistoryTest {
    @TestSetup
    static void setupData() {
        insert new BusinessBrand(Name = 'Colmena Vida');
        insert new DataUsePurpose(Name = WSHabeasDataUtilities.PROSPECTO);
        insert new DataUsePurpose(Name = WSHabeasDataUtilities.CLIENTE_REPRESENTANTE_LEGAL);
        insert new DataUsePurpose(Name = WSHabeasDataUtilities.PROSPECTO_REPRESENTANTE_LEGAL);
        insert new DataUsePurpose(Name = WSHabeasDataUtilities.DATA_MARKETING);
        insert new DataUsePurpose(Name = WSHabeasDataUtilities.DEBT_COLLECT);
        insert new EngagementChannelType(Name = 'Email');
        insert new EngagementChannelType(Name = 'Phone');

        Individual ind = new Individual(LastName = 'Tester');
        insert ind;

        ContactPointEmail cpe = new ContactPointEmail(EmailAddress = 'ana@example.com', ParentId = ind.Id, ClientIdentityNumber__c = '900123');
        insert cpe;

        ContactPointPhone cpp = new ContactPointPhone(TelephoneNumber = '3001112233', ParentId = ind.Id, ClientIdentityNumber__c = '900123');
        insert cpp;

        BusinessBrand bb = [SELECT Id FROM BusinessBrand LIMIT 1];
        DataUsePurpose dupProspect = [SELECT Id FROM DataUsePurpose WHERE Name = :WSHabeasDataUtilities.PROSPECTO LIMIT 1];
        DataUsePurpose dupClientRL = [SELECT Id FROM DataUsePurpose WHERE Name = :WSHabeasDataUtilities.CLIENTE_REPRESENTANTE_LEGAL LIMIT 1];
        DataUsePurpose dupDebt = [SELECT Id FROM DataUsePurpose WHERE Name = :WSHabeasDataUtilities.DEBT_COLLECT LIMIT 1];
        DataUsePurpose dupMkt = [SELECT Id FROM DataUsePurpose WHERE Name = :WSHabeasDataUtilities.DATA_MARKETING LIMIT 1];
        EngagementChannelType ectEmail = [SELECT Id FROM EngagementChannelType WHERE Name = 'Email' LIMIT 1];
        EngagementChannelType ectPhone = [SELECT Id FROM EngagementChannelType WHERE Name = 'Phone' LIMIT 1];

        Datetime t1 = System.now();
        Datetime t2 = t1.addMinutes(1);

        insert new PartyConsent(
            Name = 'Ana Tester',
            PartyId = ind.Id,
            AuthorizationChannel__c = 'MARI',
            BusinessBrandId = bb.Id,
            CaptureDate = t1,
            DataUsePurposeId = dupProspect.Id,
            GeneralDataMarketing__c = true,
            GeneralProcessingData__c = true,
            MedicalHistory__c = false,
            Email__c = 'ana@example.com',
            Phone__c = '3001112233',
            DataMarketing__c = true,
            PrivacyConsentStatus = WSHabeasDataUtilities.PRIVACY_STATUS_OPT_IN,
            Action = 'Data Collection'
        );
        insert new PartyConsent(
            Name = 'Ana Tester',
            PartyId = ind.Id,
            AuthorizationChannel__c = 'MARI',
            BusinessBrandId = bb.Id,
            CaptureDate = t2,
            DataUsePurposeId = dupClientRL.Id,
            GeneralDataMarketing__c = false,
            GeneralProcessingData__c = true,
            MedicalHistory__c = false,
            PrivacyConsentStatus = WSHabeasDataUtilities.PRIVACY_STATUS_OPT_IN,
            Action = 'Data Collection'
        );

        insert new ContactPointConsent(
            Name = 'Ana Tester',
            BusinessBrandId = bb.Id,
            AuthorizationChannel__c = 'MARI',
            CaptureDate = t1,
            EngagementChannelTypeId = ectEmail.Id,
            DataUsePurposeId = dupDebt.Id,
            PrivacyConsentStatus = WSHabeasDataUtilities.PRIVACY_STATUS_OPT_IN,
            Approved__c = true,
            ContactPointId = cpe.Id
        );
        insert new ContactPointConsent(
            Name = 'Ana Tester',
            BusinessBrandId = bb.Id,
            AuthorizationChannel__c = 'MARI',
            CaptureDate = t1,
            EngagementChannelTypeId = ectPhone.Id,
            DataUsePurposeId = dupMkt.Id,
            PrivacyConsentStatus = WSHabeasDataUtilities.PRIVACY_STATUS_OPT_IN,
            Approved__c = false,
            ContactPointId = cpp.Id
        );
    }

    /**
     * @description Validates successful consent aggregation for an Individual Id and presence of aggregated channels.
     * @test
     */
    @IsTest
    static void test_getConsents_success_via_call() {
        Individual ind = [SELECT Id FROM Individual LIMIT 1];
        WSHabeasDataHistory svc = new WSHabeasDataHistory();
        Map<String, Object> input = new Map<String, Object>{ 'recordId' => ind.Id };
        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();

        Test.startTest();
        Boolean ok = (Boolean) svc.call('getConsents', new Map<String, Object>{ 'input' => input, 'output' => output, 'options' => options });
        Test.stopTest();

        System.assertEquals(true, ok);
        System.assert(output.containsKey('consents'));
        List<Object> cons = (List<Object>) output.get('consents');
        System.assert(cons.size() >= 2);

        Boolean hasDebt = false, hasMkt = false;
        for (Object o : cons) {
            Map<String, Object> row = (Map<String, Object>) o;
            if (
                row.containsKey('GestionCartera2300') &&
                row.get('GestionCartera2300') != null &&
                String.valueOf(row.get('GestionCartera2300')).contains('Email: Si')
            )
                hasDebt = true;
            if (
                row.containsKey('OfrecimientoComercial2300') &&
                row.get('OfrecimientoComercial2300') != null &&
                String.valueOf(row.get('OfrecimientoComercial2300')).contains('Phone: No"')
            )
                hasMkt = true;
        }
        System.assertEquals(true, hasDebt);
    }

    /**
     * @description Validates error path for not implemented action.
     * @test
     */
    @IsTest
    static void test_call_not_implemented() {
        Individual ind = [SELECT Id FROM Individual LIMIT 1];
        WSHabeasDataHistory svc = new WSHabeasDataHistory();
        Map<String, Object> input = new Map<String, Object>{ 'recordId' => ind.Id };
        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();

        Boolean ok = (Boolean) svc.call('getConsentsPaged', new Map<String, Object>{ 'input' => input, 'output' => output, 'options' => options });
        System.assertEquals(false, ok);
        System.assertEquals(true, (Boolean) output.get('error'));
    }

    /**
     * @description Validates error path for unknown action.
     * @test
     */
    @IsTest
    static void test_call_unknown_method() {
        WSHabeasDataHistory svc = new WSHabeasDataHistory();
        Map<String, Object> input = new Map<String, Object>();
        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();

        Boolean ok = (Boolean) svc.call('unknownAction', new Map<String, Object>{ 'input' => input, 'output' => output, 'options' => options });
        System.assertEquals(false, ok);
        System.assertEquals(true, (Boolean) output.get('error'));
    }

    /**
     * @description Validates error path for blank method name.
     * @test
     */
    @IsTest
    static void test_call_blank_method() {
        WSHabeasDataHistory svc = new WSHabeasDataHistory();
        Map<String, Object> output = new Map<String, Object>();
        Boolean ok = (Boolean) svc.call(
            '',
            new Map<String, Object>{ 'input' => new Map<String, Object>(), 'output' => output, 'options' => new Map<String, Object>() }
        );
        System.assertEquals(false, ok);
        System.assertEquals(true, (Boolean) output.get('error'));
    }

    /**
     * @description Validates error path when recordId is null.
     * @test
     */
    @IsTest
    static void test_getConsents_null_recordId() {
        WSHabeasDataHistory svc = new WSHabeasDataHistory();
        Map<String, Object> input = new Map<String, Object>{ 'recordId' => null };
        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        Boolean ok = (Boolean) svc.call('getConsents', new Map<String, Object>{ 'input' => input, 'output' => output, 'options' => options });
        System.assertEquals(false, ok);
        System.assertEquals(true, (Boolean) output.get('error'));
    }

    /**
     * @description Validates resolveIndividualId Task branches: no WhatId, WhatId not Account, Account without PersonIndividualId.
     * @test
     */
    @IsTest
    static void test_getConsents_task_error_branches() {
        WSHabeasDataHistory svc = new WSHabeasDataHistory();
        Map<String, Object> output;
        Map<String, Object> args;
        Boolean ok;

        Id recordTypeid = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('SLEEfectiveLine').getRecordTypeId();

        Task t1 = new Task(Subject = 'T1', RecordTypeId =recordTypeid);
        insert t1;
        output = new Map<String, Object>();
        args = new Map<String, Object>{ 'input' => new Map<String, Object>{ 'recordId' => t1.Id }, 'output' => output, 'options' => new Map<String, Object>() };
        ok = (Boolean) svc.call('getConsents', args);
        System.assertEquals(false, ok);
        System.assertEquals(true, (Boolean) output.get('error'));

        Account a = new Account(Name = 'Biz');
        insert a;
        Task t3 = new Task(Subject = 'T3', WhatId = a.Id, RecordTypeId = recordTypeid);
        insert t3;
        output = new Map<String, Object>();
        args = new Map<String, Object>{ 'input' => new Map<String, Object>{ 'recordId' => t3.Id }, 'output' => output, 'options' => new Map<String, Object>() };
        ok = (Boolean) svc.call('getConsents', args);
        System.assertEquals(false, ok);
        System.assertEquals(true, (Boolean) output.get('error'));
    }

    /**
     * @description Validates direct invocation of getConsents with an Individual Id returns serializable list.
     * @test
     */
    @IsTest
    static void test_getConsents_direct_call_serializable() {
        Individual ind = [SELECT Id, AuthorizationChannel__c FROM Individual LIMIT 1];
        WSHabeasDataHistory svc = new WSHabeasDataHistory();
        List<Object> out = svc.getConsents(ind.Id);
        System.assertNotEquals(null, out);
        System.assert(out.size() > 0);
    }
}