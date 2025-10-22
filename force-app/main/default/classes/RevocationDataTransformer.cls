global with sharing class RevocationDataTransformer implements Callable {

    private static final String LIFE_INSURANCE = 'Seguro de Vida';
    private static final String ARL = 'ARL';
    private static final String GENERAL_INSURANCE = 'Seguros Generales';
    private static final String COMMERCIAL_OFFER_PURPOSE = 'Ofrecimiento Comercial-2300';
    private static final String PORTFOLIO_MANAGEMENT_PURPOSE = 'Gestión Cartera-2300';
    private static final String WHATSAPP_CONTACT = 'WhatsApp';
    private static final String EMAIL_CONTACT = 'correo electrónico';
    private static final String PHONE_CONTACT = 'celular';
    private static final String SMS_CONTACT = 'mensaje de texto';

    global Object call(String action, Map<String, Object> args) {
        Map<String, Object> input = (Map<String, Object>) args.get('input');
        Map<String, Object> output = (Map<String, Object>) args.get('output');
        Map<String, Object> options = (Map<String, Object>) args.get('options');
        return invokeMethod(action, input, output, options);
    }

    global Boolean invokeMethod(String methodName, Map<String, Object> inputMap, Map<String, Object> outMap, Map<String, Object> options) {
        Boolean result = true;
        try {
            if (methodName.equals('transformRevocationData')) {
                transformRevocationData(inputMap, outMap);
            } else {
                result = false;
            }
        } catch (Exception e) {
            outMap.put('error', true);
            outMap.put('message', e.getMessage());
            result = false;
        }
        return result;
    }

    public void transformRevocationData(Map<String, Object> inputMap, Map<String, Object> outMap) {
        Object groupedConsentsObj = inputMap.get('groupedConsents');

        if (groupedConsentsObj == null) {
            outMap.put('error', 'No grouped consents found');
            return;
        }

        // Manejar si viene como objeto único o como array
        List<Object> groupedConsentsList = new List<Object>();
        if (groupedConsentsObj instanceof List<Object>) {
            groupedConsentsList = (List<Object>) groupedConsentsObj;
        } else {
            groupedConsentsList.add(groupedConsentsObj);
        }

        if (groupedConsentsList.isEmpty()) {
            outMap.put('error', 'No grouped consents found');
            return;
        }

        // Procesar cada elemento de groupedConsents
        List<Map<String, Object>> transformedDataList = new List<Map<String, Object>>();

        for (Object consentObj : groupedConsentsList) {
            Map<String, Object> consentData = (Map<String, Object>) consentObj;
            Map<String, Object> habeasDataDTO = buildHabeasDataDTO(consentData);
            transformedDataList.add(habeasDataDTO);
        }

        outMap.put('transformedDataList', transformedDataList);
    }

    private Map<String, Object> buildHabeasDataDTO(Map<String, Object> consentData) {
        Map<String, Object> dto = new Map<String, Object>();

        String usePurpose = (String) consentData.get('UsePurpose');
        Boolean isRegular = usePurpose == 'Cliente' || usePurpose == 'Prospecto';
        Boolean isLegalRepresentative = usePurpose == 'Cliente Representante Legal' || usePurpose == 'Prospecto Representante Legal';

        // Determinar qué campos de identificación usar para identityType/identityNumber
        String identityType = isLegalRepresentative ?
            (String) consentData.get('IdentificationType_Emp') :
            (String) consentData.get('IdentificationType');
        String identityNumber = isLegalRepresentative ?
            (String) consentData.get('IdentificationNumber_Emp') :
            (String) consentData.get('IdentificationNumber');

        // Orden exacto según el ejemplo
        dto.put('subjectId', null);
        dto.put('sex', null);
        dto.put('secondName', isRegular ? consentData.get('MiddleName') : null);
        dto.put('secondLastName', isRegular ? consentData.get('Suffix') : null);
        dto.put('process', consentData.get('Process'));
        dto.put('origin', consentData.get('Origin'));
        dto.put('numberPhone', consentData.get('Phone'));
        dto.put('lastName', isRegular ? consentData.get('LastName') : consentData.get('EntityName'));
        dto.put('idIndividual', null);
        dto.put('idIdentityValidation', null);
        dto.put('identityValidationType', isRegular ? consentData.get('IndividualIdentificationType') : null);
        dto.put('identityValidationStatus', null);
        dto.put('identityValidationSource', null);
        dto.put('identityValidationResult', null);
        dto.put('identityValidationNoData', consentData.get('IdentityValidationNoData'));
        dto.put('identityType', identityType);
        dto.put('identityNumber', identityNumber);
        dto.put('idClient', null);
        dto.put('idAccountLR', null);
        dto.put('firstName', isRegular ? consentData.get('FirstName') : null);
        dto.put('email', consentData.get('Email'));
        dto.put('dataUsePurpose', usePurpose);
        dto.put('contactLastName', isLegalRepresentative ? consentData.get('LastName') : null);
        dto.put('contactIdType', isLegalRepresentative ? consentData.get('IndividualIdentificationType') : null);
        dto.put('contactIdNumber', isLegalRepresentative ? consentData.get('IndividualIdentificationNumber') : null);
        dto.put('contactFirstName', isLegalRepresentative ? consentData.get('FirstName') : null);

        // Procesar companies
        List<Object> authChecks = (List<Object>) consentData.get('AuthorizationChecks');
        dto.put('companies', buildCompanies(authChecks));

        dto.put('collectionMethodType', consentData.get('CollectionMethodType'));
        dto.put('channelType', consentData.get('ChannelType'));
        dto.put('businessCoverage', consentData.get('BusinessCoverage'));
        dto.put('authorizationChannel', consentData.get('AuthorizationChannel'));

        return dto;
    }

    private List<Map<String, Object>> buildCompanies(List<Object> authChecks) {
        List<Map<String, Object>> companies = new List<Map<String, Object>>();

        if (authChecks == null) {
            return companies;
        }

        for (Object authCheckObj : authChecks) {
            Map<String, Object> authCheck = (Map<String, Object>) authCheckObj;
            String businessBrand = (String) authCheck.get('BusinessBrand');

            Map<String, Object> company = new Map<String, Object>();
            company.put('notEssentialFunctionalities', null);
            company.put('name', businessBrand);
            company.put('medicalHistory', authCheck.get('MedicalHistory'));
            company.put('generalProcessingData', authCheck.get('GeneralProcessingData'));
            company.put('dataMarketing', authCheck.get('GeneralDataMarketing'));
            company.put('generalCommercialOffer', authCheck.get('GeneralCommercialOffer'));

            // Construir authorization2300
            List<Map<String, Object>> authorization2300 = new List<Map<String, Object>>();

            // Procesar CommercialOffering2300 primero
            Map<String, Object> commercialData = (Map<String, Object>) authCheck.get('CommercialOffering2300');
            if (commercialData != null) {
                authorization2300.addAll(buildAuthorization2300List(commercialData, COMMERCIAL_OFFER_PURPOSE));
            }

            // Procesar PortfolioManagement2300 después
            Map<String, Object> portfolioData = (Map<String, Object>) authCheck.get('PortfolioManagement2300');
            if (portfolioData != null) {
                authorization2300.addAll(buildAuthorization2300List(portfolioData, PORTFOLIO_MANAGEMENT_PURPOSE));
            }

            company.put('authorization2300', authorization2300);
            companies.add(company);
        }

        return companies;
    }

    private List<Map<String, Object>> buildAuthorization2300List(Map<String, Object> data, String purpose) {
        List<Map<String, Object>> authList = new List<Map<String, Object>>();

        // Determinar qué campos usar según el purpose
        Boolean isCommercial = purpose == COMMERCIAL_OFFER_PURPOSE;
        String whatsappField = isCommercial ? 'WhatsapppCO' : 'WhatsapppPM';
        String emailField = isCommercial ? 'EmailCO' : 'EmailPM';
        String phoneField = isCommercial ? 'CelularCO' : 'CelularPM';
        String smsField = isCommercial ? 'SmsCO' : 'SmsPM';

        // WhatsApp - siempre incluir incluso si es false
        Boolean whatsappValue = (Boolean) data.get(whatsappField);
        authList.add(createAuth2300Entry(
            WHATSAPP_CONTACT,
            purpose,
            null,
            whatsappValue != null ? whatsappValue : false
        ));

        // Email - siempre incluir incluso si es false
        Boolean emailValue = (Boolean) data.get(emailField);
        authList.add(createAuth2300Entry(
            EMAIL_CONTACT,
            purpose,
            null,
            emailValue != null ? emailValue : false
        ));

        // Phone (Celular) - siempre incluir incluso si es false
        Boolean phoneValue = (Boolean) data.get(phoneField);
        authList.add(createAuth2300Entry(
            PHONE_CONTACT,
            purpose,
            null,
            phoneValue != null ? phoneValue : false
        ));

        // SMS - siempre incluir incluso si es false
        Boolean smsValue = (Boolean) data.get(smsField);
        authList.add(createAuth2300Entry(
            SMS_CONTACT,
            purpose,
            null,
            smsValue != null ? smsValue : false
        ));

        return authList;
    }

    private Map<String, Object> createAuth2300Entry(String contactType, String purpose, String contactPoint, Boolean value) {
        Map<String, Object> entry = new Map<String, Object>();
        entry.put('value', value);
        entry.put('dataUsePurpose', purpose);
        entry.put('contactPointType', contactType);
        entry.put('contactPoint', contactPoint);
        return entry;
    }
}