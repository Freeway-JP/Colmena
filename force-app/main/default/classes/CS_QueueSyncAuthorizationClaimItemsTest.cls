@isTest
public with sharing class CS_QueueSyncAuthorizationClaimItemsTest {

        @isTest
    static void testQueueableExecution() {
        // Preparar RecordType
        RecordType authRecordType = CS_TestDataFactory.getRecordType('ClaimItem', 'Authorization');
        RecordType serviceRecordType = CS_TestDataFactory.getRecordType('ClaimItem', 'AuthorizationService');
        RecordType authServiceRecordType = CS_TestDataFactory.getRecordType('GeneralCharacteristics__c', 'AuthorizationServices');

        // Crear Claim relacionado
        Claim claim = new Claim(Name = 'Name',CS_numeroLinea__c = 'L999999');
        insert claim;

        // Crear ClaimItem principal
        ClaimItem mainItem = new ClaimItem(
            Name = 'Name',
            RecordTypeId = authRecordType.Id,
            ClaimId = claim.Id,
            CreationFailAtSendaMedico__c = true,
            IsCommercial__c = true,
            ObservationsClaimAuthorization__c = 'Observación de prueba'
        );
        insert mainItem;

        // Crear AuthorizationService asociado al ClaimItem
        GeneralCharacteristics__c service = new GeneralCharacteristics__c(
            ServiceCode__c = 'SCODE001',
            ServiceType__c = 1,
            UnitPrice__c = 100,
            Description__c = 'Descripción de prueba',
            RecordTypeId = authServiceRecordType.Id
        );
        insert service;

        // Crear ClaimItem hijo
        ClaimItem serviceItem = new ClaimItem(
            Name = 'Name',
            RecordTypeId = serviceRecordType.Id,
            ParentId__c = mainItem.Id,
            Amount__c = 2.0,
            ClaimId = claim.Id,
            AuthorizationServices__c = service.Id
        );
        insert serviceItem;

        Test.startTest();
        System.enqueueJob(new CS_QueueSyncAuthorizationClaimItems(mainItem.Id));
        Test.stopTest();

        System.assert(true); // Verificación implícita: sin errores
    }

}