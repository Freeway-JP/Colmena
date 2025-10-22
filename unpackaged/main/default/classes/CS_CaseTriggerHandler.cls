/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-10-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class CS_CaseTriggerHandler {
    
    public static  void handleTrigger(List<Case> TriggerNew, List<Case> TriggerOld,
                                      Map<Id, Case> TriggerOldMap, System.TriggerOperation triggerEvent){
       System.debug('=======este es el trigger event================'+triggerEvent);                                
       switch on triggerEvent{
           when AFTER_UPDATE{
              after(TriggerNew);
           }  
           when AFTER_INSERT{
              after(TriggerNew);
           }
           when BEFORE_INSERT{
            beforeInsert(TriggerNew);
         }  
         when BEFORE_UPDATE{
            beforeUpdate(TriggerNew,TriggerOld);
         }           
       }           
    }
    public static void beforeInsert(List<Case> TriggerNew) {
    System.debug('=======entra a before Insert================');
    
    // Variables para almacenar los IDs de los Entitlements
    String consultaEntiId = null;
    String solicitudEntiId = null;
    
        if (!Test.isRunningTest()) {
            // Consulta para Entitlements con "consulta"
            List<Entitlement> consultaEntitlementList = [
                SELECT Id 
                FROM Entitlement 
                WHERE Name LIKE '%consulta%' 
                LIMIT 1
            ];
    	
            if (!consultaEntitlementList.isEmpty()) {
                consultaEntiId = consultaEntitlementList[0].Id;
            }
            
            // Consulta para Entitlements con "solicitud"
            List<Entitlement> solicitudEntitlementList = [
                SELECT Id 
                FROM Entitlement 
                WHERE Name LIKE '%solicitud%' 
                LIMIT 1
            ];
            
            if (!solicitudEntitlementList.isEmpty()) {
                solicitudEntiId = solicitudEntitlementList[0].Id;
            }
            
        }
    
        // Iterar sobre los casos y asignar el Entitlement correspondiente
        for (Case caso : TriggerNew) {
            if ((consultaEntiId != null) && caso.RecordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Consulta').getRecordTypeId()) {
                caso.EntitlementId = consultaEntiId;
            } else if ((solicitudEntiId != null) && caso.RecordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CS_Solicitud').getRecordTypeId()) {
                caso.EntitlementId = solicitudEntiId;
            }
        }
    }
    
    public static void beforeUpdate(List<Case> TriggerNew, List<Case> TriggerOld) {
    System.debug('=======entra a before update================');
    Integer bandera = 0;

        for (Case caso : TriggerNew) {
        System.debug(caso.RecordTypeId);
        System.debug(caso.Status);
        
        // Obtener el RecordTypeId anterior del caso para comparar con el actual
        String oldRecordTypeId = TriggerOld[bandera].RecordTypeId;
        
        // Lógica para casos de tipo 'Consulta' o 'CS_Buzon' cerrados
            if (
                (caso.RecordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Consulta').getRecordTypeId() ||
                 caso.RecordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CS_Solicitud').getRecordTypeId() ||
                 caso.RecordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CS_Buzon').getRecordTypeId()) 
                 && (caso.Status == 'Cerrado Atendido' || caso.Status == 'Cerrado Inactivo')
            ) {
                CS_Utilities.completeIndependentMilestone(caso.Id, System.now(), TriggerOld[bandera].Status);
            }
            
            // Lógica para cuando el caso cambia de tipo 'CS_Buzon' a otro tipo de registro
            if (
                oldRecordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CS_Buzon').getRecordTypeId() && 
                caso.RecordTypeId != oldRecordTypeId
            ) {
                // Completar el hito cuando el tipo de registro cambia de 'CS_Buzon' a otro tipo
                CS_Utilities.completeIndependentMilestone(caso.Id, System.now(), TriggerOld[bandera].Status);
            }
                bandera = bandera + 1;
        }
    }
    
    public static void after(List<Case> TriggerNew){
        Set<Id> idsCasos = new Set<Id>();
        Set<String> subtipos = new Set<String>();
        Set<String> motivos = new Set<String>();
        Set<String> submotivos = new Set<String>();
        Set<String> tipos = new Set<String>();
        List<Case> casosAAsignar = new List<Case>();
        Set<Id> idsRecordType= new Set<Id>();
        Map<Id, String> mapeoRecType= new Map<Id, String> ();
        for(Case caso : TriggerNew){
            System.debug('dentro 1');
            if(caso.CS_Subtipo__c != null && 
               caso.CS_MacroMotivo__c != null && caso.CS_Submotivo__c != null && 
               caso.Status != 'Cerrado Atendido' && caso.Status != 'Cerrado Inactivo' 
               ){
                idsCasos.add(caso.Id);
                subtipos.add(caso.CS_Subtipo__c);
                motivos.add(caso.CS_MacroMotivo__c);
                submotivos.add(caso.CS_Submotivo__c);
                casosAAsignar.add(caso);
                idsRecordType.add(caso.RecordTypeId);

            }
        }
       
        if(idsCasos.size()>0){
            list<CS_AsginacionPasosAtencion__c> listAsignacionRelated = [Select Id,CS_CasoRelacionado__c
                                                            From CS_AsginacionPasosAtencion__c
                                                            Where CS_CasoRelacionado__c IN:idsCasos
                                                            ];
            if(listAsignacionRelated.size()>0){
                for(CS_AsginacionPasosAtencion__c asignacion :listAsignacionRelated){
                    if(idsCasos.contains(asignacion.CS_CasoRelacionado__c)){
                        idsCasos.remove(asignacion.CS_CasoRelacionado__c);
                    }
                }
            }
        }
        
        if(idsCasos.size()>0){
            
        List<RecordType> recTypeLst=[SELECT Id, DeveloperName FROM RecordType WHERE ID IN :idsRecordType];
        for(RecordType recType:recTypeLst){
            tipos.add(recType.DeveloperName);
            mapeoRecType.put(recType.Id,recType.DeveloperName);
        }
            
        List<CS_ProcesoAtencion__c> listProcesos = [Select Id,Name,
                                                    CS_Subtipo__c,CS_Submotivo__c,CS_MacroMotivo__c,
                                                    CS_TiempoGlobalAtencion__c
                                                    From CS_ProcesoAtencion__c
                                                    Where CS_Subtipo__c IN: subtipos AND
                                                    CS_Submotivo__c IN: submotivos AND
                                                    CS_MacroMotivo__c IN:motivos AND
                                                    CS_Tipo_de_caso__c IN:tipos];

            if(listProcesos.size()>0){
                List<CS_PasosAtencion__c> listPasos = [Select Id, Name,CS_Tiempoatencion__c,
                                                        CS_ProcesoAtencion__c,
                                                        CS_ProcesoAtencion__r.Name,
                                                        CS_ProcesoAtencion__r.CS_Subtipo__c,
                                                        CS_ProcesoAtencion__r.CS_Submotivo__c,
                                                        CS_ProcesoAtencion__r.CS_MacroMotivo__c,
                                                        CS_ProcesoAtencion__r.CS_TiempoGlobalAtencion__c,
                                                        CS_ProcesoAtencion__r.CS_Tipo_de_caso__c
                                                        From CS_PasosAtencion__c
                                                        Where CS_ProcesoAtencion__c IN: listProcesos];

                if(listPasos.size()>0){
                    list<CS_AsginacionPasosAtencion__c> listAsignacion = new List<CS_AsginacionPasosAtencion__c>();
                    Boolean primero = false;
                    String nombre;
                    for(Case caso : casosAAsignar){
                        
                        if( idsCasos.contains(caso.Id) ){
                            	for(CS_PasosAtencion__c paso: listPasos){
                           
                            if(mapeoRecType.get(caso.RecordTypeId)==paso.CS_ProcesoAtencion__r.CS_Tipo_de_caso__c &&
                               caso.CS_Subtipo__c == paso.CS_ProcesoAtencion__r.CS_Subtipo__c &&
                               caso.CS_MacroMotivo__c == paso.CS_ProcesoAtencion__r.CS_MacroMotivo__c &&
                               caso.CS_Submotivo__c == paso.CS_ProcesoAtencion__r.CS_Submotivo__c && primero == false ){
                                nombre = paso.Name ; 
                                   
                                if(Integer.valueOf(nombre.mid(5,1)) == 1){
                                    
                                    primero = true;
                                    CS_AsginacionPasosAtencion__c asignacion = new CS_AsginacionPasosAtencion__c();
                                    asignacion.CS_CasoRelacionado__c = caso.Id;
                                    asignacion.CS_Estado__c = 'Iniciado';
                                    asignacion.CS_ProcesoAtencion__c = paso.CS_ProcesoAtencion__c;
                                    asignacion.CS_PasoAtencionId__c = paso.Id;
                                    asignacion.CS_AsignacionFlujoSecundario__c = false;
                                    asignacion.Name = paso.Name;//paso.CS_ProcesoAtencion__r.Name + '-' +paso.Name;
                                    asignacion.CS_Es_un_paso_de_atencion_adicional__c = false;
                                    asignacion.CS_Tiempo_de_AtencionN__c = paso.CS_Tiempoatencion__c;
                                    asignacion.CS_TiempoGlobalDeAtencionN__c = paso.CS_ProcesoAtencion__r.CS_TiempoGlobalAtencion__c;
                                    listAsignacion.add(asignacion);
                                }
                            }
                        }
                        primero = false;
                        }
                        
                    }
                    if(listAsignacion.size()>0){

                        insert listAsignacion;
                    }                    
                }
            }
        }
    }
    // Nuevo método para manejar la lógica al actualizar casos
	public static void afterUpdate(Map<Id, Case> oldCases, Map<Id, Case> newCases) {
        Set<Id> updatedCaseIdSet = new Set<Id>();
        Set<Id> newRecordTypeIds = new Set<Id>();
        Set<Id> emailMessageParentIds = new Set<Id>();

        for (Case newCase : newCases.values()) {
        newRecordTypeIds.add(newCase.RecordTypeId);
    } 

    // Consultar RecordTypes
    Map<Id, RecordType> recordTypeMap = new Map<Id, RecordType>(
        [SELECT Id, DeveloperName FROM RecordType WHERE Id IN :newRecordTypeIds]
    );

    // Recolectar casos que cambiaron su RecordTypeId
    for (Id caseId : newCases.keySet()) {
        Case oldCase = oldCases.get(caseId);
        Case newCase = newCases.get(caseId);

        if (oldCase.RecordTypeId != newCase.RecordTypeId) {
            RecordType newRecordType = recordTypeMap.get(newCase.RecordTypeId);
            if (newRecordType != null && newRecordType.DeveloperName == 'CS_Queja') {
                updatedCaseIdSet.add(caseId);
            }
        }
    }

    // Consultar EmailMessages si hay casos actualizados
    if (!updatedCaseIdSet.isEmpty()) {
        List<EmailMessage> emailMessages = [
            SELECT Id, ParentId
            FROM EmailMessage
            WHERE ParentId IN :updatedCaseIdSet
        ];

        for (EmailMessage emailMessage : emailMessages) {
            emailMessageParentIds.add(emailMessage.Id);
        }
    }

    // Consultar ContentDocumentLinks para casos actualizados
    if (!updatedCaseIdSet.isEmpty()) {
        List<ContentDocumentLink> contentDocumentLinks = [
            SELECT Id, LinkedEntityId, ContentDocumentId, ShareType
            FROM ContentDocumentLink
            WHERE LinkedEntityId IN :updatedCaseIdSet
        ];

        if (!contentDocumentLinks.isEmpty()) {
            Set<Id> contentDocumentIdSet = new Set<Id>();
            for (ContentDocumentLink cdl : contentDocumentLinks) {
                contentDocumentIdSet.add(cdl.ContentDocumentId);
            }
            CS_ContentDocumentLink_Helper.reparentCaseContentDocumentLinks(contentDocumentIdSet, contentDocumentLinks);
        }
    }

    // Consultar ContentDocumentLinks para EmailMessages si hay IDs
    if (!emailMessageParentIds.isEmpty()) {
        List<ContentDocumentLink> emailContentDocumentLinks = [
            SELECT Id, LinkedEntityId, ContentDocumentId, ShareType
            FROM ContentDocumentLink
            WHERE LinkedEntityId IN :emailMessageParentIds
        ];

        if (!emailContentDocumentLinks.isEmpty()) {
            Set<Id> emailContentDocumentIdSet = new Set<Id>();
            Set<Id> contDocLinEntIdSet = new Set<Id>();
            for (ContentDocumentLink emailm : emailContentDocumentLinks) {
                emailContentDocumentIdSet.add(emailm.ContentDocumentId);
                contDocLinEntIdSet.add(emailm.LinkedEntityId); 
            }
                CS_ContentDocumentLink_Helper.addNewLinkEmailContentDocumentLinks(emailContentDocumentIdSet, emailContentDocumentLinks, contDocLinEntIdSet);
                //CS_ContentDocumentLink_Helper.addNewLinkEmailContentDocumentLinks(emailMContentDocIdSet,emailMContentDocLinkList,contDocLinEntIdSet);
            }
        }
    }
}