/**
 * @description Batch class to process consent revocations in batches
 * Processes transformedDataList from RevocationDataTransformer one treatment at a time
 *
 * Example usage:
 * List<Object> transformedDataList = ... // from RevocationDataTransformer
 * RevocationBatch batch = new RevocationBatch(transformedDataList);
 * Database.executeBatch(batch, 1); // Process 1 treatment at a time
 */
global class RevocationBatch implements Database.Batchable<Object> {

    private List<Object> transformedDataList;

    /**
     * @description Constructor
     * @param data List of transformed data from RevocationDataTransformer
     */
    global RevocationBatch(List<Object> data) {
        this.transformedDataList = data != null ? data : new List<Object>();
    }

    /**
     * @description Start method - returns the list of treatments to process
     * @param BC BatchableContext
     * @return Iterable<Object> List of treatments to process
     */
    global Iterable<Object> start(Database.BatchableContext BC) {
        return transformedDataList;
    }

    /**
     * @description Execute method - processes each batch of treatments
     * @param BC BatchableContext
     * @param scope List of treatments in current batch (typically 1 treatment)
     */
    global void execute(Database.BatchableContext BC, List<Object> scope) {
        // Procesar cada tratamiento en el scope actual
        for (Object treatment : scope) {
            try {
                Map<String, Object> treatmentData = (Map<String, Object>) treatment;

                // Convertir a DTO usando JSON
                String jsonData = JSON.serialize(treatmentData);
                WSHabeasDataExtendWrapper.HabeasDataDto habeasRequest =
                    (WSHabeasDataExtendWrapper.HabeasDataDto) JSON.deserialize(
                        jsonData,
                        WSHabeasDataExtendWrapper.HabeasDataDto.class
                    );

                // Llamar al servicio para procesar
                WSHabeasDataService habeasService = new WSHabeasDataService();
                WSHabeasDataExtendWrapper.HabeasDataResponseDto response =
                    habeasService.processAuth_V2(habeasRequest);

                // Log resultado exitoso
                System.debug('Successfully processed treatment: ' +
                             treatmentData.get('identityType') + ' ' +
                             treatmentData.get('identityNumber') +
                             ' - Response: ' + response);

            } catch (Exception e) {
                System.debug('Exception processing treatment: ' + e.getMessage());
                System.debug('Stack trace: ' + e.getStackTraceString());
            }
        }
    }

    /**
     * @description Finish method - executes after all batches complete
     * @param BC BatchableContext
     */
    global void finish(Database.BatchableContext BC) {
        System.debug('RevocationBatch completed. Job Id: ' + BC.getJobId());
    }
}