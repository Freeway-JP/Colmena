/**
 * @author Harold Garcia Vargas
 * @email harold.garcia@vasscompany.com
 * @create date 2024-07-25 11:47:06
 * @modify date 2024-07-25 11:47:06
 * @desc [Clase de prueba para RestrictiveListsContracts]
 */

@isTest
public with sharing class RestrictiveListsContractsTest {
    
    @isTest
    static void testprocessStringForContractsWithNegativeResponse() {
        // Configurar la respuesta simulada del servicio web
        String jsonResponse = '{ "Matches": false, "QueryNumber": 289072, "Lists": [] }';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(jsonResponse, 200));
        
        // Crear un Account y un Contract
        RecordType personRecordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'PersonAccount' AND SObjectType = 'Account' LIMIT 1];
        
        Account acc = new Account();
        acc.CS_NumeroIdentificacion__c = '1006269926';
        acc.FirstName = 'John';
        acc.LastName = 'Doe';
        acc.MiddleName = 'Smith';
        acc.RecordTypeId = personRecordType.Id;
        acc.Phone = '3104770791';
        insert acc;
        
        Contract cont = new Contract();
        cont.AccountId = acc.Id;
        insert cont;     
       
        List<String> inputStrings = new List<String>();
        inputStrings.add(cont.Id);
        
        // Ejecutar el método de prueba
        Test.startTest();
        RestrictiveListsContracts.processStringForContracts(inputStrings);
        Test.stopTest();
        // Verificar que el contrato se haya actualizado correctamente
        Contract updatedContract = [SELECT QueryDateRestrictiveList__c, ContainsRestrictedList__c, QueryResult__c FROM Contract WHERE Id = :cont.Id];
        System.assertNotEquals(null, updatedContract.QueryDateRestrictiveList__c);
        System.assertEquals('No', updatedContract.ContainsRestrictedList__c);
    }
    
   @isTest
    static void testprocessStringForContractsWithPositiveResponse() {
        // Configurar una respuesta vacía del servicio web
        String jsonResponse = '{ "Matches": true, "QueryNumber": 289261, "Lists": [ { "IdList": 218604, "Priority": "1", "ListType": "Registros retirados de otros listados", "Identification": { "Type": "NIT", "Number": "890900608" }, "FullName": "ALMACENES EXITO SA", "IdListType": 81 }, { "IdList": 7409793, "Priority": "1", "ListType": "Otras sanciones administrativas diferentes de otros listados", "Identification": { "Type": "NIT   ", "Number": "890900608         " }, "FullName": "ALMACENES EXITO SA", "IdListType": 108 }, { "IdList": 8534930, "Priority": "1", "ListType": "Otras sanciones administrativas diferentes de otros listados", "Identification": { "Type": "NIT   ", "Number": "890900608         " }, "FullName": "ALMACENES EXITO SA", "IdListType": 108 }, { "IdList": 10460973, "Priority": "1", "ListType": "Otras sanciones administrativas diferentes de otros listados", "Identification": { "Type": "NIT", "Number": "890900608" }, "FullName": "ALMACENES EXITO SA", "IdListType": 108 }, { "IdList": 10617749, "Priority": "1", "ListType": "Otras sanciones administrativas diferentes de otros listados", "Identification": { "Type": "NIT   ", "Number": "890900608         " }, "FullName": "ALMACENES EXITO SA                  ", "IdListType": 108 }, { "IdList": 7392029, "Priority": "1", "ListType": "Colombia - Multas y/o Sanciones de la Superintendencia Financiera", "Identification": { "Type": "NIT", "Number": "890900608" }, "FullName": "ALMACENES EXITO SA", "IdListType": 195 }, { "IdList": 10805033, "Priority": "1", "ListType": "Colombia - Registro Nacional de Valores y Emisores - RNVE - de la Superintendencia Financiera", "Identification": { "Type": "NIT", "Number": "890900608" }, "FullName": "ALMACENES EXITO SA", "IdListType": 444 }, { "IdList": 7118704, "Priority": "2", "ListType": "Otras sanciones administrativas diferentes de otros listados", "Identification": { "Type": "NIT", "Number": "890900608" }, "FullName": "ALMACENES EXITO", "IdListType": 108 }, { "IdList": 9758301, "Priority": "3", "ListType": "Chile - Emisores de renta variable autorizados por la Bolsa de Valores de Chile", "Identification": { "Type": "RUT", "Number": "" }, "FullName": "ALMACENES EXITO SA", "IdListType": 336 }, { "IdList": 9758302, "Priority": "3", "ListType": "Chile - Emisores de renta variable autorizados por la Bolsa de Valores de Chile", "Identification": { "Type": "RUT", "Number": "" }, "FullName": "ALMACENES EXITO SA", "IdListType": 336 }, { "IdList": 9758303, "Priority": "3", "ListType": "Chile - Emisores de renta variable autorizados por la Bolsa de Valores de Chile", "Identification": { "Type": "RUT", "Number": "" }, "FullName": "ALMACENES EXITO SA", "IdListType": 336 }, { "IdList": 10024047, "Priority": "3", "ListType": "Colombia - Registro de Personas Naturales o Jurídicas que tienen o han tenido procesos sancionatorios por violación del tratamiento de datos personales ante la Superintendencia de Industria y Comercio (SIC)", "Identification": { "Type": "", "Number": "" }, "FullName": "ALMACENES EXITO SA", "IdListType": 365 }, { "IdList": 10024209, "Priority": "3", "ListType": "Colombia - Registro de Personas Naturales o Jurídicas que tienen o han tenido procesos sancionatorios por violación del tratamiento de datos personales ante la Superintendencia de Industria y Comercio (SIC)", "Identification": { "Type": "", "Number": "" }, "FullName": "ALMACENES EXITO SA", "IdListType": 365 }, { "IdList": 11074033, "Priority": "3", "ListType": "Colombia - Registro Único de Infractores Ambientales – ANLA", "Identification": { "Type": "CC", "Number": "" }, "FullName": "ALMACENES EXITO SA", "IdListType": 99 }, { "IdList": 18950049, "Priority": "1", "ListType": "SAP", "Identification": { "Type": "NIT", "Number": "890900608" }, "FullName": "ALMACENES EXITO S.A", "IdListType": 4688 }, { "IdList": 19356329, "Priority": "1", "ListType": "SAP", "Identification": { "Type": "NIT", "Number": "890900608" }, "FullName": "ALMACENES EXITO S.A", "IdListType": 4688 } ] }';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(jsonResponse, 200));
        
        // Crear un Account y un Contract
        RecordType personRecordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'CS_Juridico' AND SObjectType = 'Account' LIMIT 1];
        
        Account acc = new Account();
        acc.CS_NumeroIdentificacion__c = '890900608';
        acc.Name = 'ALMACENES EXITO SA';
        acc.RecordTypeId = personRecordType.Id;
        acc.Phone = '3104770791'; 
        insert acc;
        
        Contract cont = new Contract();
        cont.AccountId = acc.Id;
        insert cont;     
       
        List<String> inputStrings = new List<String>();
        inputStrings.add(cont.Id);
        
        // Ejecutar el método de prueba
        Test.startTest();
        RestrictiveListsContracts.processStringForContracts(inputStrings);
        Test.stopTest();
        // Verificar que el contrato se haya actualizado correctamente
        Contract updatedContract = [SELECT QueryDateRestrictiveList__c, ContainsRestrictedList__c, QueryResult__c FROM Contract WHERE Id = :cont.Id];
        System.assertNotEquals(null, updatedContract.QueryDateRestrictiveList__c);
        System.assertEquals('Si', updatedContract.ContainsRestrictedList__c);
}
    @isTest
    static void testprocessStringForContractsWithoutResponse() {
        // Configurar una respuesta vacía del servicio web
        String jsonResponse = '{ "status": 500, "code": "RETRY_EXHAUSTED", "message": { "message": "HTTP GET on resource failed: not found (500)." }, "messageServer": "null", "cause": [ { "origin": "security-experience-api", "message": "org.mule.runtime.internal.exception.SuppressedMuleException" } ] }';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(jsonResponse, 500));
        
        // Crear un Account y un Contract
        RecordType personRecordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'CS_Juridico' AND SObjectType = 'Account' LIMIT 1];
        
        Account acc = new Account();
        acc.CS_NumeroIdentificacion__c = '890900608';
        acc.Name = 'ALMACENES EXITO SA';
        acc.RecordTypeId = personRecordType.Id;
        acc.Phone = '3104770791'; 
        insert acc;
        
        Contract cont = new Contract();
        cont.AccountId = acc.Id;
        insert cont;     
       
        List<String> inputStrings = new List<String>();
        inputStrings.add(cont.Id);
        
        // Ejecutar el método de prueba
        Test.startTest();
        RestrictiveListsContracts.processStringForContracts(inputStrings);
        Test.stopTest();
        // Verificar que el contrato se haya actualizado correctamente
        Contract updatedContract = [SELECT QueryDateRestrictiveList__c, ContainsRestrictedList__c, QueryResult__c FROM Contract WHERE Id = :cont.Id];
        System.assertNotEquals(null, updatedContract.QueryDateRestrictiveList__c);
        System.assertEquals(null, updatedContract.ContainsRestrictedList__c);
    }
    
    // Clase MockHttpResponse
    private class MockHttpResponse implements HttpCalloutMock {
        private String response;
        private Integer statusCode;
        private CalloutException ex;
        
        public MockHttpResponse(String response, Integer statusCode) {
            this.response = response;
            this.statusCode = statusCode;
        }
        
        public MockHttpResponse(CalloutException ex) {
            this.ex = ex;
        }
        
        public HttpResponse respond(HttpRequest req) {
            if (ex != null) {
                throw ex;
            }
            
            HttpResponse res = new HttpResponse();
            res.setBody(response);
            res.setStatusCode(statusCode);
            return res;
        }
    }
}