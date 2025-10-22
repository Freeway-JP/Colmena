trigger CS_CaseTrigger on Case (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    CS_CaseTriggerHandler.handleTrigger(trigger.new,trigger.old,trigger.oldMap,trigger.operationType);
    if(Trigger.isUpdate && Trigger.isAfter){
        CS_CaseTriggerHandler.afterUpdate(Trigger.oldMap, Trigger.newMap);      
    } 
}