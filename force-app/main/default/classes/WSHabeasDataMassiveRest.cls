@RestResource(urlMapping='/v2/WSHabeasData/Massive/*')
global with sharing class WSHabeasDataMassiveRest {
    @HttpPost
    global static void doPost() {
        WSHabeasDataAPIDto.MassiveDto request = new WSHabeasDataAPIDto.MassiveDto();
        WSHabeasDataAPIDto.MassiveResponseDto response = new WSHabeasDataAPIDto.MassiveResponseDto();

        RestRequest requestContext = RestContext.request;
        RestResponse responseContext = RestContext.response;

        try {
            if (requestContext.requestBody == null || String.isBlank(requestContext.requestBody.toString())) {
                throw new AuraHandledException('Empty payload');
            }
            WSHabeasDataAPIDto.MassiveDto payload = (WSHabeasDataAPIDto.MassiveDto) JSON.deserializeStrict(
                requestContext.requestBody.toString(),
                WSHabeasDataAPIDto.MassiveDto.class
            );

            if (payload == null || payload.massiveAuth.isEmpty())
                throw new AuraHandledException('No records received');
            if (payload.massiveAuth.size() > 600) {
                responseContext.statusCode = 400;
                response.jobId = null;
                response.responseCode = 600;
                response.message = 'Max 600 records per request';
            } else {
                Id jobId = Database.executeBatch(new WsHabeasDataMassiveBach(payload.massiveAuth, payload.massiveAuthType), 50);
                responseContext.statusCode = 200;
                response.jobId = jobId;
                response.responseCode = 200;
                response.message = 'Accepted';
            }
        } catch (Exception e) {
            responseContext.statusCode = 400;
            response.jobId = null;
            response.responseCode = 400;
            response.message = e.getMessage();
        }
        responseContext.addHeader('Content-Type', 'application/json');
        responseContext.responseBody = Blob.valueOf(JSON.serialize(response));
    }
}