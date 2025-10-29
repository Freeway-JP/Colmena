/**
 * WSHabeasDataHistory
 * -------------------
 * Provides consent history for a given Party (Contact/Lead/Person Account) by
 * aggregating records from PartyConsent and ContactPointConsent into a DTO that
 * is easy to consume by LWC, Aura, or REST callers. Implements the Callable
 * interface to expose a small command surface (`getConsents`, `getConsentsPaged`).
 *
 * @author  Carlos Vivas
 * @since   2025-09-15
 * @group   Habeas Data
 * @see     PartyConsent, ContactPointConsent, Security.stripInaccessible
 */
public with sharing class WSHabeasDataHistory implements Callable {
    // ======================================================================
    // Constants
    // ======================================================================

    /** Maximum number of records to return per query to avoid excessive payloads. */
    private static final Integer MAX_QUERY_RECORDS = 200;

    /** Input/Output map key for the Party (Contact/Lead) Id. */
    private static final String KEY_PARTY_ID = 'recordId';

    /** Output map key for the consent list returned by getConsents. */
    private static final String KEY_CONSENTS = 'consents';

    /** Cached Authorization Channel configuration from Custom Metadata. */
    List<Autorization_Channels__mdt> mcs = new List<Autorization_Channels__mdt>();

    /**
     * Creates the service and preloads Authorization Channel configuration.
     */
    public WSHabeasDataHistory() {
        getAuthorizationChannelConfig();
    }

    /**
     * Callable entry point.
     *
     * @param action  The logical operation to execute (e.g., "getConsents").
     * @param args    A wrapper map that must contain "input", "output", "options".
     * @return        Whatever the invoked method returns (usually Boolean).
     * @throws AuraHandledException if the action is unknown or invalid.
     */
    public Object call(String action, Map<String, Object> args) {
        Map<String, Object> input = (Map<String, Object>) args.get('input');
        Map<String, Object> output = (Map<String, Object>) args.get('output');
        Map<String, Object> options = (Map<String, Object>) args.get('options');
        return invokeMethod(action, input, output, options);
    }

    /**
     * Dispatches the requested action to a concrete method.
     *
     * @param methodName  Logical name of the operation (case-insensitive).
     * @param inMap       Input map; must contain "recordId" for getConsents.
     * @param outMap      Output map; results will be placed under known keys.
     * @param options     Optional options map.
     * @return            true if the method completed successfully; false on handled error.
     * @throws AuraHandledException when methodName is blank or unknown.
     */
    private Boolean invokeMethod(String methodName, Map<String, Object> inMap, Map<String, Object> outMap, Map<String, Object> options) {
        try {
            if (String.isBlank(methodName)) {
                throw new AuraHandledException('methodName is required');
            }
            String m = methodName.toLowerCase();
            switch on m {
                when 'getconsents' {
                    Id partyId = (Id) inMap.get(KEY_PARTY_ID);
                    outMap.put(KEY_CONSENTS, getConsents(partyId));
                    return true;
                }
                when 'getconsentspaged' {
                    throw new AuraHandledException('Not implemented: getConsentsPaged');
                }
                when else {
                    throw new AuraHandledException('Unknown method: ' + methodName);
                }
            }
        } catch (Exception e) {
            System.debug(System.LoggingLevel.ERROR, e);
            outMap.put('error', true);
            outMap.put('message', e.getMessage());
            return false;
        }
    }

    /**
     * Returns the consent history for the given Party, grouped by
     * Authorization Channel + Business Brand + Capture Date.
     *
     * @param recordId  Can be an Individual Id (0PK) or Task Id (00T). If Task, resolves Individual via WhatId.
     * @return         A JSON-serializable List&lt;Object&gt; of {@link ConsentGroup} DTOs.
     * @throws SecurityException if the running user lacks read access to consent objects.
     */
    public List<Object> getConsents(Id recordId) {
        // --- CRUD/FLS guard (read)
        if (!Schema.sObjectType.PartyConsent.isAccessible() || !Schema.sObjectType.ContactPointConsent.isAccessible()) {
            System.debug(System.LoggingLevel.ERROR, 'You do not have permission to read consents.');
            throw new SecurityException('You do not have permission to read consents.');
        }

        // Resolve the actual Individual Id (partyId) from recordId
        Id partyId = resolveIndividualId(recordId);

        // Query PartyConsent and sanitize fields
        List<PartyConsent> pcRaw = getPartyConsetByPartyId(partyId);
        SObjectAccessDecision pcDec = Security.stripInaccessible(AccessType.READABLE, pcRaw);
        List<PartyConsent> partyConsentList = (List<PartyConsent>) pcDec.getRecords();

        // Query ContactPointConsent and sanitize fields
        List<ContactPointConsent> cpcRaw = getContactPointConsentByPartyId(partyId);
        SObjectAccessDecision cpcDec = Security.stripInaccessible(AccessType.READABLE, cpcRaw);
        List<ContactPointConsent> contactPointList = (List<ContactPointConsent>) cpcDec.getRecords();

        // Group by Channel|Brand|CaptureDate using PartyConsent as the skeleton
        Map<String, ConsentGroup> groups = new Map<String, ConsentGroup>();
        for (PartyConsent pc : partyConsentList) {
            String key = buildKey(pc.AuthorizationChannel__c, pc.BusinessBrand.Name, pc.CaptureDate);
            groups.put(key, createConsentGroup(pc));
        }

        // Merge purpose-specific channels from ContactPointConsent into each group
        for (ContactPointConsent cpc : contactPointList) {
            String key = buildKey(cpc.AuthorizationChannel__c, cpc.BusinessBrand.Name, cpc.CaptureDate);
            ConsentGroup g = groups.get(key);
            if (g == null)
                continue;

            String channel = (cpc.EngagementChannelType != null) ? cpc.EngagementChannelType.Name : null;
            if (cpc.DataUsePurpose != null) {
                if (WSHabeasDataUtilities.DEBT_COLLECT.equals(cpc.DataUsePurpose.Name)) {
                    addChannel(g.gestionCarteraChannels, channel + validateStatusContactPointConsent(cpc.Approved__c));
                } else if (WSHabeasDataUtilities.DATA_MARKETING.equals(cpc.DataUsePurpose.Name)) {
                    addChannel(g.ofrecimientoComercialChannels, channel + validateStatusContactPointConsent(cpc.Approved__c));
                }
            }
        }

        // Materialize accumulated channel strings
        List<ConsentGroup> consentList = new List<ConsentGroup>();
        for (ConsentGroup g : groups.values()) {
            g.GestionCartera2300 = joinNonBlank(g.gestionCarteraChannels, ' / ');
            g.OfrecimientoComercial2300 = joinNonBlank(g.ofrecimientoComercialChannels, ' / ');
            consentList.add(g);
        }

        // Return as untyped for straightforward JSON serialization
        List<Object> serializable = (List<Object>) JSON.deserializeUntyped(System.JSON.serialize(consentList));
        return serializable;
    }

    /**
     * Queries PartyConsent records for the given Party.
     *
     * @param partyId  Party Id (Contact/Lead/Person Account).
     * @return         List of PartyConsent (can be empty; never null unless partyId is null).
     */
    private static List<PartyConsent> getPartyConsetByPartyId(Id partyId) {
        if (partyId == null)
            return null;
        List<PartyConsent> partyConsentList = [
            SELECT
                Id,
                AuthorizationChannel__c,
                BusinessBrand.Name,
                CaptureDate,
                Party.Name,
                DataUsePurpose.Name,
                GeneralDataMarketing__c,
                GeneralProcessingData__c,
                MedicalHistory__c,
                Email__c,
                Phone__c,
                DataMarketing__c,
                HistoryValidation__r.Estado__c,
                HistoryValidation__r.Tipo__c,
                HistoryValidation__r.Source__c,
                HistoryValidation__r.Mensaje__c,
                LastModifiedBy.Name
            FROM PartyConsent
            WHERE PartyId = :partyId
            ORDER BY CaptureDate DESC
            LIMIT :MAX_QUERY_RECORDS
        ];
        return partyConsentList;
    }

    /**
     * Queries ContactPointConsent records for the given Party.
     *
     * @param partyId  Party Id (Contact/Lead/Person Account).
     * @return         List of ContactPointConsent (can be empty; never null unless partyId is null).
     */
    private static List<ContactPointConsent> getContactPointConsentByPartyId(Id partyId) {
        if (partyId == null)
            return null;
        List<ContactPointConsent> contactPointList = [
            SELECT
                Id,
                BusinessBrand.Name,
                AuthorizationChannel__c,
                CaptureDate,
                EngagementChannelType.Name,
                DataUsePurpose.Name,
                PrivacyConsentStatus,
                Approved__c
            FROM ContactPointConsent
            WHERE PartyId = :partyId
            ORDER BY LastModifiedDate DESC
            LIMIT :MAX_QUERY_RECORDS
        ];
        return contactPointList;
    }

    // ======================================================================
    // Helpers
    // ======================================================================

    /**
     * Resolves the Individual Id from the given recordId.
     * Supports two scenarios:
     * 1. Direct Individual Id (0PK prefix) - returns as-is
     * 2. Task Id (00T prefix) - queries Task.WhatId -> Account.PersonIndividualId
     *
     * @param recordId  The input Id (Individual or Task).
     * @return          The resolved Individual Id to use for consent queries.
     * @throws AuraHandledException if the Id is a Task but cannot resolve Individual.
     */
    private Id resolveIndividualId(Id recordId) {
        if (recordId == null) {
            return null;
        }

        // Check if it's an Individual (0PK prefix)
        String objectType = recordId.getSObjectType().getDescribe().getName();
        if (objectType == 'Individual') {
            return recordId;
        }

        // Check if it's a Task (00T prefix)
        if (objectType == 'Task') {
            // Query the Task to get WhatId
            List<Task> tasks = [
                SELECT WhatId
                FROM Task
                WHERE Id = :recordId
                LIMIT 1
            ];

            if (tasks.isEmpty()) {
                throw new AuraHandledException('Task not found with Id: ' + recordId);
            }

            Task t = tasks[0];
            if (t.WhatId == null) {
                throw new AuraHandledException('Task does not have a related WhatId');
            }

            // Validate that WhatId is an Account (001 prefix)
            String whatObjectType = t.WhatId.getSObjectType().getDescribe().getName();
            if (whatObjectType != 'Account') {
                throw new AuraHandledException('Task WhatId is not an Account. Found: ' + whatObjectType);
            }

            // Query the Account to get PersonIndividualId
            List<Account> accounts = [
                SELECT PersonIndividualId
                FROM Account
                WHERE Id = :t.WhatId
                LIMIT 1
            ];

            if (accounts.isEmpty() || accounts[0].PersonIndividualId == null) {
                throw new AuraHandledException('Account does not have a PersonIndividualId');
            }

            return accounts[0].PersonIndividualId;
        }

        // If it's neither Individual nor Task, return as-is (backwards compatibility)
        return recordId;
    }

    /**
     * Builds the grouping key: Channel|Brand|CaptureDate.
     *
     * @param channel      Authorization channel (customized field).
     * @param brand        Business brand name.
     * @param captureDate  Consent capture datetime.
     * @return             Concatenated key used to group consents.
     */
    private static String buildKey(String channel, String brand, Datetime captureDate) {
        return channel + '|' + brand + '|' + captureDate;
    }

    /**
     * Adds a non-blank channel into a Set, trimming whitespace.
     *
     * @param target   Target Set to mutate.
     * @param channel  Channel string to add (ignored if blank).
     */
    private static void addChannel(Set<String> target, String channel) {
        if (!String.isBlank(channel))
            target.add(channel.trim());
    }

    /**
     * Joins a Set of non-blank strings with a given separator.
     *
     * @param values  Source values (Set).
     * @param sep     Separator to use.
     * @return        Joined string or null if the input is null/empty.
     */
    private static String joinNonBlank(Set<String> values, String sep) {
        if (values == null || values.isEmpty())
            return null;
        List<String> tmp = new List<String>();
        for (String v : values)
            if (!String.isBlank(v))
                tmp.add(v);
        return tmp.isEmpty() ? null : String.join(tmp, sep);
    }

    /**
     * Creates a ConsentGroup DTO from a PartyConsent skeleton.
     *
     * @param pc  PartyConsent record.
     * @return    Initialized ConsentGroup with base fields populated.
     */
    private ConsentGroup createConsentGroup(PartyConsent pc) {
        ConsentGroup cg = new ConsentGroup();
        cg.Canal = pc.AuthorizationChannel__c;
        cg.Proceso = searchChannelConfig(pc.AuthorizationChannel__c);
        cg.Empresa = (pc.BusinessBrand != null) ? pc.BusinessBrand.Name : null;
        cg.Fecha = pc.CaptureDate.format('dd/MM/yyyy HH:mm');
        cg.Nombre = (pc.Party != null) ? pc.Party.Name : null;
        cg.Telefono = pc.Phone__c;
        cg.Correo = pc.Email__c;
        cg.Autorizacion = (pc.DataUsePurpose != null) ? getDataUsePurposeLabel(pc.DataUsePurpose.Name) : null;
        cg.TratamientoDatos = validateBooleanString(pc.GeneralProcessingData__c);
        cg.OfrecimientoComercial = validateBooleanString(pc.GeneralDataMarketing__c);
        cg.HistoriaClinica = validateBooleanString(pc.MedicalHistory__c);
        cg.ComercializacionDatos = validateBooleanString(pc.DataMarketing__c);
        cg.EstadoValidacionIdentidad = pc.HistoryValidation__r != null ? pc.HistoryValidation__r.Estado__c : null;
        cg.OrigenValidacionIdentidad = pc.HistoryValidation__r != null ? pc.HistoryValidation__r.Source__c : null;
        cg.TipoValidacionIdentidad = pc.HistoryValidation__r != null ? pc.HistoryValidation__r.Tipo__c : null;
        cg.ResultadoValidacionIdentidad = pc.HistoryValidation__r != null ? pc.HistoryValidation__r.Mensaje__c : null;
        cg.UltimaModificacion = pc.LastModifiedBy != null ? pc.LastModifiedBy.Name : null;
        return cg;
    }

    /**
     * Maps certain Data Use Purpose values to their "Persona Juridica" equivalents.
     *
     * @param dataUsePurpose  Original Data Use Purpose string.
     * @return                Mapped value or the original if no mapping applies.
     */
    private String getDataUsePurpose(String dataUsePurpose) {
        if (dataUsePurpose == null)
            return null;

        if (WSHabeasDataUtilities.CLIENTE_REPRESENTANTE_LEGAL.equals(dataUsePurpose)) {
            return WSHabeasDataUtilities.CLIENTE_PERSONA_JURIDICA;
        } else if (WSHabeasDataUtilities.PROSPECTO_REPRESENTANTE_LEGAL.equals(dataUsePurpose)) {
            return WSHabeasDataUtilities.PROSPECTO_PERSONA_JURIDICA;
        } else {
            return dataUsePurpose;
        }
    }

    /**
     * Returns an empty string when the input is null/empty, otherwise the value plus a trailing space.
     *
     * @param value  Input string.
     * @return       '' if null/empty; otherwise value + ' '.
     */
    private String validateNullString(String value) {
        if (String.isEmpty(value) || value == null) {
            return '';
        } else {
            return value + ' ';
        }
    }

    /**
     * Converts a ContactPointConsent PrivacyConsentStatus into a boolean marker string.
     * Opt-In → ': true'; otherwise ': false'.
     *
     * @param status  PrivacyConsentStatus from ContactPointConsent.
     * @return        ': true' if Opt-In; ': false' otherwise.
     */
    private String validateStatusContactPointConsent(Boolean status) {
        return status ? ': Si' : ': No';
    }

    /**
     * Loads Authorization Channel Custom Metadata into memory for quick lookups.
     */
    private void getAuthorizationChannelConfig() {
        mcs = Autorization_Channels__mdt.getAll().values();
    }

    /**
     * Resolves the business process label configured for a given channel.
     *
     * @param channel  ExternalName__c from custom metadata.
     * @return         Process name (process__c) or null if not found.
     */
    private String searchChannelConfig(String channel) {
        for (Autorization_Channels__mdt mc : mcs) {
            if (mc.ExternalName__c.equals(channel)) {
                return mc.process__c;
            }
        }
        return null;
    }

    private static String validateBooleanString(Boolean value) {
        if (value == null)
            return null;
        return value ? 'Si' : 'No';
    }

    // ======================================================================
    // DTO
    // ======================================================================

    /**
     * DTO that represents a consolidated view of consents for a given
     * Channel/Brand/CaptureDate tuple. It also accumulates per-purpose
     * engagement channels and materializes them as readable strings.
     */
    private class ConsentGroup {
        /** Authorization Channel (customized). */
        public String Canal { get; set; }

        /** Business process resolved from Authorization Channel config (custom metadata). */
        public String Proceso { get; set; }

        /** Business brand name. */
        public String Empresa { get; set; }

        /** Capture date, formatted as dd/MM/yyyy HH:mm. */
        public String Fecha { get; set; }

        /** Party name (Contact/Lead/Person Account). */
        public String Nombre { get; set; }

        /** Phone (from PartyConsent). */
        public String Telefono { get; set; }

        /** Email (from PartyConsent). */
        public String Correo { get; set; }

        /** Data use purpose (e.g., Marketing, Debt Collection). */
        public String Autorizacion { get; set; }

        /** General marketing offering consent (PartyConsent). */
        public String OfrecimientoComercial { get; set; }

        /** General data processing consent (PartyConsent). */
        public String TratamientoDatos { get; set; }

        /** Medical history processing consent (PartyConsent). */
        public String HistoriaClinica { get; set; }

        /** Data commercialization consent (PartyConsent). */
        public String ComercializacionDatos { get; set; }

        /** Aggregated channel list for debt collection purpose (readable string). */
        public String GestionCartera2300 { get; set; }

        /** Aggregated channel list for marketing purpose (readable string). */
        public String OfrecimientoComercial2300 { get; set; }

        /** Identity validation status (related task record). */
        public String EstadoValidacionIdentidad { get; set; }

        /** Identity validation origin/source (related task record). */
        public String OrigenValidacionIdentidad { get; set; }

        /** Identity validation type (related task record). */
        public String TipoValidacionIdentidad { get; set; }

        /** Identity validation result/message (related task record). */
        public String ResultadoValidacionIdentidad { get; set; }

        public String UltimaModificacion { get; set; }

        // Internal accumulators (not serialized)
        /** Internal set of engagement channels for debt collection. */
        transient private Set<String> gestionCarteraChannels = new Set<String>();

        /** Internal set of engagement channels for marketing. */
        transient private Set<String> ofrecimientoComercialChannels = new Set<String>();
    }

    private static String getDataUsePurposeLabel(String dataUsePurpose) {
        if (WSHabeasDataUtilities.CLIENTE_REPRESENTANTE_LEGAL.equals(dataUsePurpose)) {
            return WSHabeasDataUtilities.CLIENTE_PERSONA_JURIDICA;
        } else if (WSHabeasDataUtilities.PROSPECTO_REPRESENTANTE_LEGAL.equals(dataUsePurpose)) {
            return WSHabeasDataUtilities.PROSPECTO_PERSONA_JURIDICA;
        } else {
            return dataUsePurpose;
        }
    }
}