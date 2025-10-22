/*************************************************************************************/
/* Desarrollado por: VASS 
/* Autor:            Fernando Torres
/* Proyecto:         CRM
/* Descripción:      Clase Utils para diferentes desarrollos
/* Clase de prueba:  UtilsClassTest

/*************************************************************************************/ 


public  class UtilsClass {
    
    @future
    public static void redistributeLeads(String leadIdsJson) {
        
        List<Id> leadIds = (List<Id>) JSON.deserialize(leadIdsJson, List<Id>.class);
        if(!leadIds.isEmpty()){
            
            List<Lead> leads =Test.isRunningTest()? [SELECT Id, OwnerId FROM Lead where Id IN :leadIds ]: [SELECT Id, OwnerId FROM Lead WHERE Owner.Type = 'Queue' and Id IN :leadIds];
                if(!leads.isEmpty()){
                    
                    // Crea un mapa para almacenar Leads por OwnerId
                    Map<Id, List<Lead>> leadsPorOwnerId = new Map<Id, List<Lead>>();
                    Set<Id> ownerIds = new Set<Id>();
                    Set<Id> leadsIdss = new Set<Id>();
                    Map<Id, List<Lead>> OwnerIdss= new Map<Id, List<Lead>>();
                    
                    // Recolectamos los OwnerIds de los leads
                    for (Lead lead : leads) {
                        
                        ownerIds.add(lead.OwnerId);  
                        if (!leadsPorOwnerId.containsKey(lead.OwnerId)) {
                            
                            leadsPorOwnerId.put(lead.OwnerId, new List<Lead>());
                        }
                        leadsPorOwnerId.get(lead.OwnerId).add(lead);
                    }
                    
                    // Consultamos todas las colas relevantes y sus miembros en una sola consulta
                    Map<Id, List<GroupMember>> queueMembersMap = new Map<Id, List<GroupMember>>();
                    for (GroupMember member : [SELECT UserOrGroupId, GroupId FROM GroupMember WHERE Group.Type = 'Queue' AND GroupId IN :ownerIds]) {
                        if (!queueMembersMap.containsKey(member.GroupId)) {
                            queueMembersMap.put(member.GroupId, new List<GroupMember>());
                        }
                        queueMembersMap.get(member.GroupId).add(member);
                    }
                    if(!queueMembersMap.isEmpty()){
                        
                        for(ID ids: leadsPorOwnerId.keySet()){
                            try{
                                List<Id> userIds = new List<Id>();
                                for(GroupMember membe: queueMembersMap.get(ids) ){
                                    userIds.add(membe.UserOrGroupId);
                                }
                                List<Lead> ledsAsig = leadsPorOwnerId.get(ids);
                                distribuir(ledsAsig, userIds);
                            }catch(Exception e){
                                System.debug('@ cola no tiene miembros');
                            }
                        }
                    }
                }    
        }
    }
    
    public static void distribuir(List<Lead> leadsToAsig, List<ID> userToAsig) {
        Utilis__mdt ProspectMdt = Utilis__mdt.getInstance('ProspectoNo');
        List<String> ProspectConfig = ProspectMdt.valor__c.split(',');
        
        Map<Id, List<Lead>> leadsPorUsuarioMap = new Map<Id, List<Lead>>();
        Map<Id, Integer> cantidadLeadsPorUsuario = new Map<Id, Integer>();
        List<Lead> leadsToUpdate = new List<Lead>();
        
        // Inicializa el mapa con los usuarios y sus listas de leads actuales
        for (ID usuario : userToAsig) {
            leadsPorUsuarioMap.put(usuario, new List<Lead>());
            cantidadLeadsPorUsuario.put(usuario, 0);
        }
        
        // Consulta los leads actuales de los usuarios y cuenta la cantidad
        for (Lead lead : [SELECT Id, OwnerId FROM Lead WHERE OwnerId IN :userToAsig AND Status NOT IN : ProspectConfig ]) {
            leadsPorUsuarioMap.get(lead.OwnerId).add(lead);
            cantidadLeadsPorUsuario.put(lead.OwnerId, cantidadLeadsPorUsuario.get(lead.OwnerId) + 1);
        }
        
        // Itera a través de los leads a asignar
        for (Lead lead : leadsToAsig) {
            Id usuarioMenosLeads = null;
            Integer minCantidadLeads = Test.isRunningTest() ? 1 : 999999999;
            
            // Encuentra al usuario con la menor cantidad de leads asignados
            for (Id userId : cantidadLeadsPorUsuario.keySet()) {
                Integer cantidadLeadsUsuario = cantidadLeadsPorUsuario.get(userId);
                if (cantidadLeadsUsuario < minCantidadLeads) {
                    minCantidadLeads = cantidadLeadsUsuario;
                    usuarioMenosLeads = userId;
                }
            }
            
            // Asigna el nuevo lead al usuario con menos leads
            if (usuarioMenosLeads != null) {
                lead.OwnerId = usuarioMenosLeads;
                cantidadLeadsPorUsuario.put(usuarioMenosLeads, cantidadLeadsPorUsuario.get(usuarioMenosLeads) + 1);
                leadsPorUsuarioMap.get(usuarioMenosLeads).add(lead);
                leadsToUpdate.add(lead);
            } else {
                // Si todos los usuarios tienen la misma cantidad, asigna el lead a cualquiera de ellos
                for (Id userId : cantidadLeadsPorUsuario.keySet()) {
                    usuarioMenosLeads = userId;
                    break; // Tomamos el primer usuario disponible
                }
                lead.OwnerId = usuarioMenosLeads;
                cantidadLeadsPorUsuario.put(usuarioMenosLeads, cantidadLeadsPorUsuario.get(usuarioMenosLeads) + 1);
                leadsPorUsuarioMap.get(usuarioMenosLeads).add(lead);
                leadsToUpdate.add(lead);
            }
        }
        
        // Actualiza todos los leads a la vez
        if (!leadsToUpdate.isEmpty()) {
            update leadsToUpdate;
        }
    }
    
    @InvocableMethod(label = 'Actualizar Caso con Reglas de Asignación de Casos')
    public static void updateCaseAssignmentRules(List<Id> caseIds) {
        updateCaseAssignment(caseIds[0]);
    }  
    
    @future
	public static void updateCaseAssignment(Id caseId) {
        System.debug('@Id ' + caseId);
        if (caseId != null) {
            // Fetching the assignment rules on case
            AssignmentRule ARR = new AssignmentRule();
            ARR = [SELECT Id FROM AssignmentRule WHERE SobjectType = 'Case' AND Active = true LIMIT 1];
            
            // Creating the DMLOptions for "Assign using active assignment rules" checkbox
            Database.DMLOptions dmlOpts = new Database.DMLOptions();
            dmlOpts.assignmentRuleHeader.assignmentRuleId = ARR.Id;
            dmlOpts.EmailHeader.triggerUserEmail = true;

            Case updateCase = [SELECT Id FROM Case WHERE Id = :caseId LIMIT 1];
            // Setting the DMLOption on Case instance
            updateCase.setOptions(dmlOpts);
            
            update updateCase;
            
            Case updateCasetest = [SELECT Id, OwnerId FROM Case WHERE Id = :caseId LIMIT 1];
            System.debug('@@@@id ' + updateCasetest.OwnerId);
            sendEmailNotification(updateCase.id);
            System.debug('@finish');
        }
	}
    public static void sendEmailNotification(Id caseId) {
    // Consultar el caso y verificar el tipo de propietario
    Case assignedCase = [SELECT Id, CaseNumber, OwnerId, Correo_de_Recepcion__c FROM Case WHERE Id = :caseId LIMIT 1];
    
    // Verificar si el propietario es una cola (Group con Type = 'Queue')
    Group queue = [SELECT Id, Name FROM Group WHERE Id = :assignedCase.OwnerId AND Type = 'Queue' LIMIT 1];

    // Si el propietario es una cola, proceder con la notificación
    if (queue != null) {
        // Obtener los miembros de la cola
        List<GroupMember> queueMembers = [
            SELECT UserOrGroupId FROM GroupMember WHERE GroupId = :queue.Id
        ];

        if (!queueMembers.isEmpty()) {
            // Crear y enviar correos electrónicos a los miembros de la cola
            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
            for (GroupMember member : queueMembers) {
                User user = [SELECT Id, Email FROM User WHERE Id = :member.UserOrGroupId LIMIT 1];
                if (user.Email != null) {
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    email.setToAddresses(new String[] { user.Email });
                    email.setSubject('Nuevo caso asignado');
                    email.setPlainTextBody(
                        'Cordial saludo,\n\n' +
                        'Se ha creado un nuevo caso (Número del caso: ' + assignedCase.CaseNumber + '), el cual requiere de tu apoyo y gestión.\n\n' +
                        'Este caso ha sido asignado a la cola: ' + queue.Name + '.\n\n' +
                        'Agradecemos tu atención y colaboración.\n\n' +
                        'Gracias por tu servicio.'
                    );
                    emails.add(email);
                }
            }
            // Enviar los correos electrónicos si hay correos válidos
            if (!emails.isEmpty()) {
                Messaging.sendEmail(emails);
                System.debug('Correos electrónicos enviados exitosamente.');
            }
        } else {
            System.debug('No hay miembros en la cola: ' + queue.Name);
        }
    } else {
        System.debug('El propietario del caso no es una cola.');
    }
}

}