/***************************************************************************************************************************
 * Nombre de la Clase Apex : CS_CreateAlertasAutoSLE_BatchInvTest
 * Versión                 : 1.0
 * Fecha de Creación       : 07/03/2025
 * Funcionalidad           : Replicación de Alertas SLE a los Participantes de Poliza asociados a una Poliza de Seguro. 
 * Class                   : CS_CreateAlertasAutoSLE_BatchInvocable
 *--------------------------------------------------------------------------------------------------------------------------
 *                                              HISTORIAL DE MODIFICACIONES:
 *--------------------------------------------------------------------------------------------------------------------------
 * Desarrollador         Fecha           Descripción
 *--------------------------------------------------------------------------------------------------------------------------
 * Frank Tovar           07/03/2025      Creación
 *--------------------------------------------------------------------------------------------------------------------------
 **************************************************************************************************************************/
@isTest
public with sharing class CS_CreateAlertasAutoSLE_BatchInvTest {

    /**
     * @description Método de prueba para la ejecución del batch con datos válidos.
     */
    @isTest
    static void testBatchExecution() {
        
        // Crear Account
        Id AccountRecordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CS_Juridico').getRecordTypeId();
        Account testAccount = new Account(RecordTypeId=AccountRecordTypeId,Name='Cuenta Juridico');
        insert testAccount;
        System.debug('testAccount => '+testAccount);
        
        // Crear InsurancePolicy
        Id idRecordTypeInsurancePolicy = Schema.SObjectType.InsurancePolicy.getRecordTypeInfosByDeveloperName().get('CS_Seguro_de_vida').getRecordTypeId();
        InsurancePolicy testInsurancePolicy = new InsurancePolicy();
        testInsurancePolicy.Name = 'Test Policy';
        testInsurancePolicy.RecordTypeId = idRecordTypeInsurancePolicy;
        testInsurancePolicy.NameInsuredId = testAccount.Id;
        insert testInsurancePolicy;
        System.debug('testInsurancePolicy => '+testInsurancePolicy);

        // Crear InsurancePolicyParticipant
        Id idRecordTypeInsurancePolicyParticipant = Schema.SObjectType.InsurancePolicyParticipant.getRecordTypeInfosByDeveloperName().get('CS_Asegurado').getRecordTypeId();
        InsurancePolicyParticipant newInsurancePolicyParticipant = new InsurancePolicyParticipant();
        newInsurancePolicyParticipant.Role = '0';
        newInsurancePolicyParticipant.InsurancePolicyId = testInsurancePolicy.Id;
        newInsurancePolicyParticipant.RecordTypeId = idRecordTypeInsurancePolicyParticipant;
        newInsurancePolicyParticipant.PrimaryParticipantAccountId = testAccount.Id;
        insert newInsurancePolicyParticipant;
        System.debug('newInsurancePolicyParticipant => '+newInsurancePolicyParticipant);
        
        // Crear FinServ__Alert__c
        Id idRecordTypeFinServAlert = Schema.SObjectType.FinServ__Alert__c.getRecordTypeInfosByDeveloperName().get('LEAlerts').getRecordTypeId();
        FinServ__Alert__c newFinServAlert = new FinServ__Alert__c();
        newFinServAlert.FinServ__Insurance_Policy__c = testInsurancePolicy.Id;
        newFinServAlert.RecordTypeId = idRecordTypeFinServAlert;
        newFinServAlert.FinServ__Active__c = true;
        newFinServAlert.FinServ__Message__c = 'Test Msg';
        newFinServAlert.ModuloSLE__c = 'Medicalización';
        insert newFinServAlert;
        System.debug('newFinServAlert => '+newFinServAlert);
        
        // Crear la estructura de InputVariables con los datos de prueba
        CS_CreateAlertasAutoSLE_BatchInvocable.InputVariables inputsFlow = new CS_CreateAlertasAutoSLE_BatchInvocable.InputVariables();
        inputsFlow.inputAlertSLE = newFinServAlert;
        inputsFlow.inputInsurancePolicyId = testInsurancePolicy.Id;
        // Ejecutar el batch con los datos de prueba
        List<CS_CreateAlertasAutoSLE_BatchInvocable.InputVariables> inputList = new List<CS_CreateAlertasAutoSLE_BatchInvocable.InputVariables>{ inputsFlow };
        // Iniciar el batch
        Test.startTest();
        CS_CreateAlertasAutoSLE_BatchInvocable.run(inputList);
        //Database.executeBatch(batchJob);
        Test.stopTest();
        // Validar que las alertas fueron creadas
        List<FinServ__Alert__c> alerts = [SELECT Id FROM FinServ__Alert__c WHERE InsurancePolicyParticipant__c != null];
        System.assert(alerts.size() > 0, 'Se esperaba al menos una alerta.');
    }

}