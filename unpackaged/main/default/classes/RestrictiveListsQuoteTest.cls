@isTest
public class RestrictiveListsQuoteTest {
    
    @testSetup
    static void setupTestData() {
        RecordType personAccountRT = [SELECT Id FROM RecordType WHERE DeveloperName = 'PersonAccount' LIMIT 1];
        EconomicActivity__c actividad = new EconomicActivity__c();
        actividad.Name = '1454201';
        actividad.RiskClass__c = '1';
        actividad.Code768__c = '1454201';
        actividad.Nicho__c = '005';
        actividad.Prevention_Niche__c = 'Comercio';
        insert actividad;
        
        Account acc = new Account();
        acc.CS_TipoIdentificacionCP__pc = '1';
        acc.CS_NumeroIdentificacionCP__pc = '1007389654';
        acc.CS_FechaExpedicion__pc = Date.valueOf('2018-06-26');
        acc.LastName = 'Account Test';
        acc.Suffix = 'Test';
        acc.FirstName = 'Account';
        acc.PersonMobilePhone = '1111111111';
        acc.Fecha_Ultima_Validacion_Cliente__c = DateTime.now();
        acc.CC_Tipo_de_Cuenta__c = 'Cuenta Prospecto';
        acc.EconomicActivity__c = actividad.id;
        acc.AverageMonthlyDependentContributions__c = 10000;
        acc.AverageIndependentMoContribution__c	 = 10000;
        acc.RecordTypeId = personAccountRT.Id;
        insert acc;

        
        Opportunity oppPerson = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Diseño de Oferta',
            CloseDate = Date.valueOf('2024-10-04'),
            TypeAgreement__c = 'Directo',
            ValidityProjection__c = '1 año',
            YearsToConsiderRunoff__c = '1 año',
            ThirdYear__c = 20000,
            FirstYear__c = 20000,
            SecondYear__c = 20000,
            FourthYear__c = 20000,
            FifthYear__c = 20000,
            AccountId = acc.Id
        );
        insert oppPerson;
        
        Quote quotePerson = new Quote(
            Name = 'Test Quote Person',
            OpportunityId = oppPerson.Id
        );
        insert quotePerson;
        
    }
    
    @isTest
    static void testProcessStringForQuote() {
        List<Quote> quotes = [SELECT Id FROM Quote LIMIT 1];
        System.assertNotEquals(0, quotes.size(), 'No se encontraron Quotes en la base de datos de prueba');
        
        Test.startTest();
        RestrictiveListsQuote.processStringForQuote(new List<String>{quotes[0].Id});
        Test.stopTest();
    }
    
    @isTest
    static void testCall_VS_WSGeneralExperienceService() {
        List<Quote> quotes = [SELECT Id FROM Quote LIMIT 1];
        System.assertNotEquals(0, quotes.size(), 'No se encontraron Quotes en la base de datos de prueba');
        
        Test.setMock(HttpCalloutMock.class, new RestrictiveListsMock());
        
        Test.startTest();
        RestrictiveListsQuote.Call_VS_WSGeneralExperienceService(quotes[0].Id);
        Test.stopTest();
        
        Quote updatedQuote = [SELECT QueryDateRestrictiveList__c, ContainsRestrictedList__c, QueryResult__c FROM Quote WHERE Id = :quotes[0].Id];
        System.assertNotEquals(null, updatedQuote.QueryDateRestrictiveList__c, 'El campo QueryDateRestrictiveList__c no fue actualizado');
        System.assertNotEquals(null, updatedQuote.ContainsRestrictedList__c, 'El campo ContainsRestrictedList__c no fue actualizado');
        System.assertNotEquals(null, updatedQuote.QueryResult__c, 'El campo QueryResult__c no fue actualizado');
    }
    
   class RestrictiveListsMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"emptyLists": "true", "successful": "true"}');
            res.setStatusCode(200);
            return res;
        }
    }
}