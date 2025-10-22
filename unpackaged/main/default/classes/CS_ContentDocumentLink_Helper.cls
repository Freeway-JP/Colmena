/**
 * @description       :
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             :
 * @last modified on  : 07-29-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 **/
public with sharing class CS_ContentDocumentLink_Helper {
    private static Integer emailMessageCounter = 0;
    
	public static void reparentCaseContentDocumentLinks(Set<Id> contentDocumentIdSet, List<ContentDocumentLink> contentDocumentLinkList) {
        System.debug('--------------  CS_ContentDocumentLink_Helper.reparentCaseContentDocumentLinks  --------------');
        System.debug(
            '1.1 CS_ContentDocumentLink_Helper.reparentCaseContentDocumentLinks contentDocumentLinkList.size(): ' +
            contentDocumentLinkList.size()
        );
        System.debug(
            '1.1 CS_ContentDocumentLink_Helper.reparentCaseContentDocumentLinks contentDocumentLinkList.size(): ' +
            contentDocumentIdSet
        );
        System.debug(
            '1.2 CS_ContentDocumentLink_Helper.reparentCaseContentDocumentLinks contentDocumentLinkList: ' + contentDocumentLinkList
        );
        Map<Id, ContentDocument> contentDocumentMap = new Map<Id, ContentDocument>();
        if(contentDocumentLinkList.size() > 0){
            System.debug(
                'Consulta ContentDocument 1' + contentDocumentIdSet
            );
            contentDocumentMap = new Map<Id, ContentDocument>(            
                [SELECT Id, Title, FileType FROM ContentDocument WHERE Id IN :contentDocumentIdSet]
            );
        }
    
        List<CS_DocumentoCaso__c> newDocumentoCasoList = new List<CS_DocumentoCaso__c>();
        Set<ContentDocumentLink> newContentDocumentLinkSet = new Set<ContentDocumentLink>();
        for (ContentDocumentLink contDocLink : contentDocumentLinkList) {
            ContentDocument currentContentDocument = contentDocumentMap.get(contDocLink.ContentDocumentId);
            CS_DocumentoCaso__c newDocumentoCaso = CS_DocumentoCaso_Helper.createDocumentoCaso(
                contDocLink.LinkedEntityId,
                currentContentDocument.Title,
                CS_DocumentoCaso_Helper.MomentosEnvio.NUNCA,
                false
            );
            if(currentContentDocument.FileType != 'SNOTE'){
                newDocumentoCasoList.add(newDocumentoCaso);
            }            
        }
    
        Database.SaveResult[] srList = Database.insert(newDocumentoCasoList, false);
    
        for (Integer i = 0; i < srList.size(); i++) {
            Database.SaveResult sr = srList.get(i);
            if (sr.isSuccess()) {
                ContentDocumentLink currentContentDocumentLink = contentDocumentLinkList.get(i);
                ContentDocumentLink newContentDocumentLink = new ContentDocumentLink();
                newContentDocumentLink.LinkedEntityId = sr.getId();
                newContentDocumentLink.ContentDocumentId = currentContentDocumentLink.ContentDocumentId;
                newContentDocumentLink.ShareType = currentContentDocumentLink.ShareType;
                newContentDocumentLinkSet.add(newContentDocumentLink);
            }
        }
    
        List<ContentDocumentLink> newContentDocumentLinkList = new List<ContentDocumentLink>(newContentDocumentLinkSet);
        if (!newContentDocumentLinkList.isEmpty()) {
            Database.SaveResult[] cdlSrList = Database.insert(newContentDocumentLinkList, false);
        }
    }

	public static void addNewLinkEmailContentDocumentLinks(
		Set<Id> contentDocumentIdSet,
		List<ContentDocumentLink> contentDocumentLinkList,
		Set<Id> contentDocumentLinkedEntityIdSet
	) {
		System.debug('--------------  CS_ContentDocumentLink_Helper.addNewLinkEmailContentDocumentLinks  --------------');
		System.debug(
			'1.1 CS_ContentDocumentLink_Helper.addNewLinkEmailContentDocumentLinks contentDocumentLinkList.size(): ' +
			contentDocumentLinkList.size()
		);
        Map<Id, ContentDocument> contentDocumentMap = new Map<Id, ContentDocument>();
        if(contentDocumentIdSet.size() > 0){
            System.debug(
			'Consulta ContentDocument 2' + contentDocumentIdSet + contentDocumentIdSet.size()
			);
			contentDocumentMap = new Map<Id, ContentDocument>(               
				[SELECT Id, Title FROM ContentDocument WHERE Id IN :contentDocumentIdSet]            
			);
        }
        System.debug(
			'1.3 CS_ContentDocumentLink_Helper.addNewLinkEmailContentDocumentLinks contentDocumentIdSet: ' + contentDocumentIdSet
		);
		Map<Id, EmailMessage> emailMessageMap = new Map<Id, EmailMessage>();
        System.debug('Consulta contador 1' + emailMessageCounter);
		if(contentDocumentLinkedEntityIdSet.size() > 1 || (contentDocumentLinkedEntityIdSet.size() > 0 && emailMessageCounter <= 2)){
		System.debug('Consulta cont doc size' + contentDocumentLinkedEntityIdSet.size());
			emailMessageMap = new Map<Id, EmailMessage>(                
				[SELECT Id, ParentId FROM EmailMessage WHERE Id IN :contentDocumentLinkedEntityIdSet]
			);
		emailMessageCounter++;
			System.debug('Consulta contador 2' + emailMessageCounter);
			System.debug('Obtiene datos del map: ' + emailMessageMap + ' ' + contentDocumentLinkedEntityIdSet.size());
		}   
        System.debug(
			'1.4 CS_ContentDocumentLink_Helper.addNewLinkEmailContentDocumentLinks contentDocumentLinkedEntityIdSet: ' + contentDocumentLinkedEntityIdSet
		);	
        
		List<CS_DocumentoCaso__c> newDocumentoCasoList = new List<CS_DocumentoCaso__c>();        
        Set<ContentDocumentLink> newContentDocumentLinkSet = new Set<ContentDocumentLink>();
        for (ContentDocumentLink contDocLink : contentDocumentLinkList) {
            ContentDocument currentContentDocument = contentDocumentMap.get(contDocLink.ContentDocumentId);
            EmailMessage currentEmailMessage = emailMessageMap.get(contDocLink.LinkedEntityId);
            CS_DocumentoCaso__c newDocumentoCaso = CS_DocumentoCaso_Helper.createDocumentoCaso(
                currentEmailMessage.ParentId,
                currentContentDocument.Title,
                CS_DocumentoCaso_Helper.MomentosEnvio.NUNCA,
                false
            );
            newDocumentoCasoList.add(newDocumentoCaso);
        }

        Database.SaveResult[] srList = Database.insert(newDocumentoCasoList, false);

        for(Integer i = 0; i < srList.size(); i++) {
            Database.SaveResult sr = srList.get(i);
            if (sr.isSuccess()) {
                ContentDocumentLink currentContentDocumentLink = contentDocumentLinkList.get(i);
                ContentDocumentLink newContentDocumentLink = new ContentDocumentLink();
                newContentDocumentLink.LinkedEntityId = sr.getId();
                newContentDocumentLink.ContentDocumentId = currentContentDocumentLink.ContentDocumentId;
                newContentDocumentLink.ShareType = currentContentDocumentLink.ShareType;
                newContentDocumentLinkSet.add(newContentDocumentLink);
            }
        }

        List<ContentDocumentLink> newContentDocumentLinkList = new List<ContentDocumentLink>(newContentDocumentLinkSet);
        System.debug('tamaño documentlist' + newContentDocumentLinkList.size());
        if (!newContentDocumentLinkList.isEmpty()) {
            Database.SaveResult[] cdlSrList = Database.insert(newContentDocumentLinkList, false);
        }
    }
}