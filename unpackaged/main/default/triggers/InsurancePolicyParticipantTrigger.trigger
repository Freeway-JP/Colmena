/********************************************************************
Apex Trigger Name:	InsurancePolicyParticipantTrigger
Version			:	1.0
Created Date	:	20/09/2023
Function 		: 	Trigger del Service Appointment
Handler Class	:	InsurancePolicyParticipantTriggerHandler

Modification Log
*--------------------------------------------------------------------
* Developer		     	Date			   	Description
* -------------------------------------------------------------------
* Alejandro Giraldo   	 20/09/2023       Original Version
*********************************************************************/
trigger InsurancePolicyParticipantTrigger on InsurancePolicyParticipant (after insert,  after update) {
InsurancePolicyParticipantTriggerHandler.handleTrigger(trigger.new,trigger.old,trigger.oldMap,trigger.operationType);
}