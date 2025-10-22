/**
 * WSHabeasDataLeadConversionTest
 * ---------------------------------
 * Test class for WSHabeasDataLeadConversion
 *
 * @author Julian Reales de la Ossa
 * @since  2025-10
 */
@isTest
private class WSHabeasDataLeadConversionTest {

    /**
     * Test successful invocation with all fields
     */
    @isTest
    static void testRunSuccess() {
        // Crear Request completo
        WSHabeasDataLeadConversion.Request req = new WSHabeasDataLeadConversion.Request();
        req.firstName = 'Juan';
        req.secondName = 'Carlos';
        req.lastName = 'Pérez';
        req.secondLastName = 'García';
        req.documentType = 'CC';
        req.numeroDocumento = '123456789';
        req.email = 'juan.perez@test.com';
        req.mobile = '3001234567';
        req.sex = '1';
        req.dataUsePurpose = 'Prospecto';
        req.process = 'Venta';
        req.origin = 'No aplica';
        req.channelType = 'Telefónico';
        req.businessCoverage = 'Transversal';
        req.authorizationChannel = 'Linea Efectiva outbound (Telemercadeo)';
        req.collectionMethodType = 'Salesforce';
        
        // Autorizaciones
        req.generalProcessingDataVida = true;
        req.generalCommercialOfferVida = true;
        req.generalProcessingDataARL = true;
        req.generalCommercialOfferARL = true;
        req.generalProcessingDataGenerales = true;
        req.generalCommercialOfferGenerales = true;

        // Mock del servicio
        Test.setMock(HttpCalloutMock.class, new WSHabeasDataServiceMock());

        Test.startTest();
        List<WSHabeasDataLeadConversion.Response> responses = WSHabeasDataLeadConversion.run(new List<WSHabeasDataLeadConversion.Request>{ req });
        Test.stopTest();

        // Verificar respuesta
        System.assertEquals(1, responses.size(), 'Debe haber una respuesta');
        System.assertNotEquals(null, responses[0].success, 'Success no debe ser null');
    }

    /**
     * Test with contact information (Representante Legal)
     */
    @isTest
    static void testRunWithContact() {
        // Crear Request con información de contacto
        WSHabeasDataLeadConversion.Request req = new WSHabeasDataLeadConversion.Request();
        req.firstName = 'María';
        req.secondName = 'Elena';
        req.lastName = 'González';
        req.secondLastName = 'Martínez';
        req.documentType = 'NIT';
        req.numeroDocumento = '900123456';
        req.email = 'maria@test.com';
        req.mobile = '3009876543';
        req.contactFirstName = 'Pedro';
        req.contactLastName = 'López';
        req.contactIdType = 'CC';
        req.contactIdNumber = '987654321';
        req.dataUsePurpose = 'Cliente Representante Legal';

        // Mock del servicio
        Test.setMock(HttpCalloutMock.class, new WSHabeasDataServiceMock());

        Test.startTest();
        List<WSHabeasDataLeadConversion.Response> responses = WSHabeasDataLeadConversion.run(new List<WSHabeasDataLeadConversion.Request>{ req });
        Test.stopTest();

        // Verificar respuesta
        System.assertEquals(1, responses.size(), 'Debe haber una respuesta');
        System.assertNotEquals(null, responses[0].success, 'Success no debe ser null');
    }

    /**
     * Test with minimal required fields
     */
    @isTest
    static void testRunMinimalFields() {
        // Crear Request con campos mínimos
        WSHabeasDataLeadConversion.Request req = new WSHabeasDataLeadConversion.Request();
        req.firstName = 'Ana';
        req.lastName = 'Rodríguez';
        req.documentType = 'CC';
        req.numeroDocumento = '555555555';
        req.email = 'ana@test.com';
        req.mobile = '3111111111';

        // Mock del servicio
        Test.setMock(HttpCalloutMock.class, new WSHabeasDataServiceMock());

        Test.startTest();
        List<WSHabeasDataLeadConversion.Response> responses = WSHabeasDataLeadConversion.run(new List<WSHabeasDataLeadConversion.Request>{ req });
        Test.stopTest();

        // Verificar respuesta
        System.assertEquals(1, responses.size(), 'Debe haber una respuesta');
        System.assertNotEquals(null, responses[0].success, 'Success no debe ser null');
    }

    /**
     * Test validation error - missing lastName
     */
    @isTest
    static void testValidationErrorLastName() {
        // Crear Request sin lastName
        WSHabeasDataLeadConversion.Request req = new WSHabeasDataLeadConversion.Request();
        req.firstName = 'Juan';
        req.documentType = 'CC';
        req.numeroDocumento = '123456789';
        req.email = 'test@test.com';
        req.mobile = '3001234567';

        // Mock del servicio
        Test.setMock(HttpCalloutMock.class, new WSHabeasDataServiceMock());

        Test.startTest();
        List<WSHabeasDataLeadConversion.Response> responses = WSHabeasDataLeadConversion.run(new List<WSHabeasDataLeadConversion.Request>{ req });
        Test.stopTest();

        // Verificar respuesta
        System.assertEquals(1, responses.size(), 'Debe haber una respuesta');
        System.assertEquals(false, responses[0].success, 'Debe fallar la validación');
        System.assertNotEquals(null, responses[0].message, 'Debe tener un mensaje de error');
    }

    /**
     * Test validation error - missing documentType
     */
    @isTest
    static void testValidationErrorDocumentType() {
        // Crear Request sin documentType
        WSHabeasDataLeadConversion.Request req = new WSHabeasDataLeadConversion.Request();
        req.firstName = 'Juan';
        req.lastName = 'Pérez';
        req.numeroDocumento = '123456789';
        req.email = 'test@test.com';
        req.mobile = '3001234567';

        // Mock del servicio
        Test.setMock(HttpCalloutMock.class, new WSHabeasDataServiceMock());

        Test.startTest();
        List<WSHabeasDataLeadConversion.Response> responses = WSHabeasDataLeadConversion.run(new List<WSHabeasDataLeadConversion.Request>{ req });
        Test.stopTest();

        // Verificar respuesta
        System.assertEquals(1, responses.size(), 'Debe haber una respuesta');
        System.assertEquals(false, responses[0].success, 'Debe fallar la validación');
        System.assertNotEquals(null, responses[0].message, 'Debe tener un mensaje de error');
    }

    /**
     * Test empty request list
     */
    @isTest
    static void testEmptyRequestList() {
        Test.startTest();
        List<WSHabeasDataLeadConversion.Response> responses = WSHabeasDataLeadConversion.run(new List<WSHabeasDataLeadConversion.Request>());
        Test.stopTest();

        // Verificar respuesta vacía
        System.assertEquals(0, responses.size(), 'La lista de respuestas debe estar vacía');
    }

    /**
     * Test null request list
     */
    @isTest
    static void testNullRequestList() {
        Test.startTest();
        List<WSHabeasDataLeadConversion.Response> responses = WSHabeasDataLeadConversion.run(null);
        Test.stopTest();

        // Verificar respuesta vacía
        System.assertEquals(0, responses.size(), 'La lista de respuestas debe estar vacía');
    }

    /**
     * Test buildDTO method
     */
    @isTest
    static void testBuildDTO() {
        WSHabeasDataLeadConversion.Request req = new WSHabeasDataLeadConversion.Request();
        req.firstName = 'Juan';
        req.secondName = 'Carlos';
        req.lastName = 'Pérez';
        req.secondLastName = 'García';
        req.documentType = 'CC';
        req.numeroDocumento = '123456789';
        req.email = 'juan@test.com';
        req.mobile = '3001234567';
        req.sex = '1';
        req.dataUsePurpose = 'Prospecto';

        Test.startTest();
        WSHabeasDataExtendWrapper.HabeasDataDto result = WSHabeasDataLeadConversion.buildDTO(req);
        Test.stopTest();

        System.assertEquals('Juan', result.firstName);
        System.assertEquals('Carlos', result.secondName);
        System.assertEquals('Pérez', result.lastName);
        System.assertEquals('CC', result.identityType);
        System.assertEquals('123456789', result.identityNumber);
        System.assertEquals('Prospecto', result.dataUsePurpose);
        System.assertEquals(true, result.identityValidationNoData);
        System.assertNotEquals(null, result.companies);
    }

    /**
     * Test buildCompanies method
     */
    @isTest
    static void testBuildCompanies() {
        WSHabeasDataLeadConversion.Request req = new WSHabeasDataLeadConversion.Request();
        req.generalProcessingDataVida = true;
        req.generalCommercialOfferVida = false;
        req.generalProcessingDataARL = false;
        req.generalCommercialOfferARL = true;
        req.generalProcessingDataGenerales = true;
        req.generalCommercialOfferGenerales = true;

        Test.startTest();
        List<WSHabeasDataExtendWrapper.CompanyDto> result = WSHabeasDataLeadConversion.buildCompanies(req);
        Test.stopTest();

        System.assertNotEquals(null, result);
        System.assertEquals(3, result.size(), 'Debe haber 3 compañías');
        
        // Verificar Seguro de Vida
        System.assertEquals('Seguro de Vida', result[0].name);
        System.assertEquals(true, result[0].generalProcessingData);
        System.assertEquals(false, result[0].generalCommercialOffer);
        
        // Verificar ARL
        System.assertEquals('ARL', result[1].name);
        System.assertEquals(false, result[1].generalProcessingData);
        System.assertEquals(true, result[1].generalCommercialOffer);
        
        // Verificar Seguros Generales
        System.assertEquals('Seguros Generales', result[2].name);
        System.assertEquals(false, result[2].medicalHistory);
    }

    /**
     * Test buildCompanies with null values (should use defaults)
     */
    @isTest
    static void testBuildCompaniesWithDefaults() {
        WSHabeasDataLeadConversion.Request req = new WSHabeasDataLeadConversion.Request();
        // No se asignan valores, deben usar defaults (true)

        Test.startTest();
        List<WSHabeasDataExtendWrapper.CompanyDto> result = WSHabeasDataLeadConversion.buildCompanies(req);
        Test.stopTest();

        System.assertNotEquals(null, result);
        System.assertEquals(3, result.size(), 'Debe haber 3 compañías');
        
        // Todos deben tener valores por defecto true
        for (WSHabeasDataExtendWrapper.CompanyDto company : result) {
            System.assertEquals(true, company.generalProcessingData, 'generalProcessingData debe ser true por defecto');
            System.assertEquals(true, company.generalCommercialOffer, 'generalCommercialOffer debe ser true por defecto');
        }
    }

    /**
     * Mock class for HTTP callouts
     */
    private class WSHabeasDataServiceMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"responseCode":200,"error":false,"message":"OK"}');
            res.setStatusCode(200);
            return res;
        }
    }
}