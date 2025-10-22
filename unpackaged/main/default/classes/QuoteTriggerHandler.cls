public without sharing class QuoteTriggerHandler {
    private Boolean triggerIsExecuting;
    private Integer triggerSize;
    public QuoteTriggerHelper helper;

    public QuoteTriggerHandler(Boolean triggerIsExecuting, Integer triggerSize) {
        this.triggerIsExecuting = triggerIsExecuting;
        this.triggerSize = triggerSize;
        this.helper = new QuoteTriggerHelper();
    }

    public void afterUpdate(List<SObject> oldRecords, List<SObject> newRecords, Map<ID, SObject> oldMap, Map<ID, SObject> newMap) {
        helper.updateQuoteFields((List<Quote>) newRecords);
    }
}