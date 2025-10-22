@isTest
public class VS_SendClaimToSendaScheduleTest {
    @TestSetup
    static void makeData(){
        // Create mock metadata records

        // account
        Account account = new Account();
        account.Name = 'Test Account';
        insert account;

        // contact
        Contact contact = new Contact();
        contact.FirstName = 'Test';
        contact.LastName = 'Contact';
        contact.AccountId = account.Id;
        contact.CS_TipoIdentificacionCP__c = '1';
        contact.CS_NumeroIdentificacionCP__c = '1234567890';
        insert contact;

        /*
        // get record type 
        RecordType recordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Claim' AND DeveloperName = 'CS_AT'];

        // Create mock Claim records
        claim.RecordTypeId = recordType.Id;
        Claim claim = new Claim();
        claim.Name = 'Test Claim';
        claim.AccidentDate__c = Date.today().addDays(-1);
        claim.AccidentDetails__c = '8';
        claim.AffectedBodyParts__c = '446';
        claim.AgentsCausingAccident__c = '300';
        claim.ClaimReasonType = '02';
        claim.Description_of_injury_states__c = 'Test Description of Injury States';
        claim.ReportedBy__c = 'Test User';
        claim.TypeOfInjury__c = '82';
        claim.Description_of_the_accident__c = 'Test Description of the accident';
        claim.Diagnosis__c = 'T741';
        claim.SiteAccidentOccurrence__c = '3';
        claim.ResponsibleFiling__c = '3';
        
        claim.IsBiologicalRisk__c = true;
        claim.IsDeath__c = false;
        claim.IsInsideTheCompany__c = true;
        claim.IsLunchTime__c = true;
        claim.IsWorkAtHome__c = true;
        claim.Company_Phone__c = '';
        claim.Email_Work__c = '';
        claim.Home_phone__c = '';
        claim.JobPosition__c = 'Test Job Position';
        claim.Mobile_phone__c = '';
        claim.Phone_Other__c = '';
        claim.InjuryStatus__c = '230;10';
        claim.Origin__c = 'Aprobado';
        claim.Procesamiento__c = 'AT sin AIU';
        claim.Severity = 'Moderado';
        claim.AccountId = account.Id; // todo
        claim.CoverageValidationDate__c = Datetime.now();
        claim.Last_Attempt_to_Send_Senda__c = Datetime.now().addMinutes(-2);
        claim.CreationFailAtSendaMedico__c = true;

        insert claim;
        */
        
        Id recordTypeId = Schema.SObjectType.Claim.getRecordTypeInfosByDeveloperName().get('CS_AT').getRecordTypeId();
        
        Claim claimTest = new Claim();
        claimTest.Name = 'Test Claim';
        claimTest.RecordTypeId = recordTypeId;
        insert claimTest;

        Account accountTest = new Account();
        accountTest.Name = 'Test Account';
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
/*        InsurancePolicyCoverage insurancePolicyCoverageTest = new InsurancePolicyCoverage();
        insurancePolicyCoverageTest.InsurancePolicyId = insurancePolicyTest.Id;
        insurancePolicyCoverageTest.CoverageName = 'Test Coverage';
        insurancePolicyCoverageTest.CoverageCode = '';
        insert insurancePolicyCoverageTest;

        claimTest.InsurancePolicyCoverage__c = insurancePolicyCoverageTest.Id;*/
        claimTest.PolicyNumberId = insurancePolicyTest.Id;
        claimTest.AccountId = accountTest.Id;
        claimTest.TimeOfDay__c = '1';
        claimTest.InjuryStatus__c = '230;410';
        claimTest.Last_Attempt_to_Send_Senda__c = Datetime.now().addHours(-2);
        claimTest.CreationFailAtSendaMedico__c = true;

        claimTest.AccidentDate__c = Date.today().addDays(-10);
        claimTest.AccidentDetails__c = '10050';
        claimTest.AffectedBodyParts__c = '101';
        claimTest.AgentsCausingAccident__c = '300';
        claimTest.ClaimReasonType = '02';
        claimTest.Description_of_injury_states__c = 'Test Description of Injury States';
        claimTest.ReportedBy__c = 'Test User';
        claimTest.TypeOfInjury__c = '82';
        claimTest.Description_of_the_accident__c = 'Test Description of the accident';
        claimTest.SiteAccidentOccurrence__c = '3';
        claimTest.ResponsibleFiling__c = '3';

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
        
        // create task
        Task task = new Task();
        task.Subject = 'Test Task';
        task.ActivityDate = Date.today();
        task.Description = 'Test Description';
        task.Indemnizaci_n__c = claimTest.Id;
        task.Poliza_de_seguro__c = insurancePolicyTest.Id;
        task.WhoId = contact.Id;
        task.WhatId = accountTest.Id;
        insert task;
    }

    @isTest
    static void testExecute() {
        // get claims
        List<Claim> claims = [
            SELECT Id, Name, Last_Attempt_to_Send_Senda__c, CreationDateOnSendaMedico__c, CreationFailAtSendaMedico__c, ReportedBy__c 
            FROM Claim 
            WHERE CreationFailAtSendaMedico__c = true
        ];

        System.debug('claims: ' + claims);
        Test.startTest();
        
        List<Schedule_Configuration__mdt> metadataList = new List<Schedule_Configuration__mdt>();

        Schedule_Configuration__mdt metadata = new Schedule_Configuration__mdt();
        metadata.MasterLabel = 'Send_Claim_to_Senda';
        metadata.DeveloperName = 'Send_Claim_to_Senda';
        metadata.Time__c = 1;

        // Create a mock metadata map
        Map<String, Schedule_Configuration__mdt> metadataMap = new Map<String, Schedule_Configuration__mdt>();
        metadataMap.put(metadata.MasterLabel, metadata);

        // Inject the mock metadata map into the class
        VS_SendClaimToSendaSchedule.testMetadataMap = metadataMap;
        
        VS_SendClaimToSendaSchedule schedule = new VS_SendClaimToSendaSchedule();
        
        schedule.execute(null);
        Test.stopTest();

    }
}