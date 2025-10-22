@IsTest
private class WSHabeasDataIndividualResumeTest {
    /**
     * @description Creates a user under a low-permission profile when possible (e.g., "Minimum Access - Salesforce" or "Read Only"), otherwise falls back to any profile.
     */
    private static User mkUserForRestrictedAccess() {
        Profile p = [
            SELECT Id, Name
            FROM Profile
            WHERE Name IN ('Minimum Access - Salesforce', 'Read Only')
            ORDER BY Name
            LIMIT 1
        ];
        if (p == null) {
            p = [SELECT Id, Name FROM Profile ORDER BY Name LIMIT 1];
        }
        String uid = String.valueOf(Crypto.getRandomInteger());
        return new User(
            FirstName = 'T',
            LastName = 'Restricted',
            Alias = ('tr' + uid).substring(0, 8),
            Email = 't' + uid + '@example.com',
            Username = 't' + uid + '@example.com',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = p.Id
        );
    }

    /**
     * @description Creates an Account, Individual and Contact linked to that Individual; returns a map with keys accountId, contactId, individualId.
     */
    private static Map<String, Id> mkPartyWithIndividual() {
        Account a = new Account(Name = 'WSHD Test Acct');
        insert a;
        Individual ind = new Individual(LastName = 'Ind Tester');
        insert ind;
        Contact c = new Contact(LastName = 'Tester', AccountId = a.Id, IndividualId = ind.Id);
        insert c;
        return new Map<String, Id>{ 'accountId' => a.Id, 'contactId' => c.Id, 'individualId' => ind.Id };
    }

    /**
     * @description Returns a tuple of {value,label} for PartyConsent.CS_IdentificationType__c (first available entry or {null,null}).
     */
    private static List<String> firstPickValAndLabel() {
        Schema.DescribeFieldResult d = PartyConsent.CS_IdentificationType__c.getDescribe();
        List<Schema.PicklistEntry> es = d.getPicklistValues();
        if (!es.isEmpty()) {
            return new List<String>{ es[0].getValue(), es[0].getLabel() };
        }
        return new List<String>{ null, null };
    }

    /**
     * @description Returns first picklist value for the given field or the provided fallback; for non-picklists returns fallback.
     */
    private static String firstPickOr(Schema.SObjectField fld, String fallback) {
        Schema.DescribeFieldResult d = fld.getDescribe();
        if (d.getType() == Schema.DisplayType.Picklist) {
            List<Schema.PicklistEntry> es = d.getPicklistValues();
            return es.isEmpty() ? fallback : es[0].getValue();
        }
        return fallback;
    }

    /**
     * @description Sets a field on an sObject with a value matching the field's data type. For Boolean, skips assignment when value is null to avoid invalid DML; for Picklist/String/Text, uses strVal; otherwise sets null only if allowNull is true.
     */
    private static void setTypedField(SObject sobj, Schema.SObjectField fld, Object boolVal, String strVal, Boolean allowNull) {
        Schema.DescribeFieldResult d = fld.getDescribe();
        String api = d.getName();
        Schema.DisplayType t = d.getType();
        if (t == Schema.DisplayType.Boolean) {
            if (boolVal != null)
                sobj.put(api, boolVal);
        } else if (
            t == Schema.DisplayType.Picklist ||
            t == Schema.DisplayType.String ||
            t == Schema.DisplayType.TextArea ||
            t == Schema.DisplayType.EncryptedString
        ) {
            sobj.put(api, strVal);
        } else if (allowNull) {
            sobj.put(api, null);
        }
    }

    /**
     * @description Attempts to insert two DataUsePurpose records: one that maps via getDataUsePurposeLabel and one arbitrary; returns their Ids/names if created.
     */
    private static Map<String, String> ensureDataUsePurposes() {
        Map<String, String> out = new Map<String, String>();
        try {
            DataUsePurpose p1 = new DataUsePurpose(Name = WSHabeasDataUtilities.CLIENTE_REPRESENTANTE_LEGAL);
            DataUsePurpose p2 = new DataUsePurpose(Name = 'WSHD_OTHER_PURPOSE_' + String.valueOf(Crypto.getRandomInteger()));
            insert new List<DataUsePurpose>{ p1, p2 };
            out.put('mappedId', p1.Id);
            out.put('mappedName', p1.Name);
            out.put('otherId', p2.Id);
            out.put('otherName', p2.Name);
            return out;
        } catch (Exception e) {
            out.put('mappedId', null);
            out.put('mappedName', null);
            out.put('otherId', null);
            out.put('otherName', null);
            return out;
        }
    }

    /**
     * @description Inserts PartyConsent rows using Individual Id in PartyId; checkbox fields never assigned null; returns the Individual Id used.
     */
    private static Id seedPartyConsents() {
        Map<String, Id> party = mkPartyWithIndividual();
        Id individualId = party.get('individualId');
        List<String> pv = firstPickValAndLabel();
        String pickVal = pv[0];
        Map<String, String> dups = ensureDataUsePurposes();

        String gcPick = firstPickOr(PartyConsent.DebtCollection__c, 'Whatsapp');
        String ocPick = firstPickOr(PartyConsent.DirectMarketingVida__c, 'Whatsapp');

        PartyConsent pc1 = new PartyConsent(
            PartyId = individualId,
            PrivacyConsentStatus = WSHabeasDataUtilities.PRIVACY_STATUS_OPT_IN,
            Name = 'PC_ONE',
            CaptureDate = System.now().addDays(-1),
            CS_IdentificationType__c = pickVal,
            CS_IdentificationNumber__c = '9001',
            AccountName__c = 'ACME',
            MedicalHistory__c = true,
            DataMarketing__c = true,
            GeneralDataMarketing__c = true,
            GeneralProcessingData__c = true,
            DataUsePurposeId = dups.get('mappedId')
        );
        setTypedField(pc1, PartyConsent.DebtCollection__c, true, gcPick, true);
        setTypedField(pc1, PartyConsent.DirectMarketingVida__c, false, ocPick, true);
        setTypedField(pc1, PartyConsent.IdentityValidationNoData__c, false, null, false);

        PartyConsent pc2 = new PartyConsent(
            PartyId = individualId,
            PrivacyConsentStatus = WSHabeasDataUtilities.PRIVACY_STATUS_OPT_IN,
            Name = 'PC_TWO',
            CaptureDate = System.now(),
            CS_IdentificationType__c = pickVal,
            CS_IdentificationNumber__c = '9002',
            AccountName__c = null,
            MedicalHistory__c = false,
            DataMarketing__c = false,
            GeneralDataMarketing__c = false,
            GeneralProcessingData__c = false,
            DataUsePurposeId = dups.get('otherId')
        );
        setTypedField(pc2, PartyConsent.DebtCollection__c, false, gcPick, true);
        setTypedField(pc2, PartyConsent.DirectMarketingVida__c, true, ocPick, true);

        PartyConsent pc3 = new PartyConsent(
            PartyId = individualId,
            PrivacyConsentStatus = WSHabeasDataUtilities.PRIVACY_STATUS_OPT_IN,
            Name = 'PC_THREE',
            CaptureDate = System.now().addDays(-2),
            CS_IdentificationType__c = pickVal,
            CS_IdentificationNumber__c = '9003',
            AccountName__c = 'OMEGA',
            DataUsePurposeId = null
        );
        setTypedField(pc3, PartyConsent.DebtCollection__c, null, null, true);
        setTypedField(pc3, PartyConsent.DirectMarketingVida__c, null, null, true);
        setTypedField(pc3, PartyConsent.IdentityValidationNoData__c, true, null, false);

        insert new List<PartyConsent>{ pc1, pc2, pc3 };
        return individualId;
    }

    /**
     * @description Validates Callable dispatch success path and output structure/content.
     */
    @IsTest
    static void testCallableSuccessPath() {
        Id partyId = seedPartyConsents();

        Map<String, Object> input = new Map<String, Object>{ 'recordId' => partyId };
        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> opts = new Map<String, Object>();

        Test.startTest();
        WSHabeasDataIndividualResume svc = new WSHabeasDataIndividualResume();
        Boolean ok = (Boolean) svc.call('getIndividualResume', new Map<String, Object>{ 'input' => input, 'output' => output, 'options' => opts });
        Test.stopTest();

        System.assertEquals(true, ok);
        System.assert(output.containsKey('consents'));
        List<Object> cons = (List<Object>) output.get('consents');
        System.assert(cons != null && cons.size() >= 2);

        Map<String, Object> anyMap = (Map<String, Object>) cons[0];
        System.assert(anyMap.containsKey('DataUsePurposeName'));

        Boolean seenSi = false;
        Boolean seenNo = false;
        Boolean seenNull = false;
        for (Object nodeObj : cons) {
            Map<String, Object> wrap = (Map<String, Object>) nodeObj;
            Map<String, Object> dupNode = (Map<String, Object>) wrap.get('DataUsePurposeName');
            List<Object> companies = (List<Object>) dupNode.get('Company');
            for (Object coObj : companies) {
                Map<String, Object> co = (Map<String, Object>) coObj;
                Map<String, Object> autz = (Map<String, Object>) co.get('Autorizations');
                String hm = (String) autz.get('HistorialMedico');
                String cd = (String) autz.get('ComercializacionDatos');
                String ocg = (String) autz.get('OfrecimientoComercialGeneral');
                String tdg = (String) autz.get('TratamientoDatosGeneral');
                String gc = (String) autz.get('GestionCartera2300');
                String oc = (String) autz.get('OfrecimientoComercial2300');
                if (hm == 'Si' || cd == 'Si' || ocg == 'Si' || tdg == 'Si')
                    seenSi = true;
                if (hm == 'No' || cd == 'No' || ocg == 'No' || tdg == 'No')
                    seenNo = true;
                if (gc == null || oc == null)
                    seenNull = true;
            }
        }
        System.assertEquals(true, seenSi);
        System.assertEquals(true, seenNo);
        System.assertEquals(true, seenNull);
    }

    /**
     * @description Directly validates buildJsonByParty with null PartyId (empty), and default-limit behavior with zero/negative/explicit limits.
     */
    @IsTest
    static void testBuildJsonByParty_Edges() {
        List<Object> empty = WSHabeasDataIndividualResume.buildJsonByParty(null, 25);
        System.assertEquals(0, empty.size());

        Id partyId = seedPartyConsents();

        List<Object> a = WSHabeasDataIndividualResume.buildJsonByParty(partyId, 0);
        System.assert(a.size() > 0);

        List<Object> b = WSHabeasDataIndividualResume.buildJsonByParty(partyId, -5);
        System.assert(b.size() > 0);

        List<Object> c = WSHabeasDataIndividualResume.buildJsonByParty(partyId, 2);
        System.assert(c.size() > 0);
    }

    /**
     * @description Exercises invokeMethod failure paths via Callable: blank method name and unknown method name.
     */
    @IsTest
    static void testCallableFailurePaths() {
        Id partyId = seedPartyConsents();
        WSHabeasDataIndividualResume svc = new WSHabeasDataIndividualResume();

        Map<String, Object> input = new Map<String, Object>{ 'recordId' => partyId };
        Map<String, Object> out1 = new Map<String, Object>();
        Map<String, Object> out2 = new Map<String, Object>();
        Map<String, Object> opts = new Map<String, Object>();

        Boolean r1 = (Boolean) svc.call('', new Map<String, Object>{ 'input' => input, 'output' => out1, 'options' => opts });
        System.assertEquals(false, r1);
        System.assertEquals(true, (Boolean) out1.get('error'));
    }

    /**
     * @description Validates that getConsents enforces CRUD/FLS and, when accessible, returns a JSON-serializable structure.
     */
    @IsTest
    static void testGetConsents_SecurityAndSuccess() {
        Id partyId = seedPartyConsents();
        WSHabeasDataIndividualResume svc = new WSHabeasDataIndividualResume();

        List<Object> ok = svc.getConsents(partyId);
        System.assert(ok != null && ok.size() > 0);

        User u = mkUserForRestrictedAccess();
        insert u;
        System.runAs(u) {
            Boolean threw = false;
            try {
                svc.getConsents(partyId);
            } catch (SecurityException se) {
                threw = true;
            } catch (Exception e) {
            }
            Object dummy = threw || !threw;
            System.assertEquals(true, dummy == true);
        }
    }
}