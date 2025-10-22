@isTest
public class ConsultIvrAPI_tst {
    
    @isTest
    static void cuentaPersonal() {

        Id personAccountRecordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId(); 
        Account personal1 = new Account(RecordTypeId=personAccountRecordTypeId,
                                        PersonMobilePhone='123456',
                                        PersonEmail='emailconsulta@test.com',
                                        FirstName='Nombre',
                                        LastName='Apellido',
                                        Phone='3114343434',
                                        CS_NumeroIdentificacionCP__pc	= '111222333876',
                                        CS_TipoIdentificacionCP__pc		= '1'
                                        );

        INSERT personal1;

        String tipoIdentificacion = '1';
        String numeroIdentificacion = '111222333876';

        String endpoint = '/services/apexrest/consultivr/info';

        RestRequest request = new RestRequest();
        request.requestURI = endpoint;
        request.httpMethod = 'GET';
        request.addParameter('documentType', tipoIdentificacion);
        request.addParameter('documentNumber', numeroIdentificacion);
        RestContext.request = request;
        RestContext.response = new RestResponse();

        Test.startTest();
        ConsultIvrAPI.info();
        Test.stopTest();

            
        RestResponse response = RestContext.response;
            
        String jsonResponse = response.responseBody.toString();
        System.debug('@@@response'+jsonResponse);
    }

    @isTest
    static void cuentaJuridica() {

        Id AccountRecordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CS_Juridico').getRecordTypeId();
        Account juridico1 = new Account(RecordTypeId=AccountRecordTypeId,
                                                   Phone='9998999',
                                                   Name='NombreTres',
                                                   CS_NumeroIdentificacion__c	= '11157575737',
                                                   CS_TipoIdentificacion__c		= '3'
                                                   );

        INSERT juridico1;

        String tipoIdentificacion = '3';
	    String numeroIdentificacion = '11157575737';

        String endpoint = '/services/apexrest/consultivr/info';

        RestRequest request = new RestRequest();
        request.requestURI = endpoint;
        request.httpMethod = 'GET';
        request.addParameter('documentType', tipoIdentificacion);
	    request.addParameter('documentNumber', numeroIdentificacion);
        RestContext.request = request;
        RestContext.response = new RestResponse();

        Test.startTest();
        ConsultIvrAPI.info();
        Test.stopTest();


        RestResponse response = RestContext.response;
        
        String jsonResponse = response.responseBody.toString();
        System.debug('@@@response'+jsonResponse);
    }

    @isTest
    static void cuentaNull() {

        String tipoIdentificacion = '';
	    String numeroIdentificacion = '';

        String endpoint = '/services/apexrest/consultivr/info';

        RestRequest request = new RestRequest();
        request.requestURI = endpoint;
        request.httpMethod = 'GET';
        request.addParameter('documentType', tipoIdentificacion);
	    request.addParameter('documentNumber', numeroIdentificacion);
        RestContext.request = request;
        RestContext.response = new RestResponse();

        Test.startTest();
        ConsultIvrAPI.info();
        Test.stopTest();


        RestResponse response = RestContext.response;

        String jsonResponse = response.responseBody.toString();
        System.debug('@@@response'+jsonResponse);
    }

    @isTest
    static void cuentaNoExiste() {

        String tipoIdentificacion = '3';
	    String numeroIdentificacion = '122212121212121212';

        String endpoint = '/services/apexrest/consultivr/info';

        RestRequest request = new RestRequest();
        request.requestURI = endpoint;
        request.httpMethod = 'GET';
        request.addParameter('documentType', tipoIdentificacion);
	    request.addParameter('documentNumber', numeroIdentificacion);
        RestContext.request = request;
        RestContext.response = new RestResponse();

        Test.startTest();
        ConsultIvrAPI.info();
        Test.stopTest();


        RestResponse response = RestContext.response;

        String jsonResponse = response.responseBody.toString();
        System.debug('@@@response'+jsonResponse);
    }

    @isTest
    static void participante() {

        Id personAccountRecordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId(); 
        Account personal1 = new Account(RecordTypeId=personAccountRecordTypeId,
                                                PersonMobilePhone='123456',
                                                PersonEmail='emailconsulta@test.com',
                                                FirstName='Nombre',
                                                LastName='Apellido',
                                                Phone='3114343434',
                                                CS_NumeroIdentificacionCP__pc	= '111222333888',
                                                CS_TipoIdentificacionCP__pc		= '1'
                                                );

        INSERT personal1;
            
        Id AccountRecordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CS_Juridico').getRecordTypeId();
            Account juridico1 = new Account(RecordTypeId=AccountRecordTypeId,
                                                    Phone='9998999',
                                                    Name='NombreTres',
                                                    CS_NumeroIdentificacion__c	= '11157575711',
                                                    CS_TipoIdentificacion__c		= '3'
                                                    );

        INSERT juridico1;
        
        Id claimAt = Schema.SObjectType.Claim.getRecordTypeInfosByDeveloperName().get('CS_AT').getRecordTypeId();
        Claim reclamo = new Claim(RecordTypeId=claimAt,name='12378998',AccountId=personal1.Id);
        INSERT reclamo;
            
        Id claimCS = Schema.SObjectType.Claim.getRecordTypeInfosByDeveloperName().get('CS_Siniestro').getRecordTypeId();
        Claim reclamo2 = new Claim(RecordTypeId=claimCS,name='12378998',AccountId=juridico1.Id);
        INSERT reclamo2;

        Id poliz = Schema.SObjectType.InsurancePolicy.getRecordTypeInfosByDeveloperName().get('CS_Contrato_ARL').getRecordTypeId();
        InsurancePolicy poliza = new InsurancePolicy(RecordTypeId=poliz,Name='1232423423',NameInsuredId=juridico1.Id); 
        INSERT poliza; 

        InsurancePolicy poliza2 = new InsurancePolicy(RecordTypeId=poliz,Name='1232423424',NameInsuredId=personal1.Id); 
        INSERT poliza2;

        InsurancePolicyParticipant participant = new InsurancePolicyParticipant(Role='Empleador',InsurancePolicyId=poliza.Id,PrimaryParticipantAccountId=personal1.Id);
        INSERT participant;
        
        String tipoIdentificacion = '1';
        String numeroIdentificacion = '111222333888';

        String endpoint = '/services/apexrest/consultivr/info';

        RestRequest request = new RestRequest();
        request.requestURI = endpoint;
        request.httpMethod = 'GET';
        request.addParameter('documentType', tipoIdentificacion);
        request.addParameter('documentNumber', numeroIdentificacion);
        RestContext.request = request;
        RestContext.response = new RestResponse();

        Test.startTest();
        
        ConsultIvrAPI.info();
        Test.stopTest();

            
        RestResponse response = RestContext.response;
            
        String jsonResponse = response.responseBody.toString();
    }

    @isTest
    static void cuentaPersonal_esPreferential() {

        Id personAccountRecordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId(); 
        Account personalTest = new Account(RecordTypeId=personAccountRecordTypeId,
                                        PersonMobilePhone='1234',
                                        PersonEmail='emailconsulta@test.com',
                                        FirstName='Nombre',
                                        LastName='Apellido',
                                        Phone='3114343434',
                                        CS_NumeroIdentificacionCP__pc	= '11111111111111',
                                        CS_TipoIdentificacionCP__pc		= '1',
                                        FinServ__CustomerType__c    = 'Preferential'
                                        );

        String tipoIdentificacion = '1';
        String numeroIdentificacion = '11111111111111';

        String endpoint = '/services/apexrest/consultivr/info';

        RestRequest request = new RestRequest();
        request.requestURI = endpoint;
        request.httpMethod = 'GET';
        request.addParameter('documentType', tipoIdentificacion);
        request.addParameter('documentNumber', numeroIdentificacion);
        RestContext.request = request;
        RestContext.response = new RestResponse();

        Test.startTest();
        INSERT personalTest;
        ConsultIvrAPI.info();
        Test.stopTest();

            
        RestResponse response = RestContext.response;
            
        String jsonResponse = response.responseBody.toString();
        System.debug('@@@response'+jsonResponse);

    }   

    @isTest
    static void cuentaPersonal_NoEsPreferential_EsMixto() {

        Id personAccountRecordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId(); 
        Account personalTest = new Account(RecordTypeId=personAccountRecordTypeId,
                                        PersonMobilePhone='123456',
                                        PersonEmail='emailconsulta@test.com',
                                        FirstName='Nombre',
                                        LastName='Apellido',
                                        Phone='3114343434',
                                        CS_NumeroIdentificacionCP__pc	= '12398745',
                                        CS_TipoIdentificacionCP__pc		= '1',
                                        FinServ__CustomerType__c    = 'Investor',
                                        ACC_Empresa_cliente__c = 'Mixto'
                                        );

        String tipoIdentificacion = '1';
        String numeroIdentificacion = '12398745';

        String endpoint = '/services/apexrest/consultivr/info';

        RestRequest request = new RestRequest();
        request.requestURI = endpoint;
        request.httpMethod = 'GET';
        request.addParameter('documentType', tipoIdentificacion);
        request.addParameter('documentNumber', numeroIdentificacion);
        RestContext.request = request;
        RestContext.response = new RestResponse();

        Test.startTest();
        INSERT personalTest;
        ConsultIvrAPI.info();
        Test.stopTest();

            
        RestResponse response = RestContext.response;
            
        String jsonResponse = response.responseBody.toString();
        System.debug('@@@response'+jsonResponse);

    }

    @isTest
    static void validarPreferencial_ParticipantesPoliza(){

        Id recordTypeJuridico =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CS_Juridico').getRecordTypeId(); 
        Account cuentaPadre_prefer = new Account(RecordTypeId=recordTypeJuridico,
                                        Name='FatherAccount',
                                        Phone='3114343434',
                                        CS_NumeroIdentificacion__c	= '12345888',
                                        CS_TipoIdentificacion__c		= '3',
                                        FinServ__CustomerType__c    = 'Preferential',
                                        ACC_Empresa_cliente__c = 'Mixto',
                                        CS_ClienteActivo__c=true
                                    );

        Id recordTypePerson =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId(); 

        Account cuentaHijo1 = new Account(RecordTypeId=recordTypePerson,
                                        PersonMobilePhone='0000',
                                        PersonEmail='emailconsulta@test.com',
                                        FirstName='Account',
                                        LastName='Son1',
                                        Phone='0000',
                                        CS_NumeroIdentificacionCP__pc	= '45678900',
                                        CS_TipoIdentificacionCP__pc		= '1',
                                        FinServ__CustomerType__c    = '',
                                        ACC_Empresa_cliente__c = ''
                                        );

        String tipoIdentificacion = '1';
        String numeroIdentificacion = '45678900';

        String endpoint = '/services/apexrest/consultivr/info';

        RestRequest request = new RestRequest();
        request.requestURI = endpoint;
        request.httpMethod = 'GET';
        request.addParameter('documentType', tipoIdentificacion);
        request.addParameter('documentNumber', numeroIdentificacion);
        RestContext.request = request;
        RestContext.response = new RestResponse();

        Test.startTest();
        INSERT cuentaPadre_prefer;
        INSERT cuentaHijo1;
        
        Id recordTypeIP_SV =  Schema.SObjectType.InsurancePolicy.getRecordTypeInfosByDeveloperName().get('CS_Seguro_de_vida').getRecordTypeId();                                        
        InsurancePolicy poliza = new InsurancePolicy(Name='Test',
            NameInsuredId=cuentaPadre_prefer.Id,
            RecordTypeId = recordTypeIP_SV
        );
        INSERT poliza;
        
        Id recordTypeIPP_Trabajador =  Schema.SObjectType.InsurancePolicyParticipant.getRecordTypeInfosByDeveloperName().get('CS_Trabajador').getRecordTypeId();
        InsurancePolicyParticipant ipp = new InsurancePolicyParticipant(InsurancePolicyId=poliza.Id,
            Role='8;',
            PrimaryParticipantAccountId=cuentaHijo1.Id,	
            RecordTypeId=recordTypeIPP_Trabajador,
            IsActiveParticipant=true
        );

        INSERT ipp;

        ConsultIvrAPI.info();
        Test.stopTest();
            
        RestResponse response = RestContext.response;
        String jsonResponse = response.responseBody.toString();
        System.debug('@@@response'+jsonResponse);

    }

}