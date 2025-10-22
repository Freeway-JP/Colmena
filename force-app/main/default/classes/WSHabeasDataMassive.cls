@RestResource(urlMapping='/WSHabeasData/Massive/*')
global with sharing class WSHabeasDataMassive {
    @HttpPost
    global static void doPost() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        WS_HabeasDataWrapper.ResponseWsWrapperMassive out = new WS_HabeasDataWrapper.ResponseWsWrapperMassive();

        try {
            if (req.requestBody == null || String.isBlank(req.requestBody.toString())) {
                throw new AuraHandledException('Empty payload');
            }
            List<WS_HabeasDataWrapper.RequestWSWrapper> payload = (List<WS_HabeasDataWrapper.RequestWSWrapper>) JSON.deserializeStrict(
                req.requestBody.toString(),
                List<WS_HabeasDataWrapper.RequestWSWrapper>.class
            );

            if (payload == null || payload.isEmpty())
                throw new AuraHandledException('No records received');
            if (payload.size() > 500) {
                res.statusCode = 400;
                out.jobId = null;
                out.responseCode = 400;
                out.message = 'Max 500 records per request';
            } else {
                Id jobId = Database.executeBatch(new WSHabeasDataBatch(payload), 50);
                res.statusCode = 200;
                out.jobId = jobId;
                out.responseCode = 200;
                out.message = 'Accepted';
            }
        } catch (Exception e) {
            res.statusCode = 400;
            out.jobId = null;
            out.responseCode = 400;
            out.message = e.getMessage();
        }
        res.addHeader('Content-Type', 'application/json');
        res.responseBody = Blob.valueOf(JSON.serialize(out));
    }
}