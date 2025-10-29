public without sharing class WSHabeasDataAPIDto {
    public class HabeasDataDto {
        public AccountDto account;
        public ConsentDto consent;
        public List<String> companies;
    }

    public class AccountDto {
        public String firstName { get; set; }
        public String secondName { get; set; }
        public String lastName { get; set; }
        public String secondLastName { get; set; }
        public String identityType { get; set; }
        public String identityNumber { get; set; }
        public String email { get; set; }
        public String numberPhone { get; set; }
        public String sex { get; set; }
        public String contactFirstName { get; set; }
        public String contactLastName { get; set; }
        public String contactIdType { get; set; }
        public String contactIdNumber { get; set; }
    }

    public class ConsentDto {
        public String authorizationChannel { get; set; }
        public String ipAddress { get; set; }
        public String dataUsePurpose { get; set; }
        public IdentityValidated identityValidated { get; set; }
        public List<Auth2300> authorization2300 { get; set; }
    }

    public class IdentityValidated {
        public Boolean identityValidationNoData { get; set; }
        public String identityValidationStatus { get; set; }
        public String identityValidationResult { get; set; }
        public String identityValidationSource { get; set; }
        public String identityValidationType { get; set; }
    }

    public class ResponseDto {
        public String status { get; set; }
        public Boolean error { get; set; }
        public Integer responseCode { get; set; }
        public String message { get; set; }
    }

    public class Auth2300 {
        public Boolean value { get; set; }
        public String contactPointType { get; set; }
        public String contactPoint { get; set; }
        public String dataUsePurpose { get; set; }
    }

    public class MassiveDto {
        public List<HabeasDataDto> massiveAuth { get; set; }
        public String massiveAuthType { get; set; }
    }

    public class MassiveResponseDto {
        public MassiveResponseDto() {
        }

        public Id jobId { get; set; }
        public Integer responseCode { get; set; }
        public String message { get; set; }

        public MassiveResponseDto(Id jobId, Integer code, String message) {
            this.jobId = jobId;
            this.responseCode = code;
            this.message = message;
        }
    }
}