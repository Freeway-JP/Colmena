public class WS_HabeasDataWrapper {
    public class RequestWSWrapper {
        public String FirstName;
        public String SecondName;
        public String LastName;
        public String SecondLastName;
        public String identityType;
        public String identityNumber;
        public String email;
        public String numberPhone;
        public String sex;

        public String AttentionChannel;
        public String TypeObjectCreate;
        public String IdClient;
        public String idIndividual;
        public List<String> idContactPoints;

        public List<CompaniesWrapper> companies;

        //variables de control de errores
        public String ClientController;
        public String HabeasDataController;
    }

    public class ResponseWSWrapper {
        public String status;
        public Boolean error;
        public String responseCode;
        public String message;
    }

    public class CompaniesWrapper {
        public String name;
        public Boolean essentialFunctionalities;
        public List<String> notEssentialFunctionalities;
        //se hace remoción por decision funcional -- public Boolean law2300;
        public Boolean MedicalHistory;
    }

    public class ResponseWsWrapperMassive {
        public ResponseWsWrapperMassive() {
        }

        public Id jobId { get; set; }
        public Integer responseCode { get; set; }
        public String message { get; set; }

        public ResponseWsWrapperMassive(Id jobId, Integer code, String message) {
            this.jobId = jobId;
            this.responseCode = code;
            this.message = message;
        }
    }
}