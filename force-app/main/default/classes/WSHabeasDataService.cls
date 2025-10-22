public with sharing class WSHabeasDataService {
    public WSHabeasDataService() {
    }

    private static final Integer TITULAR = 1;
    private static final Integer REP_LEGAL = 2;

    Account accountObject = new Account();
    Lead leadObject = new Lead();

    //General Autorization Process
    public WSHabeasDataExtendWrapper.HabeasDataResponseDto processAuth_V2(WSHabeasDataExtendWrapper.HabeasDataDto request) {
        WSHabeasDataExtendWrapper.HabeasDataResponseDto response = new WSHabeasDataExtendWrapper.HabeasDataResponseDto();
        try {
            if (WSHabeasDataUtilities.validateRequiredFields(request, WSHabeasDataUtilities.CONTROLLER_MANDATORY_FIELDS)) {
                return createResponse(true, 'Mandatory fields are missing', 400, 'failed');
            }

            // if (!validateMandatoryFieldsCompanies(request)) {
            //     return createResponse(true, 'Mandatory fields in companies are missing', 400, 'failed');
            // }

            WSHabeasDataOriginDomain.getAuthorizationChannelConfig(request);
            if (
                String.isBlank(request.channelType) ||
                String.isBlank(request.process) ||
                String.isBlank(request.businessCoverage) ||
                String.isBlank(request.origin) ||
                String.isBlank(request.collectionMethodType)
            ) {
                return createResponse(true, 'The authorization channel configuration was not found', 400, 'failed');
            }

            Id objectCreated = createAuthorizationSubject(request);

            if (objectCreated == null) {
                return createResponse(true, 'id de cliente vacio para relacionar la autorización', 400, 'failed');
            } else {
                request.IdClient = objectCreated;
            }

            Datetime registerTime = DateTime.now();
            //Create/Update the Individual
            WSHabeasDataConsentPrivacyDomain privacyDomain = new WSHabeasDataConsentPrivacyDomain();
            Individual individualCreated = privacyDomain.createIndividual(request, registerTime);

            if (individualCreated == null) {
                return createResponse(true, 'Error creating Individual', 500, 'failed');
            } else {
                request.idIndividual = individualCreated.Id;
            }

            //Assign Individual to Auth Subject
            if (individualCreated != null) {
                privacyDomain.assignIndividualToAuthSubject(request);
            }

            //Create Party Consent History
            privacyDomain.createPartyConsentHistory(request, registerTime);

            //Create/Update the contact point phone
            ContactPointEmail emailClient = privacyDomain.getCreateContactPointEmail(request);
            ContactPointPhone phoneClient = privacyDomain.getCreateContactPointPhone(request);

            privacyDomain.iterateAuth2300ToInsertHistory(request, emailClient.Id, phoneClient.Id, registerTime);

            return this.createResponse(false, 'successfull', 200, 'Success');
        } catch (Exception ex) {
            System.debug(ex);
            System.debug('WSHabeasDataService.processAuth_V2: ' + ex.getMessage());
            return this.createResponse(true, ex.getMessage(), 500, 'failed');
        }
    }

    //Authorization process using the metadata Rules
    public WSHabeasDataAPIDto.ResponseDto processAuth(WSHabeasDataAPIDto.HabeasDataDto request) {
        if (request != null) {
            try {
                List<HD_API_Rules__mdt> businessRules = WSHabeasDataOriginDomain.getBuisnessMetadataRules(
                    request.consent.authorizationChannel,
                    request.companies,
                    request.consent.dataUsePurpose
                );
                if (businessRules.isEmpty() || businessRules == null) {
                    return createResponseV2(
                        true,
                        'No se encontraron reglas de negocio para procesar la solicitud o los valores de compañia estan vacios',
                        400,
                        'failed'
                    );
                }
                WSHabeasDataExtendWrapper.HabeasDataDto controller = WSHabeasDataOriginDomain.transformApiToControllerDto(request, businessRules);

                if (controller == null) {
                    return this.createResponseV2(true, 'No se pudo procesar tu solicitud, error en el body del servicio', 400, 'failed');
                }

                WSHabeasDataExtendWrapper.HabeasDataResponseDto resp = processAuth_V2(controller);
                return createResponseV2(resp.error, resp.message, resp.responseCode, resp.status);
            } catch (Exception ex) {
                System.debug('WSHabeasDataService.transformServiceClass: ' + ex.getMessage());
                return this.createResponseV2(true, ex.getMessage(), 500, 'failed');
            }
        }

        return new WSHabeasDataAPIDto.ResponseDto();
    }

    private Id createAuthorizationSubject(WSHabeasDataExtendWrapper.HabeasDataDto req) {
        if (req == null || String.isBlank(req.dataUsePurpose))
            return null;

        String type = req.dataUsePurpose.trim();
        req.idClient = null;
        req.idIndividual = null;

        if (type.equals(WSHabeasDataUtilities.CLIENTE)) {
            return getOrCreateAccount(req, TITULAR).Id;
        }
        if (type.equals(WSHabeasDataUtilities.CLIENTE_REPRESENTANTE_LEGAL)) {
            Account acc = getOrCreateAccountLR(req, REP_LEGAL);
            req.idAccountLR = acc.Id;
            return getOrCreateContact(req, acc).Id;
        }
        if (type.equals(WSHabeasDataUtilities.PROSPECTO)) {
            return getOrCreateLead(req, TITULAR).Id;
        }
        if (type.equals(WSHabeasDataUtilities.PROSPECTO_REPRESENTANTE_LEGAL)) {
            return getOrCreateLeadEmp(req, REP_LEGAL).Id;
        }
        return null;
    }

    private Boolean validateMandatoryFieldsCompanies(WSHabeasDataExtendWrapper.HabeasDataDto request) {
        if (request.companies == null || request.companies.isEmpty()) {
            return false;
        }
        for (WSHabeasDataExtendWrapper.CompanyDTO company : request.companies) {
            if (String.isBlank(company.name)) {
                return false;
            } else {
                if (company.authorization2300 != null && !company.authorization2300.isEmpty()) {
                    for (WSHabeasDataExtendWrapper.Auth2300 auth : company.authorization2300) {
                        if (String.isBlank(auth.contactPointType) || String.isBlank(auth.contactPointType) || String.isBlank(auth.dataUsePurpose)) {
                            return false;
                        }
                    }
                }
            }
        }
        return true;
    }

    private WSHabeasDataExtendWrapper.HabeasDataResponseDto createResponse(Boolean error, String message, Integer responseCode, String status) {
        WSHabeasDataExtendWrapper.HabeasDataResponseDto response = new WSHabeasDataExtendWrapper.HabeasDataResponseDto();
        response.error = error;
        response.message = message;
        response.responseCode = responseCode;
        response.status = status;
        return response;
    }

    private WSHabeasDataAPIDto.ResponseDto createResponseV2(Boolean error, String message, Integer responseCode, String status) {
        WSHabeasDataAPIDto.ResponseDto response = new WSHabeasDataAPIDto.ResponseDto();
        response.error = error;
        response.message = message;
        response.responseCode = responseCode;
        response.status = status;
        return response;
    }

    // Helpers DRY
    private Account getOrCreateAccount(WSHabeasDataExtendWrapper.HabeasDataDto r, Integer variante) {
        Account acc = getAccount(r);
        if (acc != null) {
            r.idIndividual = acc.PersonIndividualId;
            return acc;
        } else {
            return WSHabeasDataOriginDomain.createAccount(r, variante);
        }
    }

    private Account getOrCreateAccountLR(WSHabeasDataExtendWrapper.HabeasDataDto r, Integer variante) {
        Account acc = getAccount(r);
        if (acc != null) {
            r.idIndividual = acc.PersonIndividualId;
            return acc;
        } else {
            return WSHabeasDataOriginDomain.createAccountRL(r, variante);
        }
    }

    private Contact getOrCreateContact(WSHabeasDataExtendWrapper.HabeasDataDto r, Account acc) {
        Contact con = getContact(r, acc);
        if (con != null) {
            r.idIndividual = con.IndividualId;
            return con;
        } else {
            return WSHabeasDataOriginDomain.createContact(r, acc);
        }
    }

    private Lead getOrCreateLead(WSHabeasDataExtendWrapper.HabeasDataDto r, Integer variante) {
        Lead lead = getLead(r);
        if (lead != null) {
            r.idIndividual = lead.IndividualId;
            return lead;
        } else {
            return WSHabeasDataOriginDomain.createLead(r, variante);
        }
    }

    private Lead getOrCreateLeadEmp(WSHabeasDataExtendWrapper.HabeasDataDto r, Integer variante) {
        Lead lead = getLeadEmp(r);
        if (lead != null) {
            //r.idIndividual = lead.IndividualId;
            return lead;
        } else {
            return WSHabeasDataOriginDomain.createLead(r, variante);
        }
    }

    private Account getAccount(WSHabeasDataExtendWrapper.HabeasDataDto request) {
        Account account = WSHabeasDataOriginDomain.getAccountByIdentifacacionNumberAndType(request.identityNumber, request.identityType);

        return account;
    }

    private Contact getContact(WSHabeasDataExtendWrapper.HabeasDataDto request, Account acc) {
        Contact contact = WSHabeasDataOriginDomain.getContactByIdentifacacionNumberAndType(request.contactIdNumber, request.contactIdType, acc.Id);
        return contact;
    }

    private Lead getLead(WSHabeasDataExtendWrapper.HabeasDataDto request) {
        Lead lead = WSHabeasDataOriginDomain.getLeadByIdentifacacionNumberAndType(request.identityNumber, request.identityType);
        return lead;
    }

    private Lead getLeadEmp(WSHabeasDataExtendWrapper.HabeasDataDto request) {
        //Lead lead = WSHabeasDataOriginDomain.getLeadByIdentifacacionNumberAndTypeEmp(request.contactIdNumber, request.contactIdType);
        Lead lead = WSHabeasDataOriginDomain.getLeadByIdentifacacionNumberAndType(request.identityNumber, request.identityType);
        return lead;
    }
}