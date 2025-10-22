trigger XFLS_ServiceReportTrigger on ServiceReport (after insert) {

    if(trigger.isAfter && trigger.isInsert){

        List<Id> contentDocumentIds = new List<Id>();
        List<Id> contentDocumentLinkIds = New List<Id>();
        List<XFLS_Soporte_Sesion__c> listSoportes = new List<XFLS_Soporte_Sesion__c>();
        List<ContentDocumentLink> cdlr = new List<ContentDocumentLink>();

        Set<ID> ids = Trigger.newMap.keySet();
        List<ServiceReport> ServiceReportLst = [SELECT ServiceReportNumber, ContentVersionDocument.ContentDocumentId FROM ServiceReport WHERE id in :ids];
        for (ServiceReport record : ServiceReportLst) {
            System.debug('ContentDocumentId '+record.ContentVersionDocument.ContentDocumentId);
            contentDocumentIds.add(record.ContentVersionDocument.ContentDocumentId);
        }        
        if(contentDocumentIds.size()>0){
            cdlr = [Select Id,LinkedEntityId,ContentDocument.title From ContentDocumentLink Where ContentDocumentId IN: contentDocumentIds];
            System.debug('cdlr '+cdlr);
            if(cdlr.size()>0){
                for(ContentDocumentLink record:  cdlr) {
                    System.debug('trigger cdl '+ record.Id);
                    System.debug('trigger cdl '+ record.LinkedEntityId?.getSObjectType());
                    System.debug('record.LinkedEntityId '+ record.LinkedEntityId);
                    System.debug('ContentDocument.title '+record.ContentDocument.title);
                    if(record.LinkedEntityId?.getSObjectType() == ServiceAppointment.sObjectType) {
                        XFLS_Soporte_Sesion__c soporte = new XFLS_Soporte_Sesion__c();
                        soporte.XFLS_ContentDocumentLinkId__c = record.Id;
                        soporte.XFLS_SesionDeTrabajo__c = record.LinkedEntityId;
                        listSoportes.add(soporte);
                        contentDocumentLinkIds.add(record.Id);
                        System.debug('objeto cdl sa encontrado');
                    }
                }
            }
            if(listSoportes.size()>0){
                insert listSoportes;
            }
            if(contentDocumentLinkIds.size()>0){
                XFLS_ServiceReportTriggerHandler.ContentDocumentLinkId(contentDocumentLinkIds);
            }
        }
    }
}