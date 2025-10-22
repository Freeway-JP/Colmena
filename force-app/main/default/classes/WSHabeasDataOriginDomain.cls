public with sharing class WSHabeasDataOriginDomain {
    public WSHabeasDataOriginDomain() {
    }

    //get Account by identification number and type
    public static Account getAccountByIdentifacacionNumberAndType(String identificationNumber, String identificationType) {
        if (String.isBlank(identificationNumber) || String.isBlank(identificationType))
            return null;
        List<Account> accountList = new List<Account>();
        if (String.isNotBlank(identificationNumber) && String.isNotBlank(identificationType)) {
            accountList = [
                SELECT Id, PersonIndividualId, CS_NumeroIdentificacionCP__pc, CS_TipoIdentificacionCP__pc
                FROM Account
                WHERE
                    (CS_NumeroIdentificacion__c = :identificationNumber
                    AND CS_TipoIdentificacion__c = :identificationType)
                    OR (CS_NumeroIdentificacionCP__pc = :identificationNumber
                    AND CS_TipoIdentificacionCP__pc = :identificationType)
                LIMIT 1
            ];
        }
        return accountList.isEmpty() ? null : accountList[0];
    }

    public static Account createAccount(WSHabeasDataExtendWrapper.HabeasDataDto request, Integer accountType) {
        Account newClient = new Account();
        //TODO: Validate when is legal account and when is natural person
        if (accountType == 1) {
            newClient.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
                .get(WSHabeasDataUtilities.RECORD_TYPE_NATURAL_PERSON)
                .getRecordTypeId();
        } else if (accountType == 2) {
            newClient.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
                .get(WSHabeasDataUtilities.RECORD_TYPE_LEGAL_ACCOUNT)
                .getRecordTypeId();
        }
        newClient.FirstName = validateNullString(request.firstName);
        newClient.MiddleName = validateNullString(request.secondName);
        newClient.LastName = validateNullString(request.lastName);
        newClient.Suffix = validateNullString(request.secondLastName);
        newClient.CS_TipoIdentificacionCP__pc = request.identityType;
        newClient.CS_NumeroIdentificacionCP__pc = request.identityNumber;
        newClient.PersonEmail = request.email;

        newClient.PersonMobilePhone = request.numberPhone;
        newClient.CS_Sexo__pc = request.sex;
        //Colmena Riesgos Laborales - 1, Colmena Seguros Vida - 2, Colmena Capitalizadora - 3, Colmena Seguros Generales - 4
        newClient.CS_Empresa_Colmena__c = WSHabeasDataUtilities.ACCOUNT_COMPANY;
        // Cuenta Prospecto, Cuenta Cliente, Cuenta Aliada
        newClient.CC_Tipo_de_Cuenta__c = WSHabeasDataUtilities.ACCOUNT_TYPE_ACCOUNT;

        insert newClient;

        //System.debug('Se Creo una cuenta:' + newClient.Id);
        //System.debug(System.JSON.serializePretty(newClient));

        return newClient;
    }

    public static Account createAccountRL(WSHabeasDataExtendWrapper.HabeasDataDto request, Integer accountType) {
        Account newClient = new Account();
        //TODO: Validate when is legal account and when is natural person
        if (accountType == 1) {
            newClient.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
                .get(WSHabeasDataUtilities.RECORD_TYPE_NATURAL_PERSON)
                .getRecordTypeId();
        } else if (accountType == 2) {
            newClient.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
                .get(WSHabeasDataUtilities.RECORD_TYPE_LEGAL_ACCOUNT)
                .getRecordTypeId();
        }
        newClient.Name =
            validateNullString(request.firstName) +
            validateNullString(request.secondName) +
            validateNullString(request.lastName) +
            validateNullString(request.secondLastName);
        newClient.CS_TipoIdentificacion__c = request.identityType;
        newClient.CS_NumeroIdentificacion__c = request.identityNumber;
        //newClient.PersonEmail = request.email;

        newClient.Phone = request.numberPhone;
        //Colmena Riesgos Laborales - 1, Colmena Seguros Vida - 2, Colmena Capitalizadora - 3, Colmena Seguros Generales - 4
        newClient.CS_Empresa_Colmena__c = WSHabeasDataUtilities.ACCOUNT_COMPANY;
        // Cuenta Prospecto, Cuenta Cliente, Cuenta Aliada
        newClient.CC_Tipo_de_Cuenta__c = WSHabeasDataUtilities.ACCOUNT_TYPE_ACCOUNT;

        insert newClient;

        return newClient;
    }

    public static String validateNullString(String value) {
        if (String.isEmpty(value) || value == null) {
            return '';
        } else {
            return value + ' ';
        }
    }

    public static Lead getLeadByIdentifacacionNumberAndType(String identificationNumber, String identificationType) {
        List<Lead> leadList = new List<Lead>();
        if (String.isNotBlank(identificationNumber) && String.isNotBlank(identificationType)) {
            leadList = [
                SELECT Id, FirstName, LastName, Email, IndividualId
                FROM Lead
                WHERE Numero_de_documento__c = :identificationNumber AND Tipo_de_documento__c = :identificationType AND IsConverted = FALSE
            ];
        }
        return leadList.isEmpty() ? null : leadList[0];
    }

    public static Lead getLeadByIdentifacacionNumberAndTypeEmp(String idNumber, String idType) {
        List<Lead> leadList = new List<Lead>();
        if (String.isNotBlank(idNumber) && String.isNotBlank(idType)) {
            leadList = [
                SELECT Id, FirstName, LastName, Email, IndividualId
                FROM Lead
                WHERE Numero_de_documento__c = :idNumber AND Tipo_de_documento__c = :idType AND IsConverted = FALSE
                // AND contactIdNumber__c = :idNumberEmp
                // AND contactIdType__c = :idTypeEmp
            ];
        }
        return leadList.isEmpty() ? null : leadList[0];
    }

    public static Lead createLead(WSHabeasDataExtendWrapper.HabeasDataDto request, Integer leadType) {
        Lead newLead = new Lead();
        newLead.Suffix = request.secondLastName;
        newLead.Email = request.email;
        newLead.MobilePhone = request.numberPhone;
        newLead.Genero__c = request.sex;
        if (leadType == 1) {
            //PERSONA NATURAL
            newLead.Tipo_de_documento__c = request.identityType;
            newLead.Numero_de_documento__c = request.identityNumber;
            newLead.TypePerson__c = WSHabeasDataUtilities.RECORD_TYPE_NATURAL_PERSON_LEAD;
            newLead.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get(WSHabeasDataUtilities.RECORD_TYPE_GENERAL_LEAD).getRecordTypeId();
            newLead.FirstName = validateNullStringLead(request.firstName);
            newLead.MiddleName = request.secondName;
            newLead.LastName = validateNullStringLead(request.lastName);
        } else if (leadType == 2) {
            //PERSONA JURIDICA
            //newLead.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get(WSHabeasDataUtilities.RECORD_TYPE_RL_LEAD).getRecordTypeId();
            newLead.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get(WSHabeasDataUtilities.RECORD_TYPE_GENERAL_LEAD).getRecordTypeId();
            newLead.Tipo_de_documento__c = request.identityType;
            newLead.Numero_de_documento__c = request.identityNumber;
            newLead.Company = request.lastName;
            //newLead.LegalRepresentativeEmail__c = request.email;
            newLead.FirstName = request.contactFirstName;
            newLead.LastName = request.contactLastName;
            newLead.TypePerson__c = WSHabeasDataUtilities.RECORD_TYPE_LEGAL_PERSON_LEAD;
            newLead.contactIdType__c = (String.isEmpty(request.contactIdType) ? null : request.contactIdType);
            newLead.contactIdNumber__c = (String.isEmpty(request.contactIdNumber) ? null : request.contactIdNumber);
            newLead.contactFirstName__c = (String.isEmpty(request.contactFirstName) ? null : request.contactFirstName);
            newLead.contactLastName__c = (String.isEmpty(request.contactLastName) ? null : request.contactLastName);
        }

        insert newLead;

        return newLead;
    }

    public static Contact getContactByIdentifacacionNumberAndType(String identificationNumber, String identificationType, Id idAccount) {
        List<Contact> contactList = new List<Contact>();
        if (String.isNotBlank(identificationNumber) && String.isNotBlank(identificationType) && String.isNotBlank(idAccount)) {
            contactList = [
                SELECT Id, FirstName, LastName, Email, IndividualId, AccountId
                FROM Contact
                WHERE
                    CS_NumeroIdentificacionCP__c = :identificationNumber
                    AND CS_TipoIdentificacionCP__c = :identificationType
                    AND AccountId = :idAccount
                    AND IsPersonAccount = FALSE
            ];
        }
        return contactList.isEmpty() ? null : contactList[0];
    }

    public static Contact createContact(WSHabeasDataExtendWrapper.HabeasDataDto request, Account newAccount) {
        Contact newContact = new Contact();
        newContact.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName()
            .get(WSHabeasDataUtilities.RECORD_TYPE_GENERAL_CONTACT)
            .getRecordTypeId();
        newContact.AccountId = newAccount.Id;
        if (WSHabeasDataUtilities.validateContactRequestData(request)) {
            newContact.FirstName = request.contactFirstName;
            newContact.LastName = request.contactLastName;
            newContact.CS_TipoIdentificacionCP__c = request.contactIdType;
            newContact.CS_NumeroIdentificacionCP__c = request.contactIdNumber;
        } else {
            newContact.FirstName = request.firstName;
            newContact.MiddleName = request.secondName;
            newContact.LastName = request.lastName;
            newContact.Suffix = request.secondLastName;
            newContact.CS_TipoIdentificacionCP__c = request.identityType;
            newContact.CS_NumeroIdentificacionCP__c = request.identityNumber;
        }

        newContact.Email = request.email;
        newContact.MobilePhone = request.numberPhone;
        newContact.CS_Sexo__c = request.sex;

        insert newContact;

        return newContact;
    }

    public static void getAuthorizationChannelConfig(WSHabeasDataExtendWrapper.HabeasDataDto request) {
        List<Autorization_Channels__mdt> mcs = Autorization_Channels__mdt.getAll().values();
        searchChannelConfig(mcs, request.authorizationChannel, request);
    }

    private static void searchChannelConfig(List<Autorization_Channels__mdt> mcs, String channel, WSHabeasDataExtendWrapper.HabeasDataDto request) {
        for (Autorization_Channels__mdt mc : mcs) {
            if (mc.ExternalName__c.equals(channel)) {
                request.channelType = mc.channelType__c;
                request.process = mc.process__c;
                request.businessCoverage = mc.businessCoverage__c;
                request.origin = mc.origin__c;
                request.collectionMethodType = mc.collectionMethodType__c;
            }
        }
    }

    public static Id validateIdentitySecurytyInfo(WSHabeasDataExtendWrapper.HabeasDataDto request) {
        if (request.identityValidationNoData == true) {
            return null;
        }

        Historial_de_Validacion__c objFound = getValidationHistoryObj(request);

        if (WSHabeasDataUtilities.IDENTITY_VALIDATION_SOURCE_MANUAL.equals(request.identityValidationSource)) {
            if (
                String.isEmpty(request.identityValidationSource) ||
                String.isEmpty(request.identityValidationStatus) ||
                String.isEmpty(request.identityValidationResult) ||
                String.isEmpty(request.identityValidationType)
            ) {
                return null;
            } else
                return createValidationHistory(request);
        }

        if (objFound != null) {
            request.idIdentityValidation = objFound.Id;
            return objFound.Relacion_Tarea_Historial_Validacion__c;
        }

        return null;
    }

    private static Historial_de_Validacion__c getValidationHistoryObj(WSHabeasDataExtendWrapper.HabeasDataDto request) {
        Historial_de_Validacion__c objFound = null;
        if (
            WSHabeasDataUtilities.CLIENTE_REPRESENTANTE_LEGAL.equals(request.dataUsePurpose) ||
            WSHabeasDataUtilities.PROSPECTO_REPRESENTANTE_LEGAL.equals(request.dataUsePurpose)
        ) {
            objFound = getValidationHistory(request.identityNumber, request.identityType);
        } else {
            objFound = getValidationHistory(request.identityNumber, request.identityType);
        }
        return objFound;
    }

    private static Historial_de_Validacion__c getValidationHistory(String identificationNumber, String identificationType) {
        List<Historial_de_Validacion__c> hvList = new List<Historial_de_Validacion__c>();
        if (String.isNotBlank(identificationNumber) && String.isNotBlank(identificationType)) {
            hvList = [
                SELECT Id, Relacion_Tarea_Historial_Validacion__c
                FROM Historial_de_Validacion__c
                WHERE Numero_de_identificacion__c = :identificationNumber AND Tipo_de_identificacion__c = :identificationType
                ORDER BY CreatedDate DESC
                LIMIT 1
            ];
        }
        return (hvList == null || hvList.isEmpty()) ? null : hvList[0];
    }

    private static Id createValidationHistory(WSHabeasDataExtendWrapper.HabeasDataDto request) {
        try {
            Relacion_Tarea_Historial_Validacion__c rthv = new Relacion_Tarea_Historial_Validacion__c();
            rthv.Name = 'Historial-' + request.firstName + '/' + request.lastName + '-' + Datetime.now().format();
            insert rthv;
            if (rthv != null) {
                Historial_de_Validacion__c hv = new Historial_de_Validacion__c();
                hv.Relacion_Tarea_Historial_Validacion__c = rthv.Id;
                hv.Estado__c = request.identityValidationStatus;
                hv.Mensaje__c = request.identityValidationResult;
                if (
                    request.dataUsePurpose.equals(WSHabeasDataUtilities.CLIENTE_REPRESENTANTE_LEGAL) ||
                    request.dataUsePurpose.equals(WSHabeasDataUtilities.PROSPECTO_REPRESENTANTE_LEGAL)
                ) {
                    hv.Numero_de_identificacion__c = request.contactIdNumber;
                    hv.Tipo_de_identificacion__c = request.contactIdType;
                } else {
                    hv.Numero_de_identificacion__c = request.identityNumber;
                    hv.Tipo_de_identificacion__c = request.identityType;
                }
                hv.tipo__c = request.identityValidationType;
                hv.Source__c = request.identityValidationSource;
                insert hv;
                request.idIdentityValidation = hv.Id;
            }
            return rthv.Id;
        } catch (Exception ex) {
            System.debug('Error creando el historial de validacion de identidad: ' + ex.getMessage());
            return null;
        }
    }

    public static List<HD_API_Rules__mdt> getBuisnessMetadataRules(String channel, List<String> buisiness, String dataUsePurpose) {
        if (String.isBlank(channel) || String.isBlank(dataUsePurpose) || buisiness == null || buisiness.isEmpty()) {
            return new List<HD_API_Rules__mdt>();
        }

        Set<String> brands = new Set<String>();
        brands.addAll(buisiness);
        if (brands.isEmpty()) {
            return null;
        }

        List<HD_API_Rules__mdt> rows = [
            SELECT
                DeveloperName,
                MasterLabel,
                authorizationChannel__c,
                dataUsePurpose__c,
                BusinessBrand__c,
                GeneralCommercialOffer__c,
                GeneralProcessingData__c,
                DataMarketing__c,
                MedicalHistory__c,
                Auth2300__c
            FROM HD_API_Rules__mdt
            WHERE authorizationChannel__c = :channel AND dataUsePurpose__c = :dataUsePurpose AND BusinessBrand__c IN :brands
            ORDER BY BusinessBrand__c
        ];
        return rows;
    }

    public static WSHabeasDataExtendWrapper.HabeasDataDto transformApiToControllerDto(
        WSHabeasDataAPIDto.HabeasDataDto request,
        List<HD_API_Rules__mdt> businessRules
    ) {
        if (!isValidApiPayload(request)) {
            return null;
        }

        WSHabeasDataExtendWrapper.HabeasDataDto controller = new WSHabeasDataExtendWrapper.HabeasDataDto();

        mapAccountSection(controller, request.account);
        mapConsentSection(controller, request.consent);

        businessRules = validateMissingGeneralDataMarketing(request, businessRules);

        List<WSHabeasDataExtendWrapper.CompanyDTO> companies = buildCompanies(
            businessRules,
            request.consent != null ? request.consent.authorization2300 : null
        );

        if (controller.companies == null) {
            controller.companies = new List<WSHabeasDataExtendWrapper.CompanyDTO>();
        }
        if (companies != null && !companies.isEmpty()) {
            controller.companies.addAll(companies);
        }

        return controller;
    }

    /**
     * @description Este metodo valida si se debe agregar las demas aseguradoras con Ofrecimiento comercial General.
     */
    @TestVisible
    private static List<HD_API_Rules__mdt> validateMissingGeneralDataMarketing(
        WSHabeasDataAPIDto.HabeasDataDto request,
        List<HD_API_Rules__mdt> businessRules
    ) {
        List<String> aseguradoras = new List<String>{ 'ARL', 'Seguro de Vida', 'Seguros Generales' };
        List<String> missing = obtenerFaltantes(aseguradoras, request.companies);

        Boolean addCompanies = false;
        for (HD_API_Rules__mdt rule : businessRules) {
            if (rule != null && rule.GeneralCommercialOffer__c) {
                addCompanies = true;
                break;
            }
        }

        if (addCompanies) {
            List<HD_API_Rules__mdt> missingRules = new List<HD_API_Rules__mdt>();
            for (String m : missing) {
                HD_API_Rules__mdt tempRule = new HD_API_Rules__mdt();
                tempRule.BusinessBrand__c = m;
                tempRule.authorizationChannel__c = request.consent.authorizationChannel;
                tempRule.dataUsePurpose__c = request.consent.dataUsePurpose;
                tempRule.DataMarketing__c = false;
                tempRule.MedicalHistory__c = false;
                tempRule.Auth2300__c = false;
                tempRule.GeneralCommercialOffer__c = true;
                tempRule.GeneralProcessingData__c = false;

                businessRules.add(tempRule);
            }
        }

        return businessRules;
    }

    /**
     * @description Devuelve los elementos de 'aseguradoras' que no están presentes en 'request'.
     */
    @TestVisible
    private static List<String> obtenerFaltantes(List<String> aseguradoras, List<String> request) {
        if (aseguradoras == null || aseguradoras.isEmpty() || request == null || request.isEmpty()) {
            return new List<String>();
        }

        Set<String> requestedLower = new Set<String>();
        for (String req : request) {
            requestedLower.add(req.toLowerCase());
        }

        List<String> missing = new List<String>();
        for (String aseguradora : aseguradoras) {
            if (!requestedLower.contains(aseguradora.toLowerCase())) {
                missing.add(aseguradora);
            }
        }

        return missing;
    }

    private static Boolean isValidApiPayload(WSHabeasDataAPIDto.HabeasDataDto req) {
        return (req != null && req.account != null && req.consent != null);
    }

    private static void mapAccountSection(WSHabeasDataExtendWrapper.HabeasDataDto target, WSHabeasDataAPIDto.AccountDto a) {
        if (target == null || a == null)
            return;

        target.firstName = a.firstName;
        target.secondName = a.secondName;
        target.lastName = a.lastName;
        target.secondLastName = a.secondLastName;
        target.identityType = a.identityType;
        target.identityNumber = a.identityNumber;
        target.email = a.email;
        target.numberPhone = a.numberPhone;
        target.sex = a.sex;

        target.contactFirstName = a.contactFirstName;
        target.contactLastName = a.contactLastName;
        target.contactIdType = a.contactIdType;
        target.contactIdNumber = a.contactIdNumber;
    }

    private static void mapConsentSection(WSHabeasDataExtendWrapper.HabeasDataDto target, WSHabeasDataAPIDto.ConsentDto c) {
        if (target == null || c == null)
            return;

        target.dataUsePurpose = c.dataUsePurpose;
        target.authorizationChannel = c.authorizationChannel;

        if (c.identityValidated != null) {
            target.identityValidationNoData = c.identityValidated.identityValidationNoData;
            target.identityValidationStatus = c.identityValidated.identityValidationStatus;
            target.identityValidationResult = c.identityValidated.identityValidationResult;
            target.identityValidationSource = c.identityValidated.identityValidationSource;
            target.identityValidationType = c.identityValidated.identityValidationType;
        }
    }

    private static List<WSHabeasDataExtendWrapper.CompanyDTO> buildCompanies(
        List<HD_API_Rules__mdt> rules,
        List<WSHabeasDataAPIDto.Auth2300> incomingAuth2300
    ) {
        List<WSHabeasDataExtendWrapper.CompanyDTO> out = new List<WSHabeasDataExtendWrapper.CompanyDTO>();
        if (rules == null || rules.isEmpty())
            return out;

        Boolean hasAuth2300Input = (incomingAuth2300 != null && !incomingAuth2300.isEmpty());

        for (HD_API_Rules__mdt rule : rules) {
            if (rule == null)
                continue;

            WSHabeasDataExtendWrapper.CompanyDTO company = new WSHabeasDataExtendWrapper.CompanyDTO();
            company.name = rule.BusinessBrand__c;
            company.medicalHistory = rule.MedicalHistory__c;
            company.dataMarketing = rule.DataMarketing__c;
            company.generalCommercialOffer = rule.GeneralCommercialOffer__c;
            company.generalProcessingData = rule.GeneralProcessingData__c;

            if (rule.Auth2300__c && hasAuth2300Input) {
                List<WSHabeasDataExtendWrapper.Auth2300> list2300 = toControllerAuth2300(incomingAuth2300);
                if (list2300 != null && !list2300.isEmpty()) {
                    if (company.authorization2300 == null) {
                        company.authorization2300 = new List<WSHabeasDataExtendWrapper.Auth2300>();
                    }
                    company.authorization2300.addAll(list2300);
                }
            }

            out.add(company);
        }
        return out;
    }

    private static List<WSHabeasDataExtendWrapper.Auth2300> toControllerAuth2300(List<WSHabeasDataAPIDto.Auth2300> input) {
        List<WSHabeasDataExtendWrapper.Auth2300> out = new List<WSHabeasDataExtendWrapper.Auth2300>();
        if (input == null || input.isEmpty())
            return out;

        for (WSHabeasDataAPIDto.Auth2300 a : input) {
            if (a == null)
                continue;
            WSHabeasDataExtendWrapper.Auth2300 x = new WSHabeasDataExtendWrapper.Auth2300();
            x.value = a.value;
            x.contactPointType = a.contactPointType;
            x.contactPoint = a.contactPoint;
            x.dataUsePurpose = a.dataUsePurpose;
            out.add(x);
        }
        return out;
    }

    private static String validateNullStringLead(String value) {
        if (String.isEmpty(value) || value == null) {
            return ' ';
        } else {
            return value;
        }
    }
}