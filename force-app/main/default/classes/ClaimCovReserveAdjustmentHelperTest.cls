@isTest
public with sharing class ClaimCovReserveAdjustmentHelperTest {
    
    @testSetup
    static void setupTestData() {
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
        
        ClaimCoverageReserveDetail detailEndosoRetro = new ClaimCoverageReserveDetail(
            Name = 'Detail Endoso Retro',
            Status = 'Aprobado',
            CS_InitialAdjustment__c = 100,
            ReserveAmount = 100,
            CS_NewReserv__c = 0,
            ClaimCoverageId = testClaimCoverage.Id 
        );

        ClaimCoverageReserveDetail detailDisminucion = new ClaimCoverageReserveDetail(
            Name = 'Detail Disminucion',
            Status = 'Objetado',
            CS_InitialAdjustment__c = 200,
            ReserveAmount = 200,
            CS_NewReserv__c = 0,
            ClaimCoverageId = testClaimCoverage.Id 
        );

        ClaimCoverageReserveDetail detailLiberacion = new ClaimCoverageReserveDetail(
            Name = 'Detail Liberacion',
            Status = 'Pending', 
            CS_InitialAdjustment__c = 300,
            ReserveAmount = 300,
            CS_NewReserv__c = 0,
            ClaimCoverageId = testClaimCoverage.Id 
        );

        ClaimCoverageReserveDetail detailElse = new ClaimCoverageReserveDetail(
            Name = 'Detail Else Condition',
            Status = 'AnotherStatus',
            CS_InitialAdjustment__c = 400,
            ReserveAmount = 400,
            CS_NewReserv__c = 0,
            ClaimCoverageId = testClaimCoverage.Id 
        );

        insert new List<ClaimCoverageReserveDetail>{ detailEndosoRetro, detailDisminucion, detailLiberacion, detailElse };

        ClaimCovReserveAdjustment adjEndosoRetro = new ClaimCovReserveAdjustment(
            Name = 'Adj Endoso Retro',
            ClaimCoverageReserveDetailId = detailEndosoRetro.Id,
            Adjustment_Type__c = 'Endoso retroactivo',
            AdjustmentAmount = 50,
            ClaimCoverageId = testClaimCoverage.Id
        );

        ClaimCovReserveAdjustment adjDisminucion = new ClaimCovReserveAdjustment(
            Name = 'Adj Disminucion',
            ClaimCoverageReserveDetailId = detailDisminucion.Id,
            Adjustment_Type__c = 'Disminución',
            AdjustmentAmount = 50,
            ClaimCoverageId = testClaimCoverage.Id
        );

        ClaimCovReserveAdjustment adjLiberacion = new ClaimCovReserveAdjustment(
            Name = 'Adj Liberacion',
            ClaimCoverageReserveDetailId = detailLiberacion.Id,
            Adjustment_Type__c = 'Liberación por objeción',
            AdjustmentAmount = 50,
            ClaimCoverageId = testClaimCoverage.Id
        );

        ClaimCovReserveAdjustment adjElse = new ClaimCovReserveAdjustment(
            Name = 'Adj Else Type',
            ClaimCoverageReserveDetailId = detailElse.Id,
            Adjustment_Type__c = 'Pago',
            AdjustmentAmount = 50,
            ClaimCoverageId = testClaimCoverage.Id
        );

        insert new List<ClaimCovReserveAdjustment>{ adjEndosoRetro, adjDisminucion, adjLiberacion, adjElse };

        ClaimCovReserveAdjustment adjDuplicate = new ClaimCovReserveAdjustment(
            Name = 'Adj Duplicate',
            ClaimCoverageReserveDetailId = detailEndosoRetro.Id,
            Adjustment_Type__c = 'Endoso retroactivo',
            AdjustmentAmount = 25,
            ClaimCoverageId = testClaimCoverage.Id
        );
        insert adjDuplicate;

        ClaimCovReserveAdjustment adjStatusBlocked = new ClaimCovReserveAdjustment(
            Name = 'Adj Status Blocked',
            ClaimCoverageReserveDetailId = detailDisminucion.Id, 
            Adjustment_Type__c = 'Disminución',
            AdjustmentAmount = 10,
            ClaimCoverageId = testClaimCoverage.Id
        );
        insert adjStatusBlocked;
    }

    @isTest
    static void testUpdateClaimCovReserve() {
        List<ClaimCovReserveAdjustment> allAdjustments = [
            SELECT Id, ClaimCoverageReserveDetailId, Adjustment_Type__c, AdjustmentAmount
            FROM ClaimCovReserveAdjustment
        ];
        
        Test.startTest();
        ClaimCovReserveAdjustmentHelper.updateClaimCovReserve(allAdjustments);
        Test.stopTest();
    }

    @isTest
    static void testRestoreClaimCovergeReserveToDefaulValues() {
        List<ClaimCovReserveAdjustment> someAdjustments = [
            SELECT Id, ClaimCoverageReserveDetailId
            FROM ClaimCovReserveAdjustment
            LIMIT 2
        ];

        Test.startTest();
        ClaimCovReserveAdjustmentHelper.restoreClaimCovergeReserveToDefaulValues(someAdjustments);
        Test.stopTest();
    }

    @isTest
    static void testValidateRecordExistence() {
        ClaimCovReserveAdjustment detailToCheck = [SELECT Id, ClaimCoverageReserveDetailId FROM ClaimCovReserveAdjustment LIMIT 1];
        ClaimCovReserveAdjustment dupCheck = new ClaimCovReserveAdjustment(
            ClaimCoverageReserveDetailId = detailToCheck.ClaimCoverageReserveDetailId,
            Adjustment_Type__c = 'Endoso retroactivo',
            AdjustmentAmount = 10
        );

        List<ClaimCovReserveAdjustment> newRecords = new List<ClaimCovReserveAdjustment>{dupCheck};
        
        Test.startTest();
        ClaimCovReserveAdjustmentHelper.validateRecordExistence(newRecords);
        Test.stopTest();
    }

    @isTest
    static void testValidateReserveStatusToUpdate() {
        ClaimCovReserveAdjustment blockedAdj = [SELECT Id, ClaimCoverageReserveDetailId FROM ClaimCovReserveAdjustment WHERE Name = 'Adj Status Blocked' LIMIT 1];
        List<ClaimCovReserveAdjustment> newRecords = new List<ClaimCovReserveAdjustment>{blockedAdj};

        Test.startTest();
        ClaimCovReserveAdjustmentHelper.validateReserveStatusToUpdate(newRecords);
        Test.stopTest();
    }

    @isTest
    static void testValidateStateOfReserveBeforeDelete() {
        ClaimCovReserveAdjustment blockedAdj = [SELECT Id, ClaimCoverageReserveDetailId FROM ClaimCovReserveAdjustment WHERE Name = 'Adj Status Blocked' LIMIT 1];
        List<ClaimCovReserveAdjustment> oldRecords = new List<ClaimCovReserveAdjustment>{blockedAdj};

        Test.startTest();
        ClaimCovReserveAdjustmentHelper.validateStateOfReserveBeforeDelete(oldRecords);
        Test.stopTest();
    }

    @isTest
    static void testNoReservFoundScenario() {
        ClaimCovReserveAdjustment nonExistentAdj = new ClaimCovReserveAdjustment(
            Name = 'Non Existent Reserv',
            ClaimCoverageReserveDetailId = Id.valueOf('001000000000000AAA'), 
            Adjustment_Type__c = 'Endoso retroactivo',
            AdjustmentAmount = 50
        );
        
        Test.startTest();
        ClaimCovReserveAdjustmentHelper.updateClaimCovReserve(new List<ClaimCovReserveAdjustment>{nonExistentAdj});
        Test.stopTest();
    }
}