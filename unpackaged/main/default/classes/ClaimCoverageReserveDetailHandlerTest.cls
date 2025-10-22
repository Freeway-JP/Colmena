@isTest
public with sharing class ClaimCoverageReserveDetailHandlerTest {
    private static Id setupTestClaimCoverage() {
        Claim testClaim = new Claim(
            Name = 'Test Claim'
        );
        insert testClaim;

        ClaimCoverage testClaimCoverage = new ClaimCoverage(
            Name = 'Test Claim Coverage',
            ClaimId = testClaim.Id,
            InternalReserveMode = 'CoverageReserve'
        );
        insert testClaimCoverage;

        return testClaimCoverage.Id;
    }

    @isTest
    static void testOnBeforeInsert() {
        Id claimCoverageId = setupTestClaimCoverage();

        ClaimCoverageReserveDetail newDetail = new ClaimCoverageReserveDetail(
            Name = 'New Detail',
            Status = 'Pending',
            CS_InitialAdjustment__c = 100,
            ReserveAmount = 100,
            CS_NewReserv__c = 0,
            ClaimCoverageId = claimCoverageId
        );

        Test.startTest();
        ClaimCoverageReserveDetailHandler.onBeforeInsert(new List<ClaimCoverageReserveDetail>{ newDetail });
        Test.stopTest();
    }

    @isTest
    static void testOnBeforeUpdate() {
        Id claimCoverageId = setupTestClaimCoverage();

        ClaimCoverageReserveDetail detail = new ClaimCoverageReserveDetail(
            Name = 'Detail Before Update',
            Status = 'Pending',
            CS_InitialAdjustment__c = 200,
            ReserveAmount = 200,
            CS_NewReserv__c = 0,
            ClaimCoverageId = claimCoverageId
        );
        insert detail;

        detail.Status = 'In Review';

        Test.startTest();
        ClaimCoverageReserveDetailHandler.onBeforeUpdate(new List<ClaimCoverageReserveDetail>{ detail });
        Test.stopTest();
    }

    @isTest
    static void testOnAfterUpdate() {
        Id claimCoverageId = setupTestClaimCoverage();

        ClaimCoverageReserveDetail detail = new ClaimCoverageReserveDetail(
            Name = 'Detail After Update',
            Status = 'Pending',
            CS_InitialAdjustment__c = 300,
            ReserveAmount = 300,
            CS_NewReserv__c = 0,
            ClaimCoverageId = claimCoverageId
        );
        insert detail;

        ClaimCoverageReserveDetail oldDetail = [SELECT Id, Status, CS_InitialAdjustment__c, ReserveAmount, CS_NewReserv__c, ClaimCoverageId
                                                 FROM ClaimCoverageReserveDetail
                                                 WHERE Id = :detail.Id
                                                 LIMIT 1];

        ClaimCoverageReserveDetail newDetail = oldDetail.clone(false, true, true, true);
        newDetail.Status = 'Updated Status'; 

        Test.startTest();
        ClaimCoverageReserveDetailHandler.onAfterUpdate(
            new List<ClaimCoverageReserveDetail>{ newDetail },
            new List<ClaimCoverageReserveDetail>{ oldDetail }
        );
        Test.stopTest();
    }
}