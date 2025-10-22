global without sharing class WSRevocationProcessAction implements Callable {

    private static final String PROCESS_REVOCATIONS_METHOD = 'processRevocations';

    global Object call(String action, Map<String, Object> args) {
        Map<String, Object> input = (Map<String, Object>) args.get('input');
        Map<String, Object> output = (Map<String, Object>) args.get('output');
        Map<String, Object> options = (Map<String, Object>) args.get('options');
        return invokeMethod(action, input, output, options);
    }

    global Boolean invokeMethod(String methodName, Map<String, Object> inputMap, Map<String, Object> outMap, Map<String, Object> options) {
        Boolean result = true;
        try {
            if (methodName.equalsIgnoreCase(PROCESS_REVOCATIONS_METHOD)) {
                processRevocations(inputMap, outMap);
            } else {
                outMap.put('result', '');
                result = false;
            }
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'WSRevocationProcessAction - Error in invokeMethod: ' + e.getMessage());
            outMap.put('error', e.getMessage());
            return false;
        }
        return result;
    }

    /**
     * @description Launches a batch job to process revocations asynchronously
     * @param inputMap Contains 'transformedDataList' with the data to process
     * @param outMap Returns the batch job ID and total records to process
     */
    public void processRevocations(Map<String, Object> inputMap, Map<String, Object> outMap) {
        List<Object> transformedDataList = (List<Object>) inputMap.get('transformedDataList');

        if (transformedDataList == null || transformedDataList.isEmpty()) {
            outMap.put('error', 'No transformed data found');
            return;
        }

        // Lanzar el batch para procesar de forma asíncrona
        RevocationBatch batch = new RevocationBatch(transformedDataList);
        Id batchJobId = Database.executeBatch(batch, 1); // Procesar 1 tratamiento a la vez

        outMap.put('batchJobId', batchJobId);
        outMap.put('totalRecords', transformedDataList.size());
        outMap.put('message', 'Batch job launched successfully. Processing ' + transformedDataList.size() + ' treatments.');

        System.debug('WSRevocationProcessAction - Batch job launched: ' + batchJobId + ' for ' + transformedDataList.size() + ' treatments');
    }

}