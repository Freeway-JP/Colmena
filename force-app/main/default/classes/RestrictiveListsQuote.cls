/* @create date 2024-07-19 16:44:17
* @modify date 2024-07-19 17:04:25
* @desc [Esta es una Clase invocable que consume el servicio de VS_WSGeneralExperienceService,
*         Recibe un Id de Oferta y lo procesa para consultar si tiene lista restrictiva.
*         y la información la almacena en 3 campos personalizados de Oferta]
*/

public without sharing class RestrictiveListsQuote {
    @InvocableMethod(label='Procesar String para Quote')
    public static void processStringForQuote(List<String> inputStrings) {
        String inputString = inputStrings[0];
        system.debug('@1  ' + inputString);
        
        Call_VS_WSGeneralExperienceService(inputString);
    }
    @future(callout=true)
    public static void Call_VS_WSGeneralExperienceService(string quoteId) {
        // variable DateTime
        //Datetime  currentDate = Datetime.NOW(); 
        Date currentDate = Date.today();        
        boolean Save =false;
        //Consulta de quotes con ese ID. 
        Quote quote = [SELECT id, Opportunity.Account.CS_NumeroIdentificacion__c,Opportunity.Account.FirstName, Opportunity.Account.MiddleName, Opportunity.Account.LastName, Opportunity.Account.RecordType.DeveloperName, Opportunity.Account.Name FROM Quote WHERE id = :quoteId LIMIT 1];
        system.debug('@2.0  ' + quote);
        
        if (quoteId != null && quote != null ) {           
            system.debug('@2  ' + quote);
            //Consumo de Metodo de estructura para consumo de listas restrictivas.
            VS_WSGeneralExperienceService.requestListaRestrictiva RestrictiveListsData = new VS_WSGeneralExperienceService.requestListaRestrictiva();
            //En esta sección define si es Persona Natural o Juridica. 
            if(quote.Opportunity.Account.RecordType.DeveloperName == 'PersonAccount'){
                RestrictiveListsData.Numbe_r = quote.Opportunity.Account.CS_NumeroIdentificacion__c;
                RestrictiveListsData.FirstName = quote.Opportunity.Account.FirstName;
                RestrictiveListsData.MiddleName = quote.Opportunity.Account.MiddleName;
                RestrictiveListsData.LastName = quote.Opportunity.Account.LastName;                
            } else{
                RestrictiveListsData.Numbe_r = quote.Opportunity.Account.CS_NumeroIdentificacion__c;
                RestrictiveListsData.FirstName = quote.Opportunity.Account.Name;                
            }
            system.debug ('@3  ' + RestrictiveListsData);
            //Consumo de Metodo de listas restrictivas. y retorna las respectivas mensajes predefinidos.              
            Map<String, String> RestrictiveLists = VS_WSGeneralExperienceService.getListaRestrictiva(RestrictiveListsData);
            system.debug('@4  ' + JSON.serializePretty(RestrictiveLists));
            system.debug('@5  ' + RestrictiveLists.get('successful'));
            final Integer MAX_LENGTH = 32765;
            String resultString = JSON.serializePretty(RestrictiveLists);
        	String queryResult = resultString.length() > MAX_LENGTH ? resultString.substring(0, MAX_LENGTH) : resultString;
            if(RestrictiveLists.get('emptyLists') == 'true' && RestrictiveLists.get('successful') == 'true'){
                quote.QueryDateRestrictiveList__c = currentDate;
                quote.ContainsRestrictedList__c = 'Si';
                quote.QueryResult__c =queryResult;  Save=true;                   
            }  
            if(RestrictiveLists.get('emptyLists') == 'false' && RestrictiveLists.get('successful') == 'true'){
                quote.QueryDateRestrictiveList__c = currentDate; 
                quote.ContainsRestrictedList__c = 'No';
                quote.QueryResult__c =queryResult;           
                Save=true;
            } 
            if(RestrictiveLists.get('successful') == 'false'){
                quote.QueryDateRestrictiveList__c = currentDate;
                quote.ContainsRestrictedList__c = '';
                quote.QueryResult__c =queryResult;
                Save=true;
            }
            if (Save==true){
                try {
                    update quote;
                }   
                catch(DmlException e) {
                    System.debug('Error updating quote: ' + e);
                }
            }  
        }
    }
}