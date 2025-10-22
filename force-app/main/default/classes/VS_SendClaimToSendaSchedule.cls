public with sharing class VS_SendClaimToSendaSchedule implements Schedulable {
    @TestVisible
    private static Map<String, Schedule_Configuration__mdt> testMetadataMap;
    
    private static String MDT_NAME = 'Send_Claim_to_Senda';
    
    public void execute(SchedulableContext sc) {
        Schedule_Configuration__mdt met = Schedule_Configuration__mdt.getInstance(MDT_NAME);
        
        if (Test.isRunningTest()) {
            met = testMetadataMap.get(MDT_NAME);
        }
        // Search Claims
        List<Claim> claims = [
            SELECT Id, Name, Last_Attempt_to_Send_Senda__c, CreationDateOnSendaMedico__c, CreationFailAtSendaMedico__c, ReportedBy__c 
            FROM Claim 
            WHERE CreationFailAtSendaMedico__c = true
        ];

        Integer hours = Integer.valueOf(met.Time__c);
        Datetime nextRunTime = Datetime.now().addHours(hours); // * add hours in Integer
        
        try {

            Boolean isRunningToSecond = false;
             
            if (!claims.isEmpty()) {
                Integer counter = 0;
                for (Claim claim : claims) {
                    counter++;
    
                    // convert hours to ms
                    Decimal ms = met.Time__c * 60 * 60 * 1000;
    
                    Datetime currentTime = System.now();
                    if (claim.Last_Attempt_to_Send_Senda__c == null || (claim.Last_Attempt_to_Send_Senda__c != null && ((currentTime.getTime() - claim.Last_Attempt_to_Send_Senda__c.getTime()) >= ms || Test.isRunningTest()))) {
                        VS_CallIPCreateWorckAccidentoToSendClaim.callout(claim.Id);
                        isRunningToSecond = true;
                    }
    
                    if (claims.size() > counter && isRunningToSecond) {
                        nextRunTime = Datetime.now().addMinutes(2);
                        break;
                    }
                }
            }
            // Datetime nextRunTime = Datetime.now().addMinutes(1); // * add hours in Integer
        }catch (Exception e) {
            System.debug('Error inesperado (VS_SendClaimToSendaSchedule): ' + e.getMessage());
        }

        // seconds, minutes, hours, day of month, month, day of week, year
        String cronExp = '0 ' + nextRunTime.minute() + ' ' + nextRunTime.hour() + ' ' + nextRunTime.day() + ' ' + nextRunTime.month() + ' ? ' + nextRunTime.year();
        if (sc != null && !Test.isRunningTest()) {
            System.abortJob(sc.getTriggerId());
        }
        
        if (!Test.isRunningTest()) {
        	System.schedule('SendClaimToSendaSchedule', cronExp, new VS_SendClaimToSendaSchedule());
        }
    }
}