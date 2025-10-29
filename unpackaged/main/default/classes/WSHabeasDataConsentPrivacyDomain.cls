public without sharing class WSHabeasDataConsentPrivacyDomain {
    List<BusinessBrand> businessBrandList = new List<BusinessBrand>();
    List<DataUsePurpose> dataUsePurposeList = new List<DataUsePurpose>();
    List<EngagementChannelType> engagementChannelTypeList = new List<EngagementChannelType>();

    public WSHabeasDataConsentPrivacyDomain() {
        businessBrandList = getAllBusinessBrands();
        dataUsePurposeList = getAllDataUsePurposes();
        engagementChannelTypeList = getAllEngagementChannelTypes();
    }

    public Individual createIndividual(WSHabeasDataExtendWrapper.HabeasDataDto request, Datetime registerTime) {
        Individual newRecordInd = new Individual();
        if (request.idClient != null) {
            newRecordInd = buildIndividualObject(request, registerTime);

            upsert newRecordInd Id;

            return newRecordInd;
        } else {
            return null;
        }
    }

    private Individual buildIndividualObject(WSHabeasDataExtendWrapper.HabeasDataDto request, Datetime registerTime) {
        Individual ind = new Individual();
        if (isLegalPerson(request)) {
            ind.FirstName = null;
            ind.MiddleName = null;
            ind.Suffix = null;
            ind.Id = validateIndividualIdEmp(request);
            ind.LastName = validateNullString(request.contactFirstName) + validateNullString(request.contactLastName);
            ind.CS_TipoIdentificacion__c = request.contactIdType;
            ind.CS_NumeroIdentificacion__c = request.contactIdNumber;
        } else {
            ind.Id = validateIndividualId(request);
            ind.FirstName = validateNullString(request.firstName);
            ind.MiddleName = validateNullString(request.secondName);
            ind.LastName = validateNullString(request.lastName);
            ind.Suffix = validateNullString(request.secondLastName);
            ind.CS_TipoIdentificacion__c = request.identityType;
            ind.CS_NumeroIdentificacion__c = request.identityNumber;
        }

        return ind;
    }

    private Id validateIndividualId(WSHabeasDataExtendWrapper.HabeasDataDto request) {
        if (request.idIndividual == null) {
            return getIndividualByIdentificacionAndNumber(request.identityNumber, request.identityType);
        }
        return request.idIndividual;
    }

    private Id validateIndividualIdEmp(WSHabeasDataExtendWrapper.HabeasDataDto request) {
        if (request.idIndividual == null) {
            return getIndividualByIdentificacionAndNumber(request.contactIdNumber, request.contactIdType);
        }
        return request.idIndividual;
    }

    private Id getIndividualByIdentificacionAndNumber(String identificationNumber, String identificationType) {
        List<Individual> objList = new List<Individual>();
        if (String.isNotBlank(identificationNumber) && String.isNotBlank(identificationType)) {
            objList = [
                SELECT Id
                FROM Individual
                WHERE
                    CS_NumeroIdentificacion__c = :identificationNumber
                    AND CS_TipoIdentificacion__c = :identificationType
                    AND CS_TipoIdentificacion_Emp__c = NULL
                    AND CS_NumeroIdentificacion_Emp__c = NULL
                LIMIT 1
            ];
        }
        return objList.isEmpty() ? null : objList[0].Id;
    }

    private Boolean validateBooleanNull(Boolean value) {
        if (value == null) {
            return false;
        }
        return value;
    }

    public void createPartyConsentHistory(WSHabeasDataExtendWrapper.HabeasDataDto request, Datetime registerTime) {
        List<PartyConsent> pcList = new List<PartyConsent>();
        Id dataUsePurposeId = getDataUsePurposeIdByName(request.dataUsePurpose);
        List<PartyConsent> oldPartyConsentList = changeStatusPartyConsent(request, dataUsePurposeId);
        if (!WSHabeasDataUtilities.NOV_PROCESS.equals(request.process) && oldPartyConsentList.size() > 0) {
            request.companies = preProcessCompaniesForSF(request, oldPartyConsentList);
            List<WSHabeasDataExtendWrapper.CompanyDTO> missingCompanies = obtenerFaltantesPartyConsent(request, oldPartyConsentList);
            request.companies = missingCompanies;
            for (WSHabeasDataExtendWrapper.CompanyDTO company : missingCompanies) {
                pcList.add(createPartyConsentElements(request, company, registerTime));
            }
        } else {
            for (WSHabeasDataExtendWrapper.CompanyDTO company : request.companies) {
                pcList.add(createPartyConsentElements(request, company, registerTime));
            }
        }

        insert pcList;
    }

    @TestVisible
    private List<PartyConsent> changeStatusPartyConsent(WSHabeasDataExtendWrapper.HabeasDataDto request, Id dataUsePurposeId) {
        List<PartyConsent> pcList = new List<PartyConsent>();
        if (isLegalPerson(request)) {
            pcList = getPartyConsentActiveByIndividualIdEmp(request, dataUsePurposeId);
        } else {
            pcList = getPartyConsentActiveByIndividualId(request, dataUsePurposeId);
        }
        updatePartyConsentStatus(pcList);
        return pcList;
    }

    public void assignIndividualToAuthSubject(WSHabeasDataExtendWrapper.HabeasDataDto request) {
        if (request.idIndividual != null && request.idClient != null) {
            String type = request.dataUsePurpose;
            if (WSHabeasDataUtilities.CLIENTE.equals(type)) {
                Account updateAcc = new account();
                updateAcc.Id = request.IdClient;
                updateAcc.PersonIndividualId = request.idIndividual;
                updateAcc.Individual_Report__c = request.idIndividual;
                update updateAcc;
            } else if (WSHabeasDataUtilities.CLIENTE_REPRESENTANTE_LEGAL.equals(type)) {
                Contact updateContact = new Contact();
                updateContact.Id = request.IdClient;
                updateContact.IndividualId = request.idIndividual;
                update updateContact;
            } else if (WSHabeasDataUtilities.PROSPECTO.equals(type)) {
                Lead updateLead = new Lead();
                updateLead.Id = request.IdClient;
                updateLead.IndividualId = request.idIndividual;
                update updateLead;
            } else if (WSHabeasDataUtilities.PROSPECTO_REPRESENTANTE_LEGAL.equals(type)) {
                Lead updateLead = new Lead();
                updateLead.Id = request.IdClient;
                updateLead.IndividualId = request.idIndividual;
                update updateLead;
            }
        }
    }

    public ContactPointEmail getCreateContactPointEmail(WSHabeasDataExtendWrapper.HabeasDataDto request) {
        ContactPointEmail emailClient = getContactPointEmails(request);
        if (emailClient == null) {
            emailClient = new ContactPointEmail();
            emailClient.EmailAddress = request.email;
            emailClient.ParentId = request.idIndividual;
            if (isLegalPerson(request)) {
                emailClient.ClientIdentityNumber__c = request.contactIdNumber;
            } else {
                emailClient.ClientIdentityNumber__c = request.identityNumber;
            }
            insert emailClient;
        }
        return emailClient;
    }

    public ContactPointPhone getCreateContactPointPhone(WSHabeasDataExtendWrapper.HabeasDataDto request) {
        ContactPointPhone phoneClient = getContactPointPhone(request);
        if (phoneClient == null) {
            phoneClient = new ContactPointPhone();
            phoneClient.TelephoneNumber = request.numberPhone;
            phoneClient.ParentId = request.idIndividual;
            if (isLegalPerson(request)) {
                phoneClient.ClientIdentityNumber__c = request.contactIdNumber;
            } else {
                phoneClient.ClientIdentityNumber__c = request.identityNumber;
            }
            insert phoneClient;
        }
        return phoneClient;
    }

    private ContactPointEmail getContactPointEmails(WSHabeasDataExtendWrapper.HabeasDataDto request) {
        if (String.isBlank(request.email))
            return null;
        List<ContactPointEmail> cpe = new List<ContactPointEmail>();
        if (isLegalPerson(request)) {
            cpe = [
                SELECT Id, ParentId
                FROM ContactPointEmail
                WHERE Name = :request.email AND ClientIdentityNumber__c = :request.contactIdNumber
                LIMIT 1
            ];
        } else {
            cpe = [
                SELECT Id, ParentId
                FROM ContactPointEmail
                WHERE Name = :request.email AND ClientIdentityNumber__c = :request.identityNumber
                LIMIT 1
            ];
        }

        return (cpe != null && !cpe.isEmpty()) ? cpe[0] : null;
    }

    private ContactPointPhone getContactPointPhone(WSHabeasDataExtendWrapper.HabeasDataDto request) {
        if (String.isBlank(request.numberPhone))
            return null;
        List<ContactPointPhone> cpe = new List<ContactPointPhone>();

        if (isLegalPerson(request)) {
            cpe = [
                SELECT Id, ParentId
                FROM ContactPointPhone
                WHERE Name = :request.numberPhone AND ClientIdentityNumber__c = :request.contactIdNumber
                LIMIT 1
            ];
        } else {
            cpe = [
                SELECT Id, ParentId
                FROM ContactPointPhone
                WHERE Name = :request.numberPhone AND ClientIdentityNumber__c = :request.identityNumber
                LIMIT 1
            ];
        }
        return (cpe != null && !cpe.isEmpty()) ? cpe[0] : null;
    }

    private String joinContactPointTypes(List<WSHabeasDataExtendWrapper.Auth2300> auths, String dataUsePurpose) {
        if (auths == null || auths.isEmpty())
            return null;
        List<String> parts = new List<String>();
        Set<String> seen = new Set<String>(); // opcional: dedup

        for (WSHabeasDataExtendWrapper.Auth2300 auth : auths) {
            if (auth != null && !String.isBlank(auth.contactPointType) && auth.value && dataUsePurpose.equals(auth.dataUsePurpose)) {
                String v = auth.contactPointType.trim();
                if (!seen.contains(v)) {
                    parts.add(v);
                    seen.add(v);
                }
            }
        }
        String s = String.join(parts, ' / ');
        return (s != null && s.length() > 255) ? s.substring(0, 255) : s; // por si el campo es 255
    }

    private PartyConsent createPartyConsentElements(
        WSHabeasDataExtendWrapper.HabeasDataDto request,
        WSHabeasDataExtendWrapper.CompanyDTO company,
        Datetime registerTime
    ) {
        PartyConsent pc = new PartyConsent();
        pc.Name =
            'Consentimiento - ' +
            company.name +
            ' - ' +
            validateNullStringValue(request.firstName) +
            ' ' +
            request.lastName +
            ' - ' +
            registerTime.format();
        pc.PartyId = request.idIndividual;
        pc.Individual_Id_Report__c = request.idIndividual;
        pc.BusinessBrandId = getBrandIdByName(company.name);
        pc.PrivacyConsentStatus = WSHabeasDataUtilities.PRIVACY_STATUS_OPT_IN;
        pc.Action = 'Data Collection';
        pc.AuthorizationChannel__c = request.authorizationChannel;
        pc.CaptureDate = registerTime;
        pc.DataUsePurposeId = getDataUsePurposeIdByName(request.dataUsePurpose);
        pc.MedicalHistory__c = validateBooleanNull(company.medicalHistory);
        pc.DataMarketing__c = validateBooleanNull(company.dataMarketing);
        pc.DebtCollection__c = joinContactPointTypes(company.authorization2300, WSHabeasDataUtilities.DEBT_COLLECT);
        pc.DirectMarketingVida__c = joinContactPointTypes(company.authorization2300, WSHabeasDataUtilities.DATA_MARKETING);
        pc.GeneralDataMarketing__c = company.generalCommercialOffer;
        pc.GeneralProcessingData__c = validateBooleanNull(company.generalProcessingData);
        pc.Phone__c = validateNullString(request.numberPhone);
        pc.Email__c = validateNullString(request.email);
        pc.PrivacyConsentStatus = WSHabeasDataUtilities.PRIVACY_STATUS_OPT_IN;
        pc.IdentityValidationNoData__c = validateBooleanNull(request.identityValidationNoData);

        if (isLegalPerson(request)) {
            pc.CS_IdentificationType_Emp__c = request.identityType;
            pc.CS_IdentificationNumber_Emp__c = request.identityNumber;
            pc.CS_IdentificationType__c = request.contactIdType;
            pc.CS_IdentificationNumber__c = request.contactIdNumber;
            pc.AccountName__c =
                validateNullString(request.firstName) +
                validateNullString(request.secondName) +
                validateNullString(request.lastName) +
                validateNullString(request.secondLastName);
            pc.FullName__c = validateNullString(request.contactFirstName) + validateNullString(request.contactLastName);
        } else {
            pc.CS_IdentificationType__c = request.identityType;
            pc.CS_IdentificationNumber__c = request.identityNumber;
            pc.FullName__c =
                validateNullString(request.firstName) +
                validateNullString(request.secondLastName) +
                validateNullString(request.secondName) +
                validateNullString(request.lastName);
        }

        pc.ChannelType__c = request.channelType;
        pc.BusinessCoverage__c = request.businessCoverage;
        pc.CollectionMethodType__c = request.collectionMethodType;
        pc.Process__c = request.process;
        pc.Origin__c = request.origin;

        pc.TaskHistoryValidationRelationship__c = WSHabeasDataOriginDomain.validateIdentitySecurytyInfo(request);
        pc.HistoryValidation__c = request.idIdentityValidation;

        pc.AccountId__c = request.idAccountLR;

        return pc;
    }

    private List<PartyConsent> getPartyConsentActiveByIndividualId(WSHabeasDataExtendWrapper.HabeasDataDto request, Id dataUsePurposeId) {
        if (request == null)
            return new List<PartyConsent>();
        return [
            SELECT
                Id,
                PrivacyConsentStatus,
                DataUsePurpose.Name,
                BusinessBrand.Name,
                MedicalHistory__c,
                DataMarketing__c,
                GeneralDataMarketing__c,
                GeneralProcessingData__c,
                DebtCollection__c,
                DirectMarketingVida__c
            FROM PartyConsent
            WHERE
                PartyId = :request.idIndividual
                AND PrivacyConsentStatus = :WSHabeasDataUtilities.PRIVACY_STATUS_OPT_IN
                AND DataUsePurposeId = :dataUsePurposeId
        ];
    }

    private List<PartyConsent> getPartyConsentActiveByIndividualIdEmp(WSHabeasDataExtendWrapper.HabeasDataDto request, Id dataUsePurposeId) {
        if (request == null)
            return new List<PartyConsent>();
        return [
            SELECT
                Id,
                PrivacyConsentStatus,
                DataUsePurpose.Name,
                BusinessBrand.Name,
                MedicalHistory__c,
                DataMarketing__c,
                GeneralDataMarketing__c,
                GeneralProcessingData__c,
                DebtCollection__c,
                DirectMarketingVida__c
            FROM PartyConsent
            WHERE
                PartyId = :request.idIndividual
                AND PrivacyConsentStatus = :WSHabeasDataUtilities.PRIVACY_STATUS_OPT_IN
                AND DataUsePurposeId = :dataUsePurposeId
                AND CS_IdentificationType__c = :request.contactIdType
                AND CS_IdentificationNumber__c = :request.contactIdNumber
                AND CS_IdentificationType_Emp__c = :request.identityType
                AND CS_IdentificationNumber_Emp__c = :request.identityNumber
        ];
    }

    private void updatePartyConsentStatus(List<PartyConsent> pcList) {
        try {
            if (pcList == null || pcList.isEmpty())
                return;
            for (PartyConsent pc : pcList) {
                pc.PrivacyConsentStatus = WSHabeasDataUtilities.PRIVACY_STATUS_OPT_OUT;
            }
            update pcList;
        } catch (Exception ex) {
            System.debug('Error actualizando PartyConsent: ' + ex.getMessage());
        }
    }

    public void iterateAuth2300ToInsertHistory(WSHabeasDataExtendWrapper.HabeasDataDto request, Id emailClientId, Id phoneClientId, Datetime registerTime) {
        List<ContactPointConsent> cpcList = new List<ContactPointConsent>();
        Id dataUsePurposeId = getDataUsePurposeIdByName(request.dataUsePurpose);
        List<ContactPointConsent> oldContactPointConsentList = changeStatusContactPointConsent(request, dataUsePurposeId);

        for (WSHabeasDataExtendWrapper.CompanyDTO company : request.companies) {
            cpcList.addAll(createContactPointConsentHistory(request, company, emailClientId, phoneClientId, registerTime));
        }

        insert cpcList;
    }

    private List<ContactPointConsent> createContactPointConsentHistory(
        WSHabeasDataExtendWrapper.HabeasDataDto request,
        WSHabeasDataExtendWrapper.CompanyDTO company,
        Id emailClientId,
        Id phoneClientId,
        Datetime registerTime
    ) {
        List<ContactPointConsent> cpcList = new List<ContactPointConsent>();
        if (company.authorization2300 != null && !company.authorization2300.isEmpty()) {
            for (WSHabeasDataExtendWrapper.Auth2300 auth2300 : company.authorization2300) {
                ContactPointConsent cpc = new ContactPointConsent();
                cpc.Name = 'Consentimiento 2300 - ' + company.name + ' - ' + request.firstName + ' ' + request.lastName + ' - ' + registerTime.format();
                cpc.BusinessBrandId = getBrandIdByName(company.name);
                cpc.AuthorizationChannel__c = request.authorizationChannel;
                cpc.CaptureDate = registerTime;
                cpc.DataUsePurposeId = getDataUsePurposeIdByName(auth2300.dataUsePurpose);
                cpc.PrivacyConsentStatus = WSHabeasDataUtilities.PRIVACY_STATUS_OPT_IN;
                if (WSHabeasDataUtilities.CONTACT_POINT_TYPE_EMAIL.equals(auth2300.contactPointType)) {
                    cpc.ContactPointId = emailClientId;
                } else {
                    cpc.ContactPointId = phoneClientId;
                }
                cpc.EngagementChannelTypeId = getEngagementChannelTypeIdByName(auth2300.contactPointType);
                cpc.Approved__c = auth2300.value;

                if (isLegalPerson(request)) {
                    cpc.CS_IdentificationType_Emp__c = request.identityType;
                    cpc.CS_IdentificationNumber_Emp__c = request.identityNumber;
                    cpc.CS_IdentificationType__c = request.contactIdType;
                    cpc.CS_IdentificationNumber__c = request.contactIdNumber;
                } else {
                    cpc.CS_IdentificationType__c = request.identityType;
                    cpc.CS_IdentificationNumber__c = request.identityNumber;
                }
                cpc.DataUsePurpose__c = request.dataUsePurpose;
                cpc.AccountId__c = request.idAccountLR;

                cpcList.add(cpc);
            }
        }
        return cpcList;
    }

    private List<ContactPointConsent> changeStatusContactPointConsent(WSHabeasDataExtendWrapper.HabeasDataDto request, Id dataUsePurposeId) {
        List<ContactPointConsent> pcList = new List<ContactPointConsent>();
        if (isLegalPerson(request)) {
            pcList = getContactPointConsentByIndividualIdEmp(request, dataUsePurposeId);
        } else {
            pcList = getContactPointConsentByIndividualId(request, dataUsePurposeId);
        }
        updateContactPointConsentStatus(pcList);
        return pcList;
    }

    private List<ContactPointConsent> getContactPointConsentByIndividualId(WSHabeasDataExtendWrapper.HabeasDataDto request, Id dataUsePurposeId) {
        if (request == null)
            return new List<ContactPointConsent>();
        return [
            SELECT Id, PrivacyConsentStatus
            FROM ContactPointConsent
            WHERE
                PartyId = :request.idIndividual
                AND PrivacyConsentStatus = :WSHabeasDataUtilities.PRIVACY_STATUS_OPT_IN
                AND DataUsePurpose__c = :request.dataUsePurpose
        ];
    }

    private List<ContactPointConsent> getContactPointConsentByIndividualIdEmp(WSHabeasDataExtendWrapper.HabeasDataDto request, Id dataUsePurposeId) {
        if (request == null)
            return new List<ContactPointConsent>();
        return [
            SELECT Id, PrivacyConsentStatus
            FROM ContactPointConsent
            WHERE
                PartyId = :request.idIndividual
                AND PrivacyConsentStatus = :WSHabeasDataUtilities.PRIVACY_STATUS_OPT_IN
                AND DataUsePurpose__c = :request.dataUsePurpose
                AND CS_IdentificationType__c = :request.contactIdType
                AND CS_IdentificationNumber__c = :request.contactIdNumber
                AND CS_IdentificationType_Emp__c = :request.identityType
                AND CS_IdentificationNumber_Emp__c = :request.identityNumber
        ];
    }

    private void updateContactPointConsentStatus(List<ContactPointConsent> pcList) {
        try {
            if (pcList == null || pcList.isEmpty())
                return;
            for (ContactPointConsent pc : pcList) {
                pc.PrivacyConsentStatus = WSHabeasDataUtilities.PRIVACY_STATUS_OPT_OUT;
            }
            update pcList;
        } catch (Exception ex) {
            System.debug('Error actualizando ContactPointConsent: ' + ex.getMessage());
        }
    }

    private List<BusinessBrand> getAllBusinessBrands() {
        if (businessBrandList.isEmpty()) {
            businessBrandList = [SELECT Id, Name FROM BusinessBrand LIMIT 50];
        }
        return businessBrandList;
    }

    private List<DataUsePurpose> getAllDataUsePurposes() {
        if (dataUsePurposeList.isEmpty()) {
            dataUsePurposeList = [SELECT Id, Name FROM DataUsePurpose LIMIT 50];
        }
        return dataUsePurposeList;
    }

    private List<EngagementChannelType> getAllEngagementChannelTypes() {
        if (engagementChannelTypeList.isEmpty()) {
            engagementChannelTypeList = [SELECT Id, Name FROM EngagementChannelType LIMIT 50];
        }
        return engagementChannelTypeList;
    }

    private Id getBrandIdByName(String name) {
        if (String.isBlank(name))
            return null;
        for (BusinessBrand brand : businessBrandList) {
            if (name.equals(brand.Name)) {
                return brand.Id;
            }
        }
        return null;
    }

    private Id getDataUsePurposeIdByName(String name) {
        if (String.isBlank(name))
            return null;
        for (DataUsePurpose purpose : dataUsePurposeList) {
            if (name.equals(purpose.Name)) {
                return purpose.Id;
            }
        }
        return null;
    }

    private Id getEngagementChannelTypeIdByName(String name) {
        if (String.isBlank(name))
            return null;
        for (EngagementChannelType ect : engagementChannelTypeList) {
            if (name.equals(ect.Name)) {
                return ect.Id;
            }
        }
        return null;
    }

    public static String validateNullString(String value) {
        if (String.isEmpty(value) || value == null) {
            return '';
        } else {
            return value + ' ';
        }
    }

    public static String validateNullStringValue(String value) {
        if (String.isEmpty(value) || value == null) {
            return '';
        } else {
            return value;
        }
    }

    private Boolean isLegalPerson(WSHabeasDataExtendWrapper.HabeasDataDto request) {
        return (WSHabeasDataUtilities.CLIENTE_REPRESENTANTE_LEGAL.equals(request.dataUsePurpose) ||
        WSHabeasDataUtilities.PROSPECTO_REPRESENTANTE_LEGAL.equals(request.dataUsePurpose));
    }

    //HELPERS
    /**
     * @description Devuelve los elementos de 'aseguradoras' que no están presentes en 'request'.
     */
    @TestVisible
    private static List<WSHabeasDataExtendWrapper.CompanyDTO> obtenerFaltantesPartyConsent(
        WSHabeasDataExtendWrapper.HabeasDataDto request,
        List<PartyConsent> oldPartyConsentList
    ) {
        if (oldPartyConsentList == null || oldPartyConsentList.isEmpty()) {
            return request.companies;
        }

        Set<String> requestedCompanies = buildRequestedCompaniesSet(request.companies);
        List<PartyConsent> missingConsents = findMissingConsents(oldPartyConsentList, requestedCompanies);

        List<WSHabeasDataExtendWrapper.CompanyDTO> result = new List<WSHabeasDataExtendWrapper.CompanyDTO>();
        result.addAll(request.companies);

        for (PartyConsent pc : missingConsents) {
            result.add(buildCompanyDTO(pc));
        }

        return result;
    }

    @TestVisible
    private static Set<String> buildRequestedCompaniesSet(List<WSHabeasDataExtendWrapper.CompanyDTO> companies) {
        Set<String> companyNames = new Set<String>();
        for (WSHabeasDataExtendWrapper.CompanyDTO company : companies) {
            if (String.isNotBlank(company.name)) {
                companyNames.add(company.name);
            }
        }
        return companyNames;
    }

    @TestVisible
    private static List<PartyConsent> findMissingConsents(List<PartyConsent> oldConsents, Set<String> requestedCompanies) {
        List<PartyConsent> missing = new List<PartyConsent>();
        for (PartyConsent pc : oldConsents) {
            if (pc.BusinessBrand != null && !requestedCompanies.contains(pc.BusinessBrand.Name)) {
                missing.add(pc);
            }
        }
        return missing;
    }

    private static WSHabeasDataExtendWrapper.CompanyDTO buildCompanyDTO(PartyConsent pc) {
        WSHabeasDataExtendWrapper.CompanyDTO company = new WSHabeasDataExtendWrapper.CompanyDTO();
        company.name = pc.BusinessBrand.Name;
        company.medicalHistory = pc.MedicalHistory__c;
        company.dataMarketing = pc.DataMarketing__c;
        company.generalCommercialOffer = pc.GeneralDataMarketing__c;
        company.generalProcessingData = pc.GeneralProcessingData__c;
        company.authorization2300 = buildAuthorizations(pc);

        return company;
    }

    @TestVisible
    private static List<WSHabeasDataExtendWrapper.Auth2300> buildAuthorizations(PartyConsent pc) {
        List<WSHabeasDataExtendWrapper.Auth2300> authorizations = new List<WSHabeasDataExtendWrapper.Auth2300>();

        List<String> debtCollections = splitSafely(pc.DebtCollection__c);
        authorizations.addAll(createAuth2300List(debtCollections, WSHabeasDataUtilities.DEBT_COLLECT));

        List<String> directMarketing = splitSafely(pc.DirectMarketingVida__c);
        authorizations.addAll(createAuth2300List(directMarketing, WSHabeasDataUtilities.DATA_MARKETING));

        return authorizations;
    }

    @TestVisible
    private static List<String> splitSafely(String value) {
        return String.isNotBlank(value) ? value.split(' / ') : new List<String>();
    }

    @TestVisible
    private static List<WSHabeasDataExtendWrapper.Auth2300> createAuth2300List(List<String> contactTypes, String purpose) {
        List<WSHabeasDataExtendWrapper.Auth2300> auths = new List<WSHabeasDataExtendWrapper.Auth2300>();
        for (String contactType : contactTypes) {
            WSHabeasDataExtendWrapper.Auth2300 auth = new WSHabeasDataExtendWrapper.Auth2300();
            auth.value = true;
            auth.contactPointType = contactType;
            auth.dataUsePurpose = purpose;
            auths.add(auth);
        }
        return auths;
    }

    @TestVisible
    private List<WSHabeasDataExtendWrapper.CompanyDTO> preProcessCompaniesForSF(
        WSHabeasDataExtendWrapper.HabeasDataDto request,
        List<PartyConsent> oldPartyConsentList
    ) {
        Set<String> requestedCompanies = buildRequestedCompaniesSet(request.companies);
        List<WSHabeasDataExtendWrapper.CompanyDTO> validCompanies = new List<WSHabeasDataExtendWrapper.CompanyDTO>();

        for (WSHabeasDataExtendWrapper.CompanyDTO company : request.companies) {
            if (!shouldRemoveCompany(company, requestedCompanies)) {
                validCompanies.add(company);
            }
        }

        return validCompanies;
        //request.companies = validCompanies;
    }

    @TestVisible
    private Boolean shouldRemoveCompany(WSHabeasDataExtendWrapper.CompanyDTO company, Set<String> requestedCompanies) {
        return hasIncompleteData(company);
    }

    @TestVisible
    private Boolean hasIncompleteData(WSHabeasDataExtendWrapper.CompanyDTO company) {
        return WSHabeasDataUtilities.UPD_VALIDATOR.equals(company.notEssentialFunctionalities);
    }
}