@isTest
public class IntegrationProcedureInvocableAsyncTest {
    
    @isTest
    static void testRunIntegrationServiceInvocable() {
        IntegrationProcedureInvocableAsync.IntegrationProcedureInput input = new IntegrationProcedureInvocableAsync.IntegrationProcedureInput();
        input.procedureAPIName = 'TestProcedure';
        input.input = 'TestInput';
        
        List<IntegrationProcedureInvocableAsync.IntegrationProcedureInput> inputList = new List<IntegrationProcedureInvocableAsync.IntegrationProcedureInput>{input};
        
        Test.startTest();
        IntegrationProcedureInvocableAsync.runIntegrationServiceInvocable(inputList);
        Test.stopTest();
        
    }
    
    @isTest
    static void testCallIntegrationProcedureAsync() {
        Test.startTest();
        IntegrationProcedureInvocableAsync.callIntegrationProcedureAsync('TestProcedure', 'TestInput');
        Test.stopTest();

    }
}