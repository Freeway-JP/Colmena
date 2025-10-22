global with sharing class getVersionsUploaded implements Callable {

    public Object call(String action, Map<String, Object> args) {

        Map<String, Object> input = (Map<String, Object>)args.get('input');
        Map<String, Object> output = (Map<String, Object>)args.get('output');
        Map<String, Object> options = (Map<String, Object>)args.get('options');
		System.debug(args);
        //return invokeMethod(action, input, output, options);
        // Validar si el método existe
        if (action == 'getVersions') {
            return invokeMethod(action, input, output, options);
        } else {
            // Si el método no es válido, devolver null
            System.debug('Método no válido: ' + action);
            return null;
        }
    }

    global Boolean invokeMethod(String methodName, Map<String, Object> inputs, Map<String, Object> output, Map<String, Object> options)
    {
        if ( methodName == 'getVersions') {
            List<Object> arguments = (List<Object>)inputs.get('arguments');
            output.put('result', toUpperCaseFormatting(arguments));
        } 
        return true;
    }
     
    

    public List<Object> toUpperCaseFormatting(List<Object> arguments)
	{
            List<Object> result = new List<Object>();
            Map<String, DocumentTypeMapping__mdt> documentsReqMap = new Map<String, DocumentTypeMapping__mdt>();
            List<DocumentTypeMapping__mdt> documentsReq = [SELECT developername, id, label, clasificacionmapping__r.developername, validityDays__c, Description__c 
                FROM DocumentTypeMapping__mdt 
                WHERE ClasificacionMapping__r.DeveloperName = 'QuotingLife'];

            String accountId = (String)arguments[0];
            List<String> documentsName = new List<String>();
            for (DocumentTypeMapping__mdt doc : documentsReq) {
                documentsReqMap.put(doc.DeveloperNAme, doc);
            }
            List<ContentDocumentLink> contentdocuments = [SELECT Id, ContentDocument.LatestPublishedVersion.StatusCheck__c,
                    ContentDocument.LatestPublishedVersion.DocumentTypeQuoting__c, 
                    ContentDocument.Title,ContentDocumentId,
                    ContentDocument.LatestPublishedVersionId
                FROM ContentDocumentLink 
                WHERE LinkedEntityId =:accountId AND ContentDocument.LatestPublishedVersion.DocumentTypeQuoting__c IN:documentsReqMap.keySet() order by  ContentDocument.CreatedDate desc ];
            System.debug(documentsName);
            System.debug(accountId);

            
            System.debug(documentsReqMap);
        	String contextUser=UserInfo.getUserType();
        	String baseUrl, pathPrefix, comunidadUrl;
        	if ( contextUser == 'PowerPartner') {
            	//ENLACE COMUNIDAD
            	 baseUrl = Site.getDomain();       // Devuelve el dominio de la comunidad (e.g. https://miempresa--uat.sandbox.my.site.com)
				 pathPrefix = Site.getPathPrefix(); // Devuelve el path de la comunidad (e.g. /miComunidad)
				 baseUrl = baseUrl + pathPrefix +'/contentdocument';
                //comunidadUrl = baseUrl + pathPrefix +'/contentdocument';
				//ACA	
            }else{
                 baseUrl = URL.getOrgDomainUrl().toExternalForm(); //Agregado
            }
        	
            
			            
            for (ContentDocumentLink doc : contentdocuments) {
                Map<String, Object> resultMap = new Map<String, Object>();
                String typeDocument = doc.ContentDocument.LatestPublishedVersion.DocumentTypeQuoting__c;
                String fullUrl = baseUrl + '/' + doc.ContentDocumentId; //Agregado
                //String fullUrl = comunidadUrl + '/' + doc.ContentDocumentId; //Agregado
                if (documentsReqMap.containsKey(typeDocument)) {
                    //resultMap.put('NameDocument', documentsReqMap.get(typeDocument).Label);
                    resultMap.put('NameDocument', documentsReqMap.get(typeDocument).Description__c);
                    resultMap.put('DevNameDocument', typeDocument);
                    resultMap.put('Status', null);
                    resultMap.put('Url', fullUrl);//Agregado
                   
                    
                    resultMap.put('Id', doc.ContentDocumentId);
                    resultMap.put('Id_ContentVersion', doc.ContentDocument.LatestPublishedVersionId);
                    resultMap.put('Title', doc.ContentDocument.Title);
                    resultMap.put('inVerification', doc.ContentDocument.LatestPublishedVersion.StatusCheck__c == 'En Proceso de Verificación');
                    resultMap.put('Status', doc.ContentDocument.LatestPublishedVersion.StatusCheck__c);
                    
                    result.add(resultMap);
                    documentsReqMap.remove(typeDocument);
                }
            }
        	Map<String, Object> resultURL = new Map<String, Object>();
        	resultURL.put('baseUrl', baseUrl);//Agregado
        	result.add(resultURL);
            for (DocumentTypeMapping__mdt doc : documentsReq) {
                if (documentsReqMap.containsKey(doc.developerNAme)) {
                    Map<String, Object> resultMap = new Map<String, Object>();
                    //resultMap.put('NameDocument', doc.Label);
                    resultMap.put('NameDocument', doc.Description__c);
                    resultMap.put('DevNameDocument', doc.developerNAme);
                    
                    resultMap.put('Id', null);
                    resultMap.put('Title', null);
                    resultMap.put('inVerification', null);
                    resultMap.put('Status', null);
                    
                    result.add(resultMap);
                    documentsReqMap.remove(doc.developerNAme);
                }
            }


            return result;
    }
    
}