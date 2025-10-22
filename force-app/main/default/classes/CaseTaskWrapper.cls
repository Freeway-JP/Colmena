global class CaseTaskWrapper {
        public String Id;
        public String CaseNumber;
    	public String NumberATEL;
        public String RecordTypeName;
        public String Description;
        public String CS_MacroReason;
        public String CS_SubReason;
        public String Status;
        public String CS_TentativeClosingDate;
        public String CS_TrafficLightString;
    	public String RecordTypeClaimName;
    	public Date salesforceFilingDate;
    	public List<TaskWrapper> taskWrapper;
    
    public CaseTaskWrapper(Case c, Claim claim) {
            if (c != null) {
                this.Id = c.Id;
                this.CaseNumber = !String.isBlank(c.CaseNumber) ? c.CaseNumber : '';
                this.RecordTypeName = c.RecordType.Name;
                this.Description = !String.isBlank(c.Description) ? c.Description : '';
                
                this.Status = c.Status;
                
                this.CS_TrafficLightString = !String.isBlank(c.CS_Semaforotexto__c) ? c.CS_Semaforotexto__c : '';
                this.NumberATEL = claim.Name;
                this.RecordTypeClaimName = claim.RecordType.Name;
                this.salesforceFilingDate = c.CreatedDate.date();
                if(this.RecordTypeName != null && !String.isBlank(this.RecordTypeName) && (this.RecordTypeName == 'Solicitud PQRS' || this.RecordTypeName == 'Derecho de Petición PQRS' ||this.RecordTypeName == 'Incidente PQRS')){
                    this.CS_MacroReason = !String.isBlank(c.Reason) ? c.Reason : '';
                	this.CS_SubReason = !String.isBlank(c.SubReason__c) ? c.SubReason__c : '';
                    this.CS_TentativeClosingDate = !String.isBlank(String.valueOf(c.AppointmentDateTime__c)) ? String.valueOf(c.AppointmentDateTime__c.year())+ '-' + String.valueOf(c.AppointmentDateTime__c.month()).leftPad(2, '0') + '-' + String.valueOf(c.AppointmentDateTime__c.day()).leftPad(2, '0') : '';
                }else{
                    this.CS_MacroReason = !String.isBlank(c.CS_MacroMotivo__c) ? c.CS_MacroMotivo__c : '';
                	this.CS_SubReason = !String.isBlank(c.CS_Submotivo__c) ? c.CS_Submotivo__c : '';
                    this.CS_TentativeClosingDate = !String.isBlank(String.valueOf(c.CS_FechaTentativaDeCierre__c)) ? String.valueOf(c.CS_FechaTentativaDeCierre__c.year())+ '-' + String.valueOf(c.CS_FechaTentativaDeCierre__c.month()).leftPad(2, '0') + '-' + String.valueOf(c.CS_FechaTentativaDeCierre__c.day()).leftPad(2, '0') : '';

                }
                
            }
        }

}