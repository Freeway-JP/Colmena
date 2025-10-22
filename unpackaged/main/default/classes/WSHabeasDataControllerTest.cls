@IsTest
public class WSHabeasDataControllerTest {
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
    static void test1() {
        WS_HabeasDataWrapper.RequestWSWrapper requestWrapper = new WS_HabeasDataWrapper.RequestWSWrapper();
        requestWrapper.FirstName       = 'Test';
        requestWrapper.SecondName      = 'Test';
        requestWrapper.LastName        = 'Test';
        requestWrapper.SecondLastName  = 'Test';
        requestWrapper.identityNumber  = '11157575739';
        requestWrapper.email           = 'TestHD01@gmail.com';
        requestWrapper.numberPhone     = '3013765431';
        requestWrapper.identityType    = '1';
        requestWrapper.AttentionChannel= 'Mary';
        
        WS_HabeasDataWrapper.CompaniesWrapper companyColCapi = new WS_HabeasDataWrapper.CompaniesWrapper();
        companyColCapi.name = 'Colmena Capitalizadora';
        companyColCapi.essentialFunctionalities = true;
        companyColCapi.notEssentialFunctionalities = null;
        //companyColCapi.law2300 = false;

        WS_HabeasDataWrapper.CompaniesWrapper companyColSegARL = new WS_HabeasDataWrapper.CompaniesWrapper();
        companyColSegARL.name = 'Colmena Seguros ARL';
        companyColSegARL.essentialFunctionalities = true;
        companyColSegARL.notEssentialFunctionalities = null;
        //companyColSegARL.law2300 = false;
        companyColSegARL.MedicalHistory = true;

        WS_HabeasDataWrapper.CompaniesWrapper companyColSegVida = new WS_HabeasDataWrapper.CompaniesWrapper();
        companyColSegVida.name = 'Colmena Seguros Vida';
        companyColSegVida.essentialFunctionalities = true;
        companyColSegVida.notEssentialFunctionalities = null;
        //companyColSegVida.law2300 = false;
        companyColSegVida.MedicalHistory = true;

        WS_HabeasDataWrapper.CompaniesWrapper companyColSegGen = new WS_HabeasDataWrapper.CompaniesWrapper();
        companyColSegGen.name = 'Colmena Seguros Generales';
        companyColSegGen.essentialFunctionalities = true;
        companyColSegGen.notEssentialFunctionalities = null;
        //companyColSegGen.law2300 = false;

        requestWrapper.companies = new List<WS_HabeasDataWrapper.CompaniesWrapper>{companyColCapi,companyColSegARL,companyColSegVida,companyColSegGen};
            
        List<Account> acc = [SELECT Id FROM Account WHERE FirstName = 'Nombre'];
        requestWrapper.IdClient = acc[0].Id;
        requestWrapper.TypeObjectCreate = 'Account';
        
        String jsonRequest = JSON.serialize(requestWrapper);
        WSHabeasDataController controller = new WSHabeasDataController();
        controller.controllerHD(requestWrapper);
    }
}