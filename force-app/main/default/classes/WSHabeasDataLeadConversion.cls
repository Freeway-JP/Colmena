/**
 * WSHabeasDataLeadConversion
 * ---------------------------------
 * Invocable Apex Action para ser llamada desde Flow de conversión de Lead y crear una solicitud
 * de autorización Habeas Data (Party/ContactPoint Consents) a través del
 * servicio WSHabeasDataService.processAuth, construyendo el DTO requerido.
 *
 * Uso en Flow:
 *  - Agregar "Apex Action" → "WSHabeasDataLeadConversion.run"
 *  - Mapear entradas (firstName, lastName, documentType, numeroDocumento, email, mobile, etc.)
 *
 * @author Julian Reales de la Ossa
 * @since  2025-10
 */
public with sharing class WSHabeasDataLeadConversion {
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
    private static final String DEFAULT_AUTH_CHANNEL = 'Linea Efectiva outbound (Telemercadeo)';
    
    /** Valores por defecto */
    private static final String DEFAULT_PROCESS = 'Venta';
    private static final String DEFAULT_ORIGIN = 'No aplica';
    private static final String DEFAULT_CHANNEL_TYPE = 'Telefónico';
    private static final String DEFAULT_BUSINESS_COVERAGE = 'Transversal';
    private static final String DEFAULT_COLLECTION_METHOD = 'Salesforce';

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

        @InvocableVariable(required=false)
        public String dataUsePurpose;

        @InvocableVariable(required=false)
        public String sex;

        @InvocableVariable(required=false)
        public String process;

        @InvocableVariable(required=false)
        public String origin;

        @InvocableVariable(required=false)
        public String channelType;

        @InvocableVariable(required=false)
        public String businessCoverage;

        @InvocableVariable(required=false)
        public String authorizationChannel;

        @InvocableVariable(required=false)
        public String collectionMethodType;

        // Autorizaciones Seguro de Vida
        @InvocableVariable(required=false)
        public Boolean generalProcessingDataVida;

        @InvocableVariable(required=false)
        public Boolean generalCommercialOfferVida;

        // Autorizaciones ARL
        @InvocableVariable(required=false)
        public Boolean generalProcessingDataARL;

        @InvocableVariable(required=false)
        public Boolean generalCommercialOfferARL;

        // Autorizaciones Seguros Generales
        @InvocableVariable(required=false)
        public Boolean generalProcessingDataGenerales;

        @InvocableVariable(required=false)
        public Boolean generalCommercialOfferGenerales;
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
    @InvocableMethod(label='HD – Create Auth from Lead Conversion' description='Construye el DTO de Habeas Data desde Lead convertido y llama WSHabeasDataService.processAuth.')
    public static List<Response> run(List<Request> reqs) {
        List<Response> out = new List<Response>();
        if (reqs == null || reqs.isEmpty())
            return out;

        for (Request r : reqs) {
            Response res = new Response();
            out.add(res);

            try {
                System.debug('════════════════════════════════════════════════════════════════');
                System.debug('INICIO - Procesando Request');
                System.debug('════════════════════════════════════════════════════════════════');
                
                validate(r);
                System.debug('✓ Validación exitosa');

                WSHabeasDataExtendWrapper.HabeasDataDto dto = buildDTO(r);
                System.debug('✓ DTO construido');
                
                // Log del JSON final antes de enviar al servicio
                System.debug('JSON FINAL PARA ENVIAR AL SERVICIO:');
                System.debug(JSON.serializePretty(dto));
                System.debug('════════════════════════════════════════════════════════════════');

                WSHabeasDataExtendWrapper.HabeasDataResponseDto svcResp = new WSHabeasDataService().processAuth_V2(dto);
                System.debug('✓ Respuesta del servicio recibida');
                System.debug('Response Code: ' + svcResp?.responseCode);
                System.debug('Error: ' + svcResp?.error);
                System.debug('Message: ' + svcResp?.message);
                
                res.success = (svcResp != null && !svcResp.error && svcResp.responseCode == 200);
                res.message = (svcResp == null)
                    ? 'No response from service'
                    : (String.isBlank(svcResp.message) ? (res.success ? 'OK' : 'Failed') : svcResp.message);
                    
                System.debug('════════════════════════════════════════════════════════════════');
                System.debug('FIN - Success: ' + res.success + ', Message: ' + res.message);
                System.debug('════════════════════════════════════════════════════════════════');
            } catch (Exception e) {
                res.success = false;
                res.message = e.getMessage();
                
                System.debug(LoggingLevel.ERROR, '════════════════════════════════════════════════════════════════');
                System.debug(LoggingLevel.ERROR, '❌ ERROR CAPTURADO:');
                System.debug(LoggingLevel.ERROR, 'Tipo: ' + e.getTypeName());
                System.debug(LoggingLevel.ERROR, 'Mensaje: ' + e.getMessage());
                System.debug(LoggingLevel.ERROR, 'Stack Trace: ' + e.getStackTraceString());
                System.debug(LoggingLevel.ERROR, 'Línea: ' + e.getLineNumber());
                System.debug(LoggingLevel.ERROR, '════════════════════════════════════════════════════════════════');
            }
        }
        return out;
    }

    // ============================================================
    // Validaciones
    // ============================================================
    /** Lógica defensiva - validar solo campos críticos. */
    @TestVisible
    private static void validate(Request r) {
        if (String.isBlank(r.documentType))
            throw new AuraHandledException('documentType is required');
        if (String.isBlank(r.numeroDocumento))
            throw new AuraHandledException('numeroDocumento is required');
    }

    // ============================================================
    // Mapeos a DTO del servicio
    // ============================================================
    /** Construye el DTO completo para el servicio. */
    @TestVisible
    private static WSHabeasDataExtendWrapper.HabeasDataDto buildDTO(Request r) {
        WSHabeasDataExtendWrapper.HabeasDataDto dto = new WSHabeasDataExtendWrapper.HabeasDataDto();
        
        // Datos personales
        dto.firstName = r.firstName;
        dto.secondName = r.secondName;
        dto.lastName = r.lastName;
        dto.secondLastName = r.secondLastName;
        dto.identityType = r.documentType;
        dto.identityNumber = r.numeroDocumento;
        dto.email = r.email;
        dto.numberPhone = r.mobile;
        dto.sex = r.sex;
        
        // Datos de contacto (Representante Legal)
        dto.contactFirstName = r.contactFirstName;
        dto.contactLastName = r.contactLastName;
        dto.contactIdType = r.contactIdType;
        dto.contactIdNumber = r.contactIdNumber;
        
        // Propósito de uso
        dto.dataUsePurpose = String.isNotBlank(r.dataUsePurpose) 
            ? r.dataUsePurpose 
            : WSHabeasDataUtilities.PROSPECTO;
        
        // Proceso y origen
        dto.process = String.isNotBlank(r.process) ? r.process : DEFAULT_PROCESS;
        dto.origin = String.isNotBlank(r.origin) ? r.origin : DEFAULT_ORIGIN;
        
        // Canal y cobertura
        dto.channelType = String.isNotBlank(r.channelType) ? r.channelType : DEFAULT_CHANNEL_TYPE;
        dto.businessCoverage = String.isNotBlank(r.businessCoverage) ? r.businessCoverage : DEFAULT_BUSINESS_COVERAGE;
        dto.authorizationChannel = String.isNotBlank(r.authorizationChannel) ? r.authorizationChannel : DEFAULT_AUTH_CHANNEL;
        dto.collectionMethodType = String.isNotBlank(r.collectionMethodType) ? r.collectionMethodType : DEFAULT_COLLECTION_METHOD;
        
        // Validación de identidad (valores por defecto)
        dto.identityValidationType = null;
        dto.identityValidationStatus = null;
        dto.identityValidationSource = null;
        dto.identityValidationResult = null;
        dto.identityValidationNoData = true;
        
        // IDs (null por defecto)
        dto.subjectId = null;
        dto.idIndividual = null;
        dto.idIdentityValidation = null;
        dto.idClient = null;
        dto.idAccountLR = null;
        
        // Compañías con autorizaciones dinámicas
        dto.companies = buildCompanies(r);
        
        return dto;
    }
    
    /** Construye la lista de compañías con sus tratamientos dinámicos. */
    @TestVisible
    private static List<WSHabeasDataExtendWrapper.CompanyDto> buildCompanies(Request r) {
        List<WSHabeasDataExtendWrapper.CompanyDto> companies = new List<WSHabeasDataExtendWrapper.CompanyDto>();
        
        // Seguro de Vida
        WSHabeasDataExtendWrapper.CompanyDto vida = new WSHabeasDataExtendWrapper.CompanyDto();
        vida.name = 'Seguro de Vida';
        vida.notEssentialFunctionalities = null;
        vida.medicalHistory = null;
        vida.generalProcessingData = r.generalProcessingDataVida != null ? r.generalProcessingDataVida : true;
        vida.generalCommercialOffer = r.generalCommercialOfferVida != null ? r.generalCommercialOfferVida : true;
        vida.dataMarketing = null;
        vida.authorization2300 = null;
        companies.add(vida);
        
        // ARL
        WSHabeasDataExtendWrapper.CompanyDto arl = new WSHabeasDataExtendWrapper.CompanyDto();
        arl.name = 'ARL';
        arl.notEssentialFunctionalities = null;
        arl.medicalHistory = null;
        arl.generalProcessingData = r.generalProcessingDataARL != null ? r.generalProcessingDataARL : true;
        arl.generalCommercialOffer = r.generalCommercialOfferARL != null ? r.generalCommercialOfferARL : true;
        arl.dataMarketing = null;
        arl.authorization2300 = null;
        companies.add(arl);
        
        // Seguros Generales
        WSHabeasDataExtendWrapper.CompanyDto generales = new WSHabeasDataExtendWrapper.CompanyDto();
        generales.name = 'Seguros Generales';
        generales.notEssentialFunctionalities = null;
        generales.medicalHistory = false;
        generales.generalProcessingData = r.generalProcessingDataGenerales != null ? r.generalProcessingDataGenerales : true;
        generales.generalCommercialOffer = r.generalCommercialOfferGenerales != null ? r.generalCommercialOfferGenerales : true;
        generales.dataMarketing = null;
        generales.authorization2300 = null;
        companies.add(generales);
        
        return companies;
    }
}