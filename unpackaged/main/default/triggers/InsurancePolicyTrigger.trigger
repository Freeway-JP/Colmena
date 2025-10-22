/********************************************************************
Apex Trigger Name:	InsurancePolicyTrigger
Version			:	1.0
Created Date	:	13/09/2023
Function 		: 	Trigger del Service Appointment
Handler Class	:	InsurancePolicyTriggerHandler

Modification Log
*--------------------------------------------------------------------
* Developer		     	Date			   	Description
* -------------------------------------------------------------------
* Alejandro Giraldo   	 13/09/2023       Original Version
*********************************************************************/
trigger InsurancePolicyTrigger on InsurancePolicy ( after insert,  after update) {
	InsurancePolicyTriggerHandler.handleTrigger(trigger.new,trigger.old,trigger.oldMap,trigger.operationType);

}