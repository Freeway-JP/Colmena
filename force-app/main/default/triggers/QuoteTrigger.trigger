trigger QuoteTrigger on Quote (
    after update
) {
    QuoteTriggerHandler handler = new QuoteTriggerHandler(Trigger.isExecuting, Trigger.size);

    switch on Trigger.operationType {
        when AFTER_UPDATE {
            handler.afterUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
        }
    }
}