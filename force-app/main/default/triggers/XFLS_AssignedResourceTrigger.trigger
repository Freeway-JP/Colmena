trigger XFLS_AssignedResourceTrigger on AssignedResource (before insert, after insert, before update, after update) {
    XFLS_AssignedResourceTriggerHandler.handleTrigger(trigger.new,trigger.old,trigger.oldMap,trigger.operationType);
}