public with sharing class WSHabeasDataIndividualResume implements Callable {
    // ======================================================================
    // Constants
    // ======================================================================

    /** Input/Output map key for the Party (Contact/Lead) Id. */
    private static final String KEY_PARTY_ID = 'recordId';

    /** Output map key for the consent list returned by getConsents. */
    private static final String KEY_CONSENTS = 'consents';

    /** Cached Authorization Channel configuration from Custom Metadata. */
    List<Autorization_Channels__mdt> mcs = new List<Autorization_Channels__mdt>();

    ///// =====================================================================
    // ---- Constants ---------------------------------------------------------
    private static final Integer DEFAULT_LIMIT = 200;

    private static final String K_DUP = 'DataUsePurposeName';
    private static final String K_NAME = 'Name';
    private static final String K_COMPANY = 'Company';
    private static final String K_AUTZ = 'Autorizations';
    private static final String K_PROCESO = 'Proceso';
    private static final String K_TIPO_CANAL = 'TipoCanal';
    private static final String K_CANAL_AUTZ = 'CanalAutorizacion';
    private static final String K_TASK_REL = 'RelacionTareaHistorialValidacion';
    private static final String K_TASK_REL_NAME = 'RelacionTareaHistorialValidacionName';
    private static final String K_ORIGEN = 'Origen';
    private static final String K_FECHA_CAP = 'FechaCaptura';
    private static final String K_COB_NEG = 'CoberturaNegocio';
    private static final String K_ID_NO_DATA = 'ValidacionIdentidadSinDatos';
    private static final String K_TIPO_CAP = 'TipoCaptura';
    private static final String K_TIPO_ID = 'TipoIdentificacion';
    private static final String K_NUM_ID = 'NumeroIdentificacion';
    private static final String K_NAME_PC = 'NamePartyConsent';
    private static final String K_HM = 'HistorialMedico';
    private static final String K_CD = 'ComercializacionDatos';
    private static final String K_OCG = 'OfrecimientoComercialGeneral';
    private static final String K_TDG = 'TratamientoDatosGeneral';
    private static final String K_GC = 'GestionCartera2300';
    private static final String K_OC = 'OfrecimientoComercial2300';
    private static final String K_NC = 'NombreCuenta';

    /**
     * Creates the service and preloads Authorization Channel configuration.
     */
    public WSHabeasDataIndividualResume() {
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
                when 'getindividualresume' {
                    Id partyId = (Id) inMap.get(KEY_PARTY_ID);
                    outMap.put(KEY_CONSENTS, getConsents(partyId));
                    return true;
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
     * @param partyId  Party id (Contact/Lead/Person Account) whose consents are requested.
     * @return         A JSON-serializable List&lt;Object&gt; of {@link ConsentGroup} DTOs.
     * @throws SecurityException if the running user lacks read access to consent objects.
     */
    public List<Object> getConsents(Id partyId) {
        // --- CRUD/FLS guard (read)
        if (!Schema.sObjectType.PartyConsent.isAccessible()) {
            System.debug(System.LoggingLevel.ERROR, 'You do not have permission to read consents.');
            throw new SecurityException('You do not have permission to read consents.');
        }

        return buildJsonByParty(partyId, DEFAULT_LIMIT);
    }

    // ---- Public API --------------------------------------------------------

    /**
     * @description Query OPT-IN PartyConsent by Party and return JSON payload.
     * @param partyId   The Party (Individual) Id.
     * @param limitSize Optional SOQL limit (defaults to 500).
     * @return JSON string with the grouped structure.
     */
    public static List<Object> buildJsonByParty(Id partyId, Integer limitSize) {
        List<PartyConsent> pcRaw = fetchOptInByParty(partyId, limitSize);

        SObjectAccessDecision pcDec = Security.stripInaccessible(AccessType.READABLE, pcRaw);
        List<PartyConsent> rows = (List<PartyConsent>) pcDec.getRecords();

        List<Object> payload = groupByDataUsePurpose(rows);
        return (List<Object>) JSON.deserializeUntyped(System.JSON.serialize(payload));
    }

    // ---- Data access -------------------------------------------------------

    /**
     * @description Queries PartyConsent OPT-IN records needed for the transform.
     * @return List<PartyConsent> (may be empty, never null).
     */
    private static List<PartyConsent> fetchOptInByParty(Id partyId, Integer limitSize) {
        if (partyId == null)
            return new List<PartyConsent>();
        Integer lim = (limitSize == null || limitSize <= 0) ? DEFAULT_LIMIT : limitSize;

        return [
            SELECT
                Id,
                Name,
                CaptureDate,
                AuthorizationChannel__c,
                ChannelType__c,
                Process__c,
                Origin__c,
                BusinessCoverage__c,
                IdentityValidationNoData__c,
                CollectionMethodType__c,
                BusinessBrand.Name,
                TaskHistoryValidationRelationship__c,
                TaskHistoryValidationRelationship__r.Name,
                DataUsePurpose.Name,
                MedicalHistory__c,
                DataMarketing__c,
                GeneralDataMarketing__c,
                GeneralProcessingData__c,
                DebtCollection__c,
                DirectMarketingVida__c,
                CS_IdentificationType__c,
                CS_IdentificationNumber__c,
                AccountName__c
            FROM PartyConsent
            WHERE PartyId = :partyId AND PrivacyConsentStatus = :WSHabeasDataUtilities.PRIVACY_STATUS_OPT_IN
            ORDER BY LastModifiedDate DESC
            LIMIT :lim
        ];
    }

    // ---- Transformation ----------------------------------------------------

    /**
     * @description Groups PartyConsent rows by DataUsePurpose.Name.
     * @return List<Object> ready to be JSON-serialized.
     */
    private static List<Object> groupByDataUsePurpose(List<PartyConsent> rows) {
        if (rows == null || rows.isEmpty())
            return new List<Object>();

        // dupName -> DUP node (with its Company list)
        Map<String, Map<String, Object>> dupMap = new Map<String, Map<String, Object>>();

        for (PartyConsent pc : rows) {
            String dupName = (pc.DataUsePurpose != null ? getDataUsePurposeLabel(pc.DataUsePurpose.Name) + validateNullString(pc.AccountName__c) : '—');

            // Get or create the DUP node
            Map<String, Object> dupNode = dupMap.get(dupName);
            if (dupNode == null) {
                dupNode = newDupNode(dupName, pc);
                dupMap.put(dupName, dupNode);
            }

            // Append company entry for this row
            ((List<Object>) dupNode.get(K_COMPANY)).add(newCompanyNode(pc));
        }

        // Wrap each DUP as { "DataUsePurposeName": {...} }
        List<Object> out = new List<Object>();
        for (String key : dupMap.keySet()) {
            out.add(new Map<String, Object>{ K_DUP => dupMap.get(key) });
        }
        return out;
    }

    /**
     * @description Creates the DUP node (common fields + empty Company list).
     */
    private static Map<String, Object> newDupNode(String dupName, PartyConsent pc) {
        return new Map<String, Object>{
            K_NAME => dupName,
            K_PROCESO => pc.Process__c,
            K_TIPO_CANAL => pc.ChannelType__c,
            K_CANAL_AUTZ => pc.AuthorizationChannel__c,
            K_TASK_REL => pc.TaskHistoryValidationRelationship__c,
            K_TASK_REL_NAME => pc.TaskHistoryValidationRelationship__r != null ? pc.TaskHistoryValidationRelationship__r.Name : null,
            K_ORIGEN => pc.Origin__c,
            K_FECHA_CAP => (pc.CaptureDate == null ? null : String.valueOf(pc.CaptureDate)),
            K_COB_NEG => pc.BusinessCoverage__c,
            K_ID_NO_DATA => validateBooleanString(pc.IdentityValidationNoData__c),
            K_TIPO_CAP => pc.CollectionMethodType__c,
            K_TIPO_ID => getIdentificacionLabel(pc),
            K_NUM_ID => pc.CS_IdentificationNumber__c,
            K_NC => pc.AccountName__c,
            K_COMPANY => new List<Object>()
        };
    }

    /**
     * @description Creates a single Company node with its Autorizations.
     */
    private static Map<String, Object> newCompanyNode(PartyConsent pc) {
        return new Map<String, Object>{
            K_NAME => (pc.BusinessBrand != null ? pc.BusinessBrand.Name : null),
            K_AUTZ => new Map<String, Object>{
                K_NAME_PC => pc.Name,
                K_HM => validateMedicalHistory(pc.BusinessBrand.Name, pc.MedicalHistory__c),
                K_CD => validateBooleanString(pc.DataMarketing__c),
                K_OCG => validateBooleanString(pc.GeneralDataMarketing__c),
                K_TDG => validateBooleanString(pc.GeneralProcessingData__c),
                K_GC => pc.DebtCollection__c,
                K_OC => pc.DirectMarketingVida__c
            }
        };
    }

    private static String validateMedicalHistory(String company, Boolean dataMarketing) {
        if ('Seguros Generales'.equals(company)) {
            return 'N/A';
        } else {
            return validateBooleanString(dataMarketing);
        }
    }

    private static String validateBooleanString(Boolean value) {
        if (value == null)
            return null;
        return value ? 'Si' : 'No';
    }

    private static String getIdentificacionLabel(PartyConsent pc) {
        Schema.SObjectField fld = PartyConsent.CS_IdentificationType__c;

        Schema.DescribeFieldResult d = fld.getDescribe();

        Map<String, String> valueToLabel = new Map<String, String>();
        for (Schema.PicklistEntry e : d.getPicklistValues()) {
            valueToLabel.put(e.getValue(), e.getLabel());
        }

        String currentValue = (String) pc.get(d.getName());
        return valueToLabel.get(currentValue);
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

    private static String validateNullString(String value) {
        if (String.isEmpty(value) || value == null) {
            return '';
        } else {
            return ' / ' + value;
        }
    }
}