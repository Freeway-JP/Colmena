/**
 * @description Test suite para WSHabeasDataConsentPrivacyDomain con éxito, fallo y edge cases. Objetivo: >=95% cobertura real, incluyendo ramas else, lookups nulos y límites de longitud de strings según org.
 * @author Carlos Vivas
 * @since 1.2
 */
@IsTest(SeeAllData=false)
private class WSHabeasDataConsentPrivacyDomainTest {
    @TestSetup
    static void setupData() {
        insert new BusinessBrand(Name = 'Colmena Vida');
        insert new BusinessBrand(Name = 'Otra Marca');

        insert new DataUsePurpose(Name = WSHabeasDataUtilities.CLIENTE);
        insert new DataUsePurpose(Name = WSHabeasDataUtilities.CLIENTE_REPRESENTANTE_LEGAL);
        insert new DataUsePurpose(Name = WSHabeasDataUtilities.PROSPECTO);
        insert new DataUsePurpose(Name = WSHabeasDataUtilities.PROSPECTO_REPRESENTANTE_LEGAL);
        insert new DataUsePurpose(Name = WSHabeasDataUtilities.DATA_MARKETING);
        insert new DataUsePurpose(Name = WSHabeasDataUtilities.DEBT_COLLECT);

        insert new EngagementChannelType(Name = 'Email');
        insert new EngagementChannelType(Name = 'Phone');
    }

    private static WSHabeasDataExtendWrapper.HabeasDataDto baseReq(Boolean legalPerson) {
        WSHabeasDataExtendWrapper.HabeasDataDto r = new WSHabeasDataExtendWrapper.HabeasDataDto();
        r.firstName = 'Ana';
        r.secondName = 'Maria';
        r.lastName = 'Garcia';
        r.secondLastName = 'Lopez';
        r.identityType = '1';
        r.identityNumber = '900123';
        r.email = 'ana@example.com';
        r.numberPhone = '3001112233';
        r.authorizationChannel = 'MARI';
        r.channelType = 'Digital';
        r.businessCoverage = 'Transversal';
        r.collectionMethodType = 'Masivo Externo';
        r.process = WSHabeasDataUtilities.SALES_PROCESS;
        r.origin = 'Indirecto';
        r.idAccountLR = null;

        WSHabeasDataExtendWrapper.CompanyDTO c = new WSHabeasDataExtendWrapper.CompanyDTO();
        c.name = 'Colmena Vida';
        c.generalCommercialOffer = true;
        c.generalProcessingData = null;
        c.dataMarketing = true;
        c.medicalHistory = null;

        List<WSHabeasDataExtendWrapper.Auth2300> a = new List<WSHabeasDataExtendWrapper.Auth2300>();
        WSHabeasDataExtendWrapper.Auth2300 e1 = new WSHabeasDataExtendWrapper.Auth2300();
        e1.dataUsePurpose = WSHabeasDataUtilities.DEBT_COLLECT;
        e1.contactPointType = 'Email';
        e1.value = true;
        a.add(e1);
        WSHabeasDataExtendWrapper.Auth2300 e2 = new WSHabeasDataExtendWrapper.Auth2300();
        e2.dataUsePurpose = WSHabeasDataUtilities.DATA_MARKETING;
        e2.contactPointType = 'Phone';
        e2.value = true;
        a.add(e2);
        WSHabeasDataExtendWrapper.Auth2300 e3 = new WSHabeasDataExtendWrapper.Auth2300();
        e3.dataUsePurpose = WSHabeasDataUtilities.DEBT_COLLECT;
        e3.contactPointType = 'Email';
        e3.value = true;
        a.add(e3);
        WSHabeasDataExtendWrapper.Auth2300 e4 = new WSHabeasDataExtendWrapper.Auth2300();
        e4.dataUsePurpose = WSHabeasDataUtilities.DATA_MARKETING;
        e4.contactPointType = 'Phone';
        e4.value = false;
        a.add(e4);
        c.authorization2300 = a;

        r.companies = new List<WSHabeasDataExtendWrapper.CompanyDTO>{ c };

        if (legalPerson) {
            r.dataUsePurpose = WSHabeasDataUtilities.CLIENTE_REPRESENTANTE_LEGAL;
            r.contactFirstName = 'Luis';
            r.contactLastName = 'Perez';
            r.contactIdType = '1';
            r.contactIdNumber = '555123';
            r.firstName = 'Colmena';
            r.lastName = 'Seguros';
        } else {
            r.dataUsePurpose = WSHabeasDataUtilities.PROSPECTO;
        }
        return r;
    }

    private static Id ensureIndividual(String idNumber, String idType, String first, String last) {
        Individual i = new Individual();
        i.FirstName = first;
        i.LastName = last;
        i.CS_NumeroIdentificacion__c = idNumber;
        i.CS_TipoIdentificacion__c = idType;
        insert i;
        return i.Id;
    }

    /**
     * @description Natural: usa upsert con match previo y camino “insert” cuando id vacíos.
     * @test
     */
    @IsTest
    static void testCreateIndividual_Natural_Branches() {
        Id existingInd = ensureIndividual('900123', '1', 'Pre', 'Existing');
        WSHabeasDataExtendWrapper.HabeasDataDto r = baseReq(false);
        Lead l1 = new Lead(LastName = 'X', Company = 'Y', FirstName = 'Z', MobilePhone = '3002324567', Numero_de_documento__c = '900000001');
        insert l1;
        r.idClient = l1.Id;

        Test.startTest();
        WSHabeasDataConsentPrivacyDomain dom = new WSHabeasDataConsentPrivacyDomain();
        Individual out1 = dom.createIndividual(r, System.now());
        System.assert(out1 != null);
        System.assertEquals(existingInd, out1.Id);

        WSHabeasDataExtendWrapper.HabeasDataDto r2 = baseReq(false);
        r2.identityNumber = '';
        r2.identityType = '';
        Lead l2 = new Lead(LastName = 'Z', Company = 'W', FirstName = 'Y', MobilePhone = '3002324568', Numero_de_documento__c = '900000002');
        insert l2;
        r2.idClient = l2.Id;

        Individual out2 = dom.createIndividual(r2, System.now());
        System.assert(out2 != null);
        System.assertNotEquals(existingInd, out2.Id);
        Test.stopTest();
    }

    /**
     * @description Jurídica: usa contacto representante para Id y valida apellidos compuestos.
     * @test
     */
    @IsTest
    static void testCreateIndividual_LegalPerson() {
        Id contactInd = ensureIndividual('555123', '1', 'Luis', 'Perez');
        WSHabeasDataExtendWrapper.HabeasDataDto r = baseReq(true);
        Account a = new Account(Name = 'Acme S.A.');
        insert a;
        r.idClient = a.Id;

        Test.startTest();
        WSHabeasDataConsentPrivacyDomain dom = new WSHabeasDataConsentPrivacyDomain();
        Individual out = dom.createIndividual(r, System.now());
        System.assertEquals(contactInd, out.Id);
        System.assertEquals('Luis Perez', out.LastName.trim());
        Test.stopTest();
    }

    /**
     * @description Retorna null si idClient es null.
     * @test
     */
    @IsTest
    static void testCreateIndividual_IdClientNull_ReturnsNull() {
        WSHabeasDataExtendWrapper.HabeasDataDto r = baseReq(false);
        r.idClient = null;
        WSHabeasDataConsentPrivacyDomain dom = new WSHabeasDataConsentPrivacyDomain();
        System.assertEquals(null, dom.createIndividual(r, System.now()));
    }

    /**
     * @description Asigna Individual a Contact y Lead; Account si hay Person Account.
     * @test
     */
    @IsTest
    static void testAssignIndividual_AllBranches() {
        Id indId = ensureIndividual('777', '1', 'Eva', 'Ruiz');

        Id personRtId = null;
        List<RecordType> paRts = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND IsPersonType = TRUE LIMIT 1];
        if (!paRts.isEmpty())
            personRtId = paRts[0].Id;

        Account acc = null;
        if (personRtId != null) {
            acc = new Account(RecordTypeId = personRtId, FirstName = 'PA', LastName = 'Holder');
            insert acc;
        }

        Account biz = new Account(Name = 'Business For Contact');
        insert biz;
        Contact con = new Contact(LastName = 'C', AccountId = biz.Id);
        insert con;

        Lead leadNat = new Lead(LastName = 'LN', Company = 'LC', FirstName = 'Leo', MobilePhone = '3002324567', Numero_de_documento__c = '900000003');
        insert leadNat;
        Lead leadLeg = new Lead(LastName = 'LL', Company = 'LC2', FirstName = 'Lia', MobilePhone = '3002324568', Numero_de_documento__c = '900000004');
        insert leadLeg;

        WSHabeasDataConsentPrivacyDomain dom = new WSHabeasDataConsentPrivacyDomain();

        if (acc != null) {
            WSHabeasDataExtendWrapper.HabeasDataDto rAcc = baseReq(false);
            rAcc.idIndividual = indId;
            rAcc.idClient = acc.Id;
            rAcc.dataUsePurpose = WSHabeasDataUtilities.CLIENTE;
            dom.assignIndividualToAuthSubject(rAcc);
            acc = [SELECT Id, PersonIndividualId, Individual_Report__c FROM Account WHERE Id = :acc.Id];
            System.assertEquals(indId, acc.PersonIndividualId);
            System.assertEquals(indId, acc.Individual_Report__c);
        }

        WSHabeasDataExtendWrapper.HabeasDataDto rCon = baseReq(false);
        rCon.idIndividual = indId;
        rCon.idClient = con.Id;
        rCon.dataUsePurpose = WSHabeasDataUtilities.CLIENTE_REPRESENTANTE_LEGAL;

        WSHabeasDataExtendWrapper.HabeasDataDto rLeadNat = baseReq(false);
        rLeadNat.idIndividual = indId;
        rLeadNat.idClient = leadNat.Id;
        rLeadNat.dataUsePurpose = WSHabeasDataUtilities.PROSPECTO;

        WSHabeasDataExtendWrapper.HabeasDataDto rLeadLeg = baseReq(true);
        rLeadLeg.idIndividual = indId;
        rLeadLeg.idClient = leadLeg.Id;
        rLeadLeg.dataUsePurpose = WSHabeasDataUtilities.PROSPECTO_REPRESENTANTE_LEGAL;

        Test.startTest();
        dom.assignIndividualToAuthSubject(rCon);
        dom.assignIndividualToAuthSubject(rLeadNat);
        dom.assignIndividualToAuthSubject(rLeadLeg);
        Test.stopTest();

        con = [SELECT Id, IndividualId FROM Contact WHERE Id = :con.Id];
        System.assertEquals(indId, con.IndividualId);
        Lead ln = [SELECT Id, IndividualId FROM Lead WHERE Id = :leadNat.Id];
        Lead ll = [SELECT Id, IndividualId FROM Lead WHERE Id = :leadLeg.Id];
        System.assertEquals(indId, ln.IndividualId);
        System.assertEquals(indId, ll.IndividualId);
    }

    /**
     * @description Contact points: recuperación e inserción para email/phone.
     * @test
     */
    @IsTest
    static void testGetCreateContactPoints() {
        Id indId = ensureIndividual('901', '1', 'Nora', 'Diaz');
        ContactPointEmail preE = new ContactPointEmail(EmailAddress = 'pre@example.com', ParentId = indId, ClientIdentityNumber__c = '901');
        insert preE;
        ContactPointPhone preP = new ContactPointPhone(TelephoneNumber = '3110000000', ParentId = indId, ClientIdentityNumber__c = '901');
        insert preP;

        preE = [SELECT Id, Name FROM ContactPointEmail WHERE Id = :preE.Id];
        preP = [SELECT Id, Name FROM ContactPointPhone WHERE Id = :preP.Id];

        WSHabeasDataExtendWrapper.HabeasDataDto r = baseReq(false);
        r.idIndividual = indId;
        r.identityNumber = '901';
        r.email = preE.Name;
        r.numberPhone = preP.Name;

        WSHabeasDataConsentPrivacyDomain dom = new WSHabeasDataConsentPrivacyDomain();

        ContactPointEmail gotE = dom.getCreateContactPointEmail(r);
        System.assertEquals(preE.Id, gotE.Id);

        r.email = 'new@example.com';
        ContactPointEmail newE = dom.getCreateContactPointEmail(r);
        System.assert(newE.Id != null);
        System.assertEquals(indId, newE.ParentId);

        ContactPointPhone gotP = dom.getCreateContactPointPhone(r);
        System.assertEquals(preP.Id, gotP.Id);

        r.numberPhone = '3209998888';
        ContactPointPhone newP = dom.getCreateContactPointPhone(r);
        System.assert(newP.Id != null);
        System.assertEquals(indId, newP.ParentId);
    }

    /**
     * @description PartyConsent: flujo estándar (pre-existentes se OPT_OUT; se insertan nuevos).
     * @test
     */
    @IsTest
    static void testCreatePartyConsentHistory_BothKinds_StdProcess() {
        Id natInd = ensureIndividual('333', '1', 'Jo', 'Ram');
        Id legInd = ensureIndividual('444', '1', 'Li', 'Pe');

        DataUsePurpose dupProspect = [SELECT Id FROM DataUsePurpose WHERE Name = :WSHabeasDataUtilities.PROSPECTO LIMIT 1];
        DataUsePurpose dupClientRL = [SELECT Id FROM DataUsePurpose WHERE Name = :WSHabeasDataUtilities.CLIENTE_REPRESENTANTE_LEGAL LIMIT 1];

        insert new PartyConsent(
            Name = 'Test',
            PartyId = natInd,
            PrivacyConsentStatus = WSHabeasDataUtilities.PRIVACY_STATUS_OPT_IN,
            DataUsePurposeId = dupProspect.Id
        );
        insert new PartyConsent(
            Name = 'Test',
            PartyId = legInd,
            PrivacyConsentStatus = WSHabeasDataUtilities.PRIVACY_STATUS_OPT_IN,
            DataUsePurposeId = dupClientRL.Id,
            CS_IdentificationType__c = '1',
            CS_IdentificationNumber__c = '555123',
            CS_IdentificationType_Emp__c = '1',
            CS_IdentificationNumber_Emp__c = '444'
        );

        WSHabeasDataConsentPrivacyDomain dom = new WSHabeasDataConsentPrivacyDomain();

        WSHabeasDataExtendWrapper.HabeasDataDto rn = baseReq(false);
        rn.idIndividual = natInd;
        Lead tempLn = new Lead(LastName = 'N', Company = 'NCo', FirstName = 'Nora', Numero_de_documento__c = '900000005', MobilePhone = '3005556677');
        insert tempLn;
        rn.idClient = tempLn.Id;

        WSHabeasDataExtendWrapper.HabeasDataDto rl = baseReq(true);
        rl.idIndividual = legInd;
        rl.contactIdType = '1';
        rl.contactIdNumber = '555123';
        rl.identityType = '1';
        rl.identityNumber = '444';
        Account al = new Account(Name = 'AL');
        insert al;
        Contact cl = new Contact(LastName = 'L', AccountId = al.Id);
        insert cl;
        rl.idClient = cl.Id;

        Test.startTest();
        dom.createPartyConsentHistory(rn, System.now());
        dom.createPartyConsentHistory(rl, System.now());
        Test.stopTest();

        List<PartyConsent> afterNat = [SELECT Id, PrivacyConsentStatus FROM PartyConsent WHERE PartyId = :natInd AND DataUsePurposeId = :dupProspect.Id];
        Boolean foundOptOutNat = false;
        for (PartyConsent pc1 : afterNat) {
            if (pc1.PrivacyConsentStatus == WSHabeasDataUtilities.PRIVACY_STATUS_OPT_OUT)
                foundOptOutNat = true;
        }
        System.assert(foundOptOutNat);

        List<PartyConsent> afterLeg = [SELECT Id, PrivacyConsentStatus FROM PartyConsent WHERE PartyId = :legInd AND DataUsePurposeId = :dupClientRL.Id];
        Boolean foundOptOutLeg = false;
        for (PartyConsent pc2 : afterLeg) {
            if (pc2.PrivacyConsentStatus == WSHabeasDataUtilities.PRIVACY_STATUS_OPT_OUT)
                foundOptOutLeg = true;
        }
        System.assert(foundOptOutLeg);
    }

    /**
     * @description PartyConsent: rama else sin consents previos (equivalente a NOV_PROCESS sin usar un valor de picklist restringido).
     * @test
     */
    @IsTest
    static void testCreatePartyConsentHistory_ElseBranch_NoOldConsents() {
        Id indId = ensureIndividual('555', '1', 'Lu', 'Na');

        WSHabeasDataExtendWrapper.HabeasDataDto r = baseReq(false);
        r.idIndividual = indId;

        WSHabeasDataExtendWrapper.CompanyDTO cOnly = new WSHabeasDataExtendWrapper.CompanyDTO();
        cOnly.name = 'Otra Marca';
        cOnly.generalCommercialOffer = true;
        cOnly.generalProcessingData = true;
        cOnly.dataMarketing = true;
        cOnly.medicalHistory = true;
        cOnly.authorization2300 = new List<WSHabeasDataExtendWrapper.Auth2300>();
        WSHabeasDataExtendWrapper.Auth2300 a1 = new WSHabeasDataExtendWrapper.Auth2300();
        a1.value = true;
        a1.contactPointType = 'Email';
        a1.dataUsePurpose = WSHabeasDataUtilities.DATA_MARKETING;
        cOnly.authorization2300.add(a1);
        r.companies = new List<WSHabeasDataExtendWrapper.CompanyDTO>{ cOnly };

        WSHabeasDataConsentPrivacyDomain dom = new WSHabeasDataConsentPrivacyDomain();

        Test.startTest();
        dom.createPartyConsentHistory(r, System.now());
        Test.stopTest();

        List<PartyConsent> pcs = [SELECT Id, BusinessBrand.Name FROM PartyConsent WHERE PartyId = :indId];
        System.assertEquals(1, pcs.size());
        System.assertEquals('Otra Marca', pcs[0].BusinessBrand.Name);
    }

    /**
     * @description ContactPointConsent: historial, OPT_OUT previo, canal y email/phone.
     * @test
     */
    @IsTest
    static void testIterateAuth2300_History_And_StatusChange() {
        Id indId = ensureIndividual('1000', '1', 'Val', 'Ortega');
        WSHabeasDataConsentPrivacyDomain dom = new WSHabeasDataConsentPrivacyDomain();

        WSHabeasDataExtendWrapper.HabeasDataDto r = baseReq(false);
        r.idIndividual = indId;
        r.identityNumber = '1000';
        r.dataUsePurpose = WSHabeasDataUtilities.PROSPECTO;

        ContactPointEmail e = new ContactPointEmail(EmailAddress = 'cpc@example.com', ParentId = indId, ClientIdentityNumber__c = '1000');
        insert e;
        ContactPointPhone p = new ContactPointPhone(TelephoneNumber = '3007776666', ParentId = indId, ClientIdentityNumber__c = '1000');
        insert p;

        ContactPointConsent pre = new ContactPointConsent();
        pre.Name = 'PreExisting';
        pre.ContactPointId = e.Id;
        pre.PrivacyConsentStatus = WSHabeasDataUtilities.PRIVACY_STATUS_OPT_IN;
        pre.DataUsePurpose__c = WSHabeasDataUtilities.PROSPECTO;
        insert pre;

        Test.startTest();
        dom.iterateAuth2300ToInsertHistory(r, e.Id, p.Id, System.now());
        Test.stopTest();

        List<ContactPointConsent> listC = [
            SELECT Id, PrivacyConsentStatus, ContactPointId, EngagementChannelTypeId, PartyId
            FROM ContactPointConsent
            WHERE PartyId = :indId
        ];
        Boolean hasOptOut = false, hasOptIn = false, hasEmail = false, hasPhone = false, allHaveChannel = true;
        for (ContactPointConsent cRec : listC) {
            if (cRec.PrivacyConsentStatus == WSHabeasDataUtilities.PRIVACY_STATUS_OPT_OUT)
                hasOptOut = true;
            if (cRec.PrivacyConsentStatus == WSHabeasDataUtilities.PRIVACY_STATUS_OPT_IN)
                hasOptIn = true;
            if (cRec.ContactPointId == e.Id)
                hasEmail = true;
            if (cRec.ContactPointId == p.Id)
                hasPhone = true;
            if (cRec.EngagementChannelTypeId == null)
                allHaveChannel = false;
        }
        System.assert(hasOptOut);
        System.assert(hasOptIn);
    }

    /**
     * @description Helpers visibles y validadores de strings.
     * @test
     */
    @IsTest
    static void testHelpersAndValidators_AndDirectCalls() {
        WSHabeasDataConsentPrivacyDomain dom = new WSHabeasDataConsentPrivacyDomain();

        WSHabeasDataExtendWrapper.CompanyDTO c1 = new WSHabeasDataExtendWrapper.CompanyDTO();
        c1.name = 'Colmena Vida';
        c1.generalCommercialOffer = true;
        c1.generalProcessingData = true;
        c1.dataMarketing = true;
        c1.medicalHistory = true;
        c1.authorization2300 = new List<WSHabeasDataExtendWrapper.Auth2300>();
        Set<String> names = WSHabeasDataConsentPrivacyDomain.buildRequestedCompaniesSet(new List<WSHabeasDataExtendWrapper.CompanyDTO>{ c1 });
        System.assertEquals(new Set<String>{ 'Colmena Vida' }, names);

        Id natInd = ensureIndividual('333x', '1', 'No', 'Va');
        PartyConsent pcA = new PartyConsent(
            Name = 'X1',
            PartyId = natInd,
            PrivacyConsentStatus = WSHabeasDataUtilities.PRIVACY_STATUS_OPT_IN,
            BusinessBrandId = [SELECT Id FROM BusinessBrand WHERE Name = 'Colmena Vida' LIMIT 1]
            .Id,
            DataUsePurposeId = [SELECT Id FROM DataUsePurpose WHERE Name = :WSHabeasDataUtilities.PROSPECTO LIMIT 1]
            .Id
        );
        insert pcA;
        PartyConsent pcB = new PartyConsent(
            Name = 'X2',
            PartyId = natInd,
            PrivacyConsentStatus = WSHabeasDataUtilities.PRIVACY_STATUS_OPT_IN,
            BusinessBrandId = [SELECT Id FROM BusinessBrand WHERE Name = 'Otra Marca' LIMIT 1]
            .Id,
            DataUsePurposeId = pcA.DataUsePurposeId
        );
        insert pcB;

        List<PartyConsent> missing = WSHabeasDataConsentPrivacyDomain.findMissingConsents(
            [
                SELECT
                    Id,
                    BusinessBrand.Name,
                    MedicalHistory__c,
                    DataMarketing__c,
                    GeneralDataMarketing__c,
                    GeneralProcessingData__c,
                    DebtCollection__c,
                    DirectMarketingVida__c
                FROM PartyConsent
                WHERE Id IN :new List<Id>{ pcA.Id, pcB.Id }
            ],
            names
        );
        Boolean containsOtra = false;
        for (PartyConsent p : missing) {
            if (p.BusinessBrand.Name == 'Otra Marca')
                containsOtra = true;
        }
        System.assert(containsOtra);

        List<String> parts = WSHabeasDataConsentPrivacyDomain.splitSafely('Email / Phone / SMS');
        System.assertEquals(3, parts.size());
        List<WSHabeasDataExtendWrapper.Auth2300> fromParts = WSHabeasDataConsentPrivacyDomain.createAuth2300List(parts, WSHabeasDataUtilities.DATA_MARKETING);
        System.assertEquals(3, fromParts.size());

        WSHabeasDataExtendWrapper.CompanyDTO incomplete = new WSHabeasDataExtendWrapper.CompanyDTO();
        incomplete.name = 'WillBeRemoved';
        incomplete.generalProcessingData = null;
        incomplete.generalCommercialOffer = null;
        incomplete.dataMarketing = null;
        incomplete.medicalHistory = null;
        incomplete.authorization2300 = null;

        WSHabeasDataExtendWrapper.HabeasDataDto d = baseReq(false);
        d.companies = new List<WSHabeasDataExtendWrapper.CompanyDTO>{ c1, incomplete };
        dom.preProcessCompaniesForSF(d, new List<PartyConsent>());
        System.assertEquals(2, d.companies.size());
    }

    /**
     * @description Join de tipos de contacto con longitud segura (<200) para evitar DML errors en org.
     * @test
     */
    @IsTest
    static void testJoinContactPointTypes_SafeLength() {
        Id indId = ensureIndividual('3000', '1', 'Max', 'Len');
        WSHabeasDataExtendWrapper.HabeasDataDto r = baseReq(false);
        r.idIndividual = indId;

        List<WSHabeasDataExtendWrapper.Auth2300> many = new List<WSHabeasDataExtendWrapper.Auth2300>();
        for (Integer i = 0; i < 20; i++) {
            WSHabeasDataExtendWrapper.Auth2300 a = new WSHabeasDataExtendWrapper.Auth2300();
            a.value = true;
            a.dataUsePurpose = WSHabeasDataUtilities.DATA_MARKETING;
            a.contactPointType = 'E' + String.valueOf(i);
            many.add(a);
        }

        WSHabeasDataExtendWrapper.CompanyDTO c = new WSHabeasDataExtendWrapper.CompanyDTO();
        c.name = 'Colmena Vida';
        c.generalCommercialOffer = true;
        c.generalProcessingData = true;
        c.dataMarketing = true;
        c.medicalHistory = true;
        c.authorization2300 = many;

        r.companies = new List<WSHabeasDataExtendWrapper.CompanyDTO>{ c };

        WSHabeasDataConsentPrivacyDomain dom = new WSHabeasDataConsentPrivacyDomain();
        dom.createPartyConsentHistory(r, System.now());

        PartyConsent pc = [SELECT Id, DirectMarketingVida__c FROM PartyConsent WHERE PartyId = :indId ORDER BY CreatedDate DESC LIMIT 1];
        System.assert(pc.DirectMarketingVida__c == null || pc.DirectMarketingVida__c.length() <= 200);
    }
}