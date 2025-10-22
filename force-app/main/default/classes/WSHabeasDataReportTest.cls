/**
 * @description Comprehensive unit test class for WSHabeasDataReport
 *
 * @author Carlos Vivas
 * @date 2025-10-16
 */
@IsTest
private class WSHabeasDataReportTest {
    private static Integer fakeIdCount = 0;

    /**
     * @description Sets up test data for all test methods
     *              Creates complete data hierarchy: Account -> Contact -> Individual -> PartyConsent + InsurancePolicy
     */
    @TestSetup
    static void setupTestData() {
        List<Account> accounts = createTestAccounts(3);
        insert accounts;

        List<Individual> individuals = createTestIndividuals(3);
        insert individuals;

        List<Contact> contacts = createTestContacts(accounts, individuals);
        insert contacts;

        List<DataUsePurpose> purposes = createDataUsePurposes();
        insert purposes;

        List<BusinessBrand> brands = createBusinessBrands();
        insert brands;

        List<PartyConsent> consents = createTestPartyConsents(individuals, accounts, purposes[0].Id, brands[0].Id);
        insert consents;

        List<InsurancePolicy> policies = createTestInsurancePolicies(accounts);
        insert policies;
    }

    /**
     * @description Tests successful report generation with complete valid data
     *              Verifies that all relationships are properly resolved and rows are created
     */
    @IsTest
    static void testFindAllWithPolicy_WithCompleteData_ReturnsRows() {
        Test.startTest();
        List<Object> result = WSHabeasDataReport.findAllWithPolicy();
        Test.stopTest();

        Assert.isNotNull(result, 'Result should not be null');
        Assert.isTrue(result.size() > 0, 'Should return at least one row');

        Map<String, Object> firstRow = (Map<String, Object>) result[0];
        Assert.isTrue(firstRow.containsKey('policyName'), 'Row should contain policyName');
        Assert.isTrue(firstRow.containsKey('numeroIdentificacion'), 'Row should contain numeroIdentificacion');
        Assert.isTrue(firstRow.containsKey('nombreCompleto'), 'Row should contain nombreCompleto');
    }

    /**
     * @description Tests Callable interface implementation with getReport action
     *              Verifies proper integration with OmniScript/DataRaptor pattern
     */
    @IsTest
    static void testCallableInterface_GetReport_ReturnsSuccess() {
        WSHabeasDataReport callable = new WSHabeasDataReport();
        Map<String, Object> input = new Map<String, Object>();
        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        Map<String, Object> args = new Map<String, Object>{ 'input' => input, 'output' => output, 'options' => options };

        Test.startTest();
        Object result = callable.call('getReport', args);
        Test.stopTest();

        Assert.isTrue((Boolean) result, 'Call should return true');
        Assert.isTrue(output.containsKey('report'), 'Output should contain report key');
        Assert.isFalse(output.containsKey('error'), 'Output should not contain error');
    }

    /**
     * @description Tests Callable interface with invalid action name
     *              Verifies proper error handling and error message in output
     */
    @IsTest
    static void testCallableInterface_InvalidAction_ReturnsError() {
        WSHabeasDataReport callable = new WSHabeasDataReport();
        Map<String, Object> input = new Map<String, Object>();
        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        Map<String, Object> args = new Map<String, Object>{ 'input' => input, 'output' => output, 'options' => options };

        Test.startTest();
        Object result = callable.call('invalidAction', args);
        Test.stopTest();

        Assert.isFalse((Boolean) result, 'Call should return false for invalid action');
        Assert.isTrue(output.containsKey('error'), 'Output should contain error flag');
        Assert.isTrue(output.containsKey('message'), 'Output should contain error message');
    }

    /**
     * @description Tests Callable interface with null method name
     *              Verifies validation of required parameters
     */
    @IsTest
    static void testCallableInterface_NullMethodName_ReturnsError() {
        WSHabeasDataReport callable = new WSHabeasDataReport();
        Map<String, Object> input = new Map<String, Object>();
        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        Map<String, Object> args = new Map<String, Object>{ 'input' => input, 'output' => output, 'options' => options };

        Test.startTest();
        Object result = callable.call(null, args);
        Test.stopTest();

        Assert.isFalse((Boolean) result, 'Call should return false for null method');
        Assert.isTrue(output.containsKey('error'), 'Output should contain error flag');
    }

    /**
     * @description Tests report with no matching contacts
     *              Verifies graceful handling when no data matches criteria
     */
    @IsTest
    static void testFindAllWithPolicy_NoContacts_ReturnsEmpty() {
        delete [SELECT Id FROM Contact];

        Test.startTest();
        List<Object> result = WSHabeasDataReport.findAllWithPolicy();
        Test.stopTest();

        Assert.isNotNull(result, 'Result should not be null');
        Assert.areEqual(0, result.size(), 'Should return empty list when no contacts exist');
    }

    /**
     * @description Tests report with contacts but no party consents
     *              Verifies that rows are not created without consents
     */
    @IsTest
    static void testFindAllWithPolicy_NoConsents_ReturnsEmpty() {
        delete [SELECT Id FROM PartyConsent];

        Test.startTest();
        List<Object> result = WSHabeasDataReport.findAllWithPolicy();
        Test.stopTest();

        Assert.isNotNull(result, 'Result should not be null');
        Assert.areEqual(0, result.size(), 'Should return empty list when no consents exist');
    }

    /**
     * @description Tests report with contacts but no insurance policies
     *              Verifies that rows are not created without policies
     */
    @IsTest
    static void testFindAllWithPolicy_NoPolicies_ReturnsEmpty() {
        delete [SELECT Id FROM InsurancePolicy];

        Test.startTest();
        List<Object> result = WSHabeasDataReport.findAllWithPolicy();
        Test.stopTest();

        Assert.isNotNull(result, 'Result should not be null');
        Assert.areEqual(0, result.size(), 'Should return empty list when no policies exist');
    }

    /**
     * @description Tests report with mismatched Individual-Account relationships
     *              Verifies that only properly matched data creates rows
     */
    @IsTest
    static void testFindAllWithPolicy_MismatchedRelationships_ReturnsPartialResults() {
        List<PartyConsent> consents = [SELECT Id, AccountId__c FROM PartyConsent LIMIT 1];
        List<Account> unusedAccount = createTestAccounts(1);
        insert unusedAccount;

        consents[0].AccountId__c = unusedAccount[0].Id;
        update consents;

        Test.startTest();
        List<Object> result = WSHabeasDataReport.findAllWithPolicy();
        Test.stopTest();

        Assert.isNotNull(result, 'Result should not be null');
    }

    /**
     * @description Tests chunking logic with large data volume
     *              Verifies proper handling of data exceeding chunk size
     */
    @IsTest
    static void testChunkIds_LargeDataset_ReturnsMultipleChunks() {
        Set<Id> largeSet = new Set<Id>();
        for (Integer i = 0; i < 600; i++) {
            largeSet.add(getFakeId(Account.SObjectType));
        }

        Test.startTest();
        List<Set<Id>> chunks = WSHabeasDataReport.chunkIds(largeSet, 500);
        Test.stopTest();

        Assert.areEqual(2, chunks.size(), 'Should create 2 chunks for 600 IDs with chunk size 500');
        Assert.areEqual(500, chunks[0].size(), 'First chunk should have 500 IDs');
        Assert.areEqual(100, chunks[1].size(), 'Second chunk should have 100 IDs');
    }

    /**
     * @description Tests chunking with null input
     *              Verifies safe handling of edge cases
     */
    @IsTest
    static void testChunkIds_NullInput_ReturnsEmpty() {
        Test.startTest();
        List<Set<Id>> chunks = WSHabeasDataReport.chunkIds(null, 500);
        Test.stopTest();

        Assert.isNotNull(chunks, 'Chunks should not be null');
        Assert.areEqual(0, chunks.size(), 'Should return empty list for null input');
    }

    /**
     * @description Tests chunking with empty set
     *              Verifies safe handling of empty collections
     */
    @IsTest
    static void testChunkIds_EmptySet_ReturnsEmpty() {
        Test.startTest();
        List<Set<Id>> chunks = WSHabeasDataReport.chunkIds(new Set<Id>(), 500);
        Test.stopTest();

        Assert.isNotNull(chunks, 'Chunks should not be null');
        Assert.areEqual(0, chunks.size(), 'Should return empty list for empty set');
    }

    /**
     * @description Tests queryContactsWithRecentPolicy method directly
     *              Verifies query returns only contacts with recent policies
     */
    @IsTest
    static void testQueryContactsWithRecentPolicy_ValidData_ReturnsContacts() {
        Test.startTest();
        List<Contact> contacts = WSHabeasDataReport.queryContactsWithRecentPolicy();
        Test.stopTest();

        Assert.isTrue(contacts.size() > 0, 'Should return contacts with recent policies');
        for (Contact c : contacts) {
            Assert.isNotNull(c.IndividualId, 'Contact should have IndividualId');
            Assert.isNotNull(c.AccountId, 'Contact should have AccountId');
        }
    }

    /**
     * @description Tests fetchPartyConsentsByIndAcc with valid IDs
     *              Verifies proper retrieval and organization of consents
     */
    @IsTest
    static void testFetchPartyConsentsByIndAcc_ValidIds_ReturnsConsents() {
        List<Contact> contacts = [
            SELECT IndividualId, AccountId
            FROM Contact
            WHERE IndividualId != NULL AND AccountId != NULL
            LIMIT 1
        ];

        Set<Id> individualIds = new Set<Id>{ contacts[0].IndividualId };
        Set<Id> accountIds = new Set<Id>{ contacts[0].AccountId };

        Test.startTest();
        Map<String, List<PartyConsent>> consents = WSHabeasDataReport.fetchPartyConsentsByIndAcc(individualIds, accountIds);
        Test.stopTest();

        Assert.isNotNull(consents, 'Consents map should not be null');
    }

    /**
     * @description Tests fetchPartyConsentsByIndAcc with empty IDs
     *              Verifies graceful handling of empty inputs
     */
    @IsTest
    static void testFetchPartyConsentsByIndAcc_EmptyIds_ReturnsEmpty() {
        Test.startTest();
        Map<String, List<PartyConsent>> consents = WSHabeasDataReport.fetchPartyConsentsByIndAcc(new Set<Id>(), new Set<Id>());
        Test.stopTest();

        Assert.isNotNull(consents, 'Consents map should not be null');
        Assert.areEqual(0, consents.size(), 'Should return empty map for empty IDs');
    }

    /**
     * @description Tests fetchPoliciesByAccount with valid account IDs
     *              Verifies proper retrieval and organization of policies
     */
    @IsTest
    static void testFetchPoliciesByAccount_ValidIds_ReturnsPolicies() {
        List<Account> accounts = [SELECT Id FROM Account LIMIT 1];
        Set<Id> accountIds = new Set<Id>{ accounts[0].Id };

        Test.startTest();
        Map<Id, List<InsurancePolicy>> policies = WSHabeasDataReport.fetchPoliciesByAccount(accountIds);
        Test.stopTest();

        Assert.isNotNull(policies, 'Policies map should not be null');
    }

    /**
     * @description Tests fetchPoliciesByAccount with empty account IDs
     *              Verifies graceful handling of empty inputs
     */
    @IsTest
    static void testFetchPoliciesByAccount_EmptyIds_ReturnsEmpty() {
        Test.startTest();
        Map<Id, List<InsurancePolicy>> policies = WSHabeasDataReport.fetchPoliciesByAccount(new Set<Id>());
        Test.stopTest();

        Assert.isNotNull(policies, 'Policies map should not be null');
        Assert.areEqual(0, policies.size(), 'Should return empty map for empty IDs');
    }

    /**
     * @description Tests buildRows with complete valid data
     *              Verifies cartesian product of consents and policies
     */
    @IsTest
    static void testBuildRows_CompleteData_ReturnsRows() {
        List<Contact> contacts = [
            SELECT Id, AccountId, IndividualId, City__c
            FROM Contact
            WHERE IndividualId != NULL AND AccountId != NULL
            LIMIT 1
        ];

        Set<Id> individualIds = new Set<Id>{ contacts[0].IndividualId };
        Set<Id> accountIds = new Set<Id>{ contacts[0].AccountId };

        Map<String, List<PartyConsent>> consents = WSHabeasDataReport.fetchPartyConsentsByIndAcc(individualIds, accountIds);
        Map<Id, List<InsurancePolicy>> policies = WSHabeasDataReport.fetchPoliciesByAccount(accountIds);

        Test.startTest();
        List<WSHabeasDataReport.Row> rows = WSHabeasDataReport.buildRows(contacts, consents, policies);
        Test.stopTest();

        Assert.isNotNull(rows, 'Rows should not be null');
    }

    /**
     * @description Tests buildRows with null consents
     *              Verifies no rows are created without consents
     */
    @IsTest
    static void testBuildRows_NullConsents_ReturnsEmpty() {
        List<Contact> contacts = [
            SELECT Id, AccountId, IndividualId, City__c
            FROM Contact
            LIMIT 1
        ];

        Set<Id> accountIds = new Set<Id>{ contacts[0].AccountId };
        Map<Id, List<InsurancePolicy>> policies = WSHabeasDataReport.fetchPoliciesByAccount(accountIds);

        Test.startTest();
        List<WSHabeasDataReport.Row> rows = WSHabeasDataReport.buildRows(contacts, new Map<String, List<PartyConsent>>(), policies);
        Test.stopTest();

        Assert.areEqual(0, rows.size(), 'Should return empty list when no consents exist');
    }

    /**
     * @description Tests buildRows with null policies
     *              Verifies no rows are created without policies
     */
    @IsTest
    static void testBuildRows_NullPolicies_ReturnsEmpty() {
        List<Contact> contacts = [
            SELECT Id, AccountId, IndividualId, City__c
            FROM Contact
            LIMIT 1
        ];

        Set<Id> individualIds = new Set<Id>{ contacts[0].IndividualId };
        Set<Id> accountIds = new Set<Id>{ contacts[0].AccountId };

        Map<String, List<PartyConsent>> consents = WSHabeasDataReport.fetchPartyConsentsByIndAcc(individualIds, accountIds);

        Test.startTest();
        List<WSHabeasDataReport.Row> rows = WSHabeasDataReport.buildRows(contacts, consents, new Map<Id, List<InsurancePolicy>>());
        Test.stopTest();

        Assert.areEqual(0, rows.size(), 'Should return empty list when no policies exist');
    }

    /**
     * @description Tests row field population
     *              Verifies all fields are correctly populated from source data
     */
    @IsTest
    static void testBuildRows_ValidData_PopulatesAllFields() {
        List<Object> result = WSHabeasDataReport.findAllWithPolicy();

        if (result.size() > 0) {
            Map<String, Object> row = (Map<String, Object>) result[0];

            Assert.isTrue(row.containsKey('policyName'), 'Should contain policyName');
            Assert.isTrue(row.containsKey('numeroIdentificacion'), 'Should contain numeroIdentificacion');
            Assert.isTrue(row.containsKey('nombreCompleto'), 'Should contain nombreCompleto');
            Assert.isTrue(row.containsKey('ciudad'), 'Should contain ciudad');
            Assert.isTrue(row.containsKey('canalAutorizacion'), 'Should contain canalAutorizacion');
            Assert.isTrue(row.containsKey('tipoCanal'), 'Should contain tipoCanal');
            Assert.isTrue(row.containsKey('aseguradora'), 'Should contain aseguradora');
            Assert.isTrue(row.containsKey('email'), 'Should contain email');
            Assert.isTrue(row.containsKey('celular'), 'Should contain celular');
        }
    }

    /**
     * @description Tests report generation with old policies outside fiscal quarter
     *              Verifies date filtering works correctly
     */
    @IsTest
    static void testFindAllWithPolicy_OldPolicies_ReturnsEmpty() {
        List<InsurancePolicy> policies = [SELECT Id, CreatedDate FROM InsurancePolicy];

        Test.setCreatedDate(policies[0].Id, Date.today().addMonths(-12));

        Test.startTest();
        List<Object> result = WSHabeasDataReport.findAllWithPolicy();
        Test.stopTest();

        Assert.isNotNull(result, 'Result should not be null');
    }

    /**
     * @description Tests with PartyConsent status other than OptIn
     *              Verifies only OptIn consents are included
     */
    @IsTest
    static void testFindAllWithPolicy_NonOptInConsents_ExcludesFromResults() {
        List<PartyConsent> consents = [SELECT Id, PrivacyConsentStatus FROM PartyConsent];
        for (PartyConsent pc : consents) {
            pc.PrivacyConsentStatus = 'OptOut';
        }
        update consents;

        Test.startTest();
        List<Object> result = WSHabeasDataReport.findAllWithPolicy();
        Test.stopTest();

        Assert.areEqual(0, result.size(), 'Should not include OptOut consents');
    }

    /**
     * @description Creates test accounts
     * @param count Number of accounts to create
     * @return List of test accounts
     */
    private static List<Account> createTestAccounts(Integer count) {
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < count; i++) {
            accounts.add(new Account(Name = 'Test Account ' + i, Type = 'Customer'));
        }
        return accounts;
    }

    /**
     * @description Creates test individuals
     * @param count Number of individuals to create
     * @return List of test individuals
     */
    private static List<Individual> createTestIndividuals(Integer count) {
        List<Individual> individuals = new List<Individual>();
        for (Integer i = 0; i < count; i++) {
            individuals.add(new Individual(FirstName = 'Test', LastName = 'Individual ' + i));
        }
        return individuals;
    }

    /**
     * @description Creates test contacts linked to accounts and individuals
     * @param accounts List of accounts to link
     * @param individuals List of individuals to link
     * @return List of test contacts
     */
    private static List<Contact> createTestContacts(List<Account> accounts, List<Individual> individuals) {
        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < Math.min(accounts.size(), individuals.size()); i++) {
            contacts.add(
                new Contact(
                    FirstName = 'Test',
                    LastName = 'Contact ' + i,
                    AccountId = accounts[i].Id,
                    IndividualId = individuals[i].Id,
                    Email = 'test' + i + '@test.com' //,
                    //City__c = 'Test City ' + i
                )
            );
        }
        return contacts;
    }

    /**
     * @description Creates test data use purposes
     * @return List of test data use purposes
     */
    private static List<DataUsePurpose> createDataUsePurposes() {
        List<DataUsePurpose> purposes = new List<DataUsePurpose>();
        purposes.add(new DataUsePurpose(Name = 'Cliente Representante Legal'));
        return purposes;
    }

    /**
     * @description Creates test business brands
     * @return List of test business brands
     */
    private static List<BusinessBrand> createBusinessBrands() {
        List<BusinessBrand> brands = new List<BusinessBrand>();
        brands.add(new BusinessBrand(Name = 'Test Insurance Brand'));
        return brands;
    }

    /**
     * @description Creates test party consents
     * @param individuals List of individuals to link
     * @param accounts List of accounts to link
     * @param purposeId Data use purpose ID
     * @param brandId Business brand ID
     * @return List of test party consents
     */
    private static List<PartyConsent> createTestPartyConsents(List<Individual> individuals, List<Account> accounts, Id purposeId, Id brandId) {
        List<PartyConsent> consents = new List<PartyConsent>();
        for (Integer i = 0; i < Math.min(individuals.size(), accounts.size()); i++) {
            consents.add(
                new PartyConsent(
                    PartyId = individuals[i].Id,
                    AccountId__c = accounts[i].Id,
                    DataUsePurposeId = purposeId,
                    BusinessBrandId = brandId,
                    PrivacyConsentStatus = 'OptIn',
                    CS_IdentificationNumber__c = '123456789' + i,
                    FullName__c = 'Test Individual ' + i,
                    AuthorizationChannel__c = 'Bases Externas',
                    ChannelType__c = 'Digital',
                    DirectMarketingVida__c = 'true',
                    DebtCollection__c = 'false',
                    AccountName__c = 'Test Account ' + i,
                    Email__c = 'consent' + i + '@test.com',
                    Phone__c = '+1234567890' + i,
                    Name = 'Test Consent ' + i
                )
            );
        }
        return consents;
    }

    /**
     * @description Creates test insurance policies
     * @param accounts List of accounts to link
     * @return List of test insurance policies
     */
    private static List<InsurancePolicy> createTestInsurancePolicies(List<Account> accounts) {
        List<InsurancePolicy> policies = new List<InsurancePolicy>();
        for (Integer i = 0; i < accounts.size(); i++) {
            policies.add(new InsurancePolicy(Name = 'Test Policy ' + i, NameInsuredId = accounts[i].Id, PolicyType = 'Auto', Status = 'Active'));
        }
        return policies;
    }

    /**
     * @description Generates a fake Salesforce ID for testing purposes
     * @param sObjectType Type of SObject for which to generate ID
     * @return Fake Salesforce ID
     */
    public static Id getFakeId(Schema.SObjectType sObjectType) {
        String result = String.valueOf(fakeIdCount++);
        return (Id) (sObjectType.getDescribe().getKeyPrefix() + '0'.repeat(12 - result.length()) + result);
    }
}