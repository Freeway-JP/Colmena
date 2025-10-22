@isTest
public class SlipDataHelperTest {
    
    @TestSetup
    static void setupTestData() {
        // Setup data if needed for future tests
    }
    
    @isTest
    static void testGetInsuredValueLabel_MultiplePlans() {
        Test.startTest();
        try {
            // Arrange
            SlipDataHelper helper = new SlipDataHelper();
            Map<String, Object> inputMap = new Map<String, Object>();
            Map<String, Object> outputMap = new Map<String, Object>();
            Map<String, Object> options = new Map<String, Object>();
            
            List<Object> coverageList = new List<Object>();
            Map<String, Object> coverage1 = new Map<String, Object>();
            coverage1.put('Plan__r.Name', 'Plan A');
            Map<String, Object> coverage2 = new Map<String, Object>();
            coverage2.put('Plan__r.Name', 'Plan B');
            
            coverageList.add(coverage1);
            coverageList.add(coverage2);
            
            inputMap.put('arguments', coverageList);
            
            // Act
            Boolean result = helper.invokeMethod('getInsuredValueLabel', inputMap, outputMap, options);
            
            // Assert
            System.assert(result, 'GetInsuredValueLabel method should return true');
            System.assert(outputMap.containsKey('result'), 'Output should contain result');
            System.assertEquals('Planes', outputMap.get('result'), 'Should return "Planes" for multiple plans');
            
        } catch (Exception e) {
            System.assert(false, 'Test failed with exception: ' + e.getMessage());
        }
        Test.stopTest();
    }
    
    @isTest
    static void testGetInsuredValueLabel_SinglePlan() {
        Test.startTest();
        try {
            // Arrange
            SlipDataHelper helper = new SlipDataHelper();
            Map<String, Object> inputMap = new Map<String, Object>();
            Map<String, Object> outputMap = new Map<String, Object>();
            Map<String, Object> options = new Map<String, Object>();
            
            List<Object> coverageList = new List<Object>();
            Map<String, Object> coverage1 = new Map<String, Object>();
            coverage1.put('Plan__r.Name', 'Plan A');
            
            coverageList.add(coverage1);
            
            inputMap.put('arguments', coverageList);
            
            // Act
            Boolean result = helper.invokeMethod('getInsuredValueLabel', inputMap, outputMap, options);
            
            // Assert
            System.assert(result, 'GetInsuredValueLabel method should return true');
            System.assert(outputMap.containsKey('result'), 'Output should contain result');
            System.assertEquals('Plan A', outputMap.get('result'), 'Should return plan name for single plan');
            
        } catch (Exception e) {
            System.assert(false, 'Test failed with exception: ' + e.getMessage());
        }
        Test.stopTest();
    }
    
    @isTest
    static void testGetApiValueByName() {
        Test.startTest();
        try {
            // Arrange
            SlipDataHelper helper = new SlipDataHelper();
            Map<String, Object> inputMap = new Map<String, Object>();
            Map<String, Object> outputMap = new Map<String, Object>();
            Map<String, Object> options = new Map<String, Object>();
            
            List<Object> argumentsList = new List<Object>();
            argumentsList.add('1'); // API value for Tomador
            
            inputMap.put('arguments', argumentsList);
            
            // Act
            Boolean result = helper.invokeMethod('getApiValueByName', inputMap, outputMap, options);
            
            // Assert
            System.assert(result, 'GetApiValueByName method should return true');
            System.assert(outputMap.containsKey('result'), 'Output should contain result');
            System.assertEquals('Tomador', outputMap.get('result'), 'Should return Tomador for API value 1');
            
        } catch (Exception e) {
            System.assert(false, 'Test failed with exception: ' + e.getMessage());
        }
        Test.stopTest();
    }
    
    @isTest
    static void testGetApiValueByName_MultipleValues() {
        Test.startTest();
        try {
            // Arrange
            SlipDataHelper helper = new SlipDataHelper();
            Map<String, Object> inputMap = new Map<String, Object>();
            Map<String, Object> outputMap = new Map<String, Object>();
            Map<String, Object> options = new Map<String, Object>();
            
            // Test multiple API values
            List<String> testValues = new List<String>{'1', '4', '23', '92', '10000'};
            List<String> expectedResults = new List<String>{'Tomador', 'Conductor habitual', 'Cónyuge', 'Consultor Comercial', 'Desconocido'};
            
            for (Integer i = 0; i < testValues.size(); i++) {
                List<Object> argumentsList = new List<Object>();
                argumentsList.add(testValues[i]);
                inputMap.put('arguments', argumentsList);
                
                // Act
                Boolean result = helper.invokeMethod('getApiValueByName', inputMap, outputMap, options);
                
                // Assert
                System.assert(result, 'GetApiValueByName method should return true for value: ' + testValues[i]);
                System.assertEquals(expectedResults[i], outputMap.get('result'), 'Should return correct role for API value: ' + testValues[i]);
            }
            
        } catch (Exception e) {
            System.assert(false, 'Test failed with exception: ' + e.getMessage());
        }
        Test.stopTest();
    }
    
    @isTest
    static void testGetApiValueByName_InvalidValue() {
        Test.startTest();
        try {
            // Arrange
            SlipDataHelper helper = new SlipDataHelper();
            Map<String, Object> inputMap = new Map<String, Object>();
            Map<String, Object> outputMap = new Map<String, Object>();
            Map<String, Object> options = new Map<String, Object>();
            
            List<Object> argumentsList = new List<Object>();
            argumentsList.add('999'); // Invalid API value
            
            inputMap.put('arguments', argumentsList);
            
            // Act
            Boolean result = helper.invokeMethod('getApiValueByName', inputMap, outputMap, options);
            
            // Assert
            System.assert(result, 'GetApiValueByName method should return true even for invalid values');
            System.assertEquals(null, outputMap.get('result'), 'Should return null for invalid API value');
            
        } catch (Exception e) {
            System.assert(false, 'Test failed with exception: ' + e.getMessage());
        }
        Test.stopTest();
    }
    
    @isTest
    static void testGetExpeditionnDate() {
        Test.startTest();
        try {
            // Arrange
            SlipDataHelper helper = new SlipDataHelper();
            Map<String, Object> inputMap = new Map<String, Object>();
            Map<String, Object> outputMap = new Map<String, Object>();
            Map<String, Object> options = new Map<String, Object>();
            
            // Act
            Boolean result = helper.invokeMethod('getExpeditionnDate', inputMap, outputMap, options);
            
            // Assert
            System.assert(result, 'GetExpeditionnDate method should return true');
            System.assert(outputMap.containsKey('result'), 'Output should contain result');
            
            String expeditionDate = (String) outputMap.get('result');
            System.assertNotEquals(null, expeditionDate, 'Expedition date should not be null');
            System.assert(expeditionDate.contains(' de '), 'Date should be in Spanish format with "de"');
            
            // Validate format: "Día DD de Mes de YYYY" (without comma)
            List<String> validDays = new List<String>{'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'};
            List<String> validMonths = new List<String>{'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'};
            
            Boolean containsValidDay = false;
            Boolean containsValidMonth = false;
            
            for (String day : validDays) {
                if (expeditionDate.contains(day)) {
                    containsValidDay = true;
                    break;
                }
            }
            
            for (String month : validMonths) {
                if (expeditionDate.contains(month)) {
                    containsValidMonth = true;
                    break;
                }
            }
            
            System.assert(containsValidDay, 'Date should contain a valid Spanish day name');
            System.assert(containsValidMonth, 'Date should contain a valid Spanish month name');
            System.assert(expeditionDate.contains(String.valueOf(Date.today().year())), 'Date should contain current year');
            
        } catch (Exception e) {
            System.assert(false, 'Test failed with exception: ' + e.getMessage());
        }
        Test.stopTest();
    }
    
    @isTest
    static void testGetInsuredValueLabel_EmptyList() {
        Test.startTest();
        try {
            // Arrange
            SlipDataHelper helper = new SlipDataHelper();
            Map<String, Object> inputMap = new Map<String, Object>();
            Map<String, Object> outputMap = new Map<String, Object>();
            Map<String, Object> options = new Map<String, Object>();
            
            List<Object> coverageList = new List<Object>();
            inputMap.put('arguments', coverageList);
            
            // Act
            Boolean result = helper.invokeMethod('getInsuredValueLabel', inputMap, outputMap, options);
            
            // Assert
            System.assert(result, 'GetInsuredValueLabel method should return true');
            System.assert(outputMap.containsKey('result'), 'Output should contain result');
            System.assertEquals('No aplica', outputMap.get('result'), 'Should return "No aplica" for empty list');
            
        } catch (Exception e) {
            System.assert(false, 'Test failed with exception: ' + e.getMessage());
        }
        Test.stopTest();
    }
    
    @isTest
    static void testInvalidMethodName() {
        Test.startTest();
        try {
            // Arrange
            SlipDataHelper helper = new SlipDataHelper();
            Map<String, Object> inputMap = new Map<String, Object>();
            Map<String, Object> outputMap = new Map<String, Object>();
            Map<String, Object> options = new Map<String, Object>();
            
            // Act
            Boolean result = helper.invokeMethod('invalidMethod', inputMap, outputMap, options);
            
            // Assert
            System.assert(!result, 'Invalid method name should return false');
            
        } catch (Exception e) {
            System.assert(false, 'Test failed with exception: ' + e.getMessage());
        }
        Test.stopTest();
    }
    
    @isTest
    static void testCallMethod() {
        Test.startTest();
        try {
            // Arrange
            SlipDataHelper helper = new SlipDataHelper();
            Map<String, Object> args = new Map<String, Object>();
            Map<String, Object> input = new Map<String, Object>();
            Map<String, Object> output = new Map<String, Object>();
            Map<String, Object> options = new Map<String, Object>();
            
            args.put('input', input);
            args.put('output', output);
            args.put('options', options);
            
            // Act
            Object result = helper.call('getExpeditionnDate', args);
            
            // Assert
            System.assertNotEquals(null, result, 'Call method should return a result');
            
        } catch (Exception e) {
            System.assert(false, 'Test failed with exception: ' + e.getMessage());
        }
        Test.stopTest();
    }
    
    @isTest
    static void testDeduplicateCoveragesByName() {
        Test.startTest();
        try {
            // Arrange
            SlipDataHelper helper = new SlipDataHelper();
            Map<String, Object> inputMap = new Map<String, Object>();
            Map<String, Object> outputMap = new Map<String, Object>();
            Map<String, Object> options = new Map<String, Object>();
            
            List<Object> coverageList = new List<Object>();
            
            // Crear coberturas duplicadas
            Map<String, Object> coverage1 = new Map<String, Object>();
            coverage1.put('Cobertura', 'Muerte por Cualquier Causa');
            coverage1.put('PlanName', 'Plan SA Libre I');
            coverage1.put('SumaAsegurada', 1000000);
            
            Map<String, Object> coverage2 = new Map<String, Object>();
            coverage2.put('Cobertura', 'Muerte por Cualquier Causa'); // Duplicada
            coverage2.put('PlanName', 'Plan SA Libre II');
            coverage2.put('SumaAsegurada', 30000000);
            
            Map<String, Object> coverage3 = new Map<String, Object>();
            coverage3.put('Cobertura', 'Gastos Exequiales');
            coverage3.put('PlanName', 'Plan SA Libre I');
            coverage3.put('SumaAsegurada', 800000);
            
            Map<String, Object> coverage4 = new Map<String, Object>();
            coverage4.put('Cobertura', 'Asistencia en Viajes');
            coverage4.put('PlanName', 'Plan SA Libre I');
            coverage4.put('SumaAsegurada', 60000);
            
            Map<String, Object> coverage5 = new Map<String, Object>();
            coverage5.put('Cobertura', 'Asistencia en Viajes'); // Duplicada
            coverage5.put('PlanName', 'Plan SA Libre III');
            coverage5.put('SumaAsegurada', 60000);
            
            coverageList.add(coverage1);
            coverageList.add(coverage2);
            coverageList.add(coverage3);
            coverageList.add(coverage4);
            coverageList.add(coverage5);
            
            inputMap.put('arguments', coverageList);
            
            // Act
            Boolean result = helper.invokeMethod('deduplicateCoveragesByName', inputMap, outputMap, options);
            
            // Assert
            System.assert(result, 'DeduplicateCoveragesByName method should return true');
            System.assert(outputMap.containsKey('result'), 'Output should contain result');
            
            Map<String, Object> deduplicatedResult = (Map<String, Object>) outputMap.get('result');
            System.assert(deduplicatedResult.containsKey('Coverages'), 'Result should contain Coverages node');
            
            List<Object> uniqueCoverages = (List<Object>) deduplicatedResult.get('Coverages');
            System.assertEquals(3, uniqueCoverages.size(), 'Should have 3 unique coverages after deduplication');
            
            // Verificar que se mantuvieron las primeras ocurrencias
            Set<String> coverageNames = new Set<String>();
            for (Object coverage : uniqueCoverages) {
                Map<String, Object> coverageMap = (Map<String, Object>) coverage;
                String coverageName = (String) coverageMap.get('Cobertura');
                coverageNames.add(coverageName);
            }
            
            System.assert(coverageNames.contains('Muerte por Cualquier Causa'), 'Should contain Muerte por Cualquier Causa');
            System.assert(coverageNames.contains('Gastos Exequiales'), 'Should contain Gastos Exequiales');
            System.assert(coverageNames.contains('Asistencia en Viajes'), 'Should contain Asistencia en Viajes');
            
        } catch (Exception e) {
            System.assert(false, 'Test failed with exception: ' + e.getMessage());
        }
        Test.stopTest();
    }
    
    @isTest
    static void testDeduplicateCoveragesByName_EmptyList() {
        Test.startTest();
        try {
            // Arrange
            SlipDataHelper helper = new SlipDataHelper();
            Map<String, Object> inputMap = new Map<String, Object>();
            Map<String, Object> outputMap = new Map<String, Object>();
            Map<String, Object> options = new Map<String, Object>();
            
            List<Object> coverageList = new List<Object>();
            inputMap.put('arguments', coverageList);
            
            // Act
            Boolean result = helper.invokeMethod('deduplicateCoveragesByName', inputMap, outputMap, options);
            
            // Assert
            System.assert(result, 'DeduplicateCoveragesByName method should return true');
            Map<String, Object> deduplicatedResult = (Map<String, Object>) outputMap.get('result');
            List<Object> coverages = (List<Object>) deduplicatedResult.get('Coverages');
            System.assertEquals(0, coverages.size(), 'Should return empty list for empty input');
            
        } catch (Exception e) {
            System.assert(false, 'Test failed with exception: ' + e.getMessage());
        }
        Test.stopTest();
    }
}