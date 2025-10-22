/**
 * WS_OSTIpoAutorizacion_V2
 * ------------------------
 * Orchestrates Habeas Data authorization creation from OmniStudio (Flow/IP/OS)
 * by translating a generic input map into the controller DTO and delegating to
 * WSHabeasDataService.processAuth.
 *
 * @author  Carlos Vivas
 * @since   1.0
 */
global with sharing class WS_OSTIpoAutorizacion_V2 implements Callable {
    // ---------------------------------------------------------------------
    // Constants
    // ---------------------------------------------------------------------
    // Channels
    private static final String CH_WHATSAPP = 'WhatsApp';
    private static final String CH_EMAIL = 'correo electrónico';
    private static final String CH_CELULAR = 'celular';
    private static final String CH_SMS = 'mensaje de texto';

    /** Default channels to emit for 2300 consents. */
    private static final Set<String> DEFAULT_CHANNELS = new Set<String>{ CH_WHATSAPP, CH_EMAIL, CH_CELULAR, CH_SMS };

    /** Default authorization channel sent to Party/ContactPoint consents. */
    private static final String DEFAULT_AUTH_CHANNEL = 'Salesforce - Indemnizaciones';

    /** Default business brands. */
    private static final List<String> DEFAULT_COMPANIES = new List<String>{ 'Seguro de Vida' };

    // Input keys to avoid magic strings
    private static final String K_FIRST_NAME = 'FirstName';
    private static final String K_SECOND_NAME = 'SecondName';
    private static final String K_LAST_NAME = 'LastName';
    private static final String K_SECOND_LAST = 'SecondLastName';
    private static final String K_ID_TYPE = 'identityType';
    private static final String K_ID_NUMBER = 'identityNumber';
    private static final String K_EMAIL = 'email';
    private static final String K_MOBILE = 'numberPhone';

    // Output keys
    private static final String OUT_STATUS = 'status';
    private static final String OUT_RESP = 'response';
    private static final String OUT_MESSAGE = 'message';

    // ---------------------------------------------------------------------
    // Callable
    // ---------------------------------------------------------------------

    /**
     * Callable entrypoint used by OmniStudio/Flows.
     *
     * @param action  Logical operation (e.g., "saveInformationHabeasData").
     * @param args    Wrapper map with "input", "output", "options".
     * @return        Boolean success flag for the invoked action.
     */
    global Object call(String action, Map<String, Object> args) {
        Map<String, Object> input = (Map<String, Object>) args.get('input');
        Map<String, Object> output = (Map<String, Object>) args.get('output');
        Map<String, Object> options = (Map<String, Object>) args.get('options');
        return invokeAction(action, input, output, options);
    }

    /**
     * Dispatches supported actions and writes a normalized result into output.
     *
     * @param methodName  Action name (case insensitive).
     * @param inputMap    Incoming input payload.
     * @param outMap      Outgoing output payload.
     * @param options     Optional options (unused).
     * @return            true when the action completes without unhandled error.
     */
    global Boolean invokeAction(String methodName, Map<String, Object> inputMap, Map<String, Object> outMap, Map<String, Object> options) {
        try {
            if (String.isBlank(methodName)) {
                throw new AuraHandledException('methodName is required');
            }
            switch on methodName.toLowerCase() {
                when 'saveinformationhabeasdata' {
                    saveInformationHabeasDataFromOmni(inputMap);

                    return true;
                }
                when else {
                    return false;
                }
            }
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, e.getStackTraceString());
            return false;
        }
    }

    // ---------------------------------------------------------------------
    // Core orchestration
    // ---------------------------------------------------------------------

    /**
     * Builds the DTOs from the inbound map and calls the domain service.
     *
     * @param inputMap  Raw input map from Omni/Flow.
     * @return          Service response DTO (never null on success path).
     */
    public static void saveInformationHabeasDataFromOmni(Map<String, Object> inputMap) {
        WSHabeasDataAPIDto.HabeasDataDto dto = new WSHabeasDataAPIDto.HabeasDataDto();
        dto.account = toAccount(inputMap);
        dto.consent = toConsent(inputMap);
        dto.companies = defaultCompanies();

        WSHabeasDataAPIDto.ResponseDto svcResp = new WSHabeasDataService().processAuth(dto);
        System.debug('WS_OSTIpoAutorizacion_V2 response: ' + JSON.serialize(svcResp));
    }

    /**
     * Maps person fields from the input map to AccountDto.
     *
     * @param inputMap Raw input map.
     * @return         Filled AccountDto.
     */
    @TestVisible
    private static WSHabeasDataAPIDto.AccountDto toAccount(Map<String, Object> inputMap) {
        WSHabeasDataAPIDto.AccountDto a = new WSHabeasDataAPIDto.AccountDto();
        a.firstName = val(inputMap, K_FIRST_NAME);
        a.secondName = val(inputMap, K_SECOND_NAME);
        a.lastName = val(inputMap, K_LAST_NAME);
        a.secondLastName = val(inputMap, K_SECOND_LAST);
        a.identityType = val(inputMap, K_ID_TYPE);
        a.identityNumber = val(inputMap, K_ID_NUMBER);
        a.email = val(inputMap, K_EMAIL);
        a.numberPhone = val(inputMap, K_MOBILE);
        return a;
    }

    /**
     * Builds ConsentDto with default authorization channel and 2300 list.
     *
     * @param inputMap Raw input map.
     * @return         Filled ConsentDto.
     */
    @TestVisible
    private static WSHabeasDataAPIDto.ConsentDto toConsent(Map<String, Object> inputMap) {
        WSHabeasDataAPIDto.ConsentDto c = new WSHabeasDataAPIDto.ConsentDto();
        c.authorizationChannel = DEFAULT_AUTH_CHANNEL;
        c.dataUsePurpose = WSHabeasDataUtilities.CLIENTE;
        c.authorization2300 = build2300(inputMap);
        return c;
    }

    /**
     * Creates Auth2300 entries per available channel for both 2300 purposes.
     *
     * @param inputMap Raw input map.
     * @return         List<Auth2300>.
     */
    @TestVisible
    private static List<WSHabeasDataAPIDto.Auth2300> build2300(Map<String, Object> inputMap) {
        final String email = val(inputMap, K_EMAIL);
        final String mobile = val(inputMap, K_MOBILE);

        List<WSHabeasDataAPIDto.Auth2300> out = new List<WSHabeasDataAPIDto.Auth2300>();
        for (String ch : DEFAULT_CHANNELS) {
            String contactPoint = (ch == CH_EMAIL) ? email : mobile;
            if (String.isBlank(contactPoint))
                continue;

            out.add(newAuth(true, ch, contactPoint, WSHabeasDataUtilities.GESTION_CARTERA_2300));
            out.add(newAuth(true, ch, contactPoint, WSHabeasDataUtilities.OFRECIMIENTO_COMERCIAL_2300));
        }
        return out;
    }

    /**
     * Factory for Auth2300 rows.
     */
    private static WSHabeasDataAPIDto.Auth2300 newAuth(Boolean value, String type, String point, String dup) {
        WSHabeasDataAPIDto.Auth2300 a = new WSHabeasDataAPIDto.Auth2300();
        a.value = value;
        a.contactPointType = type;
        a.contactPoint = point;
        a.dataUsePurpose = dup;
        return a;
    }

    /**
     * Default companies list (copy to avoid external mutation).
     */
    @TestVisible
    private static List<String> defaultCompanies() {
        return new List<String>(DEFAULT_COMPANIES);
    }

    /**
     * Safe extractor from input map -> String (null if absent).
     */
    @TestVisible
    private static String val(Map<String, Object> m, String key) {
        if (m == null || String.isBlank(key))
            return null;
        Object o = m.get(key);
        return (o == null) ? null : String.valueOf(o);
    }

    /**
     * Writes a normalized response into the output map.
     */
    private static void writeOutput(Map<String, Object> outMap, String status, WSHabeasDataAPIDto.ResponseDto resp, String msg) {
        if (outMap == null)
            return;
        outMap.put(OUT_STATUS, status);
        if (resp != null)
            outMap.put(OUT_RESP, resp);
        if (!String.isBlank(msg))
            outMap.put(OUT_MESSAGE, msg);
    }
}