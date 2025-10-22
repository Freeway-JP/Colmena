@IsTest
public class WSHabeasDataMassiveTest {
    private static void setRestContext(String body) {
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/WSHabeasData/Massive/';
        req.httpMethod = 'POST';
        if (body != null)
            req.requestBody = Blob.valueOf(body);

        RestContext.request = req;
        RestContext.response = new RestResponse();
    }

    private static WS_HabeasDataWrapper.ResponseWsWrapperMassive parseOutFromResponse() {
        RestResponse res = RestContext.response;
        System.assertNotEquals(null, res, 'RestResponse no debería ser null');
        System.assertNotEquals(null, res.responseBody, 'responseBody no debería ser null');
        String json = res.responseBody.toString();
        return (WS_HabeasDataWrapper.ResponseWsWrapperMassive) System.JSON.deserializeStrict(json, WS_HabeasDataWrapper.ResponseWsWrapperMassive.class);
    }

    private static String makeRequestsJson(Integer n, Boolean withMinimalFields) {
        List<String> rows = new List<String>();
        for (Integer i = 0; i < n; i++) {
            if (withMinimalFields) {
                rows.add(
                    '{"AttentionChannel":"Test Old Services",' +
                        '"FirstName":"Nombre' +
                        i +
                        '","LastName":"Apellido' +
                        i +
                        '",' +
                        '"identityType":"1","identityNumber":"' +
                        (100000 + i) +
                        '",' +
                        '"email":"t' +
                        i +
                        '@example.com","numberPhone":"30012345' +
                        String.valueOf(i).leftPad(2, '0') +
                        '","sex":"1"}'
                );
            } else {
                rows.add('{}');
            }
        }
        return '[' + String.join(rows, ',') + ']';
    }

    @IsTest
    static void test_EmptyPayload_NullBody() {
        setRestContext(null);

        WSHabeasDataMassive.doPost();

        RestResponse res = RestContext.response;
        WS_HabeasDataWrapper.ResponseWsWrapperMassive out = parseOutFromResponse();

        System.assertEquals(400, res.statusCode);
        System.assertEquals(400, out.responseCode);
        System.assertEquals(null, out.jobId);
        System.assertEquals('Script-thrown exception', out.message);
    }

    @IsTest
    static void test_EmptyPayload_EmptyString() {
        setRestContext('');

        WSHabeasDataMassive.doPost();

        RestResponse res = RestContext.response;
        WS_HabeasDataWrapper.ResponseWsWrapperMassive out = parseOutFromResponse();

        System.assertEquals(400, res.statusCode);
        System.assertEquals(400, out.responseCode);
        System.assertEquals(null, out.jobId);
        System.assertEquals('Script-thrown exception', out.message);
    }

    @IsTest
    static void test_EmptyPayload_Whitespace() {
        setRestContext('   ');

        WSHabeasDataMassive.doPost();

        RestResponse res = RestContext.response;
        WS_HabeasDataWrapper.ResponseWsWrapperMassive out = parseOutFromResponse();

        System.assertEquals(400, res.statusCode);
        System.assertEquals(400, out.responseCode);
        System.assertEquals(null, out.jobId);
        System.assertEquals('Script-thrown exception', out.message);
    }

    @IsTest
    static void test_MalformedJson() {
        setRestContext('no es json');

        WSHabeasDataMassive.doPost();

        RestResponse res = RestContext.response;
        WS_HabeasDataWrapper.ResponseWsWrapperMassive out = parseOutFromResponse();

        System.assertEquals(400, res.statusCode);
        System.assertEquals(400, out.responseCode);
        System.assertEquals(null, out.jobId);
        System.assert(out.message != null && out.message.length() > 0, 'Debe devolver el mensaje de la excepción de deserialización');
        System.assertNotEquals('Empty payload', out.message);
        System.assertNotEquals('No records received', out.message);
    }

    @IsTest
    static void test_NullLiteralJson() {
        setRestContext('null');

        WSHabeasDataMassive.doPost();

        RestResponse res = RestContext.response;
        WS_HabeasDataWrapper.ResponseWsWrapperMassive out = parseOutFromResponse();

        System.assertEquals(400, res.statusCode);
        System.assertEquals(400, out.responseCode);
        System.assertEquals(null, out.jobId);
        System.assertEquals('Script-thrown exception', out.message);
    }

    @IsTest
    static void test_EmptyArray() {
        setRestContext('[]');

        WSHabeasDataMassive.doPost();

        RestResponse res = RestContext.response;
        WS_HabeasDataWrapper.ResponseWsWrapperMassive out = parseOutFromResponse();

        System.assertEquals(400, res.statusCode);
        System.assertEquals(400, out.responseCode);
        System.assertEquals(null, out.jobId);
        System.assertEquals('Script-thrown exception', out.message);
    }

    @IsTest
    static void test_TooManyRecords_501() {
        String body = makeRequestsJson(501, false);
        setRestContext(body);

        WSHabeasDataMassive.doPost();

        RestResponse res = RestContext.response;
        WS_HabeasDataWrapper.ResponseWsWrapperMassive out = parseOutFromResponse();

        System.assertEquals(400, res.statusCode);
        System.assertEquals(400, out.responseCode);
        System.assertEquals(null, out.jobId, 'No debe encolar batch cuando hay >500 registros');
        System.assertEquals('Max 500 records per request', out.message);
    }

    @IsTest
    static void test_Success_OneRecord() {
        String body = makeRequestsJson(1, true);
        setRestContext(body);

        WSHabeasDataMassive.doPost();

        RestResponse res = RestContext.response;
        WS_HabeasDataWrapper.ResponseWsWrapperMassive out = parseOutFromResponse();

        System.assertEquals(200, res.statusCode);
        System.assertNotEquals(null, out.jobId, 'Debe devolver un jobId al encolar el batch');
        System.assertEquals('Accepted', out.message);
    }

    @IsTest
    static void test_Success_MultipleRecords() {
        String body = makeRequestsJson(3, true);
        setRestContext(body);

        WSHabeasDataMassive.doPost();

        RestResponse res = RestContext.response;
        WS_HabeasDataWrapper.ResponseWsWrapperMassive out = parseOutFromResponse();

        System.assertEquals(200, res.statusCode);
        System.assertNotEquals(null, out.jobId);
        System.assertEquals('Accepted', out.message);
    }
}