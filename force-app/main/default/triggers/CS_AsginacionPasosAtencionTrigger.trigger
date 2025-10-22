trigger CS_AsginacionPasosAtencionTrigger on CS_AsginacionPasosAtencion__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    CS_AsignacionPasosHandlerTrigger.handleTrigger(trigger.new,trigger.old,trigger.oldMap,trigger.operationType);
}