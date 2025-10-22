/**
 * @author Harold Garcia Vargas
 * @email harold.garcia@vasscompany.com
 * @create date 2024-07-19 16:44:17
 * @modify date 2024-07-19 17:04:25
 * @desc [Esta es una Clase invocable que consume el servicio de VS_WSGeneralExperienceService,
*         Recibe un Id de Contrato y lo procesa para consultar si tiene lista restrictiva.
*         y la información la almacena en 3 campos personalizados de Contrato]
 */

public with sharing class RestrictiveListsContracts {
    @InvocableMethod(label='Procesar String para Contract')
    public static void processStringForContracts(List<String> inputStrings) {
         String inputString = inputStrings[0];
         system.debug('@1  ' + inputString);
            
         Call_VS_WSGeneralExperienceService(inputString);
    }
     @future(callout=true)
    public static void Call_VS_WSGeneralExperienceService(string contractId) {
        // variable DateTime
        //Datetime  currentDate = Datetime.NOW(); 
        Date currentDate = Date.today();        
        boolean Save =false;
        //Consulta de contracts con ese ID. 
        Contract contract = [SELECT id, Account.CS_NumeroIdentificacion__c, Account.FirstName, Account.MiddleName, Account.LastName, Account.RecordType.DeveloperName, Account.Name FROM Contract WHERE id = :contractId LIMIT 1];
        system.debug('@2.0  ' + contract);
        
        if (contractId != null && contract != null ) {           
            system.debug('@2  ' + contract);
            //Consumo de Metodo de estructura para consumo de listas restrictivas.
            VS_WSGeneralExperienceService.requestListaRestrictiva RestrictiveListsData = new VS_WSGeneralExperienceService.requestListaRestrictiva();
           //En esta sección define si es Persona Natural o Juridica. 
            if(contract.Account.RecordType.DeveloperName == 'PersonAccount'){
                RestrictiveListsData.Numbe_r = contract.Account.CS_NumeroIdentificacion__c;
                RestrictiveListsData.FirstName = contract.Account.FirstName;
                RestrictiveListsData.MiddleName = contract.Account.MiddleName;
                RestrictiveListsData.LastName = contract.Account.LastName;                
            } else
            {
                RestrictiveListsData.Numbe_r = contract.Account.CS_NumeroIdentificacion__c;
                RestrictiveListsData.FirstName = contract.Account.Name;                
            }
                system.debug ('@3  ' + RestrictiveListsData);
                //Consumo de Metodo de listas restrictivas. y retorna las respectivas mensajes predefinidos.              
                Map<String, String> RestrictiveLists = VS_WSGeneralExperienceService.getListaRestrictiva(RestrictiveListsData);
                system.debug('@4  ' + JSON.serializePretty(RestrictiveLists));
                system.debug('@5  ' + RestrictiveLists.get('successful'));
               if(RestrictiveLists.get('emptyLists') == 'true' && RestrictiveLists.get('successful') == 'true'){
                contract.QueryDateRestrictiveList__c = currentDate;
                contract.ContainsRestrictedList__c = 'Si';
                contract.QueryResult__c =JSON.serialize( RestrictiveLists);  Save=true;                   
                }  
                if(RestrictiveLists.get('emptyLists') == 'false' && RestrictiveLists.get('successful') == 'true'){
                    contract.QueryDateRestrictiveList__c = currentDate; 
                    contract.ContainsRestrictedList__c = 'No';
                    contract.QueryResult__c =JSON.serialize( RestrictiveLists);           
                    Save=true;
                } 
                if(RestrictiveLists.get('successful') == 'false'){
                    contract.QueryDateRestrictiveList__c = currentDate;
                    contract.ContainsRestrictedList__c = '';
                    contract.QueryResult__c =JSON.serialize( RestrictiveLists);
                    Save=true;
                }
            if (Save==true){
                try {
                	update contract;
            		}	
            	catch(DmlException e) {
        		System.debug('Error updating contract: ' + e);
   			 	}
            }  
        }
    }
}