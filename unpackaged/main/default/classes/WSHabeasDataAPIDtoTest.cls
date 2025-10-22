@IsTest(seeAllData=false)
private class WSHabeasDataAPIDtoTest {
    private static WSHabeasDataAPIDto.AccountDto mkAccountDto() {
        WSHabeasDataAPIDto.AccountDto a = new WSHabeasDataAPIDto.AccountDto();
        a.firstName = 'Ana';
        a.secondName = 'Mar';
        a.lastName = 'Lopez';
        a.secondLastName = 'Vega';
        a.identityType = 'CC';
        a.identityNumber = '123456';
        a.email = 'ana@example.com';
        a.numberPhone = '3000000000';
        a.sex = 'F';
        a.contactFirstName = 'Laura';
        a.contactLastName = 'Gomez';
        a.contactIdType = 'CC';
        a.contactIdNumber = '998877';
        return a;
    }

    private static WSHabeasDataAPIDto.ConsentDto mkConsentDto(Boolean include2300) {
        WSHabeasDataAPIDto.ConsentDto c = new WSHabeasDataAPIDto.ConsentDto();
        c.authorizationChannel = 'APP_WEB';
        c.ipAddress = '203.0.113.10';
        c.dataUsePurpose = 'Prospecto';
        c.identityValidated = new WSHabeasDataAPIDto.IdentityValidated();
        c.identityValidated.identityValidationNoData = false;
        c.identityValidated.identityValidationStatus = 'OK';
        c.identityValidated.identityValidationResult = 'pass';
        c.identityValidated.identityValidationSource = 'MANUAL';
        c.identityValidated.identityValidationType = 'BASICA';
        if (include2300) {
            c.authorization2300 = new List<WSHabeasDataAPIDto.Auth2300>();
            for (Integer i = 0; i < 2; i++) {
                WSHabeasDataAPIDto.Auth2300 a = new WSHabeasDataAPIDto.Auth2300();
                a.value = true;
                a.contactPointType = 'EMAIL';
                a.contactPoint = 'user' + i + '@example.com';
                a.dataUsePurpose = 'Prospecto';
                c.authorization2300.add(a);
            }
        }
        return c;
    }

    @IsTest
    static void test_ConstructorsAndProperties() {
        WSHabeasDataAPIDto.AccountDto acc = mkAccountDto();
        System.assertEquals('Ana', acc.firstName);
        System.assertEquals('998877', acc.contactIdNumber);

        WSHabeasDataAPIDto.ConsentDto cons = mkConsentDto(true);
        System.assertEquals('APP_WEB', cons.authorizationChannel);
        System.assertEquals(false, cons.identityValidated.identityValidationNoData);
        System.assertEquals(2, cons.authorization2300.size());
        System.assertEquals('EMAIL', cons.authorization2300[0].contactPointType);

        WSHabeasDataAPIDto.HabeasDataDto root = new WSHabeasDataAPIDto.HabeasDataDto();
        root.account = acc;
        root.consent = cons;
        root.companies = new List<String>{ 'BrandA', 'BrandB' };
        System.assertEquals('BrandB', root.companies[1]);

        WSHabeasDataAPIDto.ResponseDto r = new WSHabeasDataAPIDto.ResponseDto();
        r.status = 'Success';
        r.error = false;
        r.responseCode = 200;
        r.message = 'ok';
        System.assertEquals(200, r.responseCode);
        System.assertEquals(false, r.error);

        WSHabeasDataAPIDto.MassiveDto m = new WSHabeasDataAPIDto.MassiveDto();
        m.massiveAuth = new List<WSHabeasDataAPIDto.HabeasDataDto>{ root };
        m.massiveAuthType = 'BATCH_TEST';
        System.assertEquals(1, m.massiveAuth.size());
        System.assertEquals('BATCH_TEST', m.massiveAuthType);
    }

    @IsTest
    static void test_SerializeDeserialize_Full() {
        WSHabeasDataAPIDto.HabeasDataDto root = new WSHabeasDataAPIDto.HabeasDataDto();
        root.account = mkAccountDto();
        root.consent = mkConsentDto(true);
        root.companies = new List<String>{ 'BrandA', 'BrandB' };

        String json = JSON.serialize(root);
        WSHabeasDataAPIDto.HabeasDataDto again = (WSHabeasDataAPIDto.HabeasDataDto) System.JSON.deserialize(json, WSHabeasDataAPIDto.HabeasDataDto.class);
        System.assertNotEquals(null, again);
        System.assertEquals('Ana', again.account.firstName);
        System.assertEquals('APP_WEB', again.consent.authorizationChannel);
        System.assertEquals(true, again.consent.authorization2300[0].value);
        System.assertEquals('BrandB', again.companies[1]);
    }

    @IsTest
    static void test_SerializeDeserialize_Minimal() {
        WSHabeasDataAPIDto.HabeasDataDto root = new WSHabeasDataAPIDto.HabeasDataDto();
        root.account = new WSHabeasDataAPIDto.AccountDto();
        root.consent = new WSHabeasDataAPIDto.ConsentDto();

        String json = JSON.serialize(root);
        WSHabeasDataAPIDto.HabeasDataDto again = (WSHabeasDataAPIDto.HabeasDataDto) System.JSON.deserialize(json, WSHabeasDataAPIDto.HabeasDataDto.class);
        System.assertNotEquals(null, again);
        System.assertEquals(null, again.companies);
        System.assertEquals(null, again.consent.identityValidated);
        System.assertEquals(null, again.account.firstName);
    }

    @IsTest
    static void test_MassiveResponseDto_Constructors() {
        WSHabeasDataAPIDto.MassiveResponseDto dflt = new WSHabeasDataAPIDto.MassiveResponseDto();
        System.assertEquals(null, dflt.jobId);
        dflt.jobId = null;
        dflt.responseCode = 202;
        dflt.message = 'accepted';
        System.assertEquals(202, dflt.responseCode);

        WSHabeasDataAPIDto.MassiveResponseDto param = new WSHabeasDataAPIDto.MassiveResponseDto(null, 201, 'queued');
        System.assertEquals(null, param.jobId);
        System.assertEquals(201, param.responseCode);
        System.assertEquals('queued', param.message);
    }
}