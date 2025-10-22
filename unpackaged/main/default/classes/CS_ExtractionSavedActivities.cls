/**
 * @author Harold Garcia Vargas
 * @email harold.garcia@vasscompany.com
 * @create date 2024-10-11 19:21:29
 * @modify date 2024-10-11 19:21:29
 * @desc Esta clase global con sharing implementa la interfaz Callable y se utiliza para filtrar actividades seleccionadas. 
 * Compara una lista de actividades seleccionadas (selectedRows) con una lista completa de actividades (responseSelectedActivities) 
 * y devuelve las actividades que no fueron seleccionadas. El resultado se almacena en el mapa de salida (output).
 */

global with sharing class CS_ExtractionSavedActivities implements Callable {
    public Object call(String action, Map<String, Object> args) {
        Map<String, Object> input = (Map<String, Object>) args.get('input');
        Map<String, Object> output = (Map<String, Object>) args.get('output');
        Map<String, Object> options = (Map<String, Object>) args.get('options');
        return invokeMethod(action, input, output, options);
    }
    
    private Object invokeMethod(String action, Map<String, Object> input, 
                                Map<String, Object> output, Map<String, Object> options) {  
        List<Map<String, Object>> filteredActivities = new List<Map<String, Object>>();
        if(action != null && action == 'Extraction'){
            try {
                List<Map<String, Object>> selectedRows = (List<Map<String, Object>>) input.get('selectedRows');
                List<Map<String, Object>> responseSelectedActivities = (List<Map<String, Object>>) input.get('ResponseSelectedActivities');
                Set<String> selectedIds = new Set<String>();
                for (Map<String, Object> row : selectedRows) {
                    selectedIds.add((String) row.get('Id'));
                }
                for (Map<String, Object> activity : responseSelectedActivities) {
                    if (!selectedIds.contains((String) activity.get('Id'))) {
                        filteredActivities.add(activity);
                    }
                }
            } catch (Exception e) {
                System.debug('Se produjo una excepción: ' + e.getMessage());
            }
        }else {
            System.debug('action  es nulo o no válido.');
        }
        return output.put('result', filteredActivities);
    } 

}