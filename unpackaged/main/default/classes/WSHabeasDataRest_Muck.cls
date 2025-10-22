@RestResource(urlMapping='/v2/WSHabeasDataMuck/*')
global with sharing class WSHabeasDataRest_Muck {
    public WSHabeasDataRest_Muck() {
    }

    @httpPost
    global static void doPost() {
        WSHabeasDataExtendWrapper.HabeasDataDto request = new WSHabeasDataExtendWrapper.HabeasDataDto();
        WSHabeasDataExtendWrapper.HabeasDataResponseDto response = new WSHabeasDataExtendWrapper.HabeasDataResponseDto();

        RestRequest requestContext = RestContext.request;
        RestResponse responseContext = RestContext.response;

        String params = requestContext.requestBody != null ? requestContext.requestBody.toString().trim() : '';
        //System.debug('params--->' + params);

        try {
            request = (WSHabeasDataExtendWrapper.HabeasDataDto) System.JSON.deserializeStrict(params, WSHabeasDataExtendWrapper.HabeasDataDto.class);
            WSHabeasDataService service = new WSHabeasDataService();
            //response = service.processAuth(request);
            response = service.processAuth_V2(request);

            responseContext.addHeader('Content-Type', 'application/json');
            responseContext.responseBody = Blob.valueOf(JSON.serialize(response));
            responseContext.statusCode = response.responseCode;
        } catch (Exception e) {
            System.debug('WSHabeasDataRest: ' + e.getMessage());
            response.error = true;
            response.message = e.getMessage();
            response.responseCode = 400;
            response.status = 'failed';

            responseContext.addHeader('Content-Type', 'application/json');
            responseContext.responseBody = Blob.valueOf(JSON.serialize(response));
            responseContext.statusCode = response.responseCode; // Bad Request
            return;
        }
    }
}