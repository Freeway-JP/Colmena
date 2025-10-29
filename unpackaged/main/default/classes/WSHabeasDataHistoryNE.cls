/**
 * WSHabeasDataHistoryNE
 * ---------------------
 * Builds a JSON-serializable history view for "Not Essential Functionalities"
 * changes on Individual (Field History Tracking).
 *
 * Action (Callable): "getHistoryNE"
 *
 * @author  Carlos Vivas
 * @since   1.0
 */
public with sharing class WSHabeasDataHistoryNE implements Callable {
    // ---- Constants ----
    private static final String KEY_PARTY_ID = 'recordId';
    private static final String KEY_CONSENTS = 'consents';

    private static final Set<String> TRACKED_FIELDS = new Set<String>{
        'notEssentialFunctionalitiesARL_H__c',
        'notEssentialFunctionalitiesSegGen_H__c',
        'notEssentialFunctionalitiesSegVida_H__c',
        'notEssentialFunctionalitiesCap_H__c'
    };
    private static final Map<String, String> FIELD_TO_ASEG = new Map<String, String>{
        'notEssentialFunctionalitiesARL_H__c' => 'ARL',
        'notEssentialFunctionalitiesSegGen_H__c' => 'Seguros Generales',
        'notEssentialFunctionalitiesSegVida_H__c' => 'Seguro de Vida',
        'notEssentialFunctionalitiesCap_H__c' => 'Capitalizadora'
    };
    private static final String OUT_CREATED = 'CreatedDate';
    private static final String OUT_ASEG = 'Aseguradora';
    private static final String OUT_NE1 = 'NoEsencial1';
    private static final String OUT_NE2 = 'NoEsencial2';
    private static final String OUT_NE3 = 'NoEsencial3';
    private static final String OUT_NAME = 'Nombre';
    private static final String OUT_TI = 'TipoIdentificacion';
    private static final String OUT_NI = 'NumeroIdentificacion';
    private static final String OUT_UM = 'UltimaModificacion';
    private static final String TZ_ID = UserInfo.getTimeZone().getID();
    private static final String ISO_PATTERN = 'yyyy-MM-dd\'T\'HH:mm:ss.SSSZ';
    private static final Integer DEFAULT_LIMIT = 200;
    private static final String NOT_PRESENT = 'NO';

    @TestVisible
    private static List<IndividualHistory> testRowsOverride;

    @TestVisible
    private static List<Map<String, Object>> testRowsOverrideMaps;

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
                when 'gethistoryne' {
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
     * Returns the individual history
     *
     * @param partyId  Party id (Contact/Lead/Person Account) whose consents are requested.
     * @return         A JSON-serializable List<Object> of ConsentGroup DTOs.
     * @throws SecurityException if the running user lacks read access to consent objects.
     */
    public List<Object> getConsents(Id partyId) {
        // --- CRUD/FLS guard (read)
        if (!Schema.sObjectType.IndividualHistory.isAccessible()) {
            System.debug(System.LoggingLevel.ERROR, 'You do not have permission to read consents.');
            throw new SecurityException('You do not have permission to read consents.');
        }

        return buildJson(partyId);
    }

    /**
     * Returns the full json to be used in the response.
     *
     * @param individualId
     * @return         A JSON-serializable List of List<Object>
     */
    public static List<Object> buildJson(Id individualId) {
        if (testRowsOverrideMaps != null) {
            List<Object> payloadFromMaps = makeRowsFromMaps(testRowsOverrideMaps);
            return (List<Object>) JSON.deserializeUntyped(JSON.serialize(payloadFromMaps));
        }

        List<IndividualHistory> pcRaw = (testRowsOverride == null) ? fetch(individualId, DEFAULT_LIMIT) : testRowsOverride;

        List<IndividualHistory> rows;
        if (testRowsOverride == null) {
            SObjectAccessDecision pcDec = Security.stripInaccessible(AccessType.READABLE, pcRaw);
            rows = (List<IndividualHistory>) pcDec.getRecords();
        } else {
            rows = pcRaw;
        }

        List<Object> payload = makeRows(rows);
        return (List<Object>) JSON.deserializeUntyped(JSON.serialize(payload));
    }

    @TestVisible
    private static List<Object> makeRowsFromMaps(List<Map<String, Object>> rowsMaps) {
        List<Object> out = new List<Object>();
        for (Map<String, Object> h : rowsMaps) {
            out.add(makeRowFromMap(h));
        }
        return out;
    }

    @TestVisible
    private static Map<String, Object> makeRowFromMap(Map<String, Object> h) {
        Map<String, Object> m = new Map<String, Object>();

        Datetime cd = (Datetime) h.get('CreatedDate');
        m.put(OUT_CREATED, (cd == null) ? null : cd.format(ISO_PATTERN, TZ_ID));

        String field = (String) h.get('Field');
        m.put(OUT_ASEG, FIELD_TO_ASEG.get(field));

        Map<String, Object> indiv = (Map<String, Object>) h.get('Individual');
        if (indiv != null) {
            m.put(OUT_NAME, (String) indiv.get('Name'));
            String tiVal = (String) indiv.get('CS_TipoIdentificacion__c');
            m.put(OUT_TI, getIdentificacionLabel(tiVal));
            m.put(OUT_NI, (String) indiv.get('CS_NumeroIdentificacion__c'));
        } else {
            m.put(OUT_NAME, null);
            m.put(OUT_TI, null);
            m.put(OUT_NI, null);
        }

        String newVal = (String) h.get('NewValue');
        Set<String> vals = parseSemicolonList(newVal);

        putPresence(m, OUT_NE1, 'FNE1', vals);
        putPresence(m, OUT_NE2, 'FNE2', vals);
        putPresence(m, OUT_NE3, 'FNE3', vals);

        return m;
    }

    /**
     * Returns individual history by the Individual Id.
     *
     * @param individualId Individual Id to be used in the query.
     * @param individualId Limit of records to be returned (max 200).
     * @return         A JSON-serializable List of List<IndividualHistory>
     */
    private static List<IndividualHistory> fetch(Id individualId, Integer limitSize) {
        if (individualId == null)
            return new List<IndividualHistory>();
        Integer lim = (limitSize == null || limitSize <= 0) ? DEFAULT_LIMIT : limitSize;

        return [
            SELECT
                Id,
                IndividualId,
                Field,
                OldValue,
                NewValue,
                CreatedDate,
                Individual.Name,
                Individual.CS_TipoIdentificacion__c,
                Individual.CS_NumeroIdentificacion__c,
                Individual.LastModifiedBy.Name
            FROM IndividualHistory
            WHERE IndividualId = :individualId AND Field IN :TRACKED_FIELDS
            ORDER BY CreatedDate DESC
            LIMIT :lim
        ];
    }

    /**
     * Returns individual history by the Individual Id.
     *
     * @param rows  Records of the individual history founds.
     * @return      A JSON-serializable List of List<Object>
     */
    private static List<Object> makeRows(List<IndividualHistory> rows) {
        List<Object> out = new List<Object>();
        for (IndividualHistory h : rows)
            out.add(makeRow(h));
        return out;
    }

    /**
     * Returns the new Structure that the FlexCard will be use to show the history.
     *
     * @param h  Records of the individual history founds.
     * @return   A Map-serializable Map of Map<String, Object>
     */
    private static Map<String, Object> makeRow(IndividualHistory h) {
        Map<String, Object> m = new Map<String, Object>();
        m.put(OUT_CREATED, h.CreatedDate.format(ISO_PATTERN, TZ_ID));
        m.put(OUT_ASEG, FIELD_TO_ASEG.get(h.Field));
        m.put(OUT_NAME, h.Individual.Name);
        m.put(OUT_TI, getIdentificacionLabel(h.Individual.CS_TipoIdentificacion__c));
        m.put(OUT_NI, h.Individual.CS_NumeroIdentificacion__c);
        m.put(OUT_UM, h.Individual.LastModifiedBy.Name);

        Set<String> vals = parseSemicolonList((String) h.NewValue);

        putPresence(m, OUT_NE1, 'FNE1', vals);
        putPresence(m, OUT_NE2, 'FNE2', vals);
        putPresence(m, OUT_NE3, 'FNE3', vals);

        return m;
    }

    /**
     * Returns Not Essential Functionalities as a Set<String>
     *
     * @param s  Not Essentials functionalities separed by ";".
     * @return   A Set-serializable Set of Set<String>
     */
    private static Set<String> parseSemicolonList(String s) {
        Set<String> res = new Set<String>();
        if (String.isBlank(s))
            return res;
        for (String p : s.split('\\s*;\\s*'))
            if (!String.isBlank(p))
                res.add(p.trim());
        return res;
    }

    /**
     * Add the elements if this is present in the Set
     *
     * @param m     Map to be filled.
     * @param key   Key to be used in the map.
     * @param code  Code to be searched in the Set.
     * @param vals  Set of values to be searched.
     * @return      void
     */
    private static void putPresence(Map<String, Object> m, String key, String code, Set<String> vals) {
        m.put(key, vals.contains(code) ? geLabel(code) : NOT_PRESENT);
    }

    private static String geLabel(String valueToFind) {
        Schema.SObjectField fld = Individual.notEssentialFunctionalitiesSegGen__c;

        Schema.DescribeFieldResult d = fld.getDescribe();

        Map<String, String> valueToLabel = new Map<String, String>();
        for (Schema.PicklistEntry e : d.getPicklistValues()) {
            valueToLabel.put(e.getValue(), e.getLabel());
        }

        return valueToLabel.get(valueToFind);
    }

    /**
     * Get the label of the picklist value
     *
     * @param valueToFind  Value to be searched in the picklist.
     * @return      String label of the picklist value.
     */
    private static String getIdentificacionLabel(String valueToFind) {
        Schema.SObjectField fld = Individual.CS_TipoIdentificacion__c;

        Schema.DescribeFieldResult d = fld.getDescribe();

        Map<String, String> valueToLabel = new Map<String, String>();
        for (Schema.PicklistEntry e : d.getPicklistValues()) {
            valueToLabel.put(e.getValue(), e.getLabel());
        }
        return valueToLabel.get(valueToFind);
    }
}