public with sharing class WSHabeasDataUtilities {
    //Constants
    public static final String RECORD_TYPE_NATURAL_PERSON = 'Cuenta Personal';
    public static final String RECORD_TYPE_LEGAL_ACCOUNT = 'Cuenta Jurídica';
    public static final String RECORD_TYPE_GENERAL_LEAD = 'General';
    public static final String RECORD_TYPE_RL_LEAD = 'Business Referral';
    public static final String RECORD_TYPE_NATURAL_PERSON_LEAD = 'Persona Natural';
    public static final String RECORD_TYPE_LEGAL_PERSON_LEAD = 'Persona Jurídica';
    public static final String RECORD_TYPE_GENERAL_CONTACT = 'IndustriesBusiness';
    public static final String SALES_PROCESS = 'Venta';
    public static final String DEBT_COLLECT = 'Gestión Cartera-2300';
    public static final String DATA_MARKETING = 'Ofrecimiento Comercial-2300';
    public static final String PRIVACY_STATUS_OPT_IN = 'OptIn';
    public static final String PRIVACY_STATUS_OPT_OUT = 'OptOut';
    public static final String PRIVACY_STATUS_NO_STATUS = 'NotSeen';
    public static final String IDENTITY_VALIDATION_SOURCE_MANUAL = 'Manual';
    public static final String CONTACT_POINT_TYPE_EMAIL = 'correo electrónico';

    public static List<String> CONTACT_MANDATORY_FIELDS = new List<String>{ 'contactFirstName', 'contactLastName', 'contactIdType', 'contactIdNumber' };

    public static List<String> CONTROLLER_MANDATORY_FIELDS = new List<String>{
        'identityType',
        'identityNumber',
        'email',
        'numberPhone',
        'dataUsePurpose',
        'authorizationChannel'
    };

    //Data Use Purpose
    public static String CLIENTE = 'Cliente';
    public static String CLIENTE_REPRESENTANTE_LEGAL = 'Cliente Representante Legal';
    public static String PROSPECTO = 'Prospecto';
    public static String PROSPECTO_REPRESENTANTE_LEGAL = 'Prospecto Representante Legal';
    public static String GESTION_CARTERA_2300 = 'Gestión Cartera-2300';
    public static String OFRECIMIENTO_COMERCIAL_2300 = 'Ofrecimiento Comercial-2300';
    public static String CLIENTE_PERSONA_JURIDICA = 'Cliente Persona Juridica';
    public static String PROSPECTO_PERSONA_JURIDICA = 'Prospecto Persona Juridica';

    //Account
    public static String ACCOUNT_COMPANY = '1';
    public static String ACCOUNT_TYPE_ACCOUNT = 'Cuenta Prospecto';

    //Static Methods
    public static Boolean validateContactRequestData(WSHabeasDataExtendWrapper.HabeasDataDto request) {
        if (request == null)
            return false;

        Map<String, Object> dto = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(request));

        for (String f : CONTACT_MANDATORY_FIELDS) {
            Object v = dto.get(f);
            if (v == null || (v instanceof String && String.isBlank((String) v))) {
                return false;
            }
        }
        return true;
    }

    public static Boolean validateRequiredFields(WSHabeasDataExtendWrapper.HabeasDataDto dto, List<String> requiredFields) {
        Map<String, Object> data = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(dto));

        for (String fieldName : requiredFields) {
            if (!data.containsKey(fieldName) || isBlankish(data.get(fieldName))) {
                return true;
            }
        }
        return false;
    }

    private static Boolean isBlankish(Object v) {
        if (v == null)
            return true;
        if (v instanceof String)
            return String.isBlank((String) v);
        if (v instanceof List<Object>)
            return ((List<Object>) v).isEmpty();
        if (v instanceof Map<String, Object>)
            return ((Map<String, Object>) v).isEmpty();
        return false;
    }
}