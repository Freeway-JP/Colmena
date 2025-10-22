/********************************************************************
Apex Class Name	:	XFLS_WorkOrderTriggerHandler
Version			:	1.0
Created Date	:	16/05/2022
Function 		: 	Trigger del Objeto WorkOrder
Test Class		:	XFLS_WorkOrderTriggerTest   --------

Modification Log
*--------------------------------------------------------------------
* Developer		     	Date			   	Description
* -------------------------------------------------------------------
* Luis Sandoval   	 16/05/2022	        Original Version
*********************************************************************/
trigger XFLS_WorkOrderLineItemTrigger on WorkOrderLineItem (before insert, after insert, before update, after update) {
    XFLS_WorkOrderLineItemTriggerHandler.handleTrigger(trigger.new,trigger.old,trigger.oldMap,trigger.operationType);
}