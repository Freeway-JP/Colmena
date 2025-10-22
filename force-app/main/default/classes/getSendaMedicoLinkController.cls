public with sharing class getSendaMedicoLinkController {

    @AuraEnabled
    public static Response getDataConfiguration(String recordId) {
        Response response = new Response();
        String userId = UserInfo.getUserId();
        User usr = Database.query('SELECT employeenumber FROM User WHERE Id = : userId');
        String cedula = usr?.employeenumber;
        
        Task tk = [SELECT Id, Participante_de_poliza_de_seguro__r.PrimaryParticipantContact.CS_TipoIdentificacionCP__c, 
                Participante_de_poliza_de_seguro__r.PrimaryParticipantContact.CS_NumeroIdentificacionCP__c  
            FROM Task 
            WHERE Id =:recordId];
        String idTipoDocumento = tk.Participante_de_poliza_de_seguro__r?.PrimaryParticipantContact?.CS_TipoIdentificacionCP__c;
        String documento = tk.Participante_de_poliza_de_seguro__r?.PrimaryParticipantContact?.CS_NumeroIdentificacionCP__c;
        String checksumString = 'Checksum';
        List<VS_Callout_Configuration__mdt> calloutData;
        calloutData = Database.query('SELECT Client_Secret__c, Client_Id__c, EndPoint__c FROM VS_Callout_configuration__mdt WHERE Label = :checksumString ');
        if (!calloutData.isEmpty()) {
            String url = calloutData[0].EndPoint__c;
            String parameter = 'IdLlamada=0&Cedula='+cedula+'&IdTipoDocumento='+idTipoDocumento+'&Documento='+documento+'&ProvieneDe=10';
            GenerateDigestString.InputVariables input = new GenerateDigestString.InputVariables();
            input.encodeString = parameter;
            input.cryptoKey = calloutData[0].Client_Secret__c;
            input.vector = calloutData[0].Client_Id__c;
            
            List<GenerateDigestString.ReturnVariables> checksum = GenerateDigestString.GenerateDigestString(new List<GenerateDigestString.InputVariables>{input});
            
            if (!checksum.isEmpty()) {
                response.endPoint = url+parameter+'&Checksum='+checksum[0].codifiedString;
                response.cedula = cedula;   
                response.idTipoDocumento = idTipoDocumento;
                response.documento = documento;
                response.checksum = checksum[0].codifiedString;
            }
            
        }
        return response;

    }

    public class Response {
        @AuraEnabled
        public String cedula;
        @AuraEnabled
        public String endPoint;
        @AuraEnabled
        public String idTipoDocumento;
        @AuraEnabled
        public String documento;
        @AuraEnabled
        public String checksum;
    }
}