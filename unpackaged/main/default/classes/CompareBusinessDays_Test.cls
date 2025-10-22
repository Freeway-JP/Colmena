@isTest
private class CompareBusinessDays_Test {

    @isTest
    static void testInvokeMethod() {
        // Crear datos de entrada simulados
        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> classificationMailbox = new Map<String, Object>();

        // Establecer una fecha futura (por ejemplo, 5 días después de hoy)
        Date futureDate = System.today().addDays(5);
        classificationMailbox.put('AppoimentDate', String.valueOf(futureDate));
        inputMap.put('ClassificationMailbox', classificationMailbox);

        Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> optionsMap = new Map<String, Object>();

        // Instanciar la clase a probar
        CompareBusinessDays instance = new CompareBusinessDays();

        // Ejecutar el método
        Boolean result = instance.invokeMethod('invokeMethod', inputMap, outputMap, optionsMap);

        // Verificar que el resultado sea true
        System.assertEquals(true, result);

        // Verificar que el mapa de salida contiene la clave 'totalDiasHabiles'
        System.assert(outputMap.containsKey('totalDiasHabiles'));

        // Verificar que el valor sea un número entero
        Integer diasHabiles = (Integer)outputMap.get('totalDiasHabiles');
        System.assertNotEquals(null, diasHabiles);
        System.assert(diasHabiles >= 0, 'Los días hábiles deben ser cero o más');
    }
}