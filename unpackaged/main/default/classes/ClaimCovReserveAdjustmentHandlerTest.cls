@isTest
public with sharing class ClaimCovReserveAdjustmentHandlerTest {

    static Id claimCovId = setupClaimCoverage();
    
    private static Id setupClaimCoverage() {
        Claim testClaim = new Claim(Name = 'Test Claim');
        insert testClaim;

        ClaimCoverage testClaimCoverage = new ClaimCoverage(
            Name = 'Test Claim Coverage',
            ClaimId = testClaim.Id,
            InternalReserveMode = 'CoverageReserve'
        );
        insert testClaimCoverage;

        return testClaimCoverage.Id;
    }

    private static Id setupClaimCoverageReserveDetails() {
        ClaimCoverageReserveDetail reserveDetail = new ClaimCoverageReserveDetail(
            Name = 'Reserve Detail',
            Status = 'Pending',
            CS_InitialAdjustment__c = 100,
            ReserveAmount = 100,
            CS_NewReserv__c = 0,
            ClaimCoverageId = claimCovId
        );
        insert reserveDetail;

        return reserveDetail.Id;
    }

    @isTest
    static void testOnAfterInsert() {
        Id reserveDetailId = setupClaimCoverageReserveDetails();

        ClaimCovReserveAdjustment adjustment = new ClaimCovReserveAdjustment(
            ClaimCoverageReserveDetailId = reserveDetailId,
            Adjustment_Type__c = 'Endoso retroactivo',
            AdjustmentAmount = 50
        );

        Test.startTest();
        ClaimCovReserveAdjustmentHandler.onAfterInsert(new List<ClaimCovReserveAdjustment>{ adjustment });
        Test.stopTest();
    }

    @isTest
    static void testOnAfterUpdate() {
        Id reserveDetailId = setupClaimCoverageReserveDetails();

        ClaimCovReserveAdjustment adjustment = new ClaimCovReserveAdjustment(
            ClaimCoverageReserveDetailId = reserveDetailId,
            Adjustment_Type__c = 'Disminución',
            AdjustmentAmount = 20,
            Name = 'Test',
            ClaimCoverageId = claimCovId
        );
        insert adjustment;

        ClaimCovReserveAdjustment oldAdjustment = adjustment.clone(false, true, true, true);
        adjustment.AdjustmentAmount = 30;

        Test.startTest();
        ClaimCovReserveAdjustmentHandler.onAfterUpdate(
            new List<ClaimCovReserveAdjustment>{ adjustment },
            new List<ClaimCovReserveAdjustment>{ oldAdjustment }
        );
        Test.stopTest();
    }

    @isTest
    static void testOnAfterDelete() {
        Id reserveDetailId = setupClaimCoverageReserveDetails();

        ClaimCovReserveAdjustment adjustment = new ClaimCovReserveAdjustment(
            ClaimCoverageReserveDetailId = reserveDetailId,
            Adjustment_Type__c = 'Liberación por objeción',
            AdjustmentAmount = 10,
            Name = 'Test',
            ClaimCoverageId = claimCovId
        );
        insert adjustment;

        Test.startTest();
        ClaimCovReserveAdjustmentHandler.onAfterDelete(new List<ClaimCovReserveAdjustment>{ adjustment });
        Test.stopTest();
    }

    @isTest
    static void testOnBeforeInsert() {
        Id reserveDetailId = setupClaimCoverageReserveDetails();

        ClaimCovReserveAdjustment adjustment = new ClaimCovReserveAdjustment(
            ClaimCoverageReserveDetailId = reserveDetailId,
            Adjustment_Type__c = 'Liberación por objeción',
            Name = 'Test',
            ClaimCoverageId = claimCovId
        );
        insert adjustment;

        ClaimCovReserveAdjustment duplicateAdjustment = new ClaimCovReserveAdjustment(
            ClaimCoverageReserveDetailId = reserveDetailId
        );

        Test.startTest();
        ClaimCovReserveAdjustmentHandler.onBeforeInsert(new List<ClaimCovReserveAdjustment>{ duplicateAdjustment });
        Test.stopTest();

        System.assertEquals(1, duplicateAdjustment.getErrors().size(), 'Duplicate record should trigger an error');
    }

    @isTest
    static void testOnBeforeUpdate() {
        Id reserveDetailId = setupClaimCoverageReserveDetails();

        ClaimCovReserveAdjustment adjustment = new ClaimCovReserveAdjustment(
            ClaimCoverageReserveDetailId = reserveDetailId,
            Adjustment_Type__c = 'Disminución',
            AdjustmentAmount = 10,
            Name = 'Test',
            ClaimCoverageId = claimCovId
        );
        insert adjustment;

        ClaimCoverageReserveDetail reserveDetail = [
            SELECT Id, Status FROM ClaimCoverageReserveDetail WHERE Id = :reserveDetailId LIMIT 1
        ];
        reserveDetail.Status = 'Aprobado';
        update reserveDetail;

        adjustment.AdjustmentAmount = 20;

        Test.startTest();
        ClaimCovReserveAdjustmentHandler.onBeforeUpdate(
            new List<ClaimCovReserveAdjustment>{ adjustment },
            new List<ClaimCovReserveAdjustment>{ adjustment.clone(false, true, true, true) }
        );
        Test.stopTest();

        System.assertEquals(1, adjustment.getErrors().size(), 'Blocked update should trigger an error');
    }

    @isTest
    static void testOnBeforeDelete() {
        Id reserveDetailId = setupClaimCoverageReserveDetails();

        ClaimCovReserveAdjustment adjustment = new ClaimCovReserveAdjustment(
            ClaimCoverageReserveDetailId = reserveDetailId,
            Adjustment_Type__c = 'Endoso retroactivo',
            AdjustmentAmount = 10,
            Name = 'Test',
            ClaimCoverageId = claimCovId
        );
        insert adjustment;

        ClaimCoverageReserveDetail reserveDetail = [
            SELECT Id, Status FROM ClaimCoverageReserveDetail WHERE Id = :reserveDetailId LIMIT 1
        ];
        reserveDetail.Status = 'Objetado';
        update reserveDetail;

        Test.startTest();
        ClaimCovReserveAdjustmentHandler.onBeforeDelete(
            new List<ClaimCovReserveAdjustment>(),
            new List<ClaimCovReserveAdjustment>{ adjustment }
        );
        Test.stopTest();

        System.assertEquals(1, adjustment.getErrors().size(), 'Blocked delete should trigger an error');
    }

}