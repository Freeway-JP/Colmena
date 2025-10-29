public without sharing class WSHabeasDataExtendWrapper {
    public WSHabeasDataExtendWrapper() {
    }

    public class HabeasDataDto {
        public String firstName { get; set; }
        public String secondName { get; set; }
        public String lastName { get; set; }
        public String secondLastName { get; set; }
        public String identityType { get; set; }
        public String identityNumber { get; set; }
        public String email { get; set; }
        public String numberPhone { get; set; }
        public String sex { get; set; }
        public String subjectId { get; set; }

        public String dataUsePurpose { get; set; }
        public String authorizationChannel { get; set; }
        public String channelType { get; set; }
        public String process { get; set; }
        public String businessCoverage { get; set; }
        public String origin { get; set; }
        public String collectionMethodType { get; set; }

        public String contactFirstName { get; set; }
        public String contactLastName { get; set; }
        public String contactIdType { get; set; }
        public String contactIdNumber { get; set; }
        public Boolean identityValidationNoData { get; set; }
        public String identityValidationStatus { get; set; }
        public String identityValidationResult { get; set; }
        public String identityValidationSource { get; set; }
        public String identityValidationType { get; set; }

        public List<CompanyDTO> companies;

        //Control varialbes
        public String idClient { get; set; }
        public String idIndividual { get; set; }
        public String idIdentityValidation { get; set; }
        public String idAccountLR { get; set; }
    }

    public class HabeasDataResponseDto {
        public String status { get; set; }
        public Boolean error { get; set; }
        public Integer responseCode { get; set; }
        public String message { get; set; }
    }

    public class CompanyDTO {
        public String name { get; set; }
        public Boolean medicalHistory { get; set; }
        public Boolean dataMarketing { get; set; }
        public Boolean generalCommercialOffer { get; set; }
        public Boolean generalProcessingData { get; set; }
        public String notEssentialFunctionalities;
        public List<Auth2300> authorization2300 { get; set; }
    }

    public class Auth2300 {
        public Boolean value { get; set; }
        public String contactPointType { get; set; }
        public String contactPoint { get; set; }
        public String dataUsePurpose { get; set; }
    }

    public class HabeasDataMassiveDto {
        public List<HabeasDataDto> massiveAuth { get; set; }
        public String massiveAuthType { get; set; }
    }

    public class HabeasDataMassiveResponseDto {
        public HabeasDataMassiveResponseDto() {
        }

        public Id jobId { get; set; }
        public Integer responseCode { get; set; }
        public String message { get; set; }

        public HabeasDataMassiveResponseDto(Id jobId, Integer code, String message) {
            this.jobId = jobId;
            this.responseCode = code;
            this.message = message;
        }
    }
}