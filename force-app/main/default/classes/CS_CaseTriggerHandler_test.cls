/*****************************************************************************************************************************
 * Apex Class Name	:	CS_CaseTriggerHandler_test
 * Version			:	1.0
 * Created Date	    :	20/09/2022
 * Function 		: 	Prueba el funcionamiento de la clase CS_CaseTriggerHandler
 * Test Class		:	???
 *---------------------------------------------------------------------------------------------------------------------------
 *                                                MODIFICATION LOG
 *----------------------------------------------------------------------------------------------------------------------------
 * Developer		     	Date			   	Description
 * ---------------------------------------------------------------------------------------------------------------------------
 * Fernanda Villafaña           20/09/2022          Original Version
 * Diego Caneda					09/03/2023			Modificación para cobertura y eliminación de counters.
 ****************************************************************************************************************************/
@isTest 
public class CS_CaseTriggerHandler_test {
    @testSetup
    static void setup(){        
        account ACC= CS_TestDataFactory.createPersonAccount(true);
        Entitlement ent = new Entitlement(Name='ans consulta', AccountId=ACC.Id, 
        StartDate=Date.valueof(System.now().addDays(-2)), EndDate=Date.valueof(System.now().addYears(2)));
        insert ent;
        Id recordTypeCaseId1 =Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CS_Novedad').getRecordTypeId();
        Map<Schema.SObjectField, Object> mapCase= new Map<Schema.SObjectField, Object>();
        mapCase.put(Case.RecordTypeId, recordTypeCaseId1);
        mapCase.put(Case.CS_Subtipo__c, '2');
        mapCase.put(Case.CS_MacroMotivo__c, 'Asegurados');
        mapCase.put(Case.CS_Submotivo__c, 'Ingreso de asegurados');
        mapCase.put(Case.Status, 'Nuevo');
        mapCase.put(Case.CS_FechaTentativaDeCierre__c, date.Today());
        Case caso= CS_TestDataFactory.createCase(mapCase, true);
        CS_ProcesoAtencion__c pa= new CS_ProcesoAtencion__c();
        pa.CS_MacroMotivo__c='Asegurados';
        pa.CS_Submotivo__c='Ingreso de asegurados';
        pa.CS_Subtipo__c='2';
        insert pa;
        CS_PasosAtencion__c paAt= new CS_PasosAtencion__c();
        paAt.CS_ProcesoAtencion__c=pa.Id; 
        paAt.Name='111111';
        paAt.CS_Tiempoatencion__c=3;
    	insert paAt;

    }
    @isTest
    static void caseConAsignacion(){
        Case caso=[SELECT Id FROM Case LIMIT 1];    
        CS_AsginacionPasosAtencion__c paso= new CS_AsginacionPasosAtencion__c();
        paso.CS_CasoRelacionado__c=Caso.Id;
        paso.CS_Tiempo_de_AtencionN__c=1;
        paso.CS_Estado__c='Iniciado';
        paso.CS_AsignacionFlujoSecundario__c=false;
        insert paso;
        update caso;
        List <CS_AsginacionPasosAtencion__c> lst= [SELECT ID FROM CS_AsginacionPasosAtencion__c WHERE CS_CasoRelacionado__c=:caso.Id];
        System.debug('lst con asignación: ' + lst);
        System.assertEquals(1, lst.size(), 'Se asignaron pasos de atención a pesar de que el caso ya tenía previamente');
        
    }
    @isTest
    Static void caseSinAsignacion(){
        List<Case> listCaseTest = [Select Id,RecordType.DeveloperName,CS_Subtipo__c,CS_MacroMotivo__c,CS_Submotivo__c, Status, CS_FechaTentativaDeCierre__c FROM Case];
        system.debug('listCaseTest: ' + listCaseTest);
        Case caso=[SELECT Id, CS_Subtipo__c,CS_MacroMotivo__c,CS_Submotivo__c, Status, CS_FechaTentativaDeCierre__c FROM Case LIMIT 1]; 
        update caso;
		List <CS_AsginacionPasosAtencion__c> lst= [SELECT ID FROM CS_AsginacionPasosAtencion__c WHERE CS_CasoRelacionado__c=:caso.Id];
        System.debug('lst sin asignación: ' + lst);
        System.assertEquals(0, lst.size(), 'No se asignaron los pasos de atención');
    }
    @isTest
    static void casePasosAtencion(){
        Id recordTypeCaseId =Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CS_Incidente').getRecordTypeId();
        Id recordTypeCuentaId =Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CS_Juridico').getRecordTypeId();
        
        Account cuenta = new Account(
            Name = 'cuenta',
            RecordTypeId = recordTypeCuentaId
        );
        insert cuenta;
        
        CS_ProcesoAtencion__c pa2= new CS_ProcesoAtencion__c();
        pa2.CS_MacroMotivo__c='Interna - Incidencia SV';
        pa2.CS_Submotivo__c='Error linea efectiva';
        pa2.CS_Subtipo__c='2';
        pa2.CS_Tipo_de_caso__c = 'CS_Incidente';
        insert pa2;
        CS_PasosAtencion__c paAt2= new CS_PasosAtencion__c();
        paAt2.CS_ProcesoAtencion__c=pa2.Id; 
        paAt2.Name='Paso 1';
        paAt2.CS_Tiempoatencion__c=8;
    	insert paAt2;
        
        Product2 newProduct = new Product2(
            Name = 'TestName',
            IsActive = true, 
            ProductCode = 'PC',
            Description = 'Desc',
            Family = '31',
            CS_Entidad_Producto__c = '1'
        	);
        Case casop = new Case(
            RecordTypeId = recordTypeCaseId,
            AccountId = cuenta.Id,
            CS_Subtipo__c = '2',
            CS_Pais__c = '170',
            Status = 'Nuevo',
            CS_Canal__c = '6',
            CS_Departamento__c = '91',
            CS_Municipio__c = '91263',
            CS_ProductoM2__c = '121',
            CS_MacroMotivo__c = 'Interna - Incidencia SV',
            CS_Submotivo__c = 'Error linea efectiva',
            CS_FechaTentativaDeCierre__c = Date.today().addDays(10)
        );
        insert newProduct;
            casop.ProductId = newProduct.Id;
         insert casop;

		CS_AsginacionPasosAtencion__c paso2= new CS_AsginacionPasosAtencion__c();
        paso2.CS_CasoRelacionado__c=casop.Id;
        paso2.CS_Tiempo_de_AtencionN__c=8;
        paso2.CS_Estado__c='Iniciado';
        paso2.CS_AsignacionFlujoSecundario__c=false;
        paso2.CS_ProcesoAtencion__c = pa2.Id;
        paso2.CS_PasoAtencionId__c = paAt2.Id;
        insert paso2;
        
        List <CS_AsginacionPasosAtencion__c> lst= [SELECT Id,CS_ProcesoAtencion__c,CS_PasoAtencionId__c FROM CS_AsginacionPasosAtencion__c WHERE CS_CasoRelacionado__c=:casop.Id];
        System.debug('lst pasos: ' + lst);        
    }
    
     @isTest
	static void testAfterUpdate() {
        // Setup de datos de prueba
    
        // Obtener el RecordType necesario
		String quejaRecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'CS_Queja'].Id;
    
        // Crear un caso con el RecordType necesario
        Case case1 = CS_TestDataFactory.createCase(true);
    
        // Crear EmailMessage asociado al caso
        EmailMessage email1 = CS_TestDataFactory.createEmailmessage(true);
        insert email1;
    
        // Crear ContentDocument y ContentDocumentLink asociados al caso y email
        ContentVersion contentVersion1 = new ContentVersion(
            Title = 'Documento de prueba 1',
            PathOnClient = 'Test1.pdf',
            VersionData = Blob.valueOf('Test Content 1'),
            IsMajorVersion = true
        );
        insert contentVersion1;
    
        ContentVersion contentVersion2 = new ContentVersion(
            Title = 'Test',
            PathOnClient = 'Test.pdf',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion2;
    
        // Crear los ContentDocumentLink con el LinkedEntityId correcto
        ContentDocumentLink link1 = new ContentDocumentLink(
            ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion1.Id].ContentDocumentId,
            LinkedEntityId = case1.Id,
            ShareType = 'V'
        );
        insert link1;
    
        ContentDocumentLink link2 = new ContentDocumentLink(
            ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion2.Id].ContentDocumentId,
            LinkedEntityId = email1.Id,
            ShareType = 'V'
        );
        insert link2;
    
        // Consulta los casos creados en el setup
        Case oldCase = [SELECT Id, RecordTypeId, Subject FROM Case WHERE Id = :case1.Id];
    
        // Simula un cambio en el RecordTypeId del caso
        case1.RecordTypeId = quejaRecordTypeId;
        update case1;
    
        // Ejecuta el método afterUpdate manualmente
        Map<Id, Case> oldCases = new Map<Id, Case>{ oldCase.Id => oldCase };
        Map<Id, Case> newCases = new Map<Id, Case>{ case1.Id => [SELECT Id, RecordTypeId, Subject FROM Case WHERE Id = :case1.Id] };
    
        Test.startTest();
        CS_CaseTriggerHandler.afterUpdate(oldCases, newCases);
        Test.stopTest();
    
        // Verifica que los ContentDocumentLinks y CS_DocumentoCaso__c se hayan actualizado según lo esperado
        List<CS_DocumentoCaso__c> docs = [SELECT Id FROM CS_DocumentoCaso__c WHERE CS_Caso__c = :case1.Id];
        System.assertNotEquals(0, docs.size(), 'Se esperaban documentos caso creados');
    
        // Verifica que los ContentDocumentLinks se hayan actualizado según lo esperado
        List<ContentDocumentLink> updatedContentDocumentLinks = [SELECT Id, LinkedEntityId, ContentDocumentId, ShareType FROM ContentDocumentLink WHERE LinkedEntityId = :case1.Id];
        System.assertNotEquals(0, updatedContentDocumentLinks.size(), 'Se esperaban ContentDocumentLinks actualizados');
    }
}