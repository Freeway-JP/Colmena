@isTest
public with sharing class getSendaMedicoLinkControllerTest {

    @TestSetup
    static void makeData(){
        // Create mock metadata records
        Id personAccountRecordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        Map<Schema.SObjectField, Object> customFieldsMap= new Map<Schema.SObjectField, Object>();
        customFieldsMap.put(Account.CS_Empresa_Colmena__c, '1');
        customFieldsMap.put(Account.CS_NumeroIdentificacionCP__pc, '99999');
        customFieldsMap.put(Account.CS_TipoIdentificacionCP__pc, '1');
        // account
        Account account = CS_TestDataFactory.createPersonAccount(customFieldsMap,true);

        

        
        Id recordTypeId = Schema.SObjectType.Claim.getRecordTypeInfosByDeveloperName().get('CS_AT').getRecordTypeId();
        
        Claim claimTest = new Claim();
        claimTest.Name = 'Test Claim';
        claimTest.RecordTypeId = recordTypeId;
        insert claimTest;

        Account accountTest = new Account();
        accountTest.Name = 'Test Account';
        /*accountTest.FixedAssets__c = 150;
        accountTest.BillingIncome__c = 15000;*/
        accountTest.NumberOfEmployees = 50;
        insert accountTest;

        // product2
        Product2 product2Test = new Product2();
        product2Test.Name = 'COLMENA EXEQUIAL INTEGRAL';
        product2Test.Family = '30';
        product2Test.ProductCode = '30218';
        product2Test.CS_Estrategia_M2__c = '13';
        product2Test.IsActive = true;
        product2Test.CS_Canal__c = '101';
        product2Test.CS_Producto_M2__c = '123';
        product2Test.CS_Producto_Colmena_M2__c = 'Seguro Acompañamiento Exequial';
        product2Test.CS_Entidad_Producto__c = '1';
        insert product2Test;

        InsurancePolicy insurancePolicyTest = new InsurancePolicy();
        insurancePolicyTest.Name = 'AP-0000000001';
        insurancePolicyTest.NameInsuredId = accountTest.Id;
        insurancePolicyTest.ProductId = product2Test.Id;
        insert insurancePolicyTest;

        ClaimCoverage claimCoverage = new ClaimCoverage(
            Name = 'Test Claim Coverage',
            ClaimId = claimTest.Id,
            InternalReserveMode = 'CoverageReserve',
            CS_CompensationValue__c = 6000000
        );
        insert claimCoverage;

        // CoverageCode
        InsurancePolicyCoverage insurancePolicyCoverageTest = new InsurancePolicyCoverage();
        insurancePolicyCoverageTest.InsurancePolicyId = insurancePolicyTest.Id;
        insurancePolicyCoverageTest.CoverageName = 'Test Coverage';
        insurancePolicyCoverageTest.CoverageCode = '';
        insert insurancePolicyCoverageTest;

//        claimTest.InsurancePolicyCoverage__c = insurancePolicyCoverageTest.Id;
        claimTest.PolicyNumberId = insurancePolicyTest.Id;
        claimTest.AccountId = accountTest.Id;
        claimTest.TimeOfDay__c = '1';
        claimTest.InjuryStatus__c = '230;410';
        claimTest.Last_Attempt_to_Send_Senda__c = Datetime.now().addHours(-2);
        claimTest.CreationFailAtSendaMedico__c = false;

        claimTest.AccidentDate__c = Date.today().addDays(-10);
/*        claimTest.AccidentDetails__c = '4';
        claimTest.AffectedBodyParts__c = '333';*/
        claimTest.AgentsCausingAccident__c = '300';
        claimTest.ClaimReasonType = '2';
        claimTest.Description_of_injury_states__c = 'Test Description of Injury States';
        claimTest.ReportedBy__c = 'Test User';
        claimTest.TypeOfInjury__c = '82';
        claimTest.Description_of_the_accident__c = 'Test Description of the accident';
        claimTest.SiteAccidentOccurrence__c = '3';
/*        claimTest.ResponsibleFiling__c = '3';*/

        claimTest.IsBiologicalRisk__c = true;
        claimTest.IsDeath__c = false;
        claimTest.IsInsideTheCompany__c = true;
        claimTest.IsLunchTime__c = true;
        claimTest.IsWorkAtHome__c = true;
        claimTest.Company_Phone__c = '';
        claimTest.Email_Work__c = '';
        claimTest.Home_phone__c = '';
        claimTest.JobPosition__c = 'Test Job Position';
        claimTest.Mobile_phone__c = '';
        claimTest.Phone_Other__c = '';
        claimTest.Origin__c = 'Aprobado';
        claimTest.Procesamiento__c = 'AT sin AIU';
        claimTest.Severity = 'Moderado';
        claimTest.CoverageValidationDate__c = Datetime.now();
        claimTest.Last_Attempt_to_Send_Senda__c = Datetime.now().addMinutes(-2);
        claimTest.CreationFailAtSendaMedico__c = true;
        update claimTest;

        Id devRecordTypeId = Schema.SObjectType.InsurancePolicyParticipant.getRecordTypeInfosByDeveloperName().get('CS_Asegurado').getRecordTypeId();

 
         InsurancePolicyParticipant     objConP = new InsurancePolicyParticipant (RecordTypeId  =devRecordTypeId,
         InsurancePolicyId = insurancePolicyTest.Id,Role    = 'Otros',IsMinorBeneficiary = false,IsActiveParticipant = true,PrimaryParticipantAccountId = account.id
            );
        insert objConP;
        Contact contact = [SELECT Id FROM Contact WHERE AccountId = :account.id limit 1];
        // create task
        Task task = new Task();
        task.Subject = 'Test Task';
        task.ActivityDate = Date.today();
        task.Description = 'Test Description';
        task.Indemnizaci_n__c = claimTest.Id;
        task.Poliza_de_seguro__c = insurancePolicyTest.Id;
        task.WhoId = contact.Id;
        task.WhatId = accountTest.Id;
        task.Participante_de_poliza_de_seguro__c = objConP.Id;
        insert task;
    }

    @isTest
    static void sendMedicalURL(){
        Task task = [SELECT Id FROM Task LIMIT 1];
        getSendaMedicoLinkController.Response response = getSendaMedicoLinkController.getDataConfiguration(task.Id);
        System.debug('response: ' + response);
        Assert.areEqual(response.cedula, [SELECT employeenumber FROM USER WHERE Id = : Userinfo.getUserId()]?.employeenumber);
    }

}