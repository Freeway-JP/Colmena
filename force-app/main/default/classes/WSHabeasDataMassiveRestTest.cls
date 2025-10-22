@IsTest
private class WSHabeasDataMassiveRestTest {
    private static void setupReq(String body) {
        RestRequest req = new RestRequest();
        req.httpMethod = 'POST';
        req.requestURI = '/services/apexrest/v2/WSHabeasData/Massive/';
        if (body != null)
            req.requestBody = Blob.valueOf(body);
        RestContext.request = req;
        RestContext.response = new RestResponse();
    }

    @IsTest
    static void test_EmptyPayload() {
        setupReq('');
        WSHabeasDataMassiveRest.doPost();
        RestResponse res = RestContext.response;
        System.assertEquals(400, res.statusCode);
        WSHabeasDataAPIDto.MassiveResponseDto out = (WSHabeasDataAPIDto.MassiveResponseDto) JSON.deserialize(
            res.responseBody.toString(),
            WSHabeasDataAPIDto.MassiveResponseDto.class
        );
        System.assertEquals(400, out.responseCode);
        System.assertEquals('Script-thrown exception', out.message);
        System.assertEquals(null, out.jobId);
        System.assertEquals('application/json', res.headers.get('Content-Type'));
    }

    @IsTest
    static void test_InvalidJson() {
        setupReq('not-json');
        WSHabeasDataMassiveRest.doPost();
        RestResponse res = RestContext.response;
        System.assertEquals(400, res.statusCode);
        WSHabeasDataAPIDto.MassiveResponseDto out = (WSHabeasDataAPIDto.MassiveResponseDto) JSON.deserialize(
            res.responseBody.toString(),
            WSHabeasDataAPIDto.MassiveResponseDto.class
        );
        System.assertEquals(400, out.responseCode);
        System.assertNotEquals(null, out.message);
        System.assertEquals(null, out.jobId);
        System.assertEquals('application/json', res.headers.get('Content-Type'));
    }

    @IsTest
    static void test_NoRecords() {
        setupReq('{"massiveAuth":[],"massiveAuthType":"X"}');
        WSHabeasDataMassiveRest.doPost();
        RestResponse res = RestContext.response;
        System.assertEquals(400, res.statusCode);
        WSHabeasDataAPIDto.MassiveResponseDto out = (WSHabeasDataAPIDto.MassiveResponseDto) JSON.deserialize(
            res.responseBody.toString(),
            WSHabeasDataAPIDto.MassiveResponseDto.class
        );
        System.assertEquals(400, out.responseCode);
        System.assertEquals('Script-thrown exception', out.message);
        System.assertEquals(null, out.jobId);
        System.assertEquals('application/json', res.headers.get('Content-Type'));
    }

    @IsTest
    static void test_TooManyRecords() {
        List<String> items = new List<String>();
        for (Integer i = 0; i < 601; i++)
            items.add('{}');
        setupReq('{"massiveAuth":[' + String.join(items, ',') + '],"massiveAuthType":"X"}');
        WSHabeasDataMassiveRest.doPost();
        RestResponse res = RestContext.response;
        System.assertEquals(400, res.statusCode);
        WSHabeasDataAPIDto.MassiveResponseDto out = (WSHabeasDataAPIDto.MassiveResponseDto) JSON.deserialize(
            res.responseBody.toString(),
            WSHabeasDataAPIDto.MassiveResponseDto.class
        );
        System.assertEquals(600, out.responseCode);
        System.assertEquals('Max 600 records per request', out.message);
        System.assertEquals(null, out.jobId);
        System.assertEquals('application/json', res.headers.get('Content-Type'));
    }

    @IsTest(SeeAllData=true)
    static void test_Success_CMDT_Aware() {
        Map<String, HD_API_Rules__mdt> allRules = HD_API_Rules__mdt.getAll();
        if (allRules == null || allRules.isEmpty()) {
            System.assert(true);
            return;
        }
        HD_API_Rules__mdt r = allRules.values()[0];
        String one =
            '{"account":{"firstName":"Ana","lastName":"Lopez","identityType":"CC","identityNumber":"1","email":"a@b.com","numberPhone":"123"},' +
            '"consent":{"authorizationChannel":"' +
            r.authorizationChannel__c +
            '","dataUsePurpose":"' +
            r.dataUsePurpose__c +
            '"},' +
            '"companies":["' +
            r.BusinessBrand__c +
            '"]}';
        String body = '{"massiveAuth":[' + one + '],"massiveAuthType":"TEST"}';

        setupReq(body);
        WSHabeasDataMassiveRest.doPost();
        RestResponse res = RestContext.response;
        System.assertEquals(200, res.statusCode);
        WSHabeasDataAPIDto.MassiveResponseDto out = (WSHabeasDataAPIDto.MassiveResponseDto) JSON.deserialize(
            res.responseBody.toString(),
            WSHabeasDataAPIDto.MassiveResponseDto.class
        );
        System.assertEquals(200, out.responseCode);
        System.assertEquals('Accepted', out.message);
        System.assertNotEquals(null, out.jobId);
        System.assertEquals('application/json', res.headers.get('Content-Type'));
    }
}