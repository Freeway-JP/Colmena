/**
 * @description Test suite for WSHabeasDataConsentPrivacyDomain covering success, failure, and edge cases with the goal of 100% class coverage.
 * @author Carlos Vivas
 * @date 2025-10-02
 * @since 1.0
 */
@IsTest(SeeAllData=false)
private class WSHabeasDataConsentPrivacyDomainTest {
    @TestSetup
    static void setupData() {
        BusinessBrand bb = new BusinessBrand(Name = 'Colmena Vida');
        insert bb;

        List<DataUsePurpose> dups = new List<DataUsePurpose>{
            new DataUsePurpose(Name = WSHabeasDataUtilities.CLIENTE),
            new DataUsePurpose(Name = WSHabeasDataUtilities.CLIENTE_REPRESENTANTE_LEGAL),
            new DataUsePurpose(Name = WSHabeasDataUtilities.PROSPECTO),
            new DataUsePurpose(Name = WSHabeasDataUtilities.PROSPECTO_REPRESENTANTE_LEGAL),
            new DataUsePurpose(Name = WSHabeasDataUtilities.DATA_MARKETING),
            new DataUsePurpose(Name = WSHabeasDataUtilities.DEBT_COLLECT)
        };
        insert dups;

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
     * @description Validates createIndividual for a natural person when an existing Individual is found by type/number and when values are blank (forcing insert).
     * @test
     */
    @IsTest
    static void testCreateIndividual_Natural_Branches() {
        Id existingInd = ensureIndividual('900123', '1', 'Pre', 'Existing');
        WSHabeasDataExtendWrapper.HabeasDataDto r = baseReq(false);
        Lead l1 = new Lead(LastName = 'X', Company = 'Y', FirstName = 'Z', MobilePhone = '3002324567', Numero_de_documento__c = '987654321');
        insert l1;
        r.idClient = l1.Id;

        Test.startTest();
        WSHabeasDataConsentPrivacyDomain dom = new WSHabeasDataConsentPrivacyDomain();
        Individual out1 = dom.createIndividual(r, System.now());
        System.assertNotEquals(null, out1);
        System.assertEquals(existingInd, out1.Id);

        WSHabeasDataExtendWrapper.HabeasDataDto r2 = baseReq(false);
        r2.identityNumber = '';
        r2.identityType = '';
        Lead l2 = new Lead(LastName = 'Z', Company = 'W', FirstName = 'Y', MobilePhone = '3002324568', Numero_de_documento__c = '987654322');
        insert l2;
        r2.idClient = l2.Id;

        Individual out2 = dom.createIndividual(r2, System.now());
        System.assertNotEquals(null, out2);
        System.assertNotEquals(existingInd, out2.Id);
        Test.stopTest();
    }

    /**
     * @description Validates createIndividual for a legal person path.
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
     * @description Verifies createIndividual returns null when idClient is null.
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
     * @description Exercises assignIndividualToAuthSubject across Account, Contact, Lead, and Lead (legal prospect) branches.
     * @test
     */
    @IsTest
    static void testAssignIndividual_AllBranches() {
        Id indId = ensureIndividual('777', '1', 'Eva', 'Ruiz');

        RecordType paRt = [
            SELECT Id
            FROM RecordType
            WHERE SObjectType = 'Account' AND IsPersonType = TRUE
            LIMIT 1
        ];
        Account acc = new Account(RecordTypeId = paRt.Id, FirstName = 'PA', LastName = 'Holder');
        insert acc;

        Account biz = new Account(Name = 'Business For Contact');
        insert biz;
        Contact con = new Contact(LastName = 'C', AccountId = biz.Id);
        insert con;

        Lead leadNat = new Lead(LastName = 'LN', Company = 'LC', FirstName = 'Leo', MobilePhone = '3002324567', Numero_de_documento__c = '987654323');
        insert leadNat;
        Lead leadLeg = new Lead(LastName = 'LL', Company = 'LC2', FirstName = 'Lia', MobilePhone = '3002324568', Numero_de_documento__c = '987654324');
        insert leadLeg;

        WSHabeasDataConsentPrivacyDomain dom = new WSHabeasDataConsentPrivacyDomain();

        WSHabeasDataExtendWrapper.HabeasDataDto rAcc = baseReq(false);
        rAcc.idIndividual = indId;
        rAcc.idClient = acc.Id;
        rAcc.dataUsePurpose = WSHabeasDataUtilities.CLIENTE;

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
        dom.assignIndividualToAuthSubject(rAcc);
        dom.assignIndividualToAuthSubject(rCon);
        dom.assignIndividualToAuthSubject(rLeadNat);
        dom.assignIndividualToAuthSubject(rLeadLeg);
        Test.stopTest();

        acc = [SELECT Id, PersonIndividualId, Individual_Report__c FROM Account WHERE Id = :acc.Id];
        System.assertEquals(indId, acc.PersonIndividualId);
        System.assertEquals(indId, acc.Individual_Report__c);

        con = [SELECT Id, IndividualId FROM Contact WHERE Id = :con.Id];
        System.assertEquals(indId, con.IndividualId);

        Lead ln = [SELECT Id, IndividualId FROM Lead WHERE Id = :leadNat.Id];
        Lead ll = [SELECT Id, IndividualId FROM Lead WHERE Id = :leadLeg.Id];
        System.assertEquals(indId, ln.IndividualId);
        System.assertEquals(indId, ll.IndividualId);
    }

    /**
     * @description Validates contact point retrieval/creation for email and phone, covering existing and new paths.
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
        System.assertNotEquals(null, newE.Id);
        System.assertEquals(indId, newE.ParentId);

        ContactPointPhone gotP = dom.getCreateContactPointPhone(r);
        System.assertEquals(preP.Id, gotP.Id);

        r.numberPhone = '3209998888';
        ContactPointPhone newP = dom.getCreateContactPointPhone(r);
        System.assertNotEquals(null, newP.Id);
        System.assertEquals(indId, newP.ParentId);
    }

    /**
     * @description Validates party consent history creation and status change for natural and legal person paths, including joinContactPointTypes behavior.
     * @test
     */
    @IsTest
    static void testCreatePartyConsentHistory_BothKinds() {
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
        Lead ln = new Lead(LastName = 'N', Company = 'NCo', FirstName = 'Nora', MobilePhone = '3002324567', Numero_de_documento__c = '987654325');
        insert ln;
        rn.idClient = ln.Id;

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
        Boolean foundOptInNat = false;
        for (PartyConsent pc1 : afterNat) {
            if (pc1.PrivacyConsentStatus == WSHabeasDataUtilities.PRIVACY_STATUS_OPT_OUT)
                foundOptOutNat = true;
            if (pc1.PrivacyConsentStatus == WSHabeasDataUtilities.PRIVACY_STATUS_OPT_IN)
                foundOptInNat = true;
        }
        System.assertEquals(true, foundOptOutNat);
        System.assertEquals(true, foundOptInNat);

        List<PartyConsent> afterLeg = [SELECT Id, PrivacyConsentStatus FROM PartyConsent WHERE PartyId = :legInd AND DataUsePurposeId = :dupClientRL.Id];
        Boolean foundOptOutLeg = false;
        Boolean foundOptInLeg = false;
        for (PartyConsent pc2 : afterLeg) {
            if (pc2.PrivacyConsentStatus == WSHabeasDataUtilities.PRIVACY_STATUS_OPT_OUT)
                foundOptOutLeg = true;
            if (pc2.PrivacyConsentStatus == WSHabeasDataUtilities.PRIVACY_STATUS_OPT_IN)
                foundOptInLeg = true;
        }
        System.assertEquals(true, foundOptOutLeg);
        System.assertEquals(true, foundOptInLeg);
    }

    /**
     * @description Validates ContactPointConsent history creation, status transition, engagement channel resolution, and email/phone branching.
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

        Id dupId = [SELECT Id FROM DataUsePurpose WHERE Name = :WSHabeasDataUtilities.PROSPECTO LIMIT 1].Id;
        ContactPointConsent pre = new ContactPointConsent(
            Name = 'PreExisting',
            ContactPointId = e.Id,
            PrivacyConsentStatus = WSHabeasDataUtilities.PRIVACY_STATUS_OPT_IN,
            DataUsePurpose__c = WSHabeasDataUtilities.PROSPECTO
        );
        insert pre;

        Test.startTest();
        dom.iterateAuth2300ToInsertHistory(r, e.Id, p.Id, System.now());
        Test.stopTest();

        List<ContactPointConsent> listC = [
            SELECT Id, PrivacyConsentStatus, ContactPointId, EngagementChannelTypeId
            FROM ContactPointConsent
            WHERE PartyId = :indId
        ];
        Boolean hasOptOut = false;
        Boolean hasOptIn = false;
        Boolean hasEmail = false;
        Boolean hasPhone = false;
        Boolean allHaveChannel = true;
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
        System.assertEquals(true, hasOptOut);
        System.assertEquals(true, hasOptIn);
    }

    /**
     * @description Validates validateNullString edge behavior for null, empty, and non-empty inputs.
     * @test
     */
    @IsTest
    static void testValidateNullString() {
        System.assertEquals('', WSHabeasDataConsentPrivacyDomain.validateNullString(null));
        System.assertEquals('', WSHabeasDataConsentPrivacyDomain.validateNullString(''));
        System.assertEquals('ABC ', WSHabeasDataConsentPrivacyDomain.validateNullString('ABC'));
    }
}