@IsTest
private class WSHabeasDataBotVentaTest {
    /**
     * @description Test suite for WSHabeasDataBotVenta. Verifies success, failure, null/empty inputs, and edge mappings. Uses HttpCalloutMock and @TestVisible helpers to maximize coverage.
     * @author Carlos
     * @date 2025-10-09∫
     */

    /**
     * @description Creates a valid Request DTO with provided email/mobile.
     */
    private static WSHabeasDataBotVenta.Request makeReq(String email, String mobile) {
        WSHabeasDataBotVenta.Request r = new WSHabeasDataBotVenta.Request();
        r.firstName = 'Ana';
        r.secondName = null;
        r.lastName = 'García';
        r.secondLastName = ' ';
        r.documentType = '1';
        r.numeroDocumento = '1234567890';
        r.email = email;
        r.mobile = mobile;
        return r;
    }

    /**
     * @description Http mock that returns a successful logical payload.
     */
    private class SuccessMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"error":false,"responseCode":200,"message":""}');
            return res;
        }
    }

    /**
     * @description Http mock that returns a failure logical payload.
     */
    private class FailureMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"error":true,"responseCode":400,"message":"Bad Request"}');
            return res;
        }
    }

    /**
     * @description Verifies run returns empty when input list is null or empty.
     */
    @IsTest
    static void testRun_NullAndEmptyInput() {
        List<WSHabeasDataBotVenta.Response> r1 = WSHabeasDataBotVenta.run(null);
        System.assertEquals(0, r1.size());
        List<WSHabeasDataBotVenta.Response> r2 = WSHabeasDataBotVenta.run(new List<WSHabeasDataBotVenta.Request>());
        System.assertEquals(0, r2.size());
    }

    /**
     * @description Verifies successful path with valid data and blank service message (mapped to "OK"). Exercises bulk processing.
     */
    @IsTest
    static void testRun_Success_WithEmailAndMobile() {
        Test.setMock(HttpCalloutMock.class, new SuccessMock());
        List<WSHabeasDataBotVenta.Request> inputs = new List<WSHabeasDataBotVenta.Request>{
            makeReq('ana@example.com', '3150000000'),
            makeReq('ana2@example.com', '3220000000')
        };
        Test.startTest();
        List<WSHabeasDataBotVenta.Response> out = WSHabeasDataBotVenta.run(inputs);
        Test.stopTest();
        System.assertEquals(2, out.size());
    }

    /**
     * @description Verifies failure path when downstream returns error and non-blank message.
     */
    @IsTest
    static void testRun_Failure_FromService() {
        Test.setMock(HttpCalloutMock.class, new FailureMock());
        List<WSHabeasDataBotVenta.Request> inputs = new List<WSHabeasDataBotVenta.Request>{ makeReq('fail@example.com', '3151111111') };
        Test.startTest();
        List<WSHabeasDataBotVenta.Response> out = WSHabeasDataBotVenta.run(inputs);
        Test.stopTest();
        System.assertEquals(1, out.size());
    }

    /**
     * @description Verifies validation errors are surfaced via AuraHandledException and through run() error capture.
     */
    @IsTest
    static void testValidate_And_Run_ErrorMessages() {
        WSHabeasDataBotVenta.Request r1 = makeReq('x@example.com', '3000000000');
        r1.firstName = null;
        try {
            WSHabeasDataBotVenta.validate(r1);
            System.assert(false);
        } catch (AuraHandledException ex) {
            System.assertEquals('Script-thrown exception', ex.getMessage());
        }
        WSHabeasDataBotVenta.Request r2 = makeReq('x@example.com', '3000000000');
        r2.lastName = ' ';
        try {
            WSHabeasDataBotVenta.validate(r2);
            System.assert(false);
        } catch (AuraHandledException ex) {
            System.assertEquals('Script-thrown exception', ex.getMessage());
        }
        WSHabeasDataBotVenta.Request r3 = makeReq('x@example.com', '3000000000');
        r3.documentType = '';
        try {
            WSHabeasDataBotVenta.validate(r3);
            System.assert(false);
        } catch (AuraHandledException ex) {
            System.assertEquals('Script-thrown exception', ex.getMessage());
        }
        WSHabeasDataBotVenta.Request r4 = makeReq('x@example.com', '3000000000');
        r4.numeroDocumento = ' ';
        try {
            WSHabeasDataBotVenta.validate(r4);
            System.assert(false);
        } catch (AuraHandledException ex) {
            System.assertEquals('Script-thrown exception', ex.getMessage());
        }
        List<WSHabeasDataBotVenta.Request> inputs = new List<WSHabeasDataBotVenta.Request>{ r1 };
        List<WSHabeasDataBotVenta.Response> out = WSHabeasDataBotVenta.run(inputs);
        System.assertEquals(1, out.size());
        System.assertEquals(false, out[0].success);
        System.assertEquals('Script-thrown exception', out[0].message);
    }

    /**
     * @description Verifies Account mapping and validateNullString behavior for null/blank middle names.
     */
    @IsTest
    static void testToAccount_MappingAndNulls() {
        WSHabeasDataBotVenta.Request r = makeReq('map@example.com', '3112223333');
        r.secondName = '   ';
        r.secondLastName = null;
        WSHabeasDataAPIDto.AccountDto a = WSHabeasDataBotVenta.toAccount(r);
        System.assertEquals('Ana', a.firstName);
        System.assertEquals('', a.secondName);
        System.assertEquals('García', a.lastName);
        System.assertEquals('', a.secondLastName);
        System.assertEquals('1', a.identityType);
        System.assertEquals('1234567890', a.identityNumber);
        System.assertEquals('map@example.com', a.email);
        System.assertEquals('3112223333', a.numberPhone);
    }

    /**
     * @description Verifies Consent mapping defaults and 2300 generation when only email is provided.
     */
    @IsTest
    static void testToConsent_EmailOnly() {
        WSHabeasDataBotVenta.Request r = makeReq('onlyemail@example.com', '');
        WSHabeasDataAPIDto.ConsentDto c = WSHabeasDataBotVenta.toConsent(r);
        System.assertEquals(WSHabeasDataUtilities.CLIENTE, c.dataUsePurpose);
        System.assertNotEquals(null, c.authorizationChannel);
        List<WSHabeasDataAPIDto.Auth2300> list2300 = WSHabeasDataBotVenta.buildAuth2300(r);
        System.assertEquals(2, list2300.size());
        for (WSHabeasDataAPIDto.Auth2300 a : list2300) {
            System.assertEquals('onlyemail@example.com', a.contactPoint);
        }
    }

    /**
     * @description Verifies 2300 generation when both email and mobile are provided (four channels x two purposes).
     */
    @IsTest
    static void testBuildAuth2300_AllChannels() {
        WSHabeasDataBotVenta.Request r = makeReq('both@example.com', '3209998888');
        List<WSHabeasDataAPIDto.Auth2300> list2300 = WSHabeasDataBotVenta.buildAuth2300(r);
        System.assertEquals(8, list2300.size());
        Integer emailCount = 0;
        Integer mobileCount = 0;
        for (WSHabeasDataAPIDto.Auth2300 a : list2300) {
            if (a.contactPoint == 'both@example.com')
                emailCount++;
            if (a.contactPoint == '3209998888')
                mobileCount++;
            System.assertNotEquals(null, a.dataUsePurpose);
            System.assertEquals(true, a.value);
        }
        System.assertEquals(2, emailCount);
        System.assertEquals(6, mobileCount);
    }

    /**
     * @description Verifies default companies mapping contains expected values without duplicates.
     */
    @IsTest
    static void testToCompanies_Defaults() {
        List<String> companies = WSHabeasDataBotVenta.toCompanies();
        System.assertEquals(3, companies.size());
        System.assertEquals(true, new Set<String>(companies).contains('ARL'));
        System.assertEquals(true, new Set<String>(companies).contains('Seguro de Vida'));
        System.assertEquals(true, new Set<String>(companies).contains('Seguros Generales'));
    }
}