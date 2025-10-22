global without sharing class WSAuthorizationProcessAction implements Callable {
    
    // Constants
    private static final String TRANSFORM_DATA_METHOD = 'transformData';
    private static final String LIFE_INSURANCE_COMPANY = 'Seguro de Vida';
    private static final String ARL_COMPANY = 'ARL';
    private static final String GENERAL_INSURANCE_COMPANY = 'Seguros Generales';
    private static final String COMMERCIAL_OFFER_PURPOSE = 'Ofrecimiento Comercial-2300';
    private static final String PORTFOLIO_MANAGEMENT_PURPOSE = 'Gestión Cartera-2300';
    
    // Contact types
    private static final String WHATSAPP_CONTACT = 'WhatsApp';
    private static final String EMAIL_CONTACT = 'correo electrónico';
    private static final String PHONE_CONTACT = 'celular';
    private static final String SMS_CONTACT = 'mensaje de texto';
    
    // Record types
    private static final String CONTACT_TYPE = 'Contact';
    
    // Inner class for company configuration
    private class CompanyConfig {
        String name;
        String suffix;
        String medicalHistoryField;
        String dataMarketingField;
        String generalCommercialOfferField;
        String generalProcessingDataField;
        
        CompanyConfig(String name, String suffix, String medicalHistoryField, 
                     String dataMarketingField, String generalCommercialOfferField, 
                     String generalProcessingDataField) {
            this.name = name;
            this.suffix = suffix;
            this.medicalHistoryField = medicalHistoryField;
            this.dataMarketingField = dataMarketingField;
            this.generalCommercialOfferField = generalCommercialOfferField;
            this.generalProcessingDataField = generalProcessingDataField;
        }
    }
    
    public Object call(String action, Map<String, Object> args) {
        Map<String, Object> input = (Map<String, Object>) args.get('input');
        Map<String, Object> output = (Map<String, Object>) args.get('output');
        Map<String, Object> options = (Map<String, Object>) args.get('options');
        return invokeMethod(action, input, output, options);
    }
    
    private Boolean invokeMethod(String methodName, Map<String, Object> inputMap, Map<String, Object> outMap, Map<String, Object> options) {
        Boolean result = true;
        try {
            if (methodName.equalsIgnoreCase(TRANSFORM_DATA_METHOD)) {
                transformDataMethod(inputMap, outMap, options);
            } else {
                outMap.put('result', '');
            }
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'WSAuthorizationProcessAction - Error in invokeMethod: ' + e.getMessage());
            outMap.put('error', e.getMessage());
            return false;
        }
        return result;
    } 
    
    public void transformDataMethod(Map<String, Object> input, Map<String, Object> outMap, Map<String, Object> options) {
        if (!isValidInput(input)) {
            outMap.put('error', 'Invalid input parameters');
            return;
        }
        
        try {
            WSHabeasDataExtendWrapper.HabeasDataDto habeasRequest = createHabeasDataRequest(input);
            System.debug('WSAuthorizationProcessAction - HabeasDataRequest: ' + JSON.serializePretty(habeasRequest));
            
            WSHabeasDataService habeasService = new WSHabeasDataService();
            WSHabeasDataExtendWrapper.HabeasDataResponseDto habeasResponse = habeasService.processAuth_V2(habeasRequest);
            
            outMap.put('result', createResponseMap(habeasResponse));
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'WSAuthorizationProcessAction - Error in transformDataMethod: ' + e.getMessage());
            outMap.put('error', 'Processing error: ' + e.getMessage());
        }
    }

    private WSHabeasDataExtendWrapper.HabeasDataDto createHabeasDataRequest(Map<String, Object> input) {
        Map<String, Object> generalInfo = (Map<String, Object>) input.get('GeneralInformation');
        Map<String, Object> identityValidationInfo = (Map<String, Object>) input.get('IdentityValidation');
        Map<String, Object> channelInfo = (Map<String, Object>) input.get('Channel');
        String typeRecord = (String) input.get('TypeRecord');
        
        WSHabeasDataExtendWrapper.HabeasDataDto request = new WSHabeasDataExtendWrapper.HabeasDataDto();
        
        // Mapear campos básicos directamente
        if ((String) generalInfo.get('UsePurpose') == 'Cliente Representante Legal' || (String) generalInfo.get('UsePurpose') == 'Prospecto Representante Legal') {
            request.lastName = (String) generalInfo.get('CompanyName');
            request.email = (String) generalInfo.get('ContactEmail');
            request.numberPhone = (String) generalInfo.get('ContactMobilePhone');
        } else {
            request.firstName = (String) generalInfo.get('FirstName');
            request.secondName = (String) generalInfo.get('MiddleName');
            request.lastName = (String) generalInfo.get('LastName');
            request.secondLastName = (String) generalInfo.get('Suffix');
            request.email = (String) generalInfo.get('Email');
            request.numberPhone = (String) generalInfo.get('MobilePhone');
        }
        request.identityType = (String) generalInfo.get('IdentificationType');
        request.identityNumber = (String) generalInfo.get('IdentificationNumber');
        request.sex = (String) generalInfo.get('Sexo');
        request.dataUsePurpose = (String) generalInfo.get('UsePurpose');
        request.authorizationChannel = (String) generalInfo.get('authorizationChannel');
        request.contactFirstName = (String) generalInfo.get('ContactName');
        request.contactLastName = (String) generalInfo.get('ContactLastName');
        request.contactIdType = (String) generalInfo.get('ContactIdentificationType');
        request.contactIdNumber = (String) generalInfo.get('ContactIdentificationNumber');
        
        // Mapear campos de validación de identidad directamente
        request.identityValidationNoData = (Boolean) identityValidationInfo.get('ValidateIdentityWhitoutData');
        request.identityValidationStatus = (String) identityValidationInfo.get('Status');
        request.identityValidationResult = (String) identityValidationInfo.get('Result');
        request.identityValidationSource = (String) identityValidationInfo.get('Origin');
        request.identityValidationType = (String) identityValidationInfo.get('IdentificationTypeHistory');
        
        // Mapear campos del canal
        if (channelInfo != null) {
            request.channelType = (String) channelInfo.get('channelType');
            request.process = (String) channelInfo.get('process');
            request.businessCoverage = (String) channelInfo.get('businessCoverage');
            request.origin = (String) channelInfo.get('origin');
            request.collectionMethodType = (String) channelInfo.get('collectionMethodType');
        }
        
        // Procesar companies directamente al DTO
        request.companies = processCompaniesDirectly(input);
        
        // request.subjectId = ?;
        // request.idClient = ?;
        // request.idIndividual = ?;
        
        return request;
    }

    private List<WSHabeasDataExtendWrapper.CompanyDTO> processCompaniesDirectly(Map<String, Object> input) {
        List<WSHabeasDataExtendWrapper.CompanyDTO> companies = new List<WSHabeasDataExtendWrapper.CompanyDTO>();
        
        // Obtener los nodos, manejando cadenas vacías como null
        Map<String, Object> lifeInsurance = getMapFromObject(input.get('LifeInsurance'));
        Map<String, Object> arl = getMapFromObject(input.get('ARL'));
        Map<String, Object> general = getMapFromObject(input.get('General'));
        
        // Aplicar validación para GeneralCommercialOffer en nodos null
        applyGeneralCommercialOfferValidation(input);
        
        // Actualizar referencias después de la validación
        lifeInsurance = getMapFromObject(input.get('LifeInsurance'));
        arl = getMapFromObject(input.get('ARL'));
        general = getMapFromObject(input.get('General'));
        
        // Procesar LifeInsurance - incluir si tiene algún valor relevante definido
        if (lifeInsurance != null && shouldProcessCompany(lifeInsurance, 'AuthorizeLifeInsurance', 'GeneralCommercialOfferLI')) {
            companies.add(processLifeInsuranceDTO(lifeInsurance));
        }

        // Procesar ARL - incluir si tiene algún valor relevante definido
        if (arl != null && shouldProcessCompany(arl, 'AuthorizeARL', 'GeneralCommercialOfferARL')) {
            companies.add(processARLDTO(arl));
        }

        // Procesar General (Seguros Generales) - incluir si tiene algún valor relevante definido
        if (general != null && shouldProcessCompany(general, 'AuthorizeGeneral', 'GeneralCommercialOfferGeneral')) {
            companies.add(processGeneralDTO(general));
        }
        
        return companies;
    }

    private Map<String, Object> getMapFromObject(Object obj) {
        if (obj == null || obj instanceof String && String.isBlank((String)obj)) {
            return null;
        }
        return (Map<String, Object>) obj;
    }

    private void applyGeneralCommercialOfferValidation(Map<String, Object> input) {
        Map<String, Object> lifeInsurance = getMapFromObject(input.get('LifeInsurance'));
        Map<String, Object> arl = getMapFromObject(input.get('ARL'));
        Map<String, Object> general = getMapFromObject(input.get('General'));

        Boolean hasGeneralCommercialOfferDefined = false;
        Boolean generalCommercialOfferValue = false;

        // Verificar si alguno de los nodos no-null tiene GeneralCommercialOffer definido (true o false)
        if (lifeInsurance != null && lifeInsurance.get('GeneralCommercialOfferLI') != null) {
            hasGeneralCommercialOfferDefined = true;
            generalCommercialOfferValue = (Boolean)lifeInsurance.get('GeneralCommercialOfferLI');
        }
        if (arl != null && arl.get('GeneralCommercialOfferARL') != null) {
            hasGeneralCommercialOfferDefined = true;
            generalCommercialOfferValue = (Boolean)arl.get('GeneralCommercialOfferARL');
        }
        if (general != null && general.get('GeneralCommercialOfferGeneral') != null) {
            hasGeneralCommercialOfferDefined = true;
            generalCommercialOfferValue = (Boolean)general.get('GeneralCommercialOfferGeneral');
        }

        // Si alguno tiene GeneralCommercialOffer definido, crear los nodos faltantes con el mismo valor
        if (hasGeneralCommercialOfferDefined) {
            if (lifeInsurance == null) {
                lifeInsurance = createDefaultCompanyNode(input, 'LifeInsurance', 'GeneralCommercialOfferLI', generalCommercialOfferValue);
                input.put('LifeInsurance', lifeInsurance);
            }
            if (arl == null) {
                arl = createDefaultCompanyNode(input, 'ARL', 'GeneralCommercialOfferARL', generalCommercialOfferValue);
                input.put('ARL', arl);
            }
            if (general == null) {
                general = createDefaultCompanyNode(input, 'General', 'GeneralCommercialOfferGeneral', generalCommercialOfferValue);
                input.put('General', general);
            }
        }
    }

    private Map<String, Object> createDefaultCompanyNode(Map<String, Object> input, String companyType, String generalCommercialOfferField, Boolean generalCommercialOfferValue) {
        Map<String, Object> companyNode = new Map<String, Object>();

        // Obtener el nodo original del input si existe (podría ser una cadena vacía)
        Object originalNode = input.get(companyType);
        if (originalNode != null && originalNode instanceof Map<String, Object>) {
            // Si ya existe como Map, copiamos todos sus valores
            Map<String, Object> originalMap = (Map<String, Object>) originalNode;
            companyNode.putAll(originalMap);
        }

        // Establecer GeneralCommercialOffer con el valor determinado
        companyNode.put(generalCommercialOfferField, generalCommercialOfferValue);

        return companyNode;
    }

    private Boolean shouldProcessCompany(Map<String, Object> companyData, String authorizeField, String generalCommercialOfferField) {
        // Incluir si AuthorizeXXX es true
        if ((Boolean)companyData.get(authorizeField) == true) {
            return true;
        }

        // Incluir si GeneralCommercialOfferXXX está definido (true o false)
        if (companyData.get(generalCommercialOfferField) != null) {
            return true;
        }

        // Incluir si tiene otros campos relevantes definidos (campos de configuración de la compañía)
        return hasRelevantCompanyData(companyData);
    }

    private Boolean hasRelevantCompanyData(Map<String, Object> companyData) {
        // Lista de campos que indican que la compañía tiene datos relevantes
        List<String> relevantFields = new List<String>{
            'MedicalHistoryLI', 'DataMarketingLI', 'ProcessingGeneralDataLI',
            'MedicalHistoryARL', 'DataMarketingARL', 'ProcessingGeneralDataARL',
            'DataMarketingGeneral', 'ProcessingGeneralDataGeneral',
            'CommercialOfferSectionLI', 'PortfolioManagementSectionLI',
            'CommercialOfferSectionARL', 'PortfolioManagementSectionARL',
            'CommercialOfferSectionGeneral', 'PortfolioManagementSectionGeneral'
        };

        for (String field : relevantFields) {
            if (companyData.get(field) != null) {
                return true;
            }
        }

        return false;
    }

    private WSHabeasDataExtendWrapper.CompanyDTO processLifeInsuranceDTO(Map<String, Object> lifeInsurance) {
        CompanyConfig config = new CompanyConfig(
            LIFE_INSURANCE_COMPANY,
            'LI',
            'MedicalHistoryLI',
            'DataMarketingLI',
            'GeneralCommercialOfferLI',
            'ProcessingGeneralDataLI'
        );
        return processCompanyDTO(lifeInsurance, config);
    }

    private WSHabeasDataExtendWrapper.CompanyDTO processARLDTO(Map<String, Object> arl) {
        CompanyConfig config = new CompanyConfig(
            ARL_COMPANY,
            'ARL',
            'MedicalHistoryARL',
            'DataMarketingARL',
            'GeneralCommercialOfferARL',
            'ProcessingGeneralDataARL'
        );
        return processCompanyDTO(arl, config);
    }

    private WSHabeasDataExtendWrapper.CompanyDTO processGeneralDTO(Map<String, Object> general) {
        CompanyConfig config = new CompanyConfig(
            GENERAL_INSURANCE_COMPANY,
            'General',
            null, // No medical history for General
            'DataMarketingGeneral',
            'GeneralCommercialOfferGeneral',
            'ProcessingGeneralDataGeneral'
        );
        return processCompanyDTO(general, config);
    }
    
    private WSHabeasDataExtendWrapper.CompanyDTO processCompanyDTO(Map<String, Object> companyData, CompanyConfig config) {
        WSHabeasDataExtendWrapper.CompanyDTO company = new WSHabeasDataExtendWrapper.CompanyDTO();
        
        company.name = config.name;
        company.medicalHistory = config.medicalHistoryField != null ? 
            (Boolean) companyData.get(config.medicalHistoryField) : false;
        company.dataMarketing = (Boolean) companyData.get(config.dataMarketingField);
        company.generalCommercialOffer = (Boolean) companyData.get(config.generalCommercialOfferField);
        company.generalProcessingData = (Boolean) companyData.get(config.generalProcessingDataField);
        
        // Process authorization2300 sections
        String commercialOfferSection = 'CommercialOfferSection' + config.suffix;
        String portfolioManagementSection = 'PortfolioManagementSection' + config.suffix;
        
        if (companyData.get(commercialOfferSection) != null || companyData.get(portfolioManagementSection) != null) {
            company.authorization2300 = new List<WSHabeasDataExtendWrapper.Auth2300>();
            
            Map<String, Object> commercialOffer = (Map<String, Object>) companyData.get(commercialOfferSection);
            if (commercialOffer != null) {
                company.authorization2300.addAll(processCommercialOfferSectionDTO(commercialOffer, config.suffix));
            }
            
            Map<String, Object> portfolioManagement = (Map<String, Object>) companyData.get(portfolioManagementSection);
            if (portfolioManagement != null) {
                company.authorization2300.addAll(processPortfolioManagementSectionDTO(portfolioManagement, config.suffix));
            }
        }
        
        return company;
    }
    
    private Boolean isValidInput(Map<String, Object> input) {
        return input != null && 
               input.get('GeneralInformation') != null && 
               input.get('IdentityValidation') != null;
    }

    private List<WSHabeasDataExtendWrapper.Auth2300> processCommercialOfferSectionDTO(Map<String, Object> section, String suffix) {
        return processContactSection(section, suffix, COMMERCIAL_OFFER_PURPOSE, false);
    }

    private List<WSHabeasDataExtendWrapper.Auth2300> processPortfolioManagementSectionDTO(Map<String, Object> section, String suffix) {
        return processContactSection(section, suffix, PORTFOLIO_MANAGEMENT_PURPOSE, true);
    }
    
    private List<WSHabeasDataExtendWrapper.Auth2300> processContactSection(Map<String, Object> section, String suffix, String purpose, Boolean isPortfolio) {
        List<WSHabeasDataExtendWrapper.Auth2300> authorizations = new List<WSHabeasDataExtendWrapper.Auth2300>();
        String prefix = isPortfolio ? 'Portfolio' : '';

        List<ContactTypeMapping> contactTypes = new List<ContactTypeMapping>{
            new ContactTypeMapping('WhatsApp', WHATSAPP_CONTACT),
            new ContactTypeMapping('Email', EMAIL_CONTACT),
            new ContactTypeMapping('Phone', PHONE_CONTACT),
            new ContactTypeMapping('SMS', SMS_CONTACT)
        };

        for (ContactTypeMapping mapping : contactTypes) {
            String fieldName = mapping.fieldPrefix + prefix + suffix;
            String valueFieldName = fieldName + 'Value';
            Boolean fieldValue = (Boolean)section.get(fieldName);

            if (fieldValue == true) {
                // Si el campo está en true, llenar el valor normalmente
                authorizations.add(createAuth2300DTO(
                    purpose,
                    mapping.contactType,
                    (String)section.get(valueFieldName),
                    true
                ));
            } else if (fieldValue == false) {
                // Si el campo está en false, no llenar el valor (pasar null)
                authorizations.add(createAuth2300DTO(
                    purpose,
                    mapping.contactType,
                    null,
                    false
                ));
            }
        }

        return authorizations;
    }
    
    private class ContactTypeMapping {
        String fieldPrefix;
        String contactType;
        
        ContactTypeMapping(String fieldPrefix, String contactType) {
            this.fieldPrefix = fieldPrefix;
            this.contactType = contactType;
        }
    }

    private WSHabeasDataExtendWrapper.Auth2300 createAuth2300DTO(String purpose, String contactType, String contactPoint, Boolean value) {
        WSHabeasDataExtendWrapper.Auth2300 authDTO = new WSHabeasDataExtendWrapper.Auth2300();
        authDTO.dataUsePurpose = purpose;
        authDTO.contactPointType = contactType;
        authDTO.contactPoint = contactPoint;
        authDTO.value = value;
        return authDTO;
    }

    private Map<String, Object> createResponseMap(WSHabeasDataExtendWrapper.HabeasDataResponseDto response) {
        Map<String, Object> responseMap = new Map<String, Object>();
        responseMap.put('status', response.status);
        responseMap.put('error', response.error);
        responseMap.put('responseCode', response.responseCode);
        responseMap.put('message', response.message);
        return responseMap;
    }
}