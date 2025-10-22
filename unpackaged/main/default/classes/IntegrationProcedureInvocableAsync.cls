public class IntegrationProcedureInvocableAsync {
    
    @InvocableMethod(label = 'Integration Procedure Async')
    public static void runIntegrationServiceInvocable(List<IntegrationProcedureInput> inputList) {
        if (!inputList.isEmpty()) {
            callIntegrationProcedureAsync(inputList[0].procedureAPIName, inputList[0].input);
        }
    }
    
    @future(callout=true)
    public static void callIntegrationProcedureAsync(String procedureAPIName, String input) {
        System.debug(LoggingLevel.Error, 'Calling Integration Procedure Async with Input: ' + input);
        
        String output = JSON.serialize(
            omnistudio.IntegrationProcedureService.runIntegrationService(
                procedureAPIName,
                new Map<String, Object>{ 'Id' => input },
                new Map<String, Object>()
            )
        );
        
        System.debug(LoggingLevel.Error, 'Integration Procedure Response: ' + output);
        
    }
    
    public class IntegrationProcedureInput {
        @InvocableVariable(label = 'Procedure Name') public String procedureAPIName;
        @InvocableVariable(label = 'Input') public String input;
    }
}