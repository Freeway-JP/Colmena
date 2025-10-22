trigger XFLS_IntegracionDeSoporteDeSesionesTrigge on ContentDocumentLink (after insert, before insert) {
    
    
    /*
     * Descomentar si se requiere impedir el cargue de documentos 
     * despues de que la Sesión se encuentre en estado "Enviada"
     * 
    if(trigger.isBefore && trigger.isInsert){
        Map<Id,String> mapSesionIdStatus = new Map<Id,String>();
        Set<Id> sesionesIds = new Set<Id>();
        List<ServiceAppointment> sesionesList = new List<ServiceAppointment>();
        for(ContentDocumentLink record:  Trigger.new) {
            if(record.LinkedEntityId?.getSObjectType() == ServiceAppointment.sObjectType) {
                sesionesIds.add(record.LinkedEntityId);
            }
        }
        if(sesionesIds.size()>0){
            sesionesList = [Select Id, Status From ServiceAppointment Where Id IN: sesionesIds];
            for(ServiceAppointment sa : sesionesList){
                mapSesionIdStatus.put(sa.Id,sa.Status);
            }
            for(ContentDocumentLink record:  Trigger.new) {
                if(record.LinkedEntityId?.getSObjectType() == ServiceAppointment.sObjectType) {
                    if(mapSesionIdStatus.get(record.LinkedEntityId) == 'Enviada'){
                        record.addError('No se puede agregar Soporte a la Sesión de Trabajo, pues ya está en estado Enviada');
                    }
                }
            }
        }
    }
	*/
    
    if(trigger.isAfter && trigger.isInsert){
        List<Id> IdsCDL = New List<Id>();
        List<XFLS_Soporte_Sesion__c> listSoportes = new List<XFLS_Soporte_Sesion__c>();
        for(ContentDocumentLink record:  Trigger.new) {
            System.debug(record);
            System.debug('trigger cdl '+ record.Id);
            System.debug('trigger cdl '+ record.LinkedEntityId?.getSObjectType());
            System.debug('record.LinkedEntityId '+ record.LinkedEntityId);        
            System.debug('ContentDocument.title '+record.ContentDocument.title);
            if(record.LinkedEntityId?.getSObjectType() == ServiceAppointment.sObjectType) {
                XFLS_Soporte_Sesion__c soporte = new XFLS_Soporte_Sesion__c();
                soporte.XFLS_ContentDocumentLinkId__c = record.Id;
                soporte.XFLS_SesionDeTrabajo__c = record.LinkedEntityId;
                listSoportes.add(soporte);
                IdsCDL.add(record.Id);
                System.debug('objeto cdl sa');
            }
        }
        if(listSoportes.size()>0){
            insert listSoportes;
        }
        if(IdsCDL.size()>0){
            XFLS_IntegracionDeSoporteDeSesionesHandl.ContentDocumentLinkId(IdsCDL);
        }
    }
    
}