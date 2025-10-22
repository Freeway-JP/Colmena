/**
* ===============================================================================================================================
* Developer:             VASS LATAM
* Creation Date:         09/10/2023
* Created by:            Gabriel.Velandia@vasscompany.com
* Description:           TEST de la clase AutoConvertLeads.
* Last Modified by:      edwin.martinez@vasscompany.com (10/10/2023)
* Version:               v1.0
* ===============================================================================================================================
**/
@isTest
public with sharing class WSClientControllerTest {
    @TestSetup
    private static void setupData(){
         // Crear datos necesarios para las pruebas
         Schema.Location testUbicaicon = new Schema.Location();
        testUbicaicon.Name = 'test';
        testUbicaicon.LocationType = 'Almacén';
        insert testUbicaicon;
        // Crear EngagementChannelType
        EngagementChannelType ect = new EngagementChannelType();
        ect.Name = 'Linea Efectiva';
        insert ect;
        
        Id personAccountRecordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId(); 
    	Account acc = new Account(RecordTypeId=personAccountRecordTypeId,
                                               PersonMobilePhone='55555',
                                               PersonEmail='emailconsulta@test.com',
                                               FirstName='Nombre',
                                               LastName='Apellido',
                                               Phone='55555',
                                               CS_NumeroIdentificacionCP__pc	= '11157575739',
                                               CS_TipoIdentificacionCP__pc		= '1'
                                               );
                                               INSERT acc; 

        Lead newLead = new Lead();
        newLead.recordTypeId                        = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('General').getRecordTypeId();
        newLead.Status                              = 'Afinidad';
        newLead.LeadSource                          = 'Base de datos propia';
        newLead.Tipo_de_documento__c                = '1';
        newLead.Numero_de_documento__c              = '1000350343';
        newLead.FirstName                           = 'PruebaConversión';
        newLead.LastName                            = 'PruebaConversion';
        newLead.MobilePhone                         = '3013926543';
        newLead.Email                               = 'Prueba@gmail.com';
        newLead.TypePerson__c                       = 'Persona Natural';
        newLead.SponsorCategory__c                  ='Cajas de Compensación';
        newLead.Company                             ='test';
        newLead.ContactType__c                      ='Recursos Humanos';
        newLead.NumberPotentialCustomers__c         =1;
        newLead.Ciudad__c                           =testUbicaicon.id;       
        insert newLead;
        
        // Crear Individual para asociar
        Individual individual = new Individual();
        individual.FirstName = 'Test';
        individual.LastName = 'Person';
        insert individual;
        
        // Crear ContactPointEmail y ContactPointPhone si es necesario
        ContactPointEmail email = new ContactPointEmail();
        email.EmailAddress = 'test@test.com';
        email.ParentId = acc.Id;
        insert email;
        
        ContactPointPhone phone = new ContactPointPhone();
        phone.TelephoneNumber = '123456789';
        phone.ParentId = acc.Id;
        insert phone;
        List<EngagementChannelType> attentionchannels = new List<EngagementChannelType>();
        
        EngagementChannelType attentionchannel1 = new EngagementChannelType();
        attentionchannel1.Name                   = 'Mary';
        attentionchannel1.channelReceivesPQRs__c = true;

        EngagementChannelType attentionchannel2 = new EngagementChannelType();
        attentionchannel2.Name                   = 'Mary2';
        attentionchannel2.channelReceivesPQRs__c = false;

        attentionchannels.add(attentionchannel1);
        attentionchannels.add(attentionchannel2);
        insert attentionchannels;
    }
    
    @isTest
    private static void WSClienControllerTest1(){
 
        WS_HabeasDataWrapper.RequestWSWrapper response  = new WS_HabeasDataWrapper.RequestWSWrapper(); 
        WS_HabeasDataWrapper.RequestWSWrapper wrapperRequest   = new WS_HabeasDataWrapper.RequestWSWrapper();
        List<WS_HabeasDataWrapper.CompaniesWrapper> companies = new List<WS_HabeasDataWrapper.CompaniesWrapper>();
        WS_HabeasDataWrapper.CompaniesWrapper company = new WS_HabeasDataWrapper.CompaniesWrapper();
        company.name = 'Colmena Capitalizadora';
        company.essentialFunctionalities = true;
        company.notEssentialFunctionalities = null;
        // company.law2300 = false;
        companies.add(company);

        wrapperRequest.FirstName       = 'Test';
        wrapperRequest.SecondName      = 'Test';
        wrapperRequest.LastName        = 'Test';
        wrapperRequest.SecondLastName  = 'Test';
        wrapperRequest.identityNumber  = '1000323999';
        wrapperRequest.email           = 'TestHD01@gmail.com';
        wrapperRequest.numberPhone     = '3013765431';
        wrapperRequest.identityType    = '1';
        wrapperRequest.AttentionChannel= 'Mary';
        wrapperRequest.sex			   = '1';
        wrapperRequest.companies       = companies;

        WSClientController clientManager = new WSClientController();
        response = clientManager.ValidacionIdentidad(wrapperRequest);

    }

    @isTest
    private static void WSClienControllerTest2(){
 
        WS_HabeasDataWrapper.RequestWSWrapper response  = new WS_HabeasDataWrapper.RequestWSWrapper(); 
        WS_HabeasDataWrapper.RequestWSWrapper wrapperRequest   = new WS_HabeasDataWrapper.RequestWSWrapper();
        List<WS_HabeasDataWrapper.CompaniesWrapper> companies = new List<WS_HabeasDataWrapper.CompaniesWrapper>();
        WS_HabeasDataWrapper.CompaniesWrapper company = new WS_HabeasDataWrapper.CompaniesWrapper();
        company.name = 'Colmena Capitalizadora';
        company.essentialFunctionalities = true;
        company.notEssentialFunctionalities = null;
        // company.law2300 = false;
        companies.add(company);

        wrapperRequest.FirstName       = 'Test';
        wrapperRequest.SecondName      = 'Test';
        wrapperRequest.LastName        = 'Test';
        wrapperRequest.SecondLastName  = 'Test';
        wrapperRequest.identityNumber  = '11157575739';
        wrapperRequest.email           = 'TestHD01@gmail.com';
        wrapperRequest.numberPhone     = '3013765431';
        wrapperRequest.identityType    = '1';
        wrapperRequest.AttentionChannel= 'Mary';
        wrapperRequest.sex = '1';
        wrapperRequest.companies       = companies;

        WSClientController clientManager = new WSClientController();
        response = clientManager.ValidacionIdentidad(wrapperRequest);

    }

    @isTest
    private static void WSClienControllerTest3(){
 
        WS_HabeasDataWrapper.RequestWSWrapper response  = new WS_HabeasDataWrapper.RequestWSWrapper(); 
        WS_HabeasDataWrapper.RequestWSWrapper wrapperRequest   = new WS_HabeasDataWrapper.RequestWSWrapper();
        List<WS_HabeasDataWrapper.CompaniesWrapper> companies = new List<WS_HabeasDataWrapper.CompaniesWrapper>();
        WS_HabeasDataWrapper.CompaniesWrapper company = new WS_HabeasDataWrapper.CompaniesWrapper();
        company.name = 'Colmena Capitalizadora';
        company.essentialFunctionalities = true;
        company.notEssentialFunctionalities = null;
        // company.law2300 = false;
        companies.add(company);

         wrapperRequest.FirstName       = 'Test';
        wrapperRequest.SecondName      = 'Test';
        wrapperRequest.LastName        = 'Test';
        wrapperRequest.SecondLastName  = 'Test';
        wrapperRequest.identityNumber  = '1000350343';
        wrapperRequest.email           = 'TestHD01@gmail.com';
        wrapperRequest.numberPhone     = '3013765431';
        wrapperRequest.identityType    = '1';
        wrapperRequest.AttentionChannel= 'Mary';
        wrapperRequest.sex = '1';        
        wrapperRequest.companies       = companies;

        WSClientController clientManager = new WSClientController();
        response = clientManager.ValidacionIdentidad(wrapperRequest);

    }

    @isTest
    private static void WSClienControllerTestLead(){
 
        WS_HabeasDataWrapper.RequestWSWrapper response  = new WS_HabeasDataWrapper.RequestWSWrapper(); 
        WS_HabeasDataWrapper.RequestWSWrapper wrapperRequest   = new WS_HabeasDataWrapper.RequestWSWrapper();
        List<WS_HabeasDataWrapper.CompaniesWrapper> companies = new List<WS_HabeasDataWrapper.CompaniesWrapper>();
        WS_HabeasDataWrapper.CompaniesWrapper company = new WS_HabeasDataWrapper.CompaniesWrapper();
        company.name = 'Colmena Capitalizadora';
        company.essentialFunctionalities = true;
        company.notEssentialFunctionalities = null;
        // company.law2300 = false;
        companies.add(company);

         wrapperRequest.FirstName       = 'Test';
        wrapperRequest.SecondName      = 'Test';
        wrapperRequest.LastName        = 'Test';
        wrapperRequest.SecondLastName  = 'Test';
        wrapperRequest.identityNumber  = '1000350344';
        wrapperRequest.email           = 'TestHD01@gmail.com';
        wrapperRequest.numberPhone     = '3013765431';
        wrapperRequest.identityType    = '1';
        wrapperRequest.AttentionChannel= 'Mary2';
        wrapperRequest.sex = '1';        
        wrapperRequest.companies       = companies;

        WSClientController clientManager = new WSClientController();
        response = clientManager.ValidacionIdentidad(wrapperRequest);

    }
    

    /*@isTest
    static void testControllerHDAccount() {
        // Crear request params
        WS_HabeasDataWrapper.RequestWSWrapper params = new WS_HabeasDataWrapper.RequestWSWrapper();
        params.IdClient = [SELECT Id FROM Account LIMIT 1].Id;
        params.FirstName = 'Test';
        params.SecondName = 'Second';
        params.LastName = 'Last';
        params.SecondLastName = 'LastSecond';
        params.email = 'test@test.com';
        params.numberPhone = '123456789';
        params.TypeObjectCreate = 'Account';
        
        WS_HabeasDataWrapper.CompaniesWrapper company = new WS_HabeasDataWrapper.CompaniesWrapper();
        company.Name = 'Colmena Seguros Vida';
        company.essentialFunctionalities = true;
        company.notessentialFunctionalities = new List<String>();
        company.MedicalHistory=true;
        params.companies = new List<WS_HabeasDataWrapper.CompaniesWrapper>{ company };

        // Instanciar el controlador
        WSHabeasDataController controller = new WSHabeasDataController();
        
        // Ejecutar el método controllerHD
        Test.startTest();
        WS_HabeasDataWrapper.ResponseWSWrapper response = controller.controllerHD(params);
        Test.stopTest();
        
        // Verificar resultados
        System.assertEquals('Success', response.status);
        System.assertEquals('200', response.responseCode);
        System.assertEquals(false, response.error);
    }

    @isTest
    static void testControllerHDLead() {
        // Crear request params para un Lead
        WS_HabeasDataWrapper.RequestWSWrapper params = new WS_HabeasDataWrapper.RequestWSWrapper();
        params.IdClient = [SELECT Id FROM Lead LIMIT 1].Id;
        params.FirstName = 'LeadTest';
        params.SecondName = 'SecondLead';
        params.LastName = 'LeadLast';
        params.SecondLastName = 'LeadLastSecond';
        params.email = 'leadtest@test.com';
        params.numberPhone = '987654321';
        params.TypeObjectCreate = 'Lead';
        
        WS_HabeasDataWrapper.CompaniesWrapper company = new WS_HabeasDataWrapper.CompaniesWrapper();
        company.Name = 'Colmena Seguros ARL';
        company.essentialFunctionalities = true;
        company.notessentialFunctionalities = new List<String>();
        company.MedicalHistory=true;
        params.companies = new List<WS_HabeasDataWrapper.CompaniesWrapper>{ company };

        // Instanciar el controlador
        WSHabeasDataController controller = new WSHabeasDataController();
        
        // Ejecutar el método controllerHD
        Test.startTest();
        WS_HabeasDataWrapper.ResponseWSWrapper response = controller.controllerHD(params);
        Test.stopTest();
        
        // Verificar resultados
        System.assertEquals('Success', response.status);
        System.assertEquals('200', response.responseCode);
        System.assertEquals(false, response.error);
    }*/

    @isTest
    static void testControllerHDWithoutClientId() {
        // Crear request params sin IdClient
        WS_HabeasDataWrapper.RequestWSWrapper params = new WS_HabeasDataWrapper.RequestWSWrapper();
        params.FirstName = 'NoClient';
        params.SecondName = 'NoSecond';
        params.LastName = 'NoLast';
        params.SecondLastName = 'NoLastSecond';
        WS_HabeasDataWrapper.CompaniesWrapper company = new WS_HabeasDataWrapper.CompaniesWrapper();
        company.Name = 'Colmena Seguros ARL';
        company.essentialFunctionalities = true;
        company.notessentialFunctionalities = new List<String>();
        company.MedicalHistory=true;
        params.companies = new List<WS_HabeasDataWrapper.CompaniesWrapper>{ company };
        // Instanciar el controlador
        WSHabeasDataController controller = new WSHabeasDataController();
        
        // Ejecutar el método controllerHD
        Test.startTest();
        WS_HabeasDataWrapper.ResponseWSWrapper response = controller.controllerHD(params);
        Test.stopTest();
        
        // Verificar que falla sin IdClient
        System.assertEquals('Failed', response.status);
        System.assertEquals('202', response.responseCode);
        System.assertEquals(false, response.error);
    }


}