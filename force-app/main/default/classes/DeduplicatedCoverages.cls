global with sharing class DeduplicatedCoverages implements Callable {
    
    global Object call(String action, Map<String, Object> args) {
        System.debug('Entering call method');
        Map<String, Object> input = (Map<String, Object>) args.get('input');
        Map<String, Object> output = (Map<String, Object>) args.get('output');
        Map<String, Object> options = (Map<String, Object>) args.get('options');
        return invokeMethod(action, input, output, options);
    }

    global Boolean invokeMethod(String methodName, Map<String, Object> inputMap, Map<String, Object> outMap, Map<String, Object> options) {
        System.debug('Entering invokeMethod: ' + methodName);
        Boolean result = true;
        try {
            if (methodName.equals('deduplicate')) {
                deduplicateList(inputMap, outMap, options);
            } else if (methodName.equals('combinePlansWithCoverages')) {
                combinePlansWithCoverages(inputMap, outMap, options);
            } else if (methodName.equals('test')) {
                List<Object> arguments = (List<Object>)inputMap.get('arguments');
                outMap.put('result', test(arguments));
            } else if (methodName.equals('getUniquePlanNames')) {
                List<Object> arguments = (List<Object>)inputMap.get('arguments');
                outMap.put('result', getUniquePlanNames(arguments));
            } else if (methodName.equals('getCoverageTable')) {
                List<Object> arguments = (List<Object>)inputMap.get('arguments');
                outMap.put('result', getCoverageTable(arguments));
            } else {
                result = false;
            }
        } catch(Exception e) {
            System.debug('Exception in invokeMethod: ' + e.getMessage());
            System.debug('LineNumber: ' + e.getLineNumber());
            System.debug('StackTrace: ' + e.getStackTraceString());
            System.debug('TypeName: ' + e.getTypeName());
            result = false;
        }
        return result;
    }
    
    private List<Object> deduplicateList(Map<String, Object> inputMap, Map<String, Object> outMap, Map<String, Object> options) {
        List<Object> coverageList = (List<Object>) inputMap.get('coverages');
        Map<String, Object> uniqueMap = new Map<String, Object>();
        List<Object> dedupedList = new List<Object>();

        for (Object coverage : coverageList) {
            try {
                Map<String, Object> coverageMap = (Map<String, Object>) coverage;
                String childProductId = (String) coverageMap.get('ChildProductId');
                // Solo agregar si no existe ya en el mapa
                if (String.isNotBlank(childProductId) && !uniqueMap.containsKey(childProductId)) {
                    uniqueMap.put(childProductId, coverage);
                }
            } catch (Exception e) {
                System.debug('Error processing coverage item: ' + e.getMessage());
                continue;
            }
        }
        // Retornar la lista deduplicada
        dedupedList.addAll(uniqueMap.values());
        // Si se espera el resultado en outMap, puedes ponerlo así:
        if (outMap != null) {
            outMap.put('deduplicatedCoverages', dedupedList);
        }
        return dedupedList;
    }

    private List<Object> combinePlansWithCoverages(Map<String, Object> inputMap, Map<String, Object> outMap, Map<String, Object> options) {
        List<Object> plansList = (List<Object>) inputMap.get('ListOfPlans');
        List<Object> coveragesList = (List<Object>) inputMap.get('FinalCoverages');
        List<Object> combinedList = new List<Object>();
        
        System.debug('Plans count: ' + (plansList != null ? plansList.size() : 0));
        System.debug('Coverages count: ' + (coveragesList != null ? coveragesList.size() : 0));
        
        if (plansList == null || coveragesList == null) {
            System.debug('One of the input lists is null');
            if (outMap != null) {
                outMap.put('combinedResults', combinedList);
            }
            return combinedList;
        }
        
        // Iterar sobre cada plan
        for (Object planObj : plansList) {
            try {
                Map<String, Object> plan = (Map<String, Object>) planObj;
                String planName = (String) plan.get('Name');
                String planId = (String) plan.get('Id');
                String planValue = (String) plan.get('Value');
                
                // Para cada plan, iterar sobre cada cobertura
                for (Object coverageObj : coveragesList) {
                    try {
                        Map<String, Object> coverage = (Map<String, Object>) coverageObj;
                        Boolean isOptional = (Boolean) coverage.get('isOptional');
                        String coverageValue = (String) coverage.get('Value');
                        
                        // Crear el objeto combinado
                        Map<String, Object> combinedItem = new Map<String, Object>();
                        combinedItem.put('ParentProductName', planName);
                        combinedItem.put('ParentProductId', planId);
                        combinedItem.put('CoverageName', coverage.get('CoverageName'));
                        combinedItem.put('ChildProductId', coverage.get('ChildProductId'));
                        combinedItem.put('isOptional', isOptional);
                        
                        // Determinar qué valor usar según isOptional
                        if (isOptional != null && isOptional) {
                            // Si es opcional, usar valor de la cobertura
                            combinedItem.put('Value', coverageValue);
                        } else {
                            // Si no es opcional, usar valor del plan
                            combinedItem.put('Value', planValue);
                        }
                        
                        combinedList.add(combinedItem);
                        
                    } catch (Exception e) {
                        System.debug('Error processing coverage item: ' + e.getMessage());
                        continue;
                    }
                }
                
            } catch (Exception e) {
                System.debug('Error processing plan item: ' + e.getMessage());
                continue;
            }
        }
        
        System.debug('Combined list size: ' + combinedList.size());
        
        // Guardar resultado en outMap
        if (outMap != null) {
            outMap.put('combinedResults', combinedList);
        }
        
        return combinedList;
    }

    public List<Object> test(List<Object> arguments)
	{
        // String currencyString = arguments[0]?.toString();
        return arguments;
    }

    public Map<String, String> getUniquePlanNames(List<Object> coverageList) {
        Set<String> uniquePlanNames = new Set<String>();
        
        // Extraer nombres únicos de planes
        for (Object coverage : coverageList) {
            if (coverage != null) {
                try {
                    Map<String, Object> coverageMap = (Map<String, Object>) coverage;
                    
                    String planName = null;
                    
                    // Intentar obtener el nombre del plan
                    if (coverageMap.containsKey('Plan__r.Name')) {
                        planName = (String) coverageMap.get('Plan__r.Name');
                    }
                    else if (coverageMap.containsKey('PlanName')) {
                        planName = (String) coverageMap.get('PlanName');
                    }
                    
                    if (String.isNotBlank(planName)) {
                        uniquePlanNames.add(planName);
                    }
                    
                } catch (Exception e) {
                    System.debug('Error processing coverage item for plan names: ' + e.getMessage());
                    continue;
                }
            }
        }
        
        // Crear estructura de salida
        Map<String, String> planResult = new Map<String, String>();
        planResult.put('Plan1', 'No aplica');
        planResult.put('Plan2', 'No aplica');
        planResult.put('Plan3', 'No aplica');
        planResult.put('Plan4', 'No aplica');
        planResult.put('Plan5', 'No aplica');
        
        // Llenar con los nombres encontrados
        List<String> planList = new List<String>(uniquePlanNames);
        for (Integer i = 0; i < planList.size() && i < 5; i++) {
            planResult.put('Plan' + (i + 1), planList[i]);
        }
        
        return planResult;
    }

    public Map<String, Object> getCoverageTable(List<Object> coverageList) {
        // Primero, obtener el orden de los planes
        Set<String> uniquePlanNames = new Set<String>();
        List<String> orderedPlanNames = new List<String>();
        
        for (Object coverage : coverageList) {
            if (coverage != null) {
                try {
                    Map<String, Object> coverageMap = (Map<String, Object>) coverage;
                    String planName = null;
                    
                    if (coverageMap.containsKey('Plan__r.Name')) {
                        planName = (String) coverageMap.get('Plan__r.Name');
                    }
                    
                    if (String.isNotBlank(planName) && !uniquePlanNames.contains(planName)) {
                        uniquePlanNames.add(planName);
                        orderedPlanNames.add(planName);
                    }
                } catch (Exception e) {
                    continue;
                }
            }
        }
        
        // Obtener coberturas únicas
        Map<String, String> coverageIdToName = new Map<String, String>();
        Set<String> uniqueCoverageIds = new Set<String>();
        
        for (Object coverage : coverageList) {
            if (coverage != null) {
                try {
                    Map<String, Object> coverageMap = (Map<String, Object>) coverage;
                    String coverageId = (String) coverageMap.get('CoverageName__c');
                    String coverageName = (String) coverageMap.get('CoverageName__r.Name');
                    
                    if (String.isNotBlank(coverageId) && String.isNotBlank(coverageName)) {
                        coverageIdToName.put(coverageId, coverageName);
                        uniqueCoverageIds.add(coverageId);
                    }
                } catch (Exception e) {
                    continue;
                }
            }
        }
        
        // Crear la tabla de coberturas
        List<Map<String, Object>> coberturas = new List<Map<String, Object>>();
        
        for (String coverageId : uniqueCoverageIds) {
            Map<String, Object> coverageRow = new Map<String, Object>();
            coverageRow.put('NombreCobertura', coverageIdToName.get(coverageId));
            
            // Crear un mapa temporal para obtener valores por plan
            Map<String, Object> valuesByPlan = new Map<String, Object>();
            
            for (Object coverage : coverageList) {
                if (coverage != null) {
                    try {
                        Map<String, Object> coverageMap = (Map<String, Object>) coverage;
                        String currentCoverageId = (String) coverageMap.get('CoverageName__c');
                        String planName = (String) coverageMap.get('Plan__r.Name');
                        Object sumInsured = coverageMap.get('vlocity_ins__TotalSumInsured__c');
                        
                        if (coverageId.equals(currentCoverageId) && String.isNotBlank(planName)) {
                            valuesByPlan.put(planName, sumInsured);
                        }
                    } catch (Exception e) {
                        continue;
                    }
                }
            }
            
            // Asignar valores a Plan1, Plan2, Plan3, Plan4, Plan5 en el orden correcto
            for (Integer i = 0; i < 5; i++) {
                String planKey = 'ValorPlan' + (i + 1);
                if (i < orderedPlanNames.size()) {
                    String planName = orderedPlanNames[i];
                    Object value = valuesByPlan.get(planName);
                    coverageRow.put(planKey, value != null ? formatCurrency(value) : '---');
                } else {
                    coverageRow.put(planKey, '---');
                }
            }
            
            coberturas.add(coverageRow);
        }
        
        Map<String, Object> result = new Map<String, Object>();
        result.put('Coberturas', coberturas);
        return result;
    }

    // Método auxiliar para formatear moneda
    private String formatCurrency(Object value) {
        if (value == null) return '---';
        
        try {
            Decimal decimalValue = Decimal.valueOf(String.valueOf(value));
            String formattedValue = String.valueOf(decimalValue.format());
            return '$ ' + formattedValue;
        } catch (Exception e) {
            return String.valueOf(value);
        }
    }
}