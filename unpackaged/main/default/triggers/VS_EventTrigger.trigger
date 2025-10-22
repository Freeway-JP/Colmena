trigger VS_EventTrigger on Event (after insert, after update, before insert, before update) {
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            VS_EventTriggerHandler.afterInsert(Trigger.new);
        }
        if (Trigger.isUpdate) {
            VS_EventTriggerHandler.afterUpdate(Trigger.old, Trigger.new);
        }
    }else if (Trigger.isBefore) {
        /*if (Trigger.isInsert) {
            VS_EventTriggerHandler.beforeInsert(Trigger.new);
        }*/
        if (Trigger.isUpdate) {
            VS_EventTriggerHandler.beforeUpdate(Trigger.old, Trigger.new);
        }
    }
}