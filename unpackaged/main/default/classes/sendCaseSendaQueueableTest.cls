/***************************************************************************************************************************
 * Nombre de la Clase Apex : sendCaseSendaQueueable
 * Versión                 : 1.0
 * Fecha de Creación       : 28/04/2025
 * Funcionalidad           : Invocar la clase sendCaseSenda a manera de Colas (Queueable) 
 * ApexClass               : sendCaseSendaQueueable
 *--------------------------------------------------------------------------------------------------------------------------
 *                                              HISTORIAL DE MODIFICACIONES:
 *--------------------------------------------------------------------------------------------------------------------------
 * Desarrollador         Fecha           Descripción
 *--------------------------------------------------------------------------------------------------------------------------
 * Frank Tovar           28/04/2025      Creación
 *--------------------------------------------------------------------------------------------------------------------------
 **************************************************************************************************************************/
@isTest
private class sendCaseSendaQueueableTest {
	
    @isTest
    static void testExecute() {
        Case testCase = CS_TestDataFactory.createCase(true);
        Test.startTest();
        System.enqueueJob(new sendCaseSendaQueueable(testCase.Id));
        Test.stopTest();
    }
    
}