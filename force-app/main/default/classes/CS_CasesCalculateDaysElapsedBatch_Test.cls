/*****************************************************************************************************************************
 * Apex Class Name	:	CS_CasesCalculateDaysElapsedBatch_Test
 * Version			:	1.0
 * Created Date	    :	30/01/2025
 * Function 		: 	Clase Test para la Clase Apex que realiza el calculo de dias transcurridos sobre determinados casos
 * Class	    	:	CS_CasesCalculateDaysElapsedBatch
 *----------------------------------------------------------------------------------------------------------------------------
 *                                                MODIFICATION LOG
 *----------------------------------------------------------------------------------------------------------------------------
 * Developer		        Date			   	Description
 * ---------------------------------------------------------------------------------------------------------------------------
 * Frank Tovar              30/01/2025          Original Version
 *****************************************************************************************************************************/
@isTest
public with sharing class CS_CasesCalculateDaysElapsedBatch_Test {
    
    @isTest
    static void testBatchExecution() {
        List<Case> testCases = new List<Case>();
        Product2 testExistingProduct = new Product2(StockKeepingUnit='001',Name='Fake Name',CS_Entidad_Producto__c='2',IsActive=true);
        insert testExistingProduct;
        Integer sizeBatch = 50;
        for (Integer i = 0; i < sizeBatch; i++) {
            testCases.add(new Case(
                Subject = 'Test Case ' + i,
                Status = 'Abierto',
                CS_Pais__c = '170',
                CS_Departamento__c = '15',
                CS_Municipio__c = '15469',
                CS_Subtipo__c = '2',
                ProductId = testExistingProduct.Id
            ));
        }
        insert testCases;
        Test.startTest();
        CS_CasesCalculateDaysElapsedBatch batchJob = new CS_CasesCalculateDaysElapsedBatch();
        Database.executeBatch(batchJob, sizeBatch);
        Test.stopTest();
    }

    @isTest
    static void testSchedulableExecute() {        
        Test.startTest();
        String CRON_EXP = '0 6 * * * ?';
        String jobId = System.schedule('Test Scheduled Job.', CRON_EXP, new CS_CasesCalculateDaysElapsedBatch());
        Test.stopTest();
    }

}