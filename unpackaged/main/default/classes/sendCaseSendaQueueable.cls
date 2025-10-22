/***************************************************************************************************************************
 * Nombre de la Clase Apex : sendCaseSendaQueueable
 * Versión                 : 1.0
 * Fecha de Creación       : 28/04/2025
 * Funcionalidad           : Invocar la clase sendCaseSenda a manera de Colas (Queueable) 
 * Test                    : sendCaseSendaQueueableTest
 *--------------------------------------------------------------------------------------------------------------------------
 *                                              HISTORIAL DE MODIFICACIONES:
 *--------------------------------------------------------------------------------------------------------------------------
 * Desarrollador         Fecha           Descripción
 *--------------------------------------------------------------------------------------------------------------------------
 * Frank Tovar           28/04/2025      Creación
 *--------------------------------------------------------------------------------------------------------------------------
 **************************************************************************************************************************/
public class sendCaseSendaQueueable implements Queueable {
    
    private String caseId;
    public sendCaseSendaQueueable(String caseId) {
        this.caseId = caseId;
    }

    public void execute(QueueableContext context) {
        sendCaseSenda.createOrUpdateCaseSenda(caseId);
    }
}