global with sharing class RevocationDataExtractHD implements Callable {

    private static final String KEY_PARTY_ID = 'partyId';

    global Object call(String action, Map<String, Object> args) {
        Map<String, Object> input = (Map<String, Object>) args.get('input');
        Map<String, Object> output = (Map<String, Object>) args.get('output');
        Map<String, Object> options = (Map<String, Object>) args.get('options');
        return invokeMethod(action, input, output, options);
    }

    global Boolean invokeMethod(String methodName, Map<String, Object> inputMap, Map<String, Object> outMap, Map<String, Object> options) {
        Boolean result = true;
        try {
            if (methodName.equals('getActiveConsents')) {
                Id partyId = (Id) inputMap.get(KEY_PARTY_ID);
                getData(partyId, outMap);
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

    public void getData(Id partyId, Map<String, Object> outMap) {
        List<PartyConsent> partyConsents = queryPartyConsents(partyId);
        List<ContactPointConsent> contactPointConsents = queryContactPointConsents(partyId);
        Individual individualData = queryIndividualData(partyId);

        Map<String, ConsentGroup> groupedData = groupConsentsByEntity(partyConsents, individualData);
        mergeContactPointConsents(groupedData, contactPointConsents);

        for (ConsentGroup cg : groupedData.values()) {
            cg.AuthorizationChecks = cg.authChecks.values();
        }

        outMap.put('groupedConsents', groupedData.values());
    }

    private List<PartyConsent> queryPartyConsents(Id partyId) {
        return [
            SELECT Id, Name, CaptureDate, Process__c, Origin__c, ChannelType__c,
                   BusinessCoverage__c, CollectionMethodType__c, IdentityValidationNoData__c,
                   CS_IdentificationType__c, CS_IdentificationNumber__c,
                   CS_IdentificationType_Emp__c, CS_IdentificationNumber_Emp__c,
                   BusinessBrand.Name, DataUsePurpose.Name, AccountId__c,
                   AuthorizationChannel__c, MedicalHistory__c, DataMarketing__c,
                   GeneralDataMarketing__c, GeneralProcessingData__c,
                   Email__c, Phone__c
            FROM PartyConsent
            WHERE PartyId = :partyId
            AND PrivacyConsentStatus = 'OptIn'
        ];
    }

    private List<ContactPointConsent> queryContactPointConsents(Id partyId) {
        return [
            SELECT Id, Name, CaptureDate, BusinessBrand.Name, DataUsePurpose__c,
                   EngagementChannelType.Name, Approved__c, DataUsePurpose.Name, AccountId__c
            FROM ContactPointConsent
            WHERE PartyId = :partyId
            AND PrivacyConsentStatus = 'OptIn'
        ];
    }

    private Individual queryIndividualData(Id partyId) {
        List<Individual> individuals = [
            SELECT Id, FirstName, MiddleName, LastName, Suffix,
                   CS_TipoIdentificacion__c, CS_NumeroIdentificacion__c
            FROM Individual
            WHERE Id = :partyId
            LIMIT 1
        ];

        return individuals.isEmpty() ? null : individuals[0];
    }

    private Map<String, ConsentGroup> groupConsentsByEntity(List<PartyConsent> partyConsents, Individual individualData) {
        Map<String, ConsentGroup> grouped = new Map<String, ConsentGroup>();

        for (PartyConsent pc : partyConsents) {
            String entityName = extractEntityName(pc.Name);
            String dataUsePurpose = pc.DataUsePurpose != null ? pc.DataUsePurpose.Name : '';

            if (String.isBlank(entityName)) {
                continue;
            }

            String groupKey = entityName + '|' + dataUsePurpose;

            if (!grouped.containsKey(groupKey)) {
                grouped.put(groupKey, new ConsentGroup(entityName));
            }

            ConsentGroup consentGroup = grouped.get(groupKey);

            // Agregar datos del Individual si están disponibles
            if (individualData != null && consentGroup.FirstName == null) {
                consentGroup.FirstName = individualData.FirstName;
                consentGroup.MiddleName = individualData.MiddleName;
                consentGroup.LastName = individualData.LastName;
                consentGroup.Suffix = individualData.Suffix;
                consentGroup.IndividualIdentificationType = individualData.CS_TipoIdentificacion__c;
                consentGroup.IndividualIdentificationNumber = individualData.CS_NumeroIdentificacion__c;
            }

            if (pc.CaptureDate != null && consentGroup.CaptureDate == null) {
                consentGroup.CaptureDate = pc.CaptureDate;
            }

            if (String.isNotBlank(pc.Process__c) && String.isBlank(consentGroup.Process)) {
                consentGroup.Process = pc.Process__c;
            }

            if (String.isNotBlank(pc.Origin__c) && String.isBlank(consentGroup.Origin)) {
                consentGroup.Origin = pc.Origin__c;
            }

            if (String.isNotBlank(pc.ChannelType__c) && String.isBlank(consentGroup.ChannelType)) {
                consentGroup.ChannelType = pc.ChannelType__c;
            }

            if (String.isNotBlank(pc.BusinessCoverage__c) && String.isBlank(consentGroup.BusinessCoverage)) {
                consentGroup.BusinessCoverage = pc.BusinessCoverage__c;
            }

            if (String.isNotBlank(pc.CollectionMethodType__c) && String.isBlank(consentGroup.CollectionMethodType)) {
                consentGroup.CollectionMethodType = pc.CollectionMethodType__c;
            }

            if (pc.IdentityValidationNoData__c != null && consentGroup.IdentityValidationNoData == null) {
                consentGroup.IdentityValidationNoData = pc.IdentityValidationNoData__c;
            }

            if (String.isNotBlank(pc.AuthorizationChannel__c) && String.isBlank(consentGroup.AuthorizationChannel)) {
                consentGroup.AuthorizationChannel = pc.AuthorizationChannel__c;
            }

            if (String.isNotBlank(pc.Email__c) && String.isBlank(consentGroup.Email)) {
                consentGroup.Email = pc.Email__c;
            }

            if (String.isNotBlank(pc.Phone__c) && String.isBlank(consentGroup.Phone)) {
                consentGroup.Phone = pc.Phone__c;
            }

            if (String.isNotBlank(dataUsePurpose) && String.isBlank(consentGroup.UsePurpose)) {
                consentGroup.UsePurpose = dataUsePurpose;

                if (dataUsePurpose == 'Cliente' || dataUsePurpose == 'Prospecto') {
                    consentGroup.IdentificationType = pc.CS_IdentificationType__c;
                    consentGroup.IdentificationNumber = pc.CS_IdentificationNumber__c;
                } else if (dataUsePurpose == 'Cliente Representante Legal' || dataUsePurpose == 'Prospecto Representante Legal') {
                    consentGroup.IdentificationType_Emp = pc.CS_IdentificationType_Emp__c;
                    consentGroup.IdentificationNumber_Emp = pc.CS_IdentificationNumber_Emp__c;
                }
            }

            String businessBrand = pc.BusinessBrand != null ? pc.BusinessBrand.Name : null;
            if (String.isNotBlank(businessBrand)) {
                if (!consentGroup.authChecks.containsKey(businessBrand)) {
                    consentGroup.authChecks.put(businessBrand, new AuthorizationCheck(businessBrand));
                }

                AuthorizationCheck authCheck = consentGroup.authChecks.get(businessBrand);

                if (String.isBlank(authCheck.IdPartyConsent)) {
                    authCheck.IdPartyConsent = pc.Id;
                }

                if (pc.MedicalHistory__c == true) {
                    authCheck.MedicalHistory = true;
                }
                if (pc.DataMarketing__c == true) {
                    authCheck.GeneralDataMarketing = true;
                }
                if (pc.GeneralDataMarketing__c == true) {
                    authCheck.GeneralCommercialOffer = true;
                }
                if (pc.GeneralProcessingData__c == true) {
                    authCheck.GeneralProcessingData = true;
                }
            }
        }

        return grouped;
    }

    private void mergeContactPointConsents(Map<String, ConsentGroup> grouped, List<ContactPointConsent> contactPointConsents) {
        for (ContactPointConsent cpc : contactPointConsents) {
            String entityName = extractEntityName(cpc.Name);
            String businessBrand = cpc.BusinessBrand != null ? cpc.BusinessBrand.Name : null;
            String dataUsePurposeFromCPC = cpc.DataUsePurpose__c != null ? (String)cpc.DataUsePurpose__c : '';

            if (String.isBlank(entityName) || String.isBlank(businessBrand)) {
                continue;
            }

            String groupKey = entityName + '|' + dataUsePurposeFromCPC;

            ConsentGroup consentGroup = grouped.get(groupKey);
            if (consentGroup == null || !consentGroup.authChecks.containsKey(businessBrand)) {
                continue;
            }

            AuthorizationCheck authCheck = consentGroup.authChecks.get(businessBrand);
            String dataUsePurpose = cpc.DataUsePurpose != null ? cpc.DataUsePurpose.Name : null;
            String engagementChannel = cpc.EngagementChannelType != null ? cpc.EngagementChannelType.Name : null;
            Boolean approved = cpc.Approved__c != null ? cpc.Approved__c : false;

            if (dataUsePurpose == 'Gestión Cartera-2300') {
                setChannelValuePM(authCheck.PortfolioManagement2300, engagementChannel, approved, cpc.Id);
            } else if (dataUsePurpose == 'Ofrecimiento Comercial-2300') {
                setChannelValueCO(authCheck.CommercialOffering2300, engagementChannel, approved, cpc.Id);
            }
        }
    }

    private void setChannelValuePM(PortfolioManagement2300 pm2300, String channelName, Boolean approved, String recordId) {
        if (String.isBlank(channelName)) {
            return;
        }

        if (channelName.equalsIgnoreCase('celular')) {
            pm2300.CelularPM = approved;
            if (String.isNotBlank(recordId)) {
                pm2300.IdCelular = recordId;
            }
        } else if (channelName.equalsIgnoreCase('correo electrónico')) {
            pm2300.EmailPM = approved;
            if (String.isNotBlank(recordId)) {
                pm2300.IdEmail = recordId;
            }
        } else if (channelName.equalsIgnoreCase('mensaje de texto')) {
            pm2300.SmsPM = approved;
            if (String.isNotBlank(recordId)) {
                pm2300.IdSms = recordId;
            }
        } else if (channelName.equalsIgnoreCase('WhatsApp')) {
            pm2300.WhatsapppPM = approved;
            if (String.isNotBlank(recordId)) {
                pm2300.IdWhatsappp = recordId;
            }
        }
    }

    private void setChannelValueCO(CommercialOffering2300 co2300, String channelName, Boolean approved, String recordId) {
        if (String.isBlank(channelName)) {
            return;
        }

        if (channelName.equalsIgnoreCase('celular')) {
            co2300.CelularCO = approved;
            if (String.isNotBlank(recordId)) {
                co2300.IdCelular = recordId;
            }
        } else if (channelName.equalsIgnoreCase('correo electrónico')) {
            co2300.EmailCO = approved;
            if (String.isNotBlank(recordId)) {
                co2300.IdEmail = recordId;
            }
        } else if (channelName.equalsIgnoreCase('mensaje de texto')) {
            co2300.SmsCO = approved;
            if (String.isNotBlank(recordId)) {
                co2300.IdSms = recordId;
            }
        } else if (channelName.equalsIgnoreCase('WhatsApp')) {
            co2300.WhatsapppCO = approved;
            if (String.isNotBlank(recordId)) {
                co2300.IdWhatsappp = recordId;
            }
        }
    }

    private String extractEntityName(String fullName) {
        if (String.isBlank(fullName)) {
            return null;
        }

        List<String> parts = fullName.split(' - ');

        if (parts.size() >= 3) {
            return parts[2].trim();
        }

        return null;
    }

    private class ConsentGroup {
        public String EntityName;
        public DateTime CaptureDate;
        public String Process;
        public String Origin;
        public String ChannelType;
        public String BusinessCoverage;
        public String CollectionMethodType;
        public Boolean IdentityValidationNoData;
        public String AuthorizationChannel;
        public String UsePurpose;
        public String IdentificationType;
        public String IdentificationNumber;
        public String IdentificationType_Emp;
        public String IdentificationNumber_Emp;
        public String FirstName;
        public String MiddleName;
        public String LastName;
        public String Suffix;
        public String IndividualIdentificationType;
        public String IndividualIdentificationNumber;
        public String Email;
        public String Phone;
        public List<AuthorizationCheck> AuthorizationChecks;
        transient Map<String, AuthorizationCheck> authChecks;

        public ConsentGroup(String entityName) {
            this.EntityName = entityName;
            this.CaptureDate = null;
            this.Process = null;
            this.Origin = null;
            this.ChannelType = null;
            this.BusinessCoverage = null;
            this.CollectionMethodType = null;
            this.IdentityValidationNoData = null;
            this.AuthorizationChannel = null;
            this.UsePurpose = null;
            this.IdentificationType = null;
            this.IdentificationNumber = null;
            this.IdentificationType_Emp = null;
            this.IdentificationNumber_Emp = null;
            this.FirstName = null;
            this.MiddleName = null;
            this.LastName = null;
            this.Suffix = null;
            this.IndividualIdentificationType = null;
            this.IndividualIdentificationNumber = null;
            this.Email = null;
            this.Phone = null;
            this.authChecks = new Map<String, AuthorizationCheck>();
        }
    }

    private class AuthorizationCheck {
        public String IdPartyConsent;
        public String BusinessBrand;
        public Boolean MedicalHistory;
        public Boolean GeneralDataMarketing;
        public Boolean GeneralCommercialOffer;
        public Boolean GeneralProcessingData;
        public PortfolioManagement2300 PortfolioManagement2300;
        public CommercialOffering2300 CommercialOffering2300;

        public AuthorizationCheck(String businessBrand) {
            this.IdPartyConsent = null;
            this.BusinessBrand = businessBrand;
            this.MedicalHistory = false;
            this.GeneralDataMarketing = false;
            this.GeneralCommercialOffer = false;
            this.GeneralProcessingData = false;
            this.PortfolioManagement2300 = new PortfolioManagement2300();
            this.CommercialOffering2300 = new CommercialOffering2300();
        }
    }

    private class PortfolioManagement2300 {
        public Boolean WhatsapppPM;
        public Boolean SmsPM;
        public Boolean EmailPM;
        public Boolean CelularPM;
        public String IdWhatsappp;
        public String IdSms;
        public String IdEmail;
        public String IdCelular;

        public PortfolioManagement2300() {
            this.WhatsapppPM = false;
            this.SmsPM = false;
            this.EmailPM = false;
            this.CelularPM = false;
            this.IdWhatsappp = '';
            this.IdSms = '';
            this.IdEmail = '';
            this.IdCelular = '';
        }
    }

    private class CommercialOffering2300 {
        public Boolean WhatsapppCO;
        public Boolean SmsCO;
        public Boolean EmailCO;
        public Boolean CelularCO;
        public String IdWhatsappp;
        public String IdSms;
        public String IdEmail;
        public String IdCelular;

        public CommercialOffering2300() {
            this.WhatsapppCO = false;
            this.SmsCO = false;
            this.EmailCO = false;
            this.CelularCO = false;
            this.IdWhatsappp = '';
            this.IdSms = '';
            this.IdEmail = '';
            this.IdCelular = '';
        }
    }
}