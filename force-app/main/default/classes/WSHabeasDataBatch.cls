public with sharing class WSHabeasDataBatch implements Database.Batchable<WS_HabeasDataWrapper.RequestWSWrapper>, Database.Stateful {
    private final List<WS_HabeasDataWrapper.RequestWSWrapper> payload;

    // --- Runtime counters & logging (persist across chunks thanks to Database.Stateful)
    private Id jobId;
    private Integer totalProcessed = 0;
    private Integer totalSucceeded = 0;
    private Integer totalFailed = 0;
    private List<String> errorSamples = new List<String>();
    private static final Integer MAX_ERROR_SAMPLES = 20;

    // Uniform log helper
    private void log(String level, String msg) {
        System.debug('WSHabeasDataBatch|' + level + '|jobId=' + (jobId != null ? String.valueOf(jobId) : 'n/a') + '| ' + msg);
    }

    public WSHabeasDataBatch(List<WS_HabeasDataWrapper.RequestWSWrapper> payload) {
        this.payload = (payload == null) ? new List<WS_HabeasDataWrapper.RequestWSWrapper>() : payload;
    }

    public Iterable<WS_HabeasDataWrapper.RequestWSWrapper> start(Database.BatchableContext bc) {
        this.jobId = bc.getJobId();
        log('START', 'items=' + payload.size());
        return new ListIterable(payload);
    }

    public void execute(Database.BatchableContext bc, List<WS_HabeasDataWrapper.RequestWSWrapper> scope) {
        log('EXECUTE', 'scopeSize=' + scope.size());
        Integer i = 0;
        for (WS_HabeasDataWrapper.RequestWSWrapper req : scope) {
            i++;
            try {
                WS_HabeasDataWrapper.ResponseWSWrapper r = processOne(req);
                totalProcessed++;
                if (r != null && r.error == false) {
                    totalSucceeded++;
                    log('RESULT', 'idx=' + i + ' | ok | code=' + r.responseCode);
                } else {
                    totalFailed++;
                    String em = (r != null ? r.message : 'null response');
                    if (errorSamples.size() < MAX_ERROR_SAMPLES)
                        errorSamples.add(em);
                    log('RESULT', 'idx=' + i + ' | failed | code=' + (r != null ? r.responseCode : 'n/a') + ' | msg=' + em);
                }
            } catch (Exception e) {
                System.debug('WSHabeasDataBatch.execute error: ' + e.getMessage());
            }
        }
        log(
            'LIMITS',
            'CPU=' +
                Limits.getCpuTime() +
                '/' +
                Limits.getLimitCpuTime() +
                ' | SOQL=' +
                Limits.getQueries() +
                '/' +
                Limits.getLimitQueries() +
                ' | DML=' +
                Limits.getDmlStatements() +
                '/' +
                Limits.getLimitDmlStatements()
        );
    }

    public void finish(Database.BatchableContext bc) {
        log('FINISH', 'processed=' + totalProcessed + ' | ok=' + totalSucceeded + ' | failed=' + totalFailed);
        if (!errorSamples.isEmpty()) {
            log('FINISH', 'errorSamples(' + errorSamples.size() + ')= ' + String.join(errorSamples, ' || '));
        }
    }

    private WS_HabeasDataWrapper.ResponseWSWrapper processOne(WS_HabeasDataWrapper.RequestWSWrapper req) {
        WS_HabeasDataWrapper.ResponseWSWrapper response = new WS_HabeasDataWrapper.ResponseWSWrapper();
        log('PROC', 'begin processOne');
        try {
            WSClientController clientManager = new WSClientController();
            WSHabeasDataController habeasDataManager = new WSHabeasDataController();

            log('PROC', 'calling WSClientController.ValidacionIdentidad');
            WS_HabeasDataWrapper.RequestWSWrapper requestCC = clientManager.ValidacionIdentidad(req);
            log('PROC', 'ValidacionIdentidad done');
            System.debug('requestCC ->' + requestCC);

            if (requestCC.ClientController != null) {
                log('PROC', 'clientController message: ' + requestCC.ClientController);
                response.error = true;
                response.message = requestCC.ClientController;
                response.responseCode = '201';
                response.status = 'Failed';
            } else {
                log('PROC', 'calling WSHabeasDataController.controllerHD');
                response = habeasDataManager.controllerHD(requestCC);
            }
        } catch (Exception e) {
            System.debug('WSHabeasDataBatch.processOne error: ' + e.getMessage());
            log('ERROR', 'processOne ex=' + e.getMessage() + ' | stack=' + e.getStackTraceString());
            response.error = true;
            response.message = e.getMessage();
            response.responseCode = '400';
            response.status = 'failed';
        }
        log('PROC', 'end processOne | error=' + String.valueOf(response.error) + ' | code=' + String.valueOf(response.responseCode));
        return response;
    }

    public class ListIterable implements Iterable<WS_HabeasDataWrapper.RequestWSWrapper>, Iterator<WS_HabeasDataWrapper.RequestWSWrapper> {
        private List<WS_HabeasDataWrapper.RequestWSWrapper> items;
        private Integer idx = 0;
        public ListIterable(List<WS_HabeasDataWrapper.RequestWSWrapper> src) {
            this.items = src;
        }
        public Iterator<WS_HabeasDataWrapper.RequestWSWrapper> iterator() {
            return this;
        }
        public Boolean hasNext() {
            return idx < items.size();
        }
        public WS_HabeasDataWrapper.RequestWSWrapper next() {
            return items[idx++];
        }
    }
}