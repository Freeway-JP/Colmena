@IsTest
private class RevocationDataTransformerTest {

    /**
     * Helper method to create a complete consent data for regular client
     */
    private static Map<String, Object> createRegularClientConsent() {
        Map<String, Object> consent = new Map<String, Object>();

        // Basic identity data
        consent.put('UsePurpose', 'Cliente');
        consent.put('IdentificationType', 'CC');
        consent.put('IdentificationNumber', '123456789');
        consent.put('FirstName', 'Juan');
        consent.put('MiddleName', 'Carlos');
        consent.put('LastName', 'Pérez');
        consent.put('Suffix', 'González');
        consent.put('Email', 'juan.perez@test.com');
        consent.put('Phone', '3001234567');

        // Channel and process data
        consent.put('Process', 'Revocación');
        consent.put('Origin', 'Web');
        consent.put('ChannelType', 'Digital');
        consent.put('BusinessCoverage', 'Nacional');
        consent.put('AuthorizationChannel', 'Portal');
        consent.put('CollectionMethodType', 'Virtual');

        // Identity validation
        consent.put('IndividualIdentificationType', 'Manual');
        consent.put('IdentityValidationNoData', false);

        // Authorization checks
        consent.put('AuthorizationChecks', createAuthorizationChecks());

        return consent;
    }

    /**
     * Helper method to create consent data for legal representative
     */
    private static Map<String, Object> createLegalRepConsent() {
        Map<String, Object> consent = new Map<String, Object>();

        // Company identity data
        consent.put('UsePurpose', 'Cliente Representante Legal');
        consent.put('IdentificationType_Emp', 'NIT');
        consent.put('IdentificationNumber_Emp', '900123456');
        consent.put('EntityName', 'Empresa Test SAS');

        // Legal representative personal data
        consent.put('FirstName', 'María');
        consent.put('LastName', 'López');
        consent.put('IndividualIdentificationType', 'CC');
        consent.put('IndividualIdentificationNumber', '987654321');

        consent.put('Email', 'empresa@test.com');
        consent.put('Phone', '3009876543');

        // Channel and process data
        consent.put('Process', 'Revocación');
        consent.put('Origin', 'Email');
        consent.put('ChannelType', 'Digital');
        consent.put('BusinessCoverage', 'Nacional');
        consent.put('AuthorizationChannel', 'Email');
        consent.put('CollectionMethodType', 'Virtual');

        // Identity validation
        consent.put('IdentityValidationNoData', true);

        // Authorization checks
        consent.put('AuthorizationChecks', createAuthorizationChecks());

        return consent;
    }

    /**
     * Helper method to create authorization checks for all three companies
     */
    private static List<Object> createAuthorizationChecks() {
        List<Object> checks = new List<Object>();

        // Seguro de Vida
        Map<String, Object> vida = new Map<String, Object>();
        vida.put('BusinessBrand', 'Seguro de Vida');
        vida.put('MedicalHistory', true);
        vida.put('GeneralProcessingData', true);
        vida.put('GeneralDataMarketing', false);
        vida.put('GeneralCommercialOffer', true);

        Map<String, Object> vidaCO = new Map<String, Object>();
        vidaCO.put('WhatsapppCO', true);
        vidaCO.put('EmailCO', true);
        vidaCO.put('CelularCO', false);
        vidaCO.put('SmsCO', false);
        vida.put('CommercialOffering2300', vidaCO);

        Map<String, Object> vidaPM = new Map<String, Object>();
        vidaPM.put('WhatsapppPM', false);
        vidaPM.put('EmailPM', true);
        vidaPM.put('CelularPM', true);
        vidaPM.put('SmsPM', false);
        vida.put('PortfolioManagement2300', vidaPM);

        checks.add(vida);

        // ARL
        Map<String, Object> arl = new Map<String, Object>();
        arl.put('BusinessBrand', 'ARL');
        arl.put('MedicalHistory', false);
        arl.put('GeneralProcessingData', true);
        arl.put('GeneralDataMarketing', true);
        arl.put('GeneralCommercialOffer', false);

        Map<String, Object> arlCO = new Map<String, Object>();
        arlCO.put('WhatsapppCO', false);
        arlCO.put('EmailCO', false);
        arlCO.put('CelularCO', true);
        arlCO.put('SmsCO', true);
        arl.put('CommercialOffering2300', arlCO);

        Map<String, Object> arlPM = new Map<String, Object>();
        arlPM.put('WhatsapppPM', true);
        arlPM.put('EmailPM', false);
        arlPM.put('CelularPM', false);
        arlPM.put('SmsPM', true);
        arl.put('PortfolioManagement2300', arlPM);

        checks.add(arl);

        // Seguros Generales
        Map<String, Object> generales = new Map<String, Object>();
        generales.put('BusinessBrand', 'Seguros Generales');
        generales.put('MedicalHistory', false);
        generales.put('GeneralProcessingData', true);
        generales.put('GeneralDataMarketing', false);
        generales.put('GeneralCommercialOffer', true);

        Map<String, Object> generalesCO = new Map<String, Object>();
        generalesCO.put('WhatsapppCO', true);
        generalesCO.put('EmailCO', false);
        generalesCO.put('CelularCO', true);
        generalesCO.put('SmsCO', false);
        generales.put('CommercialOffering2300', generalesCO);

        Map<String, Object> generalesPM = new Map<String, Object>();
        generalesPM.put('WhatsapppPM', false);
        generalesPM.put('EmailPM', true);
        generalesPM.put('CelularPM', false);
        generalesPM.put('SmsPM', true);
        generales.put('PortfolioManagement2300', generalesPM);

        checks.add(generales);

        return checks;
    }

    /**
     * Test call method with transformRevocationData action
     */
    @IsTest
    static void test_call_method_transform_action() {
        RevocationDataTransformer transformer = new RevocationDataTransformer();

        Map<String, Object> inputMap = new Map<String, Object>();
        inputMap.put('groupedConsents', new List<Object>{ createRegularClientConsent() });

        Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();

        Map<String, Object> args = new Map<String, Object>();
        args.put('input', inputMap);
        args.put('output', outputMap);
        args.put('options', options);

        Test.startTest();
        Object result = transformer.call('transformRevocationData', args);
        Test.stopTest();

        System.assertEquals(true, result, 'Call should return true for valid action');
        System.assert(outputMap.containsKey('transformedDataList'), 'Output should contain transformedDataList');
    }

    /**
     * Test call method with invalid action
     */
    @IsTest
    static void test_call_method_invalid_action() {
        RevocationDataTransformer transformer = new RevocationDataTransformer();

        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();

        Map<String, Object> args = new Map<String, Object>();
        args.put('input', inputMap);
        args.put('output', outputMap);
        args.put('options', options);

        Test.startTest();
        Object result = transformer.call('invalidAction', args);
        Test.stopTest();

        System.assertEquals(false, result, 'Call should return false for invalid action');
    }

    /**
     * Test transformRevocationData with single consent as list
     */
    @IsTest
    static void test_transform_single_consent_as_list() {
        RevocationDataTransformer transformer = new RevocationDataTransformer();

        Map<String, Object> inputMap = new Map<String, Object>();
        List<Object> consents = new List<Object>{ createRegularClientConsent() };
        inputMap.put('groupedConsents', consents);

        Map<String, Object> outputMap = new Map<String, Object>();

        Test.startTest();
        transformer.transformRevocationData(inputMap, outputMap);
        Test.stopTest();

        System.assert(outputMap.containsKey('transformedDataList'), 'Output should contain transformedDataList');
        List<Object> transformedList = (List<Object>) outputMap.get('transformedDataList');
        System.assertEquals(1, transformedList.size(), 'Should transform 1 consent');
    }

    /**
     * Test transformRevocationData with single consent as object (not list)
     */
    @IsTest
    static void test_transform_single_consent_as_object() {
        RevocationDataTransformer transformer = new RevocationDataTransformer();

        Map<String, Object> inputMap = new Map<String, Object>();
        inputMap.put('groupedConsents', createRegularClientConsent());

        Map<String, Object> outputMap = new Map<String, Object>();

        Test.startTest();
        transformer.transformRevocationData(inputMap, outputMap);
        Test.stopTest();

        System.assert(outputMap.containsKey('transformedDataList'), 'Output should contain transformedDataList');
        List<Object> transformedList = (List<Object>) outputMap.get('transformedDataList');
        System.assertEquals(1, transformedList.size(), 'Should transform 1 consent');
    }

    /**
     * Test transformRevocationData with multiple consents
     */
    @IsTest
    static void test_transform_multiple_consents() {
        RevocationDataTransformer transformer = new RevocationDataTransformer();

        Map<String, Object> inputMap = new Map<String, Object>();
        List<Object> consents = new List<Object>{
            createRegularClientConsent(),
            createLegalRepConsent()
        };
        inputMap.put('groupedConsents', consents);

        Map<String, Object> outputMap = new Map<String, Object>();

        Test.startTest();
        transformer.transformRevocationData(inputMap, outputMap);
        Test.stopTest();

        List<Object> transformedList = (List<Object>) outputMap.get('transformedDataList');
        System.assertEquals(2, transformedList.size(), 'Should transform 2 consents');
    }

    /**
     * Test transformRevocationData with null groupedConsents
     */
    @IsTest
    static void test_transform_null_consents() {
        RevocationDataTransformer transformer = new RevocationDataTransformer();

        Map<String, Object> inputMap = new Map<String, Object>();
        inputMap.put('groupedConsents', null);

        Map<String, Object> outputMap = new Map<String, Object>();

        Test.startTest();
        transformer.transformRevocationData(inputMap, outputMap);
        Test.stopTest();

        System.assert(outputMap.containsKey('error'), 'Output should contain error');
        System.assertEquals('No grouped consents found', outputMap.get('error'));
    }

    /**
     * Test transformRevocationData with empty list
     */
    @IsTest
    static void test_transform_empty_list() {
        RevocationDataTransformer transformer = new RevocationDataTransformer();

        Map<String, Object> inputMap = new Map<String, Object>();
        inputMap.put('groupedConsents', new List<Object>());

        Map<String, Object> outputMap = new Map<String, Object>();

        Test.startTest();
        transformer.transformRevocationData(inputMap, outputMap);
        Test.stopTest();

        System.assert(outputMap.containsKey('error'), 'Output should contain error');
        System.assertEquals('No grouped consents found', outputMap.get('error'));
    }

    /**
     * Test transformation of regular client (Cliente)
     */
    @IsTest
    static void test_transform_regular_client() {
        RevocationDataTransformer transformer = new RevocationDataTransformer();

        Map<String, Object> inputMap = new Map<String, Object>();
        inputMap.put('groupedConsents', new List<Object>{ createRegularClientConsent() });

        Map<String, Object> outputMap = new Map<String, Object>();
        transformer.transformRevocationData(inputMap, outputMap);

        List<Object> transformedList = (List<Object>) outputMap.get('transformedDataList');
        Map<String, Object> dto = (Map<String, Object>) transformedList[0];

        // Verify basic fields
        System.assertEquals('Cliente', dto.get('dataUsePurpose'), 'Should be Cliente');
        System.assertEquals('CC', dto.get('identityType'), 'Should use IdentificationType');
        System.assertEquals('123456789', dto.get('identityNumber'), 'Should use IdentificationNumber');
        System.assertEquals('Juan', dto.get('firstName'), 'Should have firstName');
        System.assertEquals('Carlos', dto.get('secondName'), 'Should have secondName');
        System.assertEquals('Pérez', dto.get('lastName'), 'Should have lastName');
        System.assertEquals('González', dto.get('secondLastName'), 'Should have secondLastName');

        // Verify contact should be null for regular client
        System.assertEquals(null, dto.get('contactFirstName'), 'Contact fields should be null for regular client');
        System.assertEquals(null, dto.get('contactLastName'), 'Contact fields should be null for regular client');
        System.assertEquals(null, dto.get('contactIdType'), 'Contact fields should be null for regular client');
        System.assertEquals(null, dto.get('contactIdNumber'), 'Contact fields should be null for regular client');
    }

    /**
     * Test transformation of legal representative
     */
    @IsTest
    static void test_transform_legal_representative() {
        RevocationDataTransformer transformer = new RevocationDataTransformer();

        Map<String, Object> inputMap = new Map<String, Object>();
        inputMap.put('groupedConsents', new List<Object>{ createLegalRepConsent() });

        Map<String, Object> outputMap = new Map<String, Object>();
        transformer.transformRevocationData(inputMap, outputMap);

        List<Object> transformedList = (List<Object>) outputMap.get('transformedDataList');
        Map<String, Object> dto = (Map<String, Object>) transformedList[0];

        // Verify company identity fields
        System.assertEquals('Cliente Representante Legal', dto.get('dataUsePurpose'));
        System.assertEquals('NIT', dto.get('identityType'), 'Should use IdentificationType_Emp');
        System.assertEquals('900123456', dto.get('identityNumber'), 'Should use IdentificationNumber_Emp');
        System.assertEquals('Empresa Test SAS', dto.get('lastName'), 'Should use EntityName for lastName');

        // Verify personal fields should be null for legal rep
        System.assertEquals(null, dto.get('firstName'), 'firstName should be null for legal rep');
        System.assertEquals(null, dto.get('secondName'), 'secondName should be null for legal rep');
        System.assertEquals(null, dto.get('secondLastName'), 'secondLastName should be null for legal rep');

        // Verify legal representative contact data
        System.assertEquals('María', dto.get('contactFirstName'), 'Should have contact firstName');
        System.assertEquals('López', dto.get('contactLastName'), 'Should have contact lastName');
        System.assertEquals('CC', dto.get('contactIdType'), 'Should have contact idType');
        System.assertEquals('987654321', dto.get('contactIdNumber'), 'Should have contact idNumber');
    }

    /**
     * Test companies transformation
     */
    @IsTest
    static void test_companies_transformation() {
        RevocationDataTransformer transformer = new RevocationDataTransformer();

        Map<String, Object> inputMap = new Map<String, Object>();
        inputMap.put('groupedConsents', new List<Object>{ createRegularClientConsent() });

        Map<String, Object> outputMap = new Map<String, Object>();
        transformer.transformRevocationData(inputMap, outputMap);

        List<Object> transformedList = (List<Object>) outputMap.get('transformedDataList');
        Map<String, Object> dto = (Map<String, Object>) transformedList[0];
        List<Object> companies = (List<Object>) dto.get('companies');

        // Should have 3 companies
        System.assertEquals(3, companies.size(), 'Should have 3 companies');

        // Verify first company (Seguro de Vida)
        Map<String, Object> vida = (Map<String, Object>) companies[0];
        System.assertEquals('Seguro de Vida', vida.get('name'));
        System.assertEquals(true, vida.get('medicalHistory'));
        System.assertEquals(true, vida.get('generalProcessingData'));
    }

    /**
     * Test authorization2300 structure
     */
    @IsTest
    static void test_authorization2300_structure() {
        RevocationDataTransformer transformer = new RevocationDataTransformer();

        Map<String, Object> inputMap = new Map<String, Object>();
        inputMap.put('groupedConsents', new List<Object>{ createRegularClientConsent() });

        Map<String, Object> outputMap = new Map<String, Object>();
        transformer.transformRevocationData(inputMap, outputMap);

        List<Object> transformedList = (List<Object>) outputMap.get('transformedDataList');
        Map<String, Object> dto = (Map<String, Object>) transformedList[0];
        List<Object> companies = (List<Object>) dto.get('companies');
        Map<String, Object> vida = (Map<String, Object>) companies[0];
        List<Object> auth2300 = (List<Object>) vida.get('authorization2300');

        // Should have 8 entries (4 for Commercial Offer + 4 for Portfolio Management)
        System.assertEquals(8, auth2300.size(), 'Should have 8 authorization2300 entries');

        // Verify first entry structure
        Map<String, Object> firstAuth = (Map<String, Object>) auth2300[0];
        System.assert(firstAuth.containsKey('value'), 'Should have value field');
        System.assert(firstAuth.containsKey('dataUsePurpose'), 'Should have dataUsePurpose field');
        System.assert(firstAuth.containsKey('contactPointType'), 'Should have contactPointType field');
        System.assert(firstAuth.containsKey('contactPoint'), 'Should have contactPoint field');
    }

    /**
     * Test authorization2300 with null values
     */
    @IsTest
    static void test_authorization2300_with_null_values() {
        RevocationDataTransformer transformer = new RevocationDataTransformer();

        Map<String, Object> consent = createRegularClientConsent();
        List<Object> authChecks = (List<Object>) consent.get('AuthorizationChecks');
        Map<String, Object> vida = (Map<String, Object>) authChecks[0];

        // Set null commercial offering data
        Map<String, Object> vidaCO = new Map<String, Object>();
        vidaCO.put('WhatsapppCO', null);
        vidaCO.put('EmailCO', null);
        vidaCO.put('CelularCO', null);
        vidaCO.put('SmsCO', null);
        vida.put('CommercialOffering2300', vidaCO);

        Map<String, Object> inputMap = new Map<String, Object>();
        inputMap.put('groupedConsents', new List<Object>{ consent });

        Map<String, Object> outputMap = new Map<String, Object>();
        transformer.transformRevocationData(inputMap, outputMap);

        List<Object> transformedList = (List<Object>) outputMap.get('transformedDataList');
        Map<String, Object> dto = (Map<String, Object>) transformedList[0];
        List<Object> companies = (List<Object>) dto.get('companies');
        Map<String, Object> vidaCompany = (Map<String, Object>) companies[0];
        List<Object> auth2300 = (List<Object>) vidaCompany.get('authorization2300');

        // Verify null values are converted to false
        for (Integer i = 0; i < 4; i++) {
            Map<String, Object> auth = (Map<String, Object>) auth2300[i];
            System.assertEquals(false, auth.get('value'), 'Null values should be converted to false');
        }
    }

    /**
     * Test with null AuthorizationChecks
     */
    @IsTest
    static void test_null_authorization_checks() {
        RevocationDataTransformer transformer = new RevocationDataTransformer();

        Map<String, Object> consent = createRegularClientConsent();
        consent.put('AuthorizationChecks', null);

        Map<String, Object> inputMap = new Map<String, Object>();
        inputMap.put('groupedConsents', new List<Object>{ consent });

        Map<String, Object> outputMap = new Map<String, Object>();

        Test.startTest();
        transformer.transformRevocationData(inputMap, outputMap);
        Test.stopTest();

        List<Object> transformedList = (List<Object>) outputMap.get('transformedDataList');
        Map<String, Object> dto = (Map<String, Object>) transformedList[0];
        List<Object> companies = (List<Object>) dto.get('companies');

        System.assertEquals(0, companies.size(), 'Should have empty companies list when AuthorizationChecks is null');
    }

    /**
     * Test invokeMethod with exception handling
     */
    @IsTest
    static void test_invoke_method_exception_handling() {
        RevocationDataTransformer transformer = new RevocationDataTransformer();

        // Create invalid input that will cause an exception
        Map<String, Object> inputMap = new Map<String, Object>();
        inputMap.put('groupedConsents', 'invalid_data_type'); // This will cause ClassCastException

        Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();

        Test.startTest();
        Boolean result = transformer.invokeMethod('transformRevocationData', inputMap, outputMap, options);
        Test.stopTest();

        System.assertEquals(false, result, 'Should return false when exception occurs');
        System.assertEquals(true, outputMap.get('error'), 'Should set error flag to true');
        System.assert(outputMap.containsKey('message'), 'Should contain error message');
    }

    /**
     * Test Prospecto use purpose
     */
    @IsTest
    static void test_prospecto_use_purpose() {
        RevocationDataTransformer transformer = new RevocationDataTransformer();

        Map<String, Object> consent = createRegularClientConsent();
        consent.put('UsePurpose', 'Prospecto');

        Map<String, Object> inputMap = new Map<String, Object>();
        inputMap.put('groupedConsents', new List<Object>{ consent });

        Map<String, Object> outputMap = new Map<String, Object>();
        transformer.transformRevocationData(inputMap, outputMap);

        List<Object> transformedList = (List<Object>) outputMap.get('transformedDataList');
        Map<String, Object> dto = (Map<String, Object>) transformedList[0];

        System.assertEquals('Prospecto', dto.get('dataUsePurpose'), 'Should be Prospecto');
        System.assertEquals('Juan', dto.get('firstName'), 'Should have firstName for regular prospect');
    }

    /**
     * Test Prospecto Representante Legal use purpose
     */
    @IsTest
    static void test_prospecto_rep_legal_use_purpose() {
        RevocationDataTransformer transformer = new RevocationDataTransformer();

        Map<String, Object> consent = createLegalRepConsent();
        consent.put('UsePurpose', 'Prospecto Representante Legal');

        Map<String, Object> inputMap = new Map<String, Object>();
        inputMap.put('groupedConsents', new List<Object>{ consent });

        Map<String, Object> outputMap = new Map<String, Object>();
        transformer.transformRevocationData(inputMap, outputMap);

        List<Object> transformedList = (List<Object>) outputMap.get('transformedDataList');
        Map<String, Object> dto = (Map<String, Object>) transformedList[0];

        System.assertEquals('Prospecto Representante Legal', dto.get('dataUsePurpose'));
        System.assertEquals(null, dto.get('firstName'), 'firstName should be null for legal rep prospect');
        System.assertEquals('María', dto.get('contactFirstName'), 'Should have contact firstName');
    }
}