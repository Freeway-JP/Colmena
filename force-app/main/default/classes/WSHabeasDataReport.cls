/**
 * @description     Reporte Habeas Data: obtiene filas (Contact–Individual–Account) con PartyConsent (OptIn) y pólizas recientes.
 * @author          Carlos Vivas
 * @date            2025-10-16
 */
public with sharing class WSHabeasDataReport implements Callable {
    /** Output map key for the report list returned by getReport. */
    private static final String KEY = 'report';
    /** Chunk size for IN filters to respect governor limits. */
    private static final Integer CHUNK = 500;

    // ---------------- Callable ----------------
    /**
     * @description  Callable entry point.
     * @param action Logical op to execute (e.g., "getReport").
     * @param args   Wrapper map with keys: input, output, options.
     * @return       Any object returned by the invoked method.
     * @throws AuraHandledException if action is unknown/invalid.
     */
    public Object call(String action, Map<String, Object> args) {
        Map<String, Object> input = (Map<String, Object>) args.get('input');
        Map<String, Object> output = (Map<String, Object>) args.get('output');
        Map<String, Object> options = (Map<String, Object>) args.get('options');
        return invokeMethod(action, input, output, options);
    }

    /**
     * @description Dispatches logical methods by name.
     */
    private Boolean invokeMethod(String methodName, Map<String, Object> inMap, Map<String, Object> outMap, Map<String, Object> options) {
        try {
            if (String.isBlank(methodName)) {
                throw new AuraHandledException('methodName is required');
            }
            switch on methodName.toLowerCase() {
                when 'getreport' {
                    outMap.put(KEY, findAllWithPolicy());
                    return true;
                }
                when else {
                    throw new AuraHandledException('Unknown method: ' + methodName);
                }
            }
        } catch (Exception e) {
            System.debug(System.LoggingLevel.ERROR, e);
            if (outMap != null) {
                outMap.put('error', true);
                outMap.put('message', e.getMessage());
            }
            return false;
        }
    }

    // ---------------- Public API ----------------
    /**
     * @description Orquesta el flujo: contactos -> consents -> pólizas -> filas.
     * @return      List<Object> (via JSON roundtrip) para consumo genérico.
     */
    public static List<Object> findAllWithPolicy() {
        List<Contact> contacts = queryContactsWithRecentPolicy();
        if (contacts.isEmpty())
            return new List<Object>();

        Index idx = indexContacts(contacts);

        Map<String, List<PartyConsent>> pcsByIndAcc = fetchPartyConsentsByIndAcc(idx.individualIds, idx.accountIds);

        //System.debug(System.LoggingLevel.WARN, 'pcsByIndAcc ' + System.JSON.serializePretty(pcsByIndAcc));

        Map<Id, List<InsurancePolicy>> polsByAccount = fetchPoliciesByAccount(idx.accountIds);

        //System.debug(System.LoggingLevel.WARN, 'polsByAccount ' + System.JSON.serializePretty(polsByAccount));

        List<Row> rows = buildRows(contacts, pcsByIndAcc, polsByAccount);

        //System.debug(System.LoggingLevel.WARN, 'Rows ' + System.JSON.serializePretty(rows));

        return (List<Object>) JSON.deserializeUntyped(JSON.serialize(rows));
    }

    @TestVisible
    private static List<Contact> queryContactsWithRecentPolicy() {
        return [
            SELECT Id, AccountId, IndividualId, City__c, MailingCity
            FROM Contact
            WHERE
                IsPersonAccount = FALSE
                AND IndividualId != NULL
                AND AccountId != NULL
                AND AccountId IN (
                    SELECT NameInsuredId
                    FROM InsurancePolicy
                    WHERE CreatedDate = THIS_FISCAL_QUARTER OR CreatedDate = LAST_FISCAL_QUARTER
                )
        ];
    }

    @TestVisible
    private static Index indexContacts(List<Contact> contacts) {
        Index idx = new Index();
        for (Contact c : contacts) {
            if (c.AccountId != null) {
                idx.accountIds.add(c.AccountId);
                ensureList(idx.contactsByAccount, c.AccountId).add(c);
            }
            if (c.IndividualId != null) {
                idx.individualIds.add(c.IndividualId);
                ensureList(idx.contactsByIndividual, c.IndividualId).add(c);
            }
        }
        return idx;
    }

    @TestVisible
    private static Map<String, List<PartyConsent>> fetchPartyConsentsByIndAcc(Set<Id> individualIds, Set<Id> accountIds) {
        Map<String, List<PartyConsent>> out = new Map<String, List<PartyConsent>>();
        if (individualIds.isEmpty() || accountIds.isEmpty())
            return out;

        List<Set<Id>> indChunks = chunkIds(individualIds, CHUNK);
        List<Set<Id>> accChunks = chunkIds(accountIds, CHUNK);

        for (Set<Id> indChunk : indChunks) {
            for (Set<Id> accChunk : accChunks) {
                for (PartyConsent pc : [
                    SELECT
                        Id,
                        PartyId,
                        AccountId__c,
                        DataUsePurpose.Name,
                        CS_IdentificationNumber__c,
                        FullName__c,
                        AuthorizationChannel__c,
                        ChannelType__c,
                        DirectMarketingVida__c,
                        DebtCollection__c,
                        BusinessBrand.Name,
                        AccountName__c,
                        Email__c,
                        Phone__c
                    FROM PartyConsent
                    WHERE
                        PrivacyConsentStatus = 'OptIn'
                        AND DataUsePurpose.Name IN ('Cliente Representante Legal')
                        AND (CreatedDate = THIS_FISCAL_QUARTER
                        OR CreatedDate = LAST_FISCAL_QUARTER)
                        AND PartyId IN :indChunk
                        AND AccountId__c IN :accChunk
                ]) {
                    if (pc.AccountId__c == null)
                        continue;
                    ensureList(out, key(pc.PartyId, pc.AccountId__c)).add(pc);
                }
            }
        }
        return out;
    }

    @TestVisible
    private static Map<Id, List<InsurancePolicy>> fetchPoliciesByAccount(Set<Id> accountIds) {
        Map<Id, List<InsurancePolicy>> polsByAccount = new Map<Id, List<InsurancePolicy>>();
        if (accountIds.isEmpty())
            return polsByAccount;

        for (Set<Id> chunk : chunkIds(accountIds, CHUNK)) {
            for (InsurancePolicy p : [
                SELECT Id, Name, NameInsuredId
                FROM InsurancePolicy
                WHERE NameInsuredId IN :chunk AND (CreatedDate = THIS_FISCAL_QUARTER OR CreatedDate = LAST_FISCAL_QUARTER)
            ]) {
                ensureList(polsByAccount, p.NameInsuredId).add(p);
            }
        }
        return polsByAccount;
    }

    @TestVisible
    private static List<Row> buildRows(List<Contact> contacts, Map<String, List<PartyConsent>> pcsByIndAcc, Map<Id, List<InsurancePolicy>> polsByAccount) {
        List<Row> out = new List<Row>();
        for (Contact c : contacts) {
            String k = key(c.IndividualId, c.AccountId);
            List<PartyConsent> pcs = pcsByIndAcc.get(k);
            List<InsurancePolicy> pols = polsByAccount.get(c.AccountId);
            if (pcs == null || pcs.isEmpty() || pols == null || pols.isEmpty())
                continue;

            for (PartyConsent pc : pcs) {
                for (InsurancePolicy p : pols) {
                    Row r = new Row();
                    r.contactId = c.Id;
                    r.individualId = c.IndividualId;
                    r.accountId = c.AccountId;
                    r.partyConsentId = pc.Id;
                    r.dupName = (pc.DataUsePurpose != null ? pc.DataUsePurpose.Name : null);
                    r.policyId = p.Id;
                    r.policyName = p.Name;

                    r.numeroIdentificacion = pc.CS_IdentificationNumber__c;
                    r.nombreCompleto = pc.FullName__c;
                    r.ciudad = c.MailingCity;
                    r.canalAutorizacion = pc.AuthorizationChannel__c;
                    r.tipoCanal = pc.ChannelType__c;
                    r.ofrecimientoComercial2300 = String.valueOf(pc.DirectMarketingVida__c);
                    r.gestionCartera2300 = String.valueOf(pc.DebtCollection__c);
                    r.aseguradora = (pc.BusinessBrand != null ? pc.BusinessBrand.Name : null);
                    r.nombreCuenta = pc.AccountName__c;
                    r.email = pc.Email__c;
                    r.celular = pc.Phone__c;

                    out.add(r);
                }
            }
        }
        return out;
    }

    // ---------------- Helpers ----------------
    @TestVisible
    private static String key(Id individualId, Id accountId) {
        return String.valueOf(individualId) + '|' + String.valueOf(accountId);
    }

    @TestVisible
    private static List<Set<Id>> chunkIds(Set<Id> src, Integer chunkSize) {
        List<Set<Id>> buckets = new List<Set<Id>>();
        if (src == null || src.isEmpty())
            return buckets;
        Set<Id> cur = new Set<Id>();
        for (Id i : src) {
            cur.add(i);
            if (cur.size() == chunkSize) {
                buckets.add(cur);
                cur = new Set<Id>();
            }
        }
        if (!cur.isEmpty())
            buckets.add(cur);
        return buckets;
    }

    @TestVisible
    private static List<Contact> ensureList(Map<Id, List<Contact>> m, Id key) {
        List<Contact> lst = m.get(key);
        if (lst == null) {
            lst = new List<Contact>();
            m.put(key, lst);
        }
        return lst;
    }

    @TestVisible
    private static List<PartyConsent> ensureList(Map<String, List<PartyConsent>> m, String key) {
        List<PartyConsent> lst = m.get(key);
        if (lst == null) {
            lst = new List<PartyConsent>();
            m.put(key, lst);
        }
        return lst;
    }

    @TestVisible
    private static List<InsurancePolicy> ensureList(Map<Id, List<InsurancePolicy>> m, Id key) {
        List<InsurancePolicy> lst = m.get(key);
        if (lst == null) {
            lst = new List<InsurancePolicy>();
            m.put(key, lst);
        }
        return lst;
    }

    // ---------------- DTO ----------------
    public class Row {
        transient public Id contactId;
        transient public Id individualId;
        transient public Id accountId;
        transient public Id partyConsentId;
        transient public String dupName;
        transient public Id policyId;
        public String policyName;
        public String numeroIdentificacion;
        public String nombreCompleto;
        public String ciudad;
        public String canalAutorizacion;
        public String tipoCanal;
        public String ofrecimientoComercial2300;
        public String gestionCartera2300;
        public String aseguradora;
        public String nombreCuenta;
        public String email;
        public String celular;
    }

    private class Index {
        Set<Id> accountIds = new Set<Id>();
        Set<Id> individualIds = new Set<Id>();
        Map<Id, List<Contact>> contactsByAccount = new Map<Id, List<Contact>>();
        Map<Id, List<Contact>> contactsByIndividual = new Map<Id, List<Contact>>();
    }
}