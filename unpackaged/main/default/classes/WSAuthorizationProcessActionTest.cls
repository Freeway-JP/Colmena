@isTest
public class WSAuthorizationProcessActionTest {
    
    @isTest
    static void testTransformDataMethodWithValidData() {
        // Setup
        WSAuthorizationProcessAction action = new WSAuthorizationProcessAction();
        Map<String, Object> input = createValidInput();
        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        Map<String, Object> args = new Map<String, Object>{
            'input' => input,
            'output' => output,
            'options' => options
        };
        
        // Execute
        Test.startTest();
        Object result = action.call('transformData', args);
        Test.stopTest();
        
        // Verify
        System.assert(result != null, 'Result should not be null');
        System.assert((Boolean)result == true, 'Method should return true');
        System.assert(output.containsKey('result'), 'Output should contain result');
        
        // Verify the response structure
        Map<String, Object> resultMap = (Map<String, Object>)output.get('result');
        System.assert(resultMap.containsKey('status'), 'Result should contain status');
        System.assert(resultMap.containsKey('error'), 'Result should contain error');
        System.assert(resultMap.containsKey('responseCode'), 'Result should contain responseCode');
        System.assert(resultMap.containsKey('message'), 'Result should contain message');
    }
    
    @isTest
    static void testTransformDataMethodWithContactType() {
        // Setup
        WSAuthorizationProcessAction action = new WSAuthorizationProcessAction();
        Map<String, Object> input = createContactTypeInput();
        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        Map<String, Object> args = new Map<String, Object>{
            'input' => input,
            'output' => output,
            'options' => options
        };
        
        // Execute
        Test.startTest();
        Object result = action.call('transformData', args);
        Test.stopTest();
        
        // Verify
        System.assert(result != null, 'Result should not be null');
        System.assert((Boolean)result == true, 'Method should return true');
        System.assert(output.containsKey('result'), 'Output should contain result');
    }
    
    @isTest
    static void testTransformDataMethodWithInvalidInput() {
        // Setup
        WSAuthorizationProcessAction action = new WSAuthorizationProcessAction();
        Map<String, Object> input = new Map<String, Object>(); // Invalid input
        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        Map<String, Object> args = new Map<String, Object>{
            'input' => input,
            'output' => output,
            'options' => options
        };
        
        // Execute
        Test.startTest();
        Object result = action.call('transformData', args);
        Test.stopTest();
        
        // Verify
        System.assert(output.containsKey('error'), 'Output should contain error message');
        System.assertEquals('Invalid input parameters', output.get('error'));
    }
    
    @isTest
    static void testInvalidMethodName() {
        // Setup
        WSAuthorizationProcessAction action = new WSAuthorizationProcessAction();
        Map<String, Object> input = createValidInput();
        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        Map<String, Object> args = new Map<String, Object>{
            'input' => input,
            'output' => output,
            'options' => options
        };
        
        // Execute
        Test.startTest();
        Object result = action.call('invalidMethod', args);
        Test.stopTest();
        
        // Verify
        System.assert(result != null, 'Result should not be null');
        System.assertEquals('', output.get('result'));
    }
    
    @isTest
    static void testProcessCompaniesWithAllTypes() {
        // Setup
        WSAuthorizationProcessAction action = new WSAuthorizationProcessAction();
        Map<String, Object> input = createInputWithAllCompanies();
        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        Map<String, Object> args = new Map<String, Object>{
            'input' => input,
            'output' => output,
            'options' => options
        };
        
        // Execute
        Test.startTest();
        Object result = action.call('transformData', args);
        Test.stopTest();
        
        // Verify
        System.assert(result != null, 'Result should not be null');
        System.assert(output.containsKey('result'), 'Output should contain result');
    }
    
    @isTest
    static void testProcessCompaniesWithOnlyCommercialOffer() {
        // Setup
        WSAuthorizationProcessAction action = new WSAuthorizationProcessAction();
        Map<String, Object> input = createInputWithCommercialOfferOnly();
        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        Map<String, Object> args = new Map<String, Object>{
            'input' => input,
            'output' => output,
            'options' => options
        };
        
        // Execute
        Test.startTest();
        Object result = action.call('transformData', args);
        Test.stopTest();
        
        // Verify
        System.assert(result != null, 'Result should not be null');
        System.assert(output.containsKey('result'), 'Output should contain result');
    }
    
    @isTest
    static void testProcessCompaniesWithNullValues() {
        // Setup
        WSAuthorizationProcessAction action = new WSAuthorizationProcessAction();
        Map<String, Object> input = createInputWithNullValues();
        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        Map<String, Object> args = new Map<String, Object>{
            'input' => input,
            'output' => output,
            'options' => options
        };
        
        // Execute
        Test.startTest();
        Object result = action.call('transformData', args);
        Test.stopTest();
        
        // Verify
        System.assert(result != null, 'Result should not be null');
        System.assert(output.containsKey('result'), 'Output should contain result');
    }
    
    @isTest
    static void testCallMethodDirectly() {
        // Setup
        WSAuthorizationProcessAction action = new WSAuthorizationProcessAction();
        Map<String, Object> input = createValidInput();
        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        Map<String, Object> args = new Map<String, Object>{
            'input' => input,
            'output' => output,
            'options' => options
        };
        
        // Execute - call method directly through call interface
        Test.startTest();
        Object result = action.call('TRANSFORMDATA', args); // Test case insensitive
        Test.stopTest();
        
        // Verify
        System.assert(result != null, 'Result should not be null');
        System.assert((Boolean)result == true, 'Method should return true');
    }
    
    // Helper methods to create test data
    private static Map<String, Object> createValidInput() {
        return new Map<String, Object>{
            'TypeRecord' => 'Account',
            'GeneralInformation' => new Map<String, Object>{
                'FirstName' => 'Juan',
                'MiddleName' => 'Carlos',
                'LastName' => 'Perez',
                'Suffix' => 'Jr',
                'IdentificationType' => '1',
                'IdentificationNumber' => '1234567890',
                'Email' => 'test@test.com',
                'MobilePhone' => '3001234567',
                'Sexo' => '1',
                'UsePurpose' => 'Prospecto',
                'authorizationChannel' => 'Web',
                'ContactName' => 'Maria',
                'ContactLastName' => 'Lopez',
                'ContactIdentificationType' => '1',
                'ContactIdentificationNumber' => '0987654321'
            },
            'IdentityValidation' => new Map<String, Object>{
                'ValidateIdentityWhitoutData' => false,
                'Status' => 'Valid',
                'Result' => 'Success',
                'Origin' => 'Test',
                'IdentificationTypeHistory' => '1'
            },
            'Channel' => new Map<String, Object>{
                'channelType' => 'Web',
                'process' => 'Venta',
                'businessCoverage' => 'Nacional',
                'origin' => 'Web',
                'collectionMethodType' => 'Digital'
            },
            'LifeInsurance' => new Map<String, Object>{
                'AuthorizeLifeInsurance' => true,
                'MedicalHistoryLI' => true,
                'DataMarketingLI' => true,
                'GeneralCommercialOfferLI' => true,
                'ProcessingGeneralDataLI' => true,
                'CommercialOfferSectionLI' => new Map<String, Object>{
                    'WhatsAppLI' => true,
                    'EmailLI' => false,
                    'PhoneLI' => true,
                    'SMSLI' => false,
                    'WhatsAppLIValue' => '3001234567',
                    'PhoneLIValue' => '3009876543'
                },
                'PortfolioManagementSectionLI' => new Map<String, Object>{
                    'WhatsAppPortfolioLI' => false,
                    'EmailPortfolioLI' => true,
                    'PhonePortfolioLI' => false,
                    'SMSPortfolioLI' => true,
                    'EmailPortfolioLIValue' => 'portfolio@test.com',
                    'SMSPortfolioLIValue' => '3001111111'
                }
            }
        };
    }
    
    private static Map<String, Object> createContactTypeInput() {
        return new Map<String, Object>{
            'TypeRecord' => 'Contact',
            'GeneralInformation' => new Map<String, Object>{
                'CompanyName' => 'Test Company S.A.S',
                'IdentificationType' => '3',
                'IdentificationNumber' => '9001234567',
                'ContactEmail' => 'contact@company.com',
                'ContactMobilePhone' => '3109876543',
                'Sexo' => null,
                'UsePurpose' => 'Cliente Representante Legal',
                'authorizationChannel' => 'Telefono',
                'ContactName' => 'Ana',
                'ContactLastName' => 'Garcia',
                'ContactIdentificationType' => '1',
                'ContactIdentificationNumber' => '1122334455'
            },
            'IdentityValidation' => new Map<String, Object>{
                'ValidateIdentityWhitoutData' => true,
                'Status' => 'Pending',
                'Result' => 'Processing',
                'Origin' => 'External',
                'IdentificationTypeHistory' => '3'
            },
            'Channel' => new Map<String, Object>{
                'channelType' => 'Telefónico',
                'process' => 'Prospección',
                'businessCoverage' => 'Regional',
                'origin' => 'Call Center',
                'collectionMethodType' => 'Manual'
            },
            'LifeInsurance' => new Map<String, Object>{
                'AuthorizeLifeInsurance' => false,
                'MedicalHistoryLI' => null,
                'DataMarketingLI' => null,
                'GeneralCommercialOfferLI' => true,
                'ProcessingGeneralDataLI' => null,
                'CommercialOfferSectionLI' => null,
                'PortfolioManagementSectionLI' => null
            }
        };
    }
    
    private static Map<String, Object> createInputWithAllCompanies() {
        Map<String, Object> input = createValidInput();
        
        input.put('ARL', new Map<String, Object>{
            'AuthorizeARL' => true,
            'MedicalHistoryARL' => false,
            'DataMarketingARL' => true,
            'GeneralCommercialOfferARL' => true,
            'ProcessingGeneralDataARL' => false,
            'CommercialOfferSectionARL' => new Map<String, Object>{
                'WhatsAppARL' => true,
                'EmailARL' => true,
                'PhoneARL' => false,
                'SMSARL' => false,
                'WhatsAppARLValue' => '3001234567',
                'EmailARLValue' => 'test@test.com'
            },
            'PortfolioManagementSectionARL' => new Map<String, Object>{
                'WhatsAppPortfolioARL' => false,
                'EmailPortfolioARL' => true,
                'PhonePortfolioARL' => true,
                'SMSPortfolioARL' => false,
                'EmailPortfolioARLValue' => 'portfolio@test.com',
                'PhonePortfolioARLValue' => '3009876543'
            }
        });
        
        input.put('General', new Map<String, Object>{
            'AuthorizeGeneral' => true,
            'DataMarketingGeneral' => false,
            'GeneralCommercialOfferGeneral' => true,
            'ProcessingGeneralDataGeneral' => true,
            'CommercialOfferSectionGeneral' => new Map<String, Object>{
                'WhatsAppGeneral' => true,
                'EmailGeneral' => false,
                'PhoneGeneral' => true,
                'SMSGeneral' => true,
                'WhatsAppGeneralValue' => '3001234567',
                'PhoneGeneralValue' => '3009876543',
                'SMSGeneralValue' => '3001111111'
            },
            'PortfolioManagementSectionGeneral' => new Map<String, Object>{
                'WhatsAppPortfolioGeneral' => true,
                'EmailPortfolioGeneral' => false,
                'PhonePortfolioGeneral' => false,
                'SMSPortfolioGeneral' => true,
                'WhatsAppPortfolioGeneralValue' => '3007777777',
                'SMSPortfolioGeneralValue' => '3008888888'
            }
        });
        
        return input;
    }
    
    private static Map<String, Object> createInputWithCommercialOfferOnly() {
        Map<String, Object> input = createValidInput();
        
        // Override LifeInsurance to only have commercial offer
        input.put('LifeInsurance', new Map<String, Object>{
            'AuthorizeLifeInsurance' => false,
            'MedicalHistoryLI' => null,
            'DataMarketingLI' => null,
            'GeneralCommercialOfferLI' => true,
            'ProcessingGeneralDataLI' => null,
            'CommercialOfferSectionLI' => null,
            'PortfolioManagementSectionLI' => null
        });
        
        input.put('ARL', new Map<String, Object>{
            'AuthorizeARL' => false,
            'MedicalHistoryARL' => null,
            'DataMarketingARL' => null,
            'GeneralCommercialOfferARL' => true,
            'ProcessingGeneralDataARL' => null,
            'CommercialOfferSectionARL' => null,
            'PortfolioManagementSectionARL' => null
        });
        
        input.put('General', new Map<String, Object>{
            'AuthorizeGeneral' => false,
            'DataMarketingGeneral' => null,
            'GeneralCommercialOfferGeneral' => true,
            'ProcessingGeneralDataGeneral' => null,
            'CommercialOfferSectionGeneral' => null,
            'PortfolioManagementSectionGeneral' => null
        });
        
        return input;
    }
    
    private static Map<String, Object> createInputWithNullValues() {
        return new Map<String, Object>{
            'TypeRecord' => null,
            'GeneralInformation' => new Map<String, Object>{
                'FirstName' => null,
                'MiddleName' => null,
                'LastName' => 'TestUser',
                'Suffix' => null,
                'IdentificationType' => '1',
                'IdentificationNumber' => '1111111111',
                'Email' => null,
                'MobilePhone' => null,
                'Sexo' => null,
                'UsePurpose' => null,
                'authorizationChannel' => null,
                'ContactName' => null,
                'ContactLastName' => null,
                'ContactIdentificationType' => null,
                'ContactIdentificationNumber' => null
            },
            'IdentityValidation' => new Map<String, Object>{
                'ValidateIdentityWhitoutData' => null,
                'Status' => null,
                'Result' => null,
                'Origin' => null,
                'IdentificationTypeHistory' => null
            },
            'Channel' => null,
            'LifeInsurance' => null,
            'ARL' => null,
            'General' => null
        };
    }
}