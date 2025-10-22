/*****************************************************************************************************************************
 * Apex Class Name	:	CS_CasesCalculateDaysElapsedBatch
 * Version			:	1.0
 * Created Date	    :	30/01/2025
 * Function 		: 	Clase Batch y Schedulable para el calculo de dias transcurridos sobre determinados casos
 * Test Class		:	CS_CasesCalculateDaysElapsedBatch_Test
 *----------------------------------------------------------------------------------------------------------------------------
 *                                                MODIFICATION LOG
 *----------------------------------------------------------------------------------------------------------------------------
 * Developer		        Date			   	Description
 * ---------------------------------------------------------------------------------------------------------------------------
 * Frank Tovar              30/01/2025          Original Version
 *****************************************************************************************************************************/
public with sharing class CS_CasesCalculateDaysElapsedBatch implements Database.Batchable<sObject>, Database.Stateful, Schedulable {

    // Query the custom metadata using SOQL
    private static CaseBatchCalculateDaysElapsed__mdt getConfigBatchMdt() {
        CaseBatchCalculateDaysElapsed__mdt result = [SELECT Id, Query__c, sizeBatch__c FROM CaseBatchCalculateDaysElapsed__mdt WHERE DeveloperName = 'CasesCalculateDaysConfig' LIMIT 1];
        return result;
    }

    private String queryForTesting = 'SELECT Id, CreatedDate, CS_DiasTranscurridos__c FROM Case WHERE Status NOT IN (\'Cerrado Atendido\', \'Cerrado Inactivo\') LIMIT 50';

    /* --------------------
     * Batchable
     --------------------*/

    private Integer recordsProcessed = 0;
    private Integer failureCount = 0;

    public Database.QueryLocator start(Database.BatchableContext context) {
        CaseBatchCalculateDaysElapsed__mdt configMtdBatch = getConfigBatchMdt();
        if(Test.isRunningTest()){ return Database.getQueryLocator(this.queryForTesting); }
        return Database.getQueryLocator(configMtdBatch.Query__c);
    }

    public void execute(Database.BatchableContext bc, List<Case> scope){

        List<Case> listOpenCasesUpdate = new List<Case>();
        Date today = Datetime.now().dateGMT();

        try{
                        
            for (Case caseOpen : scope) {
                caseOpen.Id = caseOpen.Id;
                caseOpen.CS_DiasTranscurridos__c = CS_Utilities.getWorkingDaysBetweenDates(caseOpen.CreatedDate.date(), today);
                listOpenCasesUpdate.add(caseOpen);
                recordsProcessed++;
            }

            List<Database.SaveResult> saveResults = Database.update(listOpenCasesUpdate, false); // Update records with partial success allowed

            for(Database.SaveResult sr : saveResults) {
                if (!sr.isSuccess()) {
                    // Handle individual record errors
                    for(Database.Error error : sr.getErrors()) {
                        // Log or take necessary action for the error
                        System.debug('Error occurred for record with Id: ' + sr.getId() + ', Error Message: ' + error.getMessage());
                    }
                }
            }
            
        }catch(Exception ex){
            System.debug('Exception Catch: ' + ex.getMessage());
            failureCount++;
        }
        
    }

    public void finish(Database.BatchableContext bc){
        String message = 'CS_CalculateDaysElapsedBatch Apex Job has completed = Total Success Count: ' + recordsProcessed + ' | Total Failure Count: ' + failureCount;
        System.debug(message);
    }

    /* --------------------
     * Schedulable
     --------------------*/

    public void execute(SchedulableContext ctx) {
        CaseBatchCalculateDaysElapsed__mdt configMtdBatch = getConfigBatchMdt();
        Database.executeBatch(new CS_CasesCalculateDaysElapsedBatch(), Integer.valueOf(configMtdBatch.sizeBatch__c));
    }

}