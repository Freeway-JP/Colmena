/**
 * ===================================================================================
 * @className        WSHabeasDataRest
 * @description      Esta clase es la controladora que se encargar de contener todos los metodos de integracion involucrados para habeas data.
 * @email            Carlos.vivas@VassCompany.com
 * @version          V0.1
 * @testClass        WSHabeasDataTest
 * @dateCreated      2025/11/08
 * ==============================================================================================================================
 */
@RestResource(urlMapping='/v2/WSHabeasData/*')
global with sharing class WSHabeasDataRest {
    public WSHabeasDataRest() {
    }

    @httpPost
    global static void doPost() {
        WSHabeasDataAPIDto.HabeasDataDto request = new WSHabeasDataAPIDto.HabeasDataDto();
        WSHabeasDataAPIDto.ResponseDto response = new WSHabeasDataAPIDto.ResponseDto();

        RestRequest requestContext = RestContext.request;
        RestResponse responseContext = RestContext.response;

        String params = requestContext.requestBody != null ? requestContext.requestBody.toString().trim() : '';

        try {
            request = (WSHabeasDataAPIDto.HabeasDataDto) System.JSON.deserializeStrict(params, WSHabeasDataAPIDto.HabeasDataDto.class);
            WSHabeasDataService service = new WSHabeasDataService();
            response = service.processAuth(request);

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