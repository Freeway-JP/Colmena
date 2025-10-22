/********************************************************************
Apex Class Name	:	CS_ScheduledSyncAuthorizationClaimItems
Version			:	1.0
Created Date	:	17/07/2025
Function 		: 	<>
Test Class		:	CS_ScheduledSyncAuthClaimItemsTest

Modification Log
*--------------------------------------------------------------------
* Developer		     	Date			   	Description
* -------------------------------------------------------------------
* Frank Tovar    	 17/07/2025			Original Version
*********************************************************************/
public with sharing class CS_ScheduledSyncAuthorizationClaimItems implements Schedulable {
    
    private static final String RECORDTYPE_DEVNAME = 'Authorization';

    public void execute(SchedulableContext sc) {
        // Buscar ClaimItems con error
        List<ClaimItem> claimItemsToProcess = [ 
            SELECT Id
            FROM ClaimItem
            WHERE CreationFailAtSendaMedico__c = true
            AND RecordType.DeveloperName = :RECORDTYPE_DEVNAME
        ];
        // Si hay registros, encolar su reintento
        if (!claimItemsToProcess.isEmpty()) {
            for (ClaimItem claimItem : claimItemsToProcess) {
                System.debug(claimItem.Id);
                System.enqueueJob(new CS_QueueSyncAuthorizationClaimItems(claimItem.Id));
            }
        }

    }

}