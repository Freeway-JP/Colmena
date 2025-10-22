@isTest
private class IntegrationProcedureInvocableTest {
    @isTest
    static void testRunIntegrationServiceInvocable() {
        IntegrationProcedureInvocable.IntegrationProcedureInput input = new IntegrationProcedureInvocable.IntegrationProcedureInput();
        input.procedureAPIName = 'Test_Procedure';
        input.input = 'Test_Id';
        
        List<IntegrationProcedureInvocable.IntegrationProcedureInput> inputList = new List<IntegrationProcedureInvocable.IntegrationProcedureInput>{ input };
        
        Test.startTest();

        List<IntegrationProcedureInvocable.IntegrationProcedureOutput> results = IntegrationProcedureInvocable.runIntegrationServiceInvocable(inputList);
        
        Test.stopTest();

        System.assertNotEquals(null, results, 'El resultado no debe ser null');
    }
}