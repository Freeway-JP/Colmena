@IsTest(SeeAllData=false)
private class WSHabeasDataOriginDomainTest {
    private static WSHabeasDataExtendWrapper.HabeasDataDto mkCtrlDto() {
        WSHabeasDataExtendWrapper.HabeasDataDto d = new WSHabeasDataExtendWrapper.HabeasDataDto();
        d.firstName = 'Ana';
        d.secondName = 'Maria';
        d.lastName = 'Gomez';
        d.secondLastName = 'Lopez';
        d.identityType = '1';
        d.identityNumber = '1234567890';
        d.email = 'ana@example.com';
        d.numberPhone = '3001112233';
        d.sex = '1';
        d.authorizationChannel = 'Enlace Colmena';
        d.dataUsePurpose = 'Cliente';
        return d;
    }

    private static WSHabeasDataAPIDto.HabeasDataDto mkApiDto(Boolean with2300) {
        WSHabeasDataAPIDto.HabeasDataDto api = new WSHabeasDataAPIDto.HabeasDataDto();

        WSHabeasDataAPIDto.AccountDto a = new WSHabeasDataAPIDto.AccountDto();
        a.firstName = 'Ana';
        a.secondName = 'Maria';
        a.lastName = 'Gomez';
        a.secondLastName = 'Lopez';
        a.identityType = '1';
        a.identityNumber = '1234567890';
        a.email = 'ana@example.com';
        a.numberPhone = '3001112233';
        a.sex = '1';
        a.contactFirstName = 'Camilo';
        a.contactLastName = 'Perez';
        a.contactIdType = '1';
        a.contactIdNumber = '99887766';
        api.account = a;

        WSHabeasDataAPIDto.ConsentDto c = new WSHabeasDataAPIDto.ConsentDto();
        c.dataUsePurpose = 'Cliente';
        c.authorizationChannel = 'Enlace Colmena';

        WSHabeasDataAPIDto.IdentityValidated iv = new WSHabeasDataAPIDto.IdentityValidated();
        iv.identityValidationNoData = false;
        iv.identityValidationStatus = 'Exitoso';
        iv.identityValidationResult = 'OK';
        iv.identityValidationSource = 'Transunion';
        iv.identityValidationType = 'Token';
        c.identityValidated = iv;

        if (with2300) {
            WSHabeasDataAPIDto.Auth2300 auth2300 = new WSHabeasDataAPIDto.Auth2300();
            auth2300.value = true;
            auth2300.contactPointType = 'WhatsApp';
            auth2300.contactPoint = '3001112233';
            auth2300.dataUsePurpose = 'DATA_MARKETING';
            List<WSHabeasDataAPIDto.Auth2300> list2300 = new List<WSHabeasDataAPIDto.Auth2300>();
            list2300.add(auth2300);
            c.authorization2300 = list2300;
        }
        api.consent = c;
        return api;
    }

    @IsTest
    static void test_validateNullString() {
        System.assertEquals('', WSHabeasDataOriginDomain.validateNullString(null));
        System.assertEquals('', WSHabeasDataOriginDomain.validateNullString(''));
        System.assertEquals('X ', WSHabeasDataOriginDomain.validateNullString('X'));
    }

    @IsTest
    static void test_createAccount_person_and_get_by_cp_fields() {
        Test.startTest();
        WSHabeasDataExtendWrapper.HabeasDataDto req = mkCtrlDto();
        Account pa = WSHabeasDataOriginDomain.createAccount(req, 1); // Persona (PA)
        Test.stopTest();

        System.assertNotEquals(null, pa.Id);
        Account found = WSHabeasDataOriginDomain.getAccountByIdentifacacionNumberAndType(req.identityNumber, req.identityType);
        System.assertNotEquals(null, found);
        System.assertEquals(pa.Id, found.Id);
    }

    @IsTest
    static void test_createAccountRL_business_and_get_by_std_fields() {
        WSHabeasDataExtendWrapper.HabeasDataDto req = mkCtrlDto();

        Test.startTest();
        Account ba = WSHabeasDataOriginDomain.createAccountRL(req, 2);
        Test.stopTest();

        System.assertNotEquals(null, ba.Id);
        ba.CS_NumeroIdentificacion__c = req.identityNumber;
        ba.CS_TipoIdentificacion__c = req.identityType;
        update ba;

        Account found = WSHabeasDataOriginDomain.getAccountByIdentifacacionNumberAndType(req.identityNumber, req.identityType);
        System.assertNotEquals(null, found);
        System.assertEquals(ba.Id, found.Id);
    }

    @IsTest
    static void test_getAccountByIdent_blank_returns_null() {
        System.assertEquals(null, WSHabeasDataOriginDomain.getAccountByIdentifacacionNumberAndType('', '1'));
        System.assertEquals(null, WSHabeasDataOriginDomain.getAccountByIdentifacacionNumberAndType('123', ''));
    }

    @IsTest
    static void test_createLead_types_and_finders() {
        WSHabeasDataExtendWrapper.HabeasDataDto req1 = mkCtrlDto();
        Test.startTest();
        Lead l1 = WSHabeasDataOriginDomain.createLead(req1, 1);
        System.assertNotEquals(null, l1.Id);

        Lead found1 = WSHabeasDataOriginDomain.getLeadByIdentifacacionNumberAndType(req1.identityNumber, req1.identityType);
        System.assertNotEquals(null, found1);

        WSHabeasDataExtendWrapper.HabeasDataDto req2 = mkCtrlDto();
        Lead l3 = new Lead(
            FirstName = 'F',
            LastName = 'L',
            Company = 'C',
            Numero_de_documento__c = '1234567899',
            Tipo_de_documento__c = req2.contactIdType,
            contactIdNumber__c = req2.contactIdNumber,
            contactIdType__c = req2.contactIdType,
            MobilePhone = '3001112233'
        );
        insert l3;

        Lead foundEmp = WSHabeasDataOriginDomain.getLeadByIdentifacacionNumberAndTypeEmp(req2.identityNumber, req2.identityType);
    }

    @IsTest
    static void test_createContact_both_branches_and_finder() {
        WSHabeasDataExtendWrapper.HabeasDataDto reqAcc = mkCtrlDto();
        Account acc = WSHabeasDataOriginDomain.createAccountRL(reqAcc, 2);

        WSHabeasDataExtendWrapper.HabeasDataDto reqT = mkCtrlDto();
        reqT.contactFirstName = 'Camilo';
        reqT.contactLastName = 'Perez';
        reqT.contactIdType = '1';
        reqT.contactIdNumber = '777';

        Test.startTest();
        Contact c1 = WSHabeasDataOriginDomain.createContact(reqT, acc);

        System.assertNotEquals(null, c1.Id);
        System.assertEquals('777', c1.CS_NumeroIdentificacionCP__c);

        Contact f1 = WSHabeasDataOriginDomain.getContactByIdentifacacionNumberAndType('777', '1', acc.Id);
        System.assertNotEquals(null, f1);
        System.assertEquals(c1.Id, f1.Id);

        WSHabeasDataExtendWrapper.HabeasDataDto reqF = mkCtrlDto();
        reqF.contactFirstName = null;
        reqF.contactLastName = null;
        reqF.contactIdType = null;
        reqF.contactIdNumber = null;

        Contact c2 = WSHabeasDataOriginDomain.createContact(reqF, acc);
        Test.stopTest();
        System.assertEquals(reqF.identityNumber, c2.CS_NumeroIdentificacionCP__c);
    }

    @IsTest
    static void test_contact_finder_blank_returns_null() {
        System.assertEquals(null, WSHabeasDataOriginDomain.getContactByIdentifacacionNumberAndType(null, '1', '001xx0000001AAA'));
        System.assertEquals(null, WSHabeasDataOriginDomain.getContactByIdentifacacionNumberAndType('123', null, '001xx0000001AAA'));
        System.assertEquals(null, WSHabeasDataOriginDomain.getContactByIdentifacacionNumberAndType('123', '1', null));
    }

    @IsTest
    static void test_getAuthorizationChannelConfig_safe_call() {
        WSHabeasDataExtendWrapper.HabeasDataDto req = mkCtrlDto();
        WSHabeasDataOriginDomain.getAuthorizationChannelConfig(req);
        System.assert(true, 'Método ejecutado sin excepción');
    }

    @IsTest
    static void test_identity_existing_and_create_new_and_missing() {
        WSHabeasDataExtendWrapper.HabeasDataDto req = mkCtrlDto();

        Relacion_Tarea_Historial_Validacion__c rel = new Relacion_Tarea_Historial_Validacion__c(Name = 'Rel1');
        insert rel;

        Historial_de_Validacion__c hv = new Historial_de_Validacion__c(
            Relacion_Tarea_Historial_Validacion__c = rel.Id,
            Numero_de_identificacion__c = req.identityNumber,
            Tipo_de_identificacion__c = req.identityType
        );
        insert hv;

        Id ret1 = WSHabeasDataOriginDomain.validateIdentitySecurytyInfo(req);
        System.assertEquals(rel.Id, ret1);
        System.assertEquals(hv.Id, req.idIdentityValidation);

        WSHabeasDataExtendWrapper.HabeasDataDto reqMissing = mkCtrlDto();
        reqMissing.identityNumber = '55555';
        reqMissing.identityValidationStatus = null;
        reqMissing.identityValidationResult = null;
        reqMissing.identityValidationSource = null;
        reqMissing.identityValidationType = null;

        Id ret2 = WSHabeasDataOriginDomain.validateIdentitySecurytyInfo(reqMissing);
        System.assertEquals(null, ret2);

        reqMissing.identityValidationStatus = 'Exitoso';
        reqMissing.identityValidationResult = 'OK';
        reqMissing.identityValidationSource = 'Manual';
        reqMissing.identityValidationType = 'Token';

        Id ret3 = WSHabeasDataOriginDomain.validateIdentitySecurytyInfo(reqMissing);
        System.assertNotEquals(null, ret3);
        System.assertNotEquals(null, reqMissing.idIdentityValidation);
    }

    @IsTest
    static void test_transform_with_rules_in_memory_and_bizRules_method() {
        List<HD_API_Rules__mdt> rules = new List<HD_API_Rules__mdt>();
        HD_API_Rules__mdt r1 = new HD_API_Rules__mdt();
        r1.authorizationChannel__c = 'Enlace Colmena';
        r1.dataUsePurpose__c = 'Cliente';
        r1.BusinessBrand__c = 'ARL';
        r1.GeneralCommercialOffer__c = true;
        r1.GeneralProcessingData__c = true;
        r1.DataMarketing__c = true;
        r1.MedicalHistory__c = false;
        r1.Auth2300__c = true;
        rules.add(r1);

        HD_API_Rules__mdt r2 = new HD_API_Rules__mdt();
        r2.authorizationChannel__c = 'Enlace Colmena';
        r2.dataUsePurpose__c = 'Cliente';
        r2.BusinessBrand__c = 'Seguros Generales';
        r2.GeneralCommercialOffer__c = true;
        r2.GeneralProcessingData__c = true;
        r2.DataMarketing__c = true;
        r2.MedicalHistory__c = false;
        r2.Auth2300__c = false;
        rules.add(r2);

        WSHabeasDataAPIDto.HabeasDataDto api = mkApiDto(true);
        WSHabeasDataExtendWrapper.HabeasDataDto dto = WSHabeasDataOriginDomain.transformApiToControllerDto(api, rules);
        System.assertNotEquals(null, dto);
        System.assert(dto.companies != null && dto.companies.size() == 2, '2 compañías generadas');

        Boolean any2300 = false;
        for (WSHabeasDataExtendWrapper.CompanyDTO c : dto.companies) {
            if (c.authorization2300 != null && !c.authorization2300.isEmpty())
                any2300 = true;
        }
        System.assertEquals(true, any2300, 'Debe haber al menos una compañía con 2300');

        System.assertEquals(0, WSHabeasDataOriginDomain.getBuisnessMetadataRules(null, new List<String>{ 'ARL' }, 'X').size());
        System.assertEquals(0, WSHabeasDataOriginDomain.getBuisnessMetadataRules('Canal', null, 'X').size());
        System.assertEquals(0, WSHabeasDataOriginDomain.getBuisnessMetadataRules('Canal', new List<String>(), 'X').size());
        System.assertEquals(0, WSHabeasDataOriginDomain.getBuisnessMetadataRules('Canal', new List<String>{ 'ARL' }, null).size());

        List<HD_API_Rules__mdt> rows = WSHabeasDataOriginDomain.getBuisnessMetadataRules(
            'Enlace Colmena',
            new List<String>{ 'ARL', 'Seguros Generales' },
            'Cliente'
        );
        System.assertNotEquals(null, rows);
    }

    @IsTest
    static void test_transform_invalid_payload_returns_null() {
        List<HD_API_Rules__mdt> rules = new List<HD_API_Rules__mdt>();
        System.assertEquals(null, WSHabeasDataOriginDomain.transformApiToControllerDto(null, rules));
        System.assertEquals(null, WSHabeasDataOriginDomain.transformApiToControllerDto(new WSHabeasDataAPIDto.HabeasDataDto(), rules));
    }
}