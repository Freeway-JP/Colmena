public with sharing class VS_CallIPCreateWorckAccidentoToSendClaim {
    @future(callout=true)
    public static void callout(Id claimId) {
        // get claim
        Claim claim = [
            SELECT Id, ReportedBy__c, SinisterCity__c, AccidentDate__c, ClaimReasonType, AffectedBodyParts__c, TypeOfInjury__c, AccidentDetails__c, 
            AgentsCausingAccident__c, Description_of_injury_states__c, Severity, TimeOfDay__c, ResponsibleFiling__c, IncidentSite, Diagnosis__c, Diagnosis__r.Name, 
            Description_of_the_accident__c, IsLunchTime__c, IsInsideTheCompany__c, IsBiologicalRisk__c, IsWorkAtHome__c, IsDeath__c, DeathDate__c, 
            Origin__c, Procesamiento__c, InjuryStatus__c, SiteAccidentOccurrence__c, Company_Phone__c, Email_Work__c, Home_phone__c, JobPosition__c, 
            Phone_Other__c, Mobile_phone__c, CreatedBy.Username, CreationDateOnSendaMedico__c, Last_Attempt_to_Send_Senda__c, 
            CreationFailAtSendaMedico__c, CS_numeroLinea__c, Accept_Notifications__c, LossDate, CS_correoReclamante__c, CS_Origen__c
            FROM Claim 
            WHERE Id = :claimId
            LIMIT 1
        ];

        if (claim != null) {
            List<Task> taskList = [
                SELECT Id, WhoId, Subject, ActivityDate, Description, Poliza_de_seguro__r.Name 
                FROM Task
                WHERE Indemnizaci_n__c = :ClaimId
            ];
            
            if(taskList == null || taskList.size() == 0){
                claim.CreationFailAtSendaMedico__c = true;
                claim.Last_Attempt_to_Send_Senda__c = Datetime.now();
                update claim;
                System.debug('taskList: null');
                return;
            }
            
            Task task = taskList[0];

            Contact contact = null;
            if (task != null) {
                contact = [
                    SELECT Id, LastName, CS_TipoIdentificacionCP__c, CS_NumeroIdentificacionCP__c, FirstName 
                    FROM Contact 
                    WHERE Id = :task.WhoId
                ];
            }
            
            Map<String, Object> requestBody = new Map<String, Object> ();

            requestBody.put('withinCompany',            claim.IsInsideTheCompany__c ? '1' : '0');
            requestBody.put('responsibleCode',          claim.ResponsibleFiling__c);
            requestBody.put('position',                 String.isBlank(claim.JobPosition__c) ? '' : claim.JobPosition__c );
            requestBody.put('biologicalRisk',           claim.IsBiologicalRisk__c ? '1' : '0');
            requestBody.put('shiftCode',                Integer.valueOf(claim.TimeOfDay__c));
            requestBody.put('otherPhone',               String.isBlank(claim.Phone_Other__c) ? '' : claim.Phone_Other__c );
            requestBody.put('celphone',                 String.isBlank(claim.Mobile_phone__c) ? '' : claim.Mobile_phone__c );
            requestBody.put('classificationCode',       String.isBlank(claim.ClaimReasonType) ? '' : claim.ClaimReasonType );
            requestBody.put('diagnosisCode',            String.isBlank(claim.Diagnosis__r.Name) ? '' : claim.Diagnosis__r.Name);
            requestBody.put('housePhone',               String.isBlank(claim.Home_phone__c) ? '' : claim.Home_phone__c );
            requestBody.put('workAtHome',               claim.IsWorkAtHome__c ? '1' : '0');
            requestBody.put('recordNumber',             String.isBlank(claim.CS_numeroLinea__c) ? '' : claim.CS_numeroLinea__c);
            requestBody.put('death',                    claim.IsDeath__c ? '1' : '0');
            requestBody.put('companyPhone',             String.isBlank(claim.Company_Phone__c) ? '' : claim.Company_Phone__c );
            requestBody.put('occurrenceSiteCode',       String.isBlank(claim.SiteAccidentOccurrence__c) ? '' : claim.SiteAccidentOccurrence__c );
            requestBody.put('specificBodyPartCode',     String.isBlank(claim.AffectedBodyParts__c) ? '' : claim.AffectedBodyParts__c );
            requestBody.put('accidentDateTime',         claim.LossDate);
            requestBody.put('emailWorker',              String.isBlank(claim.CS_correoReclamante__c) ? '' : claim.CS_correoReclamante__c );
            requestBody.put('injuryCode',               String.isBlank(claim.TypeOfInjury__c) ? '' : claim.TypeOfInjury__c );
            requestBody.put('description',              String.isBlank(claim.Description_of_the_accident__c) ? '' : claim.Description_of_the_accident__c );
            requestBody.put('agentCode',                String.isBlank(claim.AgentsCausingAccident__c) ? '' : claim.AgentsCausingAccident__c );
            requestBody.put('mechanismCode',            String.isBlank(claim.AccidentDetails__c) ? '' : claim.AccidentDetails__c );
            requestBody.put('lunchBreakMarking',        claim.IsLunchTime__c ? '1' : '0');

            List<Schema.Location> locationRecord = [
                SELECT Id, Name, Codigo_Ciudad__c FROM Location WHERE Id = :claim.SinisterCity__c
            ];
            if (locationRecord.size() > 0) {
                requestBody.put('occurrenceCityCode', locationRecord[0].Codigo_Ciudad__c);
            }

            String userName = claim.CreatedBy.Username;
            Integer atPosition = userName.indexOf('@');
            String networkUser = atPosition != -1 ? userName.substring(0, atPosition) : '';
            requestBody.put('networkUser', networkUser);
            
            if (claim.DeathDate__c != null) {
                requestBody.put('deathDateTime', claim.DeathDate__c);
            }

            Map<string, string> severityCodeMap = new Map<string, string> {
                'Alta inmediata' => '5',
                'Muy leve' => '6',
                'Leve' => '7',
                'Moderado' => '8',
                'Severo' => '9',
                'Grave' => '10'
            };
            requestBody.put('severityCode', severityCodeMap.get(claim.Severity));

            Map<String, String> originCodeMap = new Map<String,String> {
                'Aprobado' => 'A',
                'Pendiente' => 'P'
            };
            requestBody.put('originCode', originCodeMap.containsKey(claim.CS_Origen__c) ? originCodeMap.get(claim.CS_Origen__c) : '');



            Map<String,String> procedureCodeMap = new Map<String,String> {
                'AT con AIU' => '1',
                'AT sin AIU' => '2',
                'Incidente(No requiere AIU)' => '3',
                'Origen común' => '4'
            };
            requestBody.put('procedureCode', procedureCodeMap.get(claim.Procesamiento__c));
            
            List<Integer> injuryStatusCodes = new List<Integer>();
            List<String> injuryStatusCodesString = claim.InjuryStatus__c.split(';');
            for (String injuryStatusCode : injuryStatusCodesString) {
                injuryStatusCodes.add(Integer.valueOf(injuryStatusCode));
            }
            requestBody.put('injuryStatusCodes', injuryStatusCodes);
        

            if (task != null && task.Poliza_de_seguro__r.Name != null) {
                String inputString = task.Poliza_de_seguro__r.Name;
                Integer dashPosition = inputString.indexOf('-');
                String companyContractNumber = dashPosition != -1 ? inputString.substring(dashPosition + 1) : '';
                requestBody.put('companyContractNumber', companyContractNumber);
            }

            if (contact != null) {
                requestBody.put('documentTypeCode', contact.CS_TipoIdentificacionCP__c);
                requestBody.put('injuredDocumentNumber', contact.CS_NumeroIdentificacionCP__c);
            }

            // default values
            requestBody.put('isLocalAffiliate', false);
            requestBody.put('originatesFromCode', '10'); 
            
            requestBody.put('notify', claim.Accept_Notifications__c ? '1' : '0');

            String procedureName = 'Request_CreateWorkAccident';
            Map<String, Object> ipInput = new Map<String, Object> ();
            Map<String, Object> ipOutput = new Map<String, Object> ();
            Map<String, Object> ipOptions = new Map<String, Object> ();

            String stringRequestBody = JSON.serialize(requestBody);
            System.debug('Request Body: ' + stringRequestBody);
            ipInput.put('requestBody', stringRequestBody);

            try {
                ipOutput = (Map<String, Object>) omnistudio.IntegrationProcedureService.runIntegrationService(procedureName, ipInput, ipOptions);

                Map<String, Object> responseCreateWorkAccident = (Map<String, Object>) ipOutput.get('responseCreateWorkAccident');
                
                System.debug('responseCreateWorkAccident => '+responseCreateWorkAccident);

                /*
                if (responseCreateWorkAccident != null && responseCreateWorkAccident.containsKey('message') && responseCreateWorkAccident.get('message') == 'Transaccion Exitosa') {
                    System.debug('Claim sent to Senda Medico successfully');
                    claim.CreationFailAtSendaMedico__c = false;
                    claim.Last_Attempt_to_Send_Senda__c = Datetime.now();
                    claim.CreationDateOnSendaMedico__c = Datetime.now();
                }else if (responseCreateWorkAccident != null && ((responseCreateWorkAccident.containsKey('errors') && responseCreateWorkAccident.get('errors') != null) ||
                    (responseCreateWorkAccident.containsKey('status') && responseCreateWorkAccident.get('status') != null))){
                    //System.debug('Error sending to Senda Medico: ' + responseCreateWorkAccident.get('errors'));
                    claim.CreationFailAtSendaMedico__c = true;
                    claim.Last_Attempt_to_Send_Senda__c = Datetime.now();
                }else{
                    claim.CreationFailAtSendaMedico__c = true;
                    claim.Last_Attempt_to_Send_Senda__c = Datetime.now();
                }
                */
                
                if (responseCreateWorkAccident != null && responseCreateWorkAccident.containsKey('message') && responseCreateWorkAccident.get('message') == 'Transaccion Exitosa') {
                    System.debug('Claim sent to Senda Medico successfully');
                    claim.ResponseSendaMedico__c = String.valueOf(responseCreateWorkAccident.get('message'));
                    claim.CreationFailAtSendaMedico__c = false;
                    claim.Last_Attempt_to_Send_Senda__c = Datetime.now();
                    claim.CreationDateOnSendaMedico__c = Datetime.now();
                }else{

                    if (responseCreateWorkAccident.containsKey('errors')) {
                        claim.ResponseSendaMedico__c = String.valueOf(responseCreateWorkAccident.get('errors'));
                    } else {
                        claim.ResponseSendaMedico__c = 'Error Codigo: '+String.valueOf(responseCreateWorkAccident.get('status'));
                    }
                    
                    claim.CreationFailAtSendaMedico__c = true;
                    claim.Last_Attempt_to_Send_Senda__c = Datetime.now();
                }
                
                update claim;
            } catch (Exception e) {
                System.debug('Error (VS_CallIPCreateWorckAccidentoToSendClaim): ' + e.getMessage());
                
                claim.CreationFailAtSendaMedico__c = true;
                claim.Last_Attempt_to_Send_Senda__c = Datetime.now();
                try {
                    update claim;
                } catch (DMLException mdlE) {
                    System.debug('ErrorDML: ' + mdlE.getMessage());
                }
            }
        }
        

    }
}