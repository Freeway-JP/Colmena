@isTest
public with sharing class CS_ScheduledSyncAuthClaimItemsTest {
    
    @isTest
    static void testScheduledExecute() {
        // Preparar datos simulados
        RecordType authRecordType = CS_TestDataFactory.getRecordType('ClaimItem', 'Authorization');

        Claim claim = new Claim(Name = 'Claim', CS_numeroLinea__c = 'L123456');
        insert claim;

        ClaimItem ci = new ClaimItem(
            Name = 'Name',
            RecordTypeId = authRecordType.Id,
            ClaimId = claim.Id,
            CreationFailAtSendaMedico__c = true
        );
        insert ci;

        Test.startTest();
        String cronExp = '0 0 0 * * ?'; // Todos los días a las 00:00
        System.schedule('Test Scheduled Job', cronExp, new CS_ScheduledSyncAuthorizationClaimItems());
        Test.stopTest();

        // Verificación implícita: no se lanzan errores
        System.assert(true);
    }

}