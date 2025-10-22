/********************************************************************
Apex Class Name	:	XFLS_ServiceAppointmentTrigger
Version			:	1.0
Created Date	:	16/05/2022
Function 		: 	Trigger del Service Appointment
Handler Class	:	XFLS_ServiceAppointmentTriggerHandler

Modification Log
*--------------------------------------------------------------------
* Developer		     	Date			   	Description
* -------------------------------------------------------------------
* José Quevedo   	 16/05/2022	        Original Version
*********************************************************************/
trigger XFLS_ServiceAppointmentTrigger on ServiceAppointment (before insert, after insert, before update, after update) {
	XFLS_ServiceAppointmentTriggerHandler.handleTrigger(trigger.new,trigger.old,trigger.oldMap,trigger.operationType);
}