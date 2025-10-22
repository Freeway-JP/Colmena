@isTest
public with sharing class ClaimCoverageReserveDetailHelperTest {
    private static Map<String, Id> setupTestRecords(String claimCoverageStatus, String reserveDetailStatus, Decimal initialAdjustment, Decimal reserveAmount) {
        Claim testClaim = new Claim(Name = 'Test Claim');
        insert testClaim;

        ClaimCoverage testClaimCoverage = new ClaimCoverage(
            Name = 'Test Claim Coverage',
            ClaimId = testClaim.Id,
            InternalReserveMode = 'CoverageReserve',
            Status = claimCoverageStatus
        );
        insert testClaimCoverage;

        ClaimCoverageReserveDetail reserveDetail = new ClaimCoverageReserveDetail(
            Name = 'Test Reserve Detail',
            Status = reserveDetailStatus,
            CS_InitialAdjustment__c = initialAdjustment,
            ReserveAmount = reserveAmount,
            CS_NewReserv__c = 0,
            ClaimCoverageId = testClaimCoverage.Id
        );
        insert reserveDetail;

        return new Map<String, Id>{'ClaimCoverageId' => testClaimCoverage.Id, 'ReserveDetailId' => reserveDetail.Id};
    }

    @isTest
    static void testUpdateStatusOfClaimCoverage() {
        Map<String, Id> ids = setupTestRecords('Pending', 'Objetado', 100, 50);

        List<ClaimCoverageReserveDetail> records = [SELECT Id, Status, ClaimCoverageId FROM ClaimCoverageReserveDetail WHERE Id = :ids.get('ReserveDetailId')];

        Test.startTest();
        ClaimCoverageReserveDetailHelper.updateStatusOfClaimCoverage(records);
        Test.stopTest();

        ClaimCoverage updatedClaimCoverage = [SELECT Status FROM ClaimCoverage WHERE Id = :ids.get('ClaimCoverageId')];
        System.assertEquals('Pending', updatedClaimCoverage.Status, 'ClaimCoverage status should be updated to Objetado');
    }

    @isTest
    static void testUpdateNewReserve() {
        Map<String, Id> ids = setupTestRecords('Pending', 'Aprobado', 200, 150);

        List<ClaimCoverageReserveDetail> records = [SELECT Id, Status, ReserveAmount, CS_InitialAdjustment__c FROM ClaimCoverageReserveDetail WHERE Id = :ids.get('ReserveDetailId')];

        Test.startTest();
        ClaimCoverageReserveDetailHelper.updateNewReserve(records);
        Test.stopTest();

        ClaimCoverageReserveDetail updatedDetail = [SELECT ReserveAmount, CS_NewReserv__c FROM ClaimCoverageReserveDetail WHERE Id = :ids.get('ReserveDetailId')];
        System.assertEquals(150.00, updatedDetail.ReserveAmount, 'ReserveAmount should match CS_InitialAdjustment__c');
        System.assertEquals(0, updatedDetail.CS_NewReserv__c, 'CS_NewReserv__c should be 0 for approved status');
    }

    @isTest
    static void testUpdateClaimCovReserve_WithAdjustments() {
        Map<String, Id> ids = setupTestRecords('Pending', 'Aprobado', 300, 250);

        ClaimCovReserveAdjustment adjustment = new ClaimCovReserveAdjustment(
            Name = 'Test Adjustment',
            ClaimCoverageReserveDetailId = ids.get('ReserveDetailId'),
            Adjustment_Type__c = 'Liberación por objeción',
            AdjustmentAmount = 50,
            ClaimCoverageId = ids.get('ClaimCoverageId')
        );
        insert adjustment;

        List<ClaimCoverageReserveDetail> records = [SELECT Id, Status, ReserveAmount, CS_InitialAdjustment__c FROM ClaimCoverageReserveDetail WHERE Id = :ids.get('ReserveDetailId')];

        Test.startTest();
        ClaimCoverageReserveDetailHelper.updateClaimCovReserve(records);
        Test.stopTest();

        ClaimCoverageReserveDetail updatedDetail = [SELECT CS_NewReserv__c FROM ClaimCoverageReserveDetail WHERE Id = :ids.get('ReserveDetailId')];
        System.assertEquals(0.00, updatedDetail.CS_NewReserv__c, 'CS_NewReserv__c should match CS_InitialAdjustment__c');
    }

    @isTest
    static void testUpdateClaimCovReserve_WithoutAdjustments() {
        Map<String, Id> ids = setupTestRecords('Pending', 'Aprobado', 300, 250);

        List<ClaimCoverageReserveDetail> records = [SELECT Id, Status, ReserveAmount, CS_InitialAdjustment__c FROM ClaimCoverageReserveDetail WHERE Id = :ids.get('ReserveDetailId')];

        Test.startTest();
        ClaimCoverageReserveDetailHelper.updateClaimCovReserve(records);
        Test.stopTest();

        ClaimCoverageReserveDetail updatedDetail = [SELECT CS_NewReserv__c FROM ClaimCoverageReserveDetail WHERE Id = :ids.get('ReserveDetailId')];
        System.assertEquals(0.00, updatedDetail.CS_NewReserv__c, 'CS_NewReserv__c should be CS_InitialAdjustment__c - ReserveAmount');
    }

    @isTest
    static void testUpdateClaimCovReserve_InvalidStatus() {
        Map<String, Id> ids = setupTestRecords('Pending', 'InvalidStatus', 300, 250);

        List<ClaimCoverageReserveDetail> records = [SELECT Id, Status, ReserveAmount, CS_InitialAdjustment__c FROM ClaimCoverageReserveDetail WHERE Id = :ids.get('ReserveDetailId')];

        Test.startTest();
        ClaimCoverageReserveDetailHelper.updateClaimCovReserve(records);
        Test.stopTest();

        ClaimCoverageReserveDetail updatedDetail = [SELECT CS_NewReserv__c FROM ClaimCoverageReserveDetail WHERE Id = :ids.get('ReserveDetailId')];
        System.assertEquals(0.00, updatedDetail.CS_NewReserv__c, 'CS_NewReserv__c should be null for invalid status');
    }
}