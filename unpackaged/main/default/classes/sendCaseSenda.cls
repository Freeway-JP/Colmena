public class sendCaseSenda {
    
     @future(callout=true)
     public static void createOrUpdateCaseSenda(String idString)
     {
        Set<id> parentIdSet = new Set<id>();
        try{
            Case caso = [Select Id, CaseNumber, RecordType.Name, Description, CS_MacroMotivo__c, Reason, SubReason__c,AppointmentDateTime__c,
                        CS_Submotivo__c, Status, CS_FechaTentativaDeCierre__c, CS_Semaforotexto__c, CS_Numero_de_ATEL__c, CreatedDate From Case where id =: idString];         
            if (caso != null && ((caso.RecordType.Name == 'Queja' || caso.RecordType.Name == 'Solicitud' || caso.RecordType.Name == 'Derecho de peticion' 
                                  || caso.RecordType.Name == 'Incidente' || caso.RecordType.Name == 'Queja Supersalud' || caso.RecordType.Name == 'Requerimiento Jurídico' 
                                  || caso.RecordType.Name == 'Queja Superintendencia' || caso.RecordType.Name == 'Solicitud PQRS'
                                  || caso.RecordType.Name == 'Derecho de Petición PQRS' || caso.RecordType.Name == 'Incidente PQRS') && caso.CS_Numero_de_ATEL__c != null)){
                Claim indemnizacionATEL = [Select Id, RecordType.Name, Name From Claim where id =: caso.CS_Numero_de_ATEL__c AND RecordType.Name IN ('AT','EL')];
                parentIdSet.add(caso.Id);
                CaseTaskWrapper caseTaskWrapper = new CaseTaskWrapper(caso, indemnizacionATEL);
                TaskWrapper tasks1 = null;
                List<TaskWrapper> tasksList = new List<TaskWrapper>();
                Map<Id, List<TaskWrapper>> mapOfChildObject = new Map<Id, List<TaskWrapper>>();
                For(Task tarea : [Select Id, Subject,ActivityDate,Status,Description,OwnerId, createdDate, RecordType.Name,
                                  WhatId, Owner.Name,  Owner.UserRole.Name From Task Where WhatId In:parentIdSet]){
                    //Solo se envian tareas específicas
                        if (tarea.Subject == 'Enviar a Senda Médico' && tarea.RecordType.Name == 'Tareas'){
                        tasks1 = new TaskWrapper(tarea);
                        tasksList.add(tasks1);
                    }
                }
                caseTaskWrapper.taskWrapper = tasksList; 
                String token = AuthenticationMulesoft.GenerateToken();
                //llamado al fileConfig
                FileConfigMulesoft fileConfMulesoft = new FileConfigMulesoft('cs-salesforce-crm-xapi');
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                request.setEndpoint(fileConfMulesoft.urlMulesoft);
                request.setMethod('POST');
                request.setHeader('Content-Type', 'application/json;charset=UTF-8');
                request.setHeader('Authorization', 'Bearer '+token);
                request.setHeader('client_id', fileConfMulesoft.client_id); 
                request.setHeader('client_secret', fileConfMulesoft.client_secret);
                // Set the body as a JSON object
                System.debug('Petición');
				System.debug(caseTaskWrapper);
                request.setBody(JSON.serialize(caseTaskWrapper));
                HttpResponse response = http.send(request);
                System.debug('despues de mule');
                // Parse the JSON response
                if(response.getStatusCode() != 200) {
                    System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                }
                if(response.getStatusCode() == 200) {
                    System.debug('Kelly respoindió bien. ' + response.getStatusCode() + ' ' + response.getStatus());
                }
            }
        } catch (Exception e) {
            System.debug(e);
        }
    }
}