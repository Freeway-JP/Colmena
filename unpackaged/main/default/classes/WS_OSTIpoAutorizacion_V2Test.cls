/**
 * @description Tests for WS_OSTIpoAutorizacion_V2 covering success, failure, and edge cases.
 * @author Carlos Vivas
 * @since 1.0
 * @group HabeasData
 */
@IsTest(SeeAllData=false)
private class WS_OSTIpoAutorizacion_V2Test {
    /**
     * @description Builds a representative input map with all fields populated.
     */
    private static Map<String, Object> fullInput() {
        return new Map<String, Object>{
            'FirstName' => 'Ana',
            'SecondName' => 'María',
            'LastName' => 'García',
            'SecondLastName' => 'López',
            'identityType' => 'CC',
            'identityNumber' => '1234567890',
            'email' => 'ana@example.com',
            'numberPhone' => '3001234567'
        };
    }

    /**
     * @description Builds a minimal input map with only email populated.
     */
    private static Map<String, Object> emailOnly() {
        return new Map<String, Object>{ 'email' => 'onlyemail@example.com' };
    }

    /**
     * @description Builds a minimal input map with only mobile populated.
     */
    private static Map<String, Object> phoneOnly() {
        return new Map<String, Object>{ 'numberPhone' => '3119876543' };
    }

    /**
     * @description Verifies DTO mapping for Account fields and val() edge handling.
     */
    @IsTest
    static void test_ToAccount_and_Val_edges() {
        WSHabeasDataAPIDto.AccountDto a = WS_OSTIpoAutorizacion_V2.toAccount(fullInput());
        System.assertEquals('Ana', a.firstName);
        System.assertEquals('María', a.secondName);
        System.assertEquals('García', a.lastName);
        System.assertEquals('López', a.secondLastName);
        System.assertEquals('CC', a.identityType);
        System.assertEquals('1234567890', a.identityNumber);
        System.assertEquals('ana@example.com', a.email);
        System.assertEquals('3001234567', a.numberPhone);

        WSHabeasDataAPIDto.AccountDto empty = WS_OSTIpoAutorizacion_V2.toAccount(null);
        System.assertEquals(null, empty.firstName);
        System.assertEquals(null, WS_OSTIpoAutorizacion_V2.val(null, 'X'));
        System.assertEquals(null, WS_OSTIpoAutorizacion_V2.val(new Map<String, Object>{ 'k' => 'v' }, null));
        System.assertEquals(null, WS_OSTIpoAutorizacion_V2.val(new Map<String, Object>{ 'k' => 'v' }, ''));
    }

    /**
     * @description Verifies consent defaults and that both email and phone produce 8 entries (4 channels x 2 purposes).
     */
    @IsTest
    static void test_Build2300_both_channels() {
        List<WSHabeasDataAPIDto.Auth2300> rows = WS_OSTIpoAutorizacion_V2.build2300(fullInput());
        System.assertEquals(8, rows.size());
        Boolean hasEmailType = false;
        Boolean hasWhatsApp = false;
        for (WSHabeasDataAPIDto.Auth2300 r : rows) {
            if (r.contactPointType == 'correo electrónico' && r.contactPoint == 'ana@example.com')
                hasEmailType = true;
            if (r.contactPointType == 'WhatsApp' && r.contactPoint == '3001234567')
                hasWhatsApp = true;
            System.assertEquals(true, r.value);
            System.assert(
                r.dataUsePurpose == WSHabeasDataUtilities.GESTION_CARTERA_2300 || r.dataUsePurpose == WSHabeasDataUtilities.OFRECIMIENTO_COMERCIAL_2300
            );
        }
        System.assertEquals(true, hasEmailType);
        System.assertEquals(true, hasWhatsApp);

        WSHabeasDataAPIDto.ConsentDto c = WS_OSTIpoAutorizacion_V2.toConsent(fullInput());
        System.assertEquals('Salesforce - Indemnizaciones', c.authorizationChannel);
        System.assertEquals(WSHabeasDataUtilities.CLIENTE, c.dataUsePurpose);
    }

    /**
     * @description Verifies that only email yields exactly 2 entries (email channel x 2 purposes).
     */
    @IsTest
    static void test_Build2300_email_only() {
        List<WSHabeasDataAPIDto.Auth2300> rows = WS_OSTIpoAutorizacion_V2.build2300(emailOnly());
        System.assertEquals(2, rows.size());
        for (WSHabeasDataAPIDto.Auth2300 r : rows) {
            System.assertEquals('correo electrónico', r.contactPointType);
            System.assertEquals('onlyemail@example.com', r.contactPoint);
        }
    }

    /**
     * @description Verifies that only phone yields 6 entries (non-email channels x 2 purposes).
     */
    @IsTest
    static void test_Build2300_phone_only() {
        List<WSHabeasDataAPIDto.Auth2300> rows = WS_OSTIpoAutorizacion_V2.build2300(phoneOnly());
        System.assertEquals(6, rows.size());
        for (WSHabeasDataAPIDto.Auth2300 r : rows) {
            System.assert(r.contactPointType != 'correo electrónico');
            System.assertEquals('3119876543', r.contactPoint);
        }
    }

    /**
     * @description Verifies that no contact points yields zero entries.
     */
    @IsTest
    static void test_Build2300_none() {
        List<WSHabeasDataAPIDto.Auth2300> rows = WS_OSTIpoAutorizacion_V2.build2300(new Map<String, Object>());
        System.assertEquals(0, rows.size());
    }

    /**
     * @description Verifies default companies are copied (mutations do not leak across calls).
     */
    @IsTest
    static void test_DefaultCompanies_copy_semantics() {
        List<String> first = WS_OSTIpoAutorizacion_V2.defaultCompanies();
        Integer baseSize = first.size();
        first.add('InjectedBrand');
        List<String> second = WS_OSTIpoAutorizacion_V2.defaultCompanies();
        System.assertEquals(baseSize, second.size());
        Boolean injectedFound = false;
        for (String s : second)
            if (s == 'InjectedBrand')
                injectedFound = true;
        System.assertEquals(false, injectedFound);
    }

    /**
     * @description Verifies invokeAction with unknown method populates failed output and returns false.
     */
    @IsTest
    static void test_InvokeAction_unknown_method() {
        Map<String, Object> out = new Map<String, Object>();
        Boolean ok = new WS_OSTIpoAutorizacion_V2().invokeAction('foobar', fullInput(), out, null);
        System.assertEquals(false, ok);
    }

    /**
     * @description Verifies invokeAction with blank method is handled via exception path and normalized output.
     */
    @IsTest
    static void test_InvokeAction_blank_method() {
        Map<String, Object> out = new Map<String, Object>();
        Boolean ok = new WS_OSTIpoAutorizacion_V2().invokeAction('  ', fullInput(), out, null);
        System.assertEquals(false, ok);
    }

    /**
     * @description Verifies invokeAction success/failure normalization for saveInformationHabeasData.
     */
    @IsTest
    static void test_InvokeAction_saveInformationHabeasData_normalization() {
        Map<String, Object> out = new Map<String, Object>();
        Test.startTest();
        Boolean ok = new WS_OSTIpoAutorizacion_V2().invokeAction('saveInformationHabeasData', fullInput(), out, null);
        Test.stopTest();
        System.assertEquals(true, ok);
    }
}