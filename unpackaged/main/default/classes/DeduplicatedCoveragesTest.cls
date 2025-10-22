@isTest
public class DeduplicatedCoveragesTest {
    
    @TestSetup
    static void setupTestData() {
        // Setup data if needed for future tests
    }
    
    @isTest
    static void testDeduplicateMethod() {
        Test.startTest();
        try {
            // Arrange
            DeduplicatedCoverages deduplicator = new DeduplicatedCoverages();
            Map<String, Object> inputMap = new Map<String, Object>();
            Map<String, Object> outputMap = new Map<String, Object>();
            Map<String, Object> options = new Map<String, Object>();
            
            List<Object> coverageList = new List<Object>();
            Map<String, Object> coverage1 = new Map<String, Object>();
            coverage1.put('ChildProductId', '123');
            coverage1.put('CoverageName', 'Test Coverage 1');
            
            Map<String, Object> coverage2 = new Map<String, Object>();
            coverage2.put('ChildProductId', '123'); // Duplicate
            coverage2.put('CoverageName', 'Test Coverage 2');
            
            Map<String, Object> coverage3 = new Map<String, Object>();
            coverage3.put('ChildProductId', '456');
            coverage3.put('CoverageName', 'Test Coverage 3');
            
            coverageList.add(coverage1);
            coverageList.add(coverage2);
            coverageList.add(coverage3);
            
            inputMap.put('coverages', coverageList);
            
            // Act
            Boolean result = deduplicator.invokeMethod('deduplicate', inputMap, outputMap, options);
            
            // Assert
            System.assert(result, 'Deduplicate method should return true');
            System.assert(outputMap.containsKey('deduplicatedCoverages'), 'Output should contain deduplicatedCoverages');
            
            List<Object> deduplicatedList = (List<Object>) outputMap.get('deduplicatedCoverages');
            System.assertEquals(2, deduplicatedList.size(), 'Should have 2 unique coverages after deduplication');
            
        } catch (Exception e) {
            System.assert(false, 'Test failed with exception: ' + e.getMessage());
        }
        Test.stopTest();
    }
    
    @isTest
    static void testCombinePlansWithCoverages() {
        Test.startTest();
        try {
            // Arrange
            DeduplicatedCoverages deduplicator = new DeduplicatedCoverages();
            Map<String, Object> inputMap = new Map<String, Object>();
            Map<String, Object> outputMap = new Map<String, Object>();
            Map<String, Object> options = new Map<String, Object>();
            
            List<Object> plansList = new List<Object>();
            Map<String, Object> plan1 = new Map<String, Object>();
            plan1.put('Name', 'Test Plan 1');
            plan1.put('Id', 'plan123');
            plan1.put('Value', '1000');
            plansList.add(plan1);
            
            List<Object> coveragesList = new List<Object>();
            Map<String, Object> coverage1 = new Map<String, Object>();
            coverage1.put('CoverageName', 'Test Coverage');
            coverage1.put('ChildProductId', 'child123');
            coverage1.put('isOptional', false);
            coverage1.put('Value', '500');
            coveragesList.add(coverage1);
            
            inputMap.put('ListOfPlans', plansList);
            inputMap.put('FinalCoverages', coveragesList);
            
            // Act
            Boolean result = deduplicator.invokeMethod('combinePlansWithCoverages', inputMap, outputMap, options);
            
            // Assert
            System.assert(result, 'CombinePlansWithCoverages method should return true');
            System.assert(outputMap.containsKey('combinedResults'), 'Output should contain combinedResults');
            
            List<Object> combinedList = (List<Object>) outputMap.get('combinedResults');
            System.assertEquals(1, combinedList.size(), 'Should have 1 combined result');
            
            Map<String, Object> combinedItem = (Map<String, Object>) combinedList[0];
            System.assertEquals('Test Plan 1', combinedItem.get('ParentProductName'), 'Parent product name should match');
            System.assertEquals('1000', combinedItem.get('Value'), 'Value should be from plan for non-optional coverage');
            
        } catch (Exception e) {
            System.assert(false, 'Test failed with exception: ' + e.getMessage());
        }
        Test.stopTest();
    }
    
    @isTest
    static void testGetUniquePlanNames() {
        Test.startTest();
        try {
            // Arrange
            DeduplicatedCoverages deduplicator = new DeduplicatedCoverages();
            Map<String, Object> inputMap = new Map<String, Object>();
            Map<String, Object> outputMap = new Map<String, Object>();
            Map<String, Object> options = new Map<String, Object>();
            
            List<Object> coverageList = new List<Object>();
            Map<String, Object> coverage1 = new Map<String, Object>();
            coverage1.put('Plan__r.Name', 'Plan A');
            Map<String, Object> coverage2 = new Map<String, Object>();
            coverage2.put('Plan__r.Name', 'Plan B');
            Map<String, Object> coverage3 = new Map<String, Object>();
            coverage3.put('Plan__r.Name', 'Plan A'); // Duplicate
            
            coverageList.add(coverage1);
            coverageList.add(coverage2);
            coverageList.add(coverage3);
            
            inputMap.put('arguments', coverageList);
            
            // Act
            Boolean result = deduplicator.invokeMethod('getUniquePlanNames', inputMap, outputMap, options);
            
            // Assert
            System.assert(result, 'GetUniquePlanNames method should return true');
            System.assert(outputMap.containsKey('result'), 'Output should contain result');
            
            Map<String, String> planResult = (Map<String, String>) outputMap.get('result');
            System.assertNotEquals('No aplica', planResult.get('Plan1'), 'Plan1 should have a value');
            System.assertNotEquals('No aplica', planResult.get('Plan2'), 'Plan2 should have a value');
            System.assertEquals('No aplica', planResult.get('Plan3'), 'Plan3 should be No aplica');
            
        } catch (Exception e) {
            System.assert(false, 'Test failed with exception: ' + e.getMessage());
        }
        Test.stopTest();
    }
    
    @isTest
    static void testGetCoverageTable() {
        Test.startTest();
        try {
            // Arrange
            DeduplicatedCoverages deduplicator = new DeduplicatedCoverages();
            Map<String, Object> inputMap = new Map<String, Object>();
            Map<String, Object> outputMap = new Map<String, Object>();
            Map<String, Object> options = new Map<String, Object>();
            
            List<Object> coverageList = new List<Object>();
            Map<String, Object> coverage1 = new Map<String, Object>();
            coverage1.put('Plan__r.Name', 'Plan A');
            coverage1.put('CoverageName__c', 'coverage123');
            coverage1.put('CoverageName__r.Name', 'Test Coverage');
            coverage1.put('vlocity_ins__TotalSumInsured__c', 1000000);
            
            coverageList.add(coverage1);
            inputMap.put('arguments', coverageList);
            
            // Act
            Boolean result = deduplicator.invokeMethod('getCoverageTable', inputMap, outputMap, options);
            
            // Assert
            System.assert(result, 'GetCoverageTable method should return true');
            System.assert(outputMap.containsKey('result'), 'Output should contain result');
            
            Map<String, Object> tableResult = (Map<String, Object>) outputMap.get('result');
            System.assert(tableResult.containsKey('Coberturas'), 'Result should contain Coberturas');
            
            List<Object> coberturas = (List<Object>) tableResult.get('Coberturas');
            System.assertEquals(1, coberturas.size(), 'Should have 1 coverage row');
            
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
            DeduplicatedCoverages deduplicator = new DeduplicatedCoverages();
            Map<String, Object> inputMap = new Map<String, Object>();
            Map<String, Object> outputMap = new Map<String, Object>();
            Map<String, Object> options = new Map<String, Object>();
            
            // Act
            Boolean result = deduplicator.invokeMethod('invalidMethod', inputMap, outputMap, options);
            
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
            DeduplicatedCoverages deduplicator = new DeduplicatedCoverages();
            Map<String, Object> args = new Map<String, Object>();
            Map<String, Object> input = new Map<String, Object>();
            Map<String, Object> output = new Map<String, Object>();
            Map<String, Object> options = new Map<String, Object>();
            
            args.put('input', input);
            args.put('output', output);
            args.put('options', options);
            
            // Act
            Object result = deduplicator.call('test', args);
            
            // Assert
            System.assertNotEquals(null, result, 'Call method should return a result');
            
        } catch (Exception e) {
            System.assert(false, 'Test failed with exception: ' + e.getMessage());
        }
        Test.stopTest();
    }
}