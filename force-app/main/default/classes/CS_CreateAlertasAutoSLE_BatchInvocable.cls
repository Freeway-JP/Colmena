/***************************************************************************************************************************
 * Nombre de la Clase Apex : CS_CreateAlertasAutoSLE_BatchInvocable
 * Versión                 : 1.0
 * Fecha de Creación       : 07/03/2025
 * Funcionalidad           : Replicación de Alertas SLE a los Participantes de Poliza asociados a una Poliza de Seguro. 
 * Test                    : CS_CreateAlertasAutoSLE_BatchInvTest
 *--------------------------------------------------------------------------------------------------------------------------
 *                                              HISTORIAL DE MODIFICACIONES:
 *--------------------------------------------------------------------------------------------------------------------------
 * Desarrollador         Fecha           Descripción
 *--------------------------------------------------------------------------------------------------------------------------
 * Frank Tovar           07/03/2025      Creación
 *--------------------------------------------------------------------------------------------------------------------------
 **************************************************************************************************************************/
global with sharing class CS_CreateAlertasAutoSLE_BatchInvocable implements Database.Batchable<sObject>, Database.Stateful {

    private FinServ__Alert__c alertToDuplicate; // Alerta que se va a duplicar durante la ejecución del batch.
    private Id insurancePolicyId; // ID de la póliza de seguro asociada a la alerta.
    
    /**
     * Clase interna para manejar las variables de entrada del proceso invocable.
     */
    public class InputVariables {

        /**
         * @description Alerta SLE que se va a duplicar.
         * @required true
         */
        @InvocableVariable(label='Alerta SLE <FinServ__Alert__c> a duplicar' description='Alerta SLE <FinServ__Alert__c> a duplicar' required=true)
        public FinServ__Alert__c inputAlertSLE;

        /**
         * @description ID de la póliza de seguro para obtener los participantes asociados.
         * @required true
         */
        @InvocableVariable(label='Id de la Poliza de Seguro <InsurancePolicy> para obtener los Participantes de Poliza asociados' description='Id de la Poliza de Seguro <InsurancePolicy> para obtener los Participantes de Poliza asociados' required=true)
        public Id inputInsurancePolicyId;
    }

    /**
     * @description Método invocable para iniciar el proceso batch de creación de alertas automatizadas SLE.
     */
    @InvocableMethod(label='Crear Alertas Auto. SLE - Batch' description='Crear Alertas Auto. SLE - Batch' category='Alert')
    public static void run(List<InputVariables> inputList) {
        Integer sizeBatch = Integer.valueOf(System.Label.sizeBatchCreateAlertsSLE);
        for (InputVariables input : inputList) {
            CS_CreateAlertasAutoSLE_BatchInvocable batchInstance = new CS_CreateAlertasAutoSLE_BatchInvocable(input);
           	Database.executeBatch(batchInstance, sizeBatch);
        }
        
    }

    // Constructor para recibir los datos del flujo
    public CS_CreateAlertasAutoSLE_BatchInvocable(InputVariables inputList) {
        this.alertToDuplicate = inputList.inputAlertSLE;
        this.insurancePolicyId = inputList.inputInsurancePolicyId;
    }

    /**
     * Batchable
     */

    private Integer recordsProcessed = 0; // Contador de registros procesados
    private Integer failureCount = 0; // Contador de registros fallidos

    /**
     * @description Método que define la consulta para recuperar los registros a procesar.
     * @param context Contexto del batch.
     * @return QueryLocator con los registros a procesar.
     */
    public Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator([SELECT Id FROM InsurancePolicyParticipant WHERE InsurancePolicyId = :this.insurancePolicyId]);
    }

    /**
     * @description Método que procesa los registros en lotes.
     * @param context Contexto del batch.
     * @param records Lista de registros a procesar.
     */
    public void execute(Database.BatchableContext context, List<InsurancePolicyParticipant> scope) {       
        List<FinServ__Alert__c> listAlertsToCreate = new List<FinServ__Alert__c>();
        Set<String> existingAlertsFromParticipants = new Set<String>();
        try{
            for (FinServ__Alert__c existingAlert : [SELECT ModuloSLE__c, FinServ__Message__c, InsurancePolicyParticipant__c 
                                                    FROM FinServ__Alert__c 
                                                    WHERE FinServ__Message__c = :this.alertToDuplicate.FinServ__Message__c 
                                                    AND ModuloSLE__c = :this.alertToDuplicate.ModuloSLE__c 
                                                    AND InsurancePolicyParticipant__c IN :scope]) 
            { existingAlertsFromParticipants.add(existingAlert.InsurancePolicyParticipant__c); }
            
            for (InsurancePolicyParticipant record : scope) {
                if (!existingAlertsFromParticipants.contains(record.Id)) { 
                    FinServ__Alert__c alertTemp = new FinServ__Alert__c(
                        FinServ__Message__c = this.alertToDuplicate.FinServ__Message__c, 
                        ModuloSLE__c = this.alertToDuplicate.ModuloSLE__c, 
                        FinServ__Severity__c = this.alertToDuplicate.FinServ__Severity__c, 
                        FinServ__Priority__c = this.alertToDuplicate.FinServ__Priority__c, 
                        FinServ__Active__c = true, 
                        InsurancePolicyParticipant__c = record.Id
                    ); 
                    listAlertsToCreate.add(alertTemp);
                    recordsProcessed++;
                }
            }

            if(!listAlertsToCreate.isEmpty()) {
                List<Database.SaveResult> saveResults = Database.insert(listAlertsToCreate, false); 
                for(Database.SaveResult sr : saveResults) {
                    if(!sr.isSuccess()) { 
                        for(Database.Error error : sr.getErrors()) { 
                            System.debug('Error occurred for record with Id: ' + sr.getId() + ', Error Message: ' + error.getMessage()); 
                        } 
                    }
                }
            }
        }catch(Exception ex){
            System.debug('Exception Catch: ' + ex.getMessage());
            failureCount++;
        }
    }

    /**
     * @description Método que se ejecuta al finalizar el batch.
     * @param context Contexto del batch.
     */
    public void finish(Database.BatchableContext context) {
        System.debug('CS_CreateAlertasAutoSLE_BatchInvocable Apex Job has completed = Total Success Count: ' + recordsProcessed + ' | Total Failure Count: ' + failureCount);
    }

}