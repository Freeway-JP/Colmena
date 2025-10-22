@isTest
public class WS_OSTIpoAutorizacionTest {
    @testSetup
    static void setupTestData() {
        List<RecordType> personalAccountRecordType = [SELECT Id, Name, DeveloperName FROM RecordType WHERE DeveloperName = 'PersonAccount' LIMIT 1];

        EngagementChannelType engagementChannelTest = new EngagementChannelType(Name = 'Mary', channelReceivesPQRs__c = true);
        insert engagementChannelTest;

        Account acc = new Account(
            RecordTypeId = personalAccountRecordType[0].Id,
            CS_TipoIdentificacionCP__pc = '1',
            CS_NumeroIdentificacionCP__pc = '1000350348',
            FirstName = 'Gabriel',
            LastName = 'Velandia',
            PersonEmail = 'Gabosvel2003@gmail.com',
            PersonMobilePhone = '3013926584',
            CS_Empresa_Colmena__c = '1',
            CC_Tipo_de_Cuenta__c = 'Cuenta Prospecto' //,
            //NumberOfEmployees = 10,
            //FixedAssets__c = 10,
            //BillingIncome__c = 10
        );
        insert acc;
    }

    @isTest
    static void testCallCreateClient() {
        Map<String, Object> request = new Map<String, Object>{
            'FirstName' => 'John',
            'SecondName' => 'Doe',
            'LastName' => 'Smith',
            'SecondLastName' => 'Johnson',
            'identityType' => 'Passport',
            'identityNumber' => '1234567890',
            'email' => 'john.doe@example.com',
            'numberPhone' => '1234567890',
            'AttentionChannel' => 'Email',
            'Companies' => new List<Map<String, Object>>{
                new Map<String, Object>{
                    'name' => 'Company1',
                    'essentialFunctionalities' => true,
                    'notessentialFunctionalities' => new List<String>{ 'FNE1', 'FNE2' },
                    'MedicalHistory' => false
                }
            }
        };

        Map<String, Object> input = new Map<String, Object>{ 'Request' => request };
        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();

        Map<String, Object> args = new Map<String, Object>{ 'input' => input, 'output' => output, 'options' => options };

        WS_OSTIpoAutorizacion instance = new WS_OSTIpoAutorizacion();
        Test.startTest();
        Object result = instance.call('createClient', args);
        Test.stopTest();

        System.assertNotEquals(null, output.get('Exito'));
    }

    @isTest
    static void testCallHomologateJsonIsLead() {
        Map<String, Object> datosCuenta = new Map<String, Object>{
            'FirstNameLead' => 'Camilo',
            'MiddleNameLead' => 'Test',
            'LastNameLead' => 'Merchan',
            'SecondLastNameLead' => 'Test',
            'IdentityTypeLead' => '1',
            'IdentityNumberLead' => '1010137364',
            'EmailLead' => 'test@example.com',
            'numberPhoneLead' => '123456789',
            'SexLead' => 'Male'
        };

        Map<String, Object> requestMap = new Map<String, Object>{ 'DatosCuenta' => datosCuenta };
        Map<String, Object> inputMap = new Map<String, Object>{ 'Request' => requestMap, 'IsLead' => true };
        Map<String, Object> outMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();

        WS_OSTIpoAutorizacion instance = new WS_OSTIpoAutorizacion();
        Test.startTest();
        Boolean result = instance.invokeMethod('homologateJson', inputMap, outMap, options);
        Test.stopTest();

        System.assertNotEquals(null, result);
    }

    @isTest
    static void testCallHomologateJsonIsQuoting() {
        Map<String, Object> datosCuenta = new Map<String, Object>{
            'FirstNamePersonal' => 'Camilo',
            'MiddleNamePersonal' => 'Test',
            'LastNamePersonal' => 'Merchan',
            'SecondLastNamePersonal' => 'Test',
            'IdentityTypePersonal' => '1',
            'IdentityNumberPersonal' => '1010137364',
            'EmailPersonal' => 'test@example.com',
            'numberPhonePersonal' => '123456789',
            'sexoPersonal' => 'Male'
        };

        Map<String, Object> requestMap = new Map<String, Object>{ 'DatosCuenta' => datosCuenta };
        Map<String, Object> inputMap = new Map<String, Object>{ 'Request' => requestMap, 'IsQuoting' => true };
        Map<String, Object> outMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();

        WS_OSTIpoAutorizacion instance = new WS_OSTIpoAutorizacion();
        Test.startTest();
        Boolean result = instance.invokeMethod('homologateJson', inputMap, outMap, options);
        Test.stopTest();

        System.assertNotEquals(null, result);
    }

    @isTest
    static void testCallHomologateJsonDefault() {
        Map<String, Object> datosCuenta = new Map<String, Object>{
            'FirstName' => 'Camilo',
            'MiddleName' => 'Test',
            'LastName' => 'Merchan',
            'SecondLastName' => 'Test',
            'IdentityType' => '1',
            'IdentityNumber' => '1010137364',
            'Email' => 'test@example.com',
            'numberPhone' => '123456789',
            'sexo' => 'Male'
        };

        Map<String, Object> requestMap = new Map<String, Object>{ 'DatosCuenta' => datosCuenta };
        Map<String, Object> inputMap = new Map<String, Object>{ 'Request' => requestMap };
        Map<String, Object> outMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();

        WS_OSTIpoAutorizacion instance = new WS_OSTIpoAutorizacion();
        Test.startTest();
        Boolean result = instance.invokeMethod('homologateJson', inputMap, outMap, options);
        Test.stopTest();

        System.assertNotEquals(null, result);
    }

    @isTest
    static void testSaveInformationHabeasDataFromOmniscript() {
        String jsonString = '{"AttentionChannel":"Mary","AuthorizeDataProcessing":{"AuthorizeDataProcessingCheckbox":true,"AuthorizeTermsAndConditions":true,"RadioGoodsProducts":"Yes","RadioGoodsProducts2":"Yes","RadioTastesHabitsInterests":"Yes"},"FNE1":"Yes","FNE2":"Yes","FNE3":"Yes","FirstName":"Test","LastName":"Test","PersonData":{"addresshome":"Test","documentNumber":"23494390","documentType":"1","email":"test@oc.vasscompany.com","firstName":"Test","lastName":"Test","phoneNumber":"3145601769","relationType":"Cónyuge","secondLastName":"Test","secondName":"Test"},"SecondLastName":"Test","SecondName":"Test"}';
        Map<String, Object> dataMap = (Map<String, Object>) JSON.deserializeUntyped(jsonString);

        Test.startTest();
        WS_OSTIpoAutorizacion.saveInformationHabeasDataFromOmniscript(dataMap);
        Test.stopTest();
    }

    @isTest
    static void testCallHomologateJsonDefaultWithCompanies() {
        Map<String, Object> datosCuenta = new Map<String, Object>{
            'FirstName' => 'Camilo',
            'MiddleName' => 'Test',
            'LastName' => 'Merchan',
            'SecondLastName' => 'Test',
            'IdentityType' => '1',
            'IdentityNumber' => '1010137364',
            'Email' => 'test@example.com',
            'numberPhone' => '123456789',
            'sexo' => 'Male',
            'ColmenaSegurosVida' => new Map<String, Object>{ 'essentialFunctionalitiesVida' => true, 'notessentialFunctionalitiesVida' => 'FNE1;FNE3' },
            'ColmenaSegurosARL' => new Map<String, Object>{ 'essentialFunctionalitiesARL' => true, 'notessentialFunctionalitiesARL' => 'FNE2' }
        };

        Map<String, Object> requestMap = new Map<String, Object>{ 'DatosCuenta' => datosCuenta };
        Map<String, Object> inputMap = new Map<String, Object>{ 'Request' => requestMap };
        Map<String, Object> outMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();

        WS_OSTIpoAutorizacion instance = new WS_OSTIpoAutorizacion();
        Test.startTest();
        Boolean result = instance.invokeMethod('homologateJson', inputMap, outMap, options);
        Test.stopTest();

        System.assertNotEquals(null, result);
    }

    @isTest
    static void testCallHomologateJsonIsQuotingWithCompanies() {
        Map<String, Object> datosCuenta = new Map<String, Object>{
            'FirstNamePersonal' => 'Camilo',
            'MiddleNamePersonal' => 'Test',
            'LastNamePersonal' => 'Merchan',
            'SecondLastNamePersonal' => 'Test',
            'IdentityTypePersonal' => '1',
            'IdentityNumberPersonal' => '1010137364',
            'EmailPersonal' => 'test@example.com',
            'numberPhonePersonal' => '123456789',
            'sexoPersonal' => 'Male',
            'ColmenaCapitalizadora' => new Map<String, Object>{
                'essentialFunctionalitiesCapitalizadora' => true,
                'notessentialFunctionalitiesCapitalizadora' => 'FNE1;FNE2'
            },
            'ColmenaSegurosGenerales' => new Map<String, Object>{
                'essentialFunctionalitiesGenerales' => true,
                'notessentialFunctionalitiesGenerales' => 'FNE1'
            },
            'ColmenaSegurosVida' => new Map<String, Object>{ 'essentialFunctionalitiesGenerales' => true, 'notessentialFunctionalitiesGenerales' => 'FNE1' },
            'ColmenaSegurosARL' => new Map<String, Object>{ 'essentialFunctionalitiesGenerales' => true, 'notessentialFunctionalitiesGenerales' => 'FNE1' }
        };

        Map<String, Object> requestMap = new Map<String, Object>{ 'DatosCuenta' => datosCuenta };
        Map<String, Object> inputMap = new Map<String, Object>{ 'Request' => requestMap, 'IsQuoting' => true };
        Map<String, Object> outMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();

        WS_OSTIpoAutorizacion instance = new WS_OSTIpoAutorizacion();
        Test.startTest();
        Boolean result = instance.invokeMethod('homologateJson', inputMap, outMap, options);
        Test.stopTest();

        System.assertNotEquals(null, result);
    }

    @isTest
    static void testCallHomologateJsonIsQuotingFalse() {
        Map<String, Object> datosCuenta = new Map<String, Object>{
            'FirstNamePersonal' => 'Camilo',
            'MiddleNamePersonal' => 'Test',
            'LastNamePersonal' => 'Merchan',
            'SecondLastNamePersonal' => 'Test',
            'IdentityTypePersonal' => '1',
            'IdentityNumberPersonal' => '1010137364',
            'EmailPersonal' => 'test@example.com',
            'numberPhonePersonal' => '123456789',
            'sexoPersonal' => 'Male',
            'ColmenaCapitalizadora' => new Map<String, Object>{
                'essentialFunctionalitiesCapitalizadora' => true,
                'notessentialFunctionalitiesCapitalizadora' => 'FNE1;FNE2'
            },
            'ColmenaSegurosGenerales' => new Map<String, Object>{
                'essentialFunctionalitiesGenerales' => true,
                'notessentialFunctionalitiesGenerales' => 'FNE1'
            },
            'ColmenaSegurosVida' => new Map<String, Object>{ 'essentialFunctionalitiesGenerales' => true, 'notessentialFunctionalitiesGenerales' => 'FNE1' },
            'ColmenaSegurosARL' => new Map<String, Object>{ 'essentialFunctionalitiesGenerales' => true, 'notessentialFunctionalitiesGenerales' => 'FNE1' }
        };

        Map<String, Object> requestMap = new Map<String, Object>{ 'DatosCuenta' => datosCuenta };
        Map<String, Object> inputMap = new Map<String, Object>{ 'Request' => requestMap, 'IsQuoting' => false, 'isLead' => true };
        Map<String, Object> outMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();

        WS_OSTIpoAutorizacion instance = new WS_OSTIpoAutorizacion();
        Test.startTest();
        Boolean result = instance.invokeMethod('homologateJson', inputMap, outMap, options);
        Test.stopTest();

        System.assertNotEquals(null, result);
    }
}