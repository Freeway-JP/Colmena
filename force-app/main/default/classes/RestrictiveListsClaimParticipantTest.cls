@isTest
public class RestrictiveListsClaimParticipantTest {

    @TestSetup
    static void makeData() {
        Claim claim = new Claim(Name = 'Test Claim');
        insert claim;

        ClaimParticipant claimCoverage = new ClaimParticipant(
            CS_FirstName__c = 'SALDIVAR',
            ClaimId = claim.Id,
            CS_DocumentNumber__c = '10062699260',
            CS_LastName__c = 'JESSICA',
            CS_NameorSocialReason__c = 'TEST PRUEBA',
            CS_SecondName__c = 'FLORES'
        );
        insert claimCoverage;
    }
    @isTest
    static void testEmpty() {
        // Crear una respuesta HTTP simulada con el JSON de respuesta vacía para Lists
        String jsonResponse = '{"Matches":"true","QueryNumber":"6765436","Lists":[{"IdList":5115069,"Priority":"1","ListType":"Perú- Contribuyentes en condición No Hallados y No Habidos SUNAT","Identification":{"Type":"RUC","Number":"10062699260"},"FullName":"SALDIVAR FLORES JESSICA MARIA","IdListType":123}]}';
        
        // Configurar la respuesta simulada
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(jsonResponse, 200));
        
        // Crear datos de prueba para los parámetros de solicitud
        VS_WSGeneralExperienceService.requestListaRestrictiva requestData = new VS_WSGeneralExperienceService.requestListaRestrictiva();
        requestData.Numbe_r = '10062699260';
        requestData.FirstName = 'SALDIVAR';
        requestData.MiddleName = 'FLORES';
        requestData.LastName = 'JESSICA';
        
        // Llamar al método que se va a probar
        Map<String, String> result = VS_WSGeneralExperienceService.getListaRestrictiva(requestData);
        
        // Deserializar la respuesta JSON a un objeto
        Map<String, Object> expectedResponse = (Map<String, Object>) JSON.deserializeUntyped(jsonResponse);
        
        List<String> listString = new  List<String>();      
		List<ClaimParticipant> listClaimParticipant = [SELECT Id, CS_DocumentNumber__c, CS_FirstName__c, CS_SecondName__c, CS_LastName__c,CS_NameorSocialReason__c FROM ClaimParticipant ];
        // Test execution
        listString.add(listClaimParticipant[0].id);
        Test.startTest();
        RestrictiveListsClaimParticipant.processStringForContracts(listString);
        
        Test.stopTest();

    }
    @isTest
    static void testNotEmpty() {
        // Crear una respuesta HTTP simulada con el JSON de respuesta vacía para Lists
        String jsonResponse = '{"Matches":"true","QueryNumber":"6765436","Lists":[]}';
        
        // Configurar la respuesta simulada
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(jsonResponse, 200));
        
        // Crear datos de prueba para los parámetros de solicitud
        VS_WSGeneralExperienceService.requestListaRestrictiva requestData = new VS_WSGeneralExperienceService.requestListaRestrictiva();
        requestData.Numbe_r = '10062699260';
        requestData.FirstName = 'SALDIVAR';
        requestData.MiddleName = 'FLORES';
        requestData.LastName = 'JESSICA';
        
        // Llamar al método que se va a probar
        Map<String, String> result = VS_WSGeneralExperienceService.getListaRestrictiva(requestData);
        
        // Deserializar la respuesta JSON a un objeto
        Map<String, Object> expectedResponse = (Map<String, Object>) JSON.deserializeUntyped(jsonResponse);
        
        List<String> listString = new  List<String>();      
		List<ClaimParticipant> listClaimParticipant = [SELECT Id, CS_DocumentNumber__c, CS_FirstName__c, CS_SecondName__c, CS_LastName__c,CS_NameorSocialReason__c FROM ClaimParticipant ];
        // Test execution
        listString.add(listClaimParticipant[0].id);
        Test.startTest();
        RestrictiveListsClaimParticipant.processStringForContracts(listString);
        
        Test.stopTest();

    }
    // Clase MockHttpResponse
    private class MockHttpResponse implements HttpCalloutMock {
        private String response;
        private Integer statusCode;
        private CalloutException ex; // Cambiar el nombre de la variable
        
        public MockHttpResponse(String response, Integer statusCode) {
            this.response = response;
            this.statusCode = statusCode;
        }
        
        public MockHttpResponse(CalloutException ex) {
            this.ex = ex; // Cambiar la asignación
        }
        
        public HttpResponse respond(HttpRequest req) {
            if (ex != null) {
                throw ex; // Lanzar la excepción aquí si está configurada
            }
            
            HttpResponse res = new HttpResponse();
            res.setBody(response);
            res.setStatusCode(statusCode);
            return res;
        }
    }
}