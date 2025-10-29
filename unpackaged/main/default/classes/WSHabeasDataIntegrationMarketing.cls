/**
 * WSHabeasDataIntegrationMarketing
 * ---------------------------------
 * Invocable Apex Action para ser llamada desde Flow (Cuenta, Prospecto, Oportunidad) y crear una solicitud
 * de autorización Habeas Data (Party/ContactPoint Consents) a través del
 * servicio WSHabeasDataService.processAuth, construyendo el DTO requerido.
 *
 * Uso en Flow:
 *  - Agregar "Apex Action" → "WSHabeasDataIntegrationMarketing.run"
 *  - Mapear entradas (firstName, lastName, documentType, numeroDocumento, email, mobile, treatmentType, etc.)
 *  - treatmentType debe ser uno de: 'Cliente', 'Cliente Representante Legal', 'Prospecto', 'Prospecto Representante Legal'
 *
 * @author Julian Reales de la Ossa
 * @since  2025-10
 */
public with sharing class WSHabeasDataIntegrationMarketing {
    // ============================================================
    // Constantes (canales y empresas por defecto)
    // ============================================================
    private static final String CH_WHATSAPP = 'WhatsApp';
    private static final String CH_EMAIL = 'correo electrónico';
    private static final String CH_CELULAR = 'celular';
    private static final String CH_SMS = 'mensaje de texto';

    /** Canales por defecto que se intentarán generar */
    private static final Set<String> DEFAULT_CHANNELS = new Set<String>{ CH_WHATSAPP, CH_EMAIL, CH_CELULAR, CH_SMS };

    /** Compañías*/
    private static final List<String> DEFAULT_COMPANIES = new List<String>{ 'ARL', 'Seguro de Vida', 'Seguros Generales' };

    /** Canal de autorización por defecto */
    private static final String DEFAULT_AUTH_CHANNEL = 'BD Banco Caja Social';

    // ============================================================
    // DTOs de entrada/salida para Flow
    // ============================================================
    public class Request {
        @InvocableVariable(required=false)
        public String firstName;

        @InvocableVariable(required=false)
        public String secondName;

        @InvocableVariable(required=true)
        public String lastName;

        @InvocableVariable(required=false)
        public String secondLastName;

        @InvocableVariable(required=true)
        public String documentType;

        @InvocableVariable(required=true)
        public String numeroDocumento;

        @InvocableVariable(required=true)
        public String email;

        @InvocableVariable(required=true)
        public String mobile;

        @InvocableVariable(required=false)
        public String contactFirstName;

        @InvocableVariable(required=false)
        public String contactLastName;

        @InvocableVariable(required=false)
        public String contactIdType;

        @InvocableVariable(required=false)
        public String contactIdNumber;

        @InvocableVariable(required=true)
        public String treatmentType;
    }

    public class Response {
        @InvocableVariable
        public Boolean success;

        @InvocableVariable
        public String message;
    }

    // ============================================================
    // Punto de entrada Invocable para Flow
    // ============================================================
    /**
     * Ejecuta la creación de autorizaciones HD por cada request.
     * @param reqs Lista de peticiones provenientes del Flow.
     * @return Lista de respuestas (una por cada input).
     */
    @InvocableMethod(label='HD – Create Auth from Marketing Integration' description='Construye el DTO de Habeas Data desde Marketing y llama WSHabeasDataService.processAuth.')
    public static List<Response> run(List<Request> reqs) {
        List<Response> out = new List<Response>();
        if (reqs == null || reqs.isEmpty())
            return out;

        for (Request r : reqs) {
            Response res = new Response();
            out.add(res);

            try {
                validate(r);

                WSHabeasDataAPIDto.HabeasDataDto dto = new WSHabeasDataAPIDto.HabeasDataDto();
                dto.account = toAccount(r);
                dto.consent = toConsent(r);
                dto.companies = toCompanies();

                WSHabeasDataAPIDto.ResponseDto svcResp = new WSHabeasDataService().processAuth(dto);
                res.success = (svcResp != null && !svcResp.error && svcResp.responseCode == 200);
                res.message = (svcResp == null)
                    ? 'No response from service'
                    : (String.isBlank(svcResp.message) ? (res.success ? 'OK' : 'Failed') : svcResp.message);
            } catch (Exception e) {
                res.success = false;
                res.message = e.getMessage();
            }
        }
        return out;
    }

    // ============================================================
    // Validaciones
    // ============================================================
    /** Lógica defensiva (el Flow ya marca requeridos, pero validamos de nuevo). */
    @TestVisible
    private static void validate(Request r) {
        if (String.isBlank(r.firstName))
            throw new AuraHandledException('firstName is required');
        if (String.isBlank(r.lastName))
            throw new AuraHandledException('lastName is required');
        if (String.isBlank(r.documentType))
            throw new AuraHandledException('documentType is required');
        if (String.isBlank(r.numeroDocumento))
            throw new AuraHandledException('numeroDocumento is required');
        if (String.isBlank(r.treatmentType))
            throw new AuraHandledException('treatmentType is required');
    }

    // ============================================================
    // Mapeos a DTO del servicio
    // ============================================================
    /** Mapea los datos de persona al AccountDto del contrato. */
    @TestVisible
    private static WSHabeasDataAPIDto.AccountDto toAccount(Request r) {
        WSHabeasDataAPIDto.AccountDto a = new WSHabeasDataAPIDto.AccountDto();
        a.firstName = validateNullString(r.firstName);
        a.secondName = validateNullString(r.secondName);
        a.lastName = validateNullString(r.lastName);
        a.secondLastName = validateNullString(r.secondLastName);
        a.identityType = r.documentType;
        a.identityNumber = r.numeroDocumento;
        a.email = r.email;
        a.numberPhone = r.mobile;
        a.contactFirstName = validateNullString(r.contactFirstName);
        a.contactLastName = validateNullString(r.contactLastName);
        a.contactIdType = validateNullString(r.contactIdType);
        a.contactIdNumber = validateNullString(r.contactIdNumber);
        return a;
    }

    /** Valida campos nulos */
    private static String validateNullString(String s) {
        if (s == null || String.isBlank(s)) {
            return '';
        }
        return s;
    }

    /** Construye el ConsentDto con canal, propósito y lista 2300. */
    @TestVisible
    private static WSHabeasDataAPIDto.ConsentDto toConsent(Request r) {
        WSHabeasDataAPIDto.ConsentDto c = new WSHabeasDataAPIDto.ConsentDto();
        c.authorizationChannel = DEFAULT_AUTH_CHANNEL;
        c.dataUsePurpose = r.treatmentType;

        // Autorizaciones por la 2300 (se crean por cada canal disponible)
        c.authorization2300 = buildAuth2300(r);
        return c;
    }

    /** Genera los registros 2300 por canal disponible y por cada propósito requerido. */
    @TestVisible
    private static List<WSHabeasDataAPIDto.Auth2300> buildAuth2300(Request r) {
        List<WSHabeasDataAPIDto.Auth2300> out = new List<WSHabeasDataAPIDto.Auth2300>();

        for (String ch : DEFAULT_CHANNELS) {
            String contactPoint = (ch == CH_EMAIL) ? r.email : r.mobile;

            if (String.isBlank(contactPoint))
                continue;

            // Gestión de Cartera 2300
            out.add(newAuth(true, ch, contactPoint, WSHabeasDataUtilities.GESTION_CARTERA_2300));
            // Ofrecimiento Comercial 2300
            out.add(newAuth(true, ch, contactPoint, WSHabeasDataUtilities.OFRECIMIENTO_COMERCIAL_2300));
        }
        return out;
    }

    /** Helper para crear un Auth2300. */
    private static WSHabeasDataAPIDto.Auth2300 newAuth(Boolean val, String type, String point, String dup) {
        WSHabeasDataAPIDto.Auth2300 a = new WSHabeasDataAPIDto.Auth2300();
        a.value = val;
        a.contactPointType = type;
        a.contactPoint = point;
        a.dataUsePurpose = dup;
        return a;
    }

    /** Obtiene compañías desde CSV o devuelve las predeterminadas sin duplicados. */
    @TestVisible
    private static List<String> toCompanies() {
        return new List<String>(DEFAULT_COMPANIES);
    }
}