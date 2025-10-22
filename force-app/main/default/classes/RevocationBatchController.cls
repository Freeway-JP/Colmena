/**
 * @description Controller for RevocationBatchMonitor LWC component
 * Provides methods to check batch job status and retrieve results
 */
public with sharing class RevocationBatchController {

    /**
     * @description Get the status of a batch job
     * @param batchJobId The ID of the batch job
     * @return Map with batch job details
     */
    @AuraEnabled(cacheable=false)
    public static Map<String, Object> getBatchStatus(Id batchJobId) {
        try {
            AsyncApexJob job = [
                SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
                       TotalJobItems, CreatedDate, CompletedDate,
                       ExtendedStatus
                FROM AsyncApexJob
                WHERE Id = :batchJobId
                LIMIT 1
            ];

            Map<String, Object> result = new Map<String, Object>();
            result.put('status', job.Status);
            result.put('processed', job.JobItemsProcessed);
            result.put('total', job.TotalJobItems);
            result.put('errors', job.NumberOfErrors);
            result.put('createdDate', job.CreatedDate);
            result.put('completedDate', job.CompletedDate);
            result.put('extendedStatus', job.ExtendedStatus);

            // Calcular porcentaje
            if (job.TotalJobItems > 0) {
                Decimal percentage = (Decimal.valueOf(job.JobItemsProcessed) / Decimal.valueOf(job.TotalJobItems)) * 100;
                result.put('percentComplete', percentage.setScale(0));
            } else {
                result.put('percentComplete', 0);
            }

            return result;

        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving batch status: ' + e.getMessage());
        }
    }

    /**
     * @description Launch a revocation batch job
     * @param partyId The Individual ID to process
     * @return Map with batch job ID and details
     */
    @AuraEnabled
    public static Map<String, Object> launchRevocationBatch(Id partyId) {
        try {
            // Extraer datos
            RevocationDataExtractHD extractor = new RevocationDataExtractHD();
            Map<String, Object> extractInput = new Map<String, Object>();
            Map<String, Object> extractOutput = new Map<String, Object>();
            extractInput.put('partyId', partyId);
            extractor.invokeMethod('extractRevocationData', extractInput, extractOutput, null);

            if (extractOutput.containsKey('error')) {
                throw new AuraHandledException((String) extractOutput.get('error'));
            }

            // Transformar datos
            RevocationDataTransformer transformer = new RevocationDataTransformer();
            Map<String, Object> transformInput = new Map<String, Object>();
            Map<String, Object> transformOutput = new Map<String, Object>();
            transformInput.put('input', extractOutput);
            transformer.invokeMethod('transformRevocationData', transformInput, transformOutput, null);

            if (transformOutput.containsKey('error')) {
                throw new AuraHandledException((String) transformOutput.get('error'));
            }

            // Lanzar batch
            WSRevocationProcessAction processor = new WSRevocationProcessAction();
            Map<String, Object> processInput = new Map<String, Object>();
            Map<String, Object> processOutput = new Map<String, Object>();
            processInput.put('transformedDataList', transformOutput.get('transformedDataList'));
            processor.invokeMethod('processRevocations', processInput, processOutput, null);

            if (processOutput.containsKey('error')) {
                throw new AuraHandledException((String) processOutput.get('error'));
            }

            return processOutput;

        } catch (Exception e) {
            throw new AuraHandledException('Error launching batch: ' + e.getMessage());
        }
    }
}