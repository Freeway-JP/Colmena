@IsTest
public class WSHabeasDataRestTest {
    private static void setRestContext(String body) {
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/v2/WSHabeasData/test';
        req.httpMethod = 'POST';
        if (body != null) {
            req.requestBody = Blob.valueOf(body);
        }

        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;
    }

    @IsTest
    static void test_constructor() {
        WSHabeasDataRest ctrl = new WSHabeasDataRest();
        System.assertNotEquals(null, ctrl);
    }

    @IsTest
    static void test_doPost_try_path_with_valid_json_objectCreated_null() {
        String jsonBody =
            '{"firstName":"John","secondName":"Q","lastName":"Doe","secondLastName":"JR",' +
            '"identityType":"CC","identityNumber":"987654321","email":"john.doe@test.com","numberPhone":"6012345678",' +
            '"dataUsePurpose":"Foo","authorizationChannel":"Portal de proveedores",' +
            '"channelType":"Digital","process":"Venta","businessCoverage":"Retail","origin":"Portal","collectionMethodType":"Form",' +
            '"companies":[{"name":"ARL","medicalHistory":true,"dataMarketing":true,"generalProcessingData":true,' +
            '"authorization2300":[{"value":true,"contactPointType":"Email","contactPoint":"john","dataUsePurpose":"x"}]}]' +
            '}';

        setRestContext(jsonBody);

        Test.startTest();
        WSHabeasDataRest.doPost();
        Test.stopTest();

        System.assertNotEquals(null, RestContext.response);
        System.assertNotEquals(null, RestContext.response.responseBody);

        String bodyOut = RestContext.response.responseBody.toString();
        System.assert(bodyOut.contains('"error":true') || bodyOut.contains('"error":false'));
        System.assertEquals(400, RestContext.response.statusCode);
    }

    @IsTest
    static void test_doPost_catch_path_with_invalid_json() {
        String invalid = '{ not a valid json }';
        setRestContext(invalid);

        Test.startTest();
        WSHabeasDataRest.doPost();
        Test.stopTest();

        System.assertEquals(400, RestContext.response.statusCode);
        System.assert(RestContext.response.responseBody.toString().contains('"status":"failed"'));
    }

    @IsTest
    static void test_doPost_catch_path_with_null_body() {
        setRestContext(null);

        Test.startTest();
        WSHabeasDataRest.doPost();
        Test.stopTest();

        System.assertEquals(400, RestContext.response.statusCode);
        String out = RestContext.response.responseBody.toString();
        System.assert(out.contains('"error":true') && out.contains('"status":"failed"'));
    }

    @IsTest
    static void test_doPost_catch_path_with_strict_unknown_field() {
        String invalidStrict = '{ "unknownField": "boom", "anotherOne": 123 }';
        setRestContext(invalidStrict);

        Test.startTest();
        WSHabeasDataRest.doPost();
        Test.stopTest();

        System.assertEquals(400, RestContext.response.statusCode);
        String out = RestContext.response.responseBody.toString();
        System.assert(out.contains('"error":true'));
        System.assert(out.contains('"status":"failed"'));
    }

    @IsTest
    static void test_doPost_catch_path_with_blank_body_but_not_null() {
        setRestContext('   \n\t   ');

        Test.startTest();
        WSHabeasDataRest.doPost();
        Test.stopTest();

        System.assertEquals(400, RestContext.response.statusCode);
        String out = RestContext.response.responseBody.toString();
        System.assert(out.contains('"error":true'));
        System.assert(out.contains('"status":"failed"'));
    }
}