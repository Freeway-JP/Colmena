/**
 * @description       :
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             :
 * @last modified on  : 07-29-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 **/
public with sharing class CS_ContentDocumentLinkTrigger_Handler {
    private static Integer emailMessageCounter = 0;
	public static void beforeInsert(List<ContentDocumentLink> newContentDocumentLinkList) {
		System.debug('--------------  CS_ContentDocumentLinkTrigger_Handler.beforeInsert  --------------');
		List<ContentDocumentLink> caseContentDocumentLinkList = new List<ContentDocumentLink>();
		List<ContentDocumentLink> emailMessageContentDocumentLinkList = new List<ContentDocumentLink>();
		Set<Id> caseContentDocumentIdSet = new Set<Id>(); 
		Set<Id> emailMessageContentDocumentIdSet = new Set<Id>();
        Set<Id> contentDocumentLinkedEntityIdSet = new Set<Id>();
        Set<Id> emailMessageIdSet = new Set<Id>();
        Set<Id> caseIdSet = new Set<Id>();
        
		for (ContentDocumentLink newContentDocumentLink : newContentDocumentLinkList) {
            newContentDocumentLink.Visibility='AllUsers';
			System.debug('2. CS_ContentDocumentLinkTrigger_Handler.beforeInsert newContentDocumentLink.ParentId: ' +newContentDocumentLink.LinkedEntityId);
			if (newContentDocumentLink.LinkedEntityId != null) {
                contentDocumentLinkedEntityIdSet.add(newContentDocumentLink.LinkedEntityId);
				Schema.DescribeSObjectResult parentObjectType = newContentDocumentLink.LinkedEntityId.getSobjectType().getDescribe();
				if (parentObjectType == Schema.SObjectType.Case) {
                    caseIdSet.add(newContentDocumentLink.LinkedEntityId);
					caseContentDocumentLinkList.add(newContentDocumentLink);
					caseContentDocumentIdSet.add(newContentDocumentLink.ContentDocumentId);
				} else if (parentObjectType == Schema.SObjectType.emailMessage) {
                    // Incrementar el contador cuando se ingresa a la declaración else if
                    emailMessageContentDocumentLinkList.add(newContentDocumentLink);
                    emailMessageContentDocumentIdSet.add(newContentDocumentLink.ContentDocumentId);
                    emailMessageIdSet.add(newContentDocumentLink.LinkedEntityId);
				}                
			}            
		}
		// Consulta para obtener los EmailMessages y sus casos relacionados
		Map<Id, Case> cases = new Map<Id, Case>();         
		if(caseIdSet.size() > 0){
			cases = new Map<Id, Case>(
            [SELECT Id, RecordType.DeveloperName
            FROM Case
            WHERE Id IN :caseIdSet]
            );
		}
        
        Map<Id, EmailMessage> emailMessages = new Map<Id, EmailMessage>();
        if(emailMessageIdSet.size() > 0){
        	emailMessages = new Map<Id, EmailMessage>(
            [SELECT Id, ParentId, Parent.CaseNumber, Parent.RecordType.DeveloperName
             FROM EmailMessage
             WHERE Id IN :emailMessageIdSet AND ParentId !=null]
        	);
        } 
                
        // Filtrar los ContentDocumentLinks basados en el tipo de registro del caso relacionado
		for (ContentDocumentLink cdl : emailMessageContentDocumentLinkList) {
            EmailMessage emailMessage = emailMessages.get(cdl.LinkedEntityId);
            if (emailMessage != null && emailMessage.Parent != null) {
                // Reemplaza 'RecordTypeId1' con el Id del RecordType que deseas validar
                if (emailMessage.Parent.RecordType.DeveloperName == 'CS_Queja' || emailMessage.Parent.RecordType.DeveloperName == 'CS_Queja_Superintendencia') {
                    // Incrementar el contador cuando se ingresa a la declaración else if con tipo de registro específico
                    emailMessageCounter++;
                }
            }
		}
        
        for (ContentDocumentLink cdl : caseContentDocumentLinkList) {
            Case caseRecord = cases.get(cdl.LinkedEntityId);
            System.debug('Validación del tipo de registro del caso: ' + caseRecord);
            if (caseRecord != null) {
                // Reemplaza 'RecordTypeId1' y 'RecordTypeId2' con los Ids de los RecordTypes que deseas validar
                if (caseRecord.RecordType.DeveloperName == 'CS_Queja' || caseRecord.RecordType.DeveloperName == 'CS_Queja_Superintendencia') {
                    // Incrementar el contador cuando se ingresa al if con tipos de registro específicos
                    emailMessageCounter++;
                }
            }
        }
        
        if (emailMessageCounter != 0 && emailMessageCounter <= 30) {
        	CS_ContentDocumentLink_Helper.reparentCaseContentDocumentLinks(caseContentDocumentIdSet, caseContentDocumentLinkList);
			CS_ContentDocumentLink_Helper.addNewLinkEmailContentDocumentLinks(
				emailMessageContentDocumentIdSet,
				emailMessageContentDocumentLinkList,
                contentDocumentLinkedEntityIdSet       
			);
        }
	}
}