@isTest
public class UtilsClassTest {
    
    @isTest
    static void testRedistributeLeads() {
        // Buscar una cola válida (puedes ajustar el criterio de búsqueda según tus necesidades)
        Group queue = [SELECT Id FROM Group WHERE Type = 'Queue'  AND Id IN (SELECT QueueId FROM QueueSobject WHERE SobjectType = 'Lead') LIMIT 1];
        
        if (queue != null) {
            // Crea algunos leads ficticios y asigna la cola como propietaria
            Lead lead1 = new Lead(
                Firstname = 'lead',
                LastName = 'Lead1',
                Company = 'lead Lead1',
                Email = 'prueba1@gmail.com',
                Numero_de_documento__c = '987541245',
                Tipo_de_documento__c = '3',
                Phone = '6012345671',
                OwnerId = queue.Id
            );
            
            Lead lead2 = new Lead(
                Firstname = 'lead',
                LastName = 'Lead2',
                Company = 'lead Lead2',
                Email = 'prueba2@gmail.com',
                Numero_de_documento__c = '987541246',
                Tipo_de_documento__c = '3',
                Phone = '6012345672',
                OwnerId = queue.Id
            );
            
            Lead lead3 = new Lead(
                Firstname = 'lead',
                LastName = 'Lead3',
                Company = 'lead Lead3',
                Email = 'prueba3@gmail.com',
                Numero_de_documento__c = '987541247',
                Tipo_de_documento__c = '3',
                Phone = '6012345673',
                OwnerId = queue.Id
            );
            
            Test.startTest();
            insert new List<Lead>{lead1, lead2, lead3};
                Test.stopTest();
        } else {
            System.debug('No se encontró una cola de tipo "Queue". Asegúrate de que haya una cola válida en tu org.');
        }
    }
    
    @isTest
    static void testDistributeLeads() {
        Profile pf = [SELECT Id FROM Profile WHERE Name LIKE '%Admin%' LIMIT 1];
        List<Lead> testLeads = new List<Lead>();
        for (Integer i = 0; i < 3; i++) {
            testLeads.add(new Lead(
                FirstName = 'Lead',
                LastName = 'Test' + i,
                Company = 'Lead Test' + i,
                Email = 'test' + i + '@example.com',
                Phone = '601234567' + i,
                Numero_de_documento__c = '98754124' + i,
                Tipo_de_documento__c = '3'
            ));
        }
        insert testLeads;
        
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@example.com',
            Username = 'testusercrmcolmena@example.com',
            Alias = 'TUser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = pf.Id
        );
        insert testUser;
        
        User testUser2 = new User(
            FirstName = 'Test',
            LastName = 'User2',
            Email = 'testuser2@example.com',
            Username = 'testusercrmcolmena2@example.com',
            Alias = 'TUser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = pf.Id
        );
        insert testUser2;
        
        List<Id> leadIds = new List<Id>();
        for (Lead lead : testLeads) {
            lead.OwnerId = testUser.Id;
            leadIds.add(lead.Id);
        }
        update testLeads;
        
        Test.startTest();
        UtilsClass.distribuir(testLeads, new List<Id>{testUser.Id,testUser2.Id});
        Test.stopTest();
    }
    @isTest
    static void testCaseAssigment() {
        map<Schema.SObjectField, Object> mapCase= new Map<Schema.SObjectField, Object>();
        mapCase.put(Case.Type , 'Problem');
        mapCase.put(Case.CS_PasosCompletados__c , true);
        mapCase.put(Case.CS_ProductoM2__c , '124');
        mapCase.put(Case.Status, 'Análisis Reaseguro');
        mapCase.put(Case.Origin, 'Facebook');
        mapCase.put(Case.CS_Subtipo__c , '2');
        mapCase.put(Case.CS_ProductoColmenaM2__c , 'Accidentes Personales');
        mapCase.put(Case.CS_FechaTentativaDeCierre__c, date.Today());
        mapCase.put(Case.RecordTypeId ,  Schema.SObjectType.Case
                                    .getRecordTypeInfosByDeveloperName()
                                    .get('CommercialValidationInstitutionalBusiness').getRecordTypeId());
        Case caso= CS_TestDataFactory.createCase(mapCase, true);
        caso.OwnerId = UserInfo.getUserId();
        update caso;
        Test.startTest();
        UtilsClass.updateCaseAssignmentRules(new List<Id>{caso.Id});
        Test.stopTest();
        //caso  = [SELECT ownerId, owner.Type,Status from Case WHERE Id =:caso.Id];
        //Group grupo = [SELECT Id, DeveloperName FROM GROUP WHERE Id = :caso.OwnerId];
        //System.debug('caso: '+caso.Status);
        //System.debug('caso: '+caso.OwnerId);
        //System.debug('caso: '+grupo.DeveloperName);
        //Assert.areEqual('ProfesionalesReaseguro',grupo.DeveloperName);
    }
    
    @isTest
    static void testSendEmailNotification() {
        
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
       // Insert account as current user
        System.runAs (thisUser) {
                // Crear un usuario de prueba
                User testUser = new User(
                    Alias = 'tuser',
                    Email = 'testuser@example.com',
                    EmailEncodingKey = 'UTF-8',
                    LastName = 'Test',
                    LanguageLocaleKey = 'en_US',
                    LocaleSidKey = 'en_US',
                    ProfileId = [SELECT Id FROM Profile WHERE Name = 'Consultor Comercial' LIMIT 1].Id,
                    TimeZoneSidKey = 'America/Los_Angeles',
                    UserName = 'testuser123testxtest@example.com'
                );
                insert testUser;
                // Crear grupo (cola) de prueba
                Group testQueue = new Group(
                    Name = 'TestQueue1x',
                    Type = 'Queue'
                );
                insert testQueue;
        
                // Asociar cola al objeto Case
                QueueSObject queueSObject = new QueueSObject(
                    QueueId = testQueue.Id,
                    SObjectType = 'Case'
                );
                insert queueSObject;
        
                // Añadir usuario como miembro del grupo
                GroupMember testQueueMember = new GroupMember(
                    GroupId = testQueue.Id,
                    UserOrGroupId = testUser.Id
                );
                insert testQueueMember;
                Case testCase = new Case(
                    Subject = 'Test Case',
                    OwnerId = testQueue.Id
                    );
                insert testCase;
                
                Test.startTest();       
                UtilsClass.sendEmailNotification(testCase.Id); 
                Test.stopTest();
        	}
        
        }
    
}