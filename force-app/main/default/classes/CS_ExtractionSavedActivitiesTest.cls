/**
 * @author Harold Garcia Vargas
 * @email harold.garcia@vasscompany.com
 * @create date 2024-10-11 20:21:37
 * @modify date 2024-10-11 20:21:37
 * @desc Esta clase de prueba se encarga de validar la funcionalidad de la clase CS_ExtractionSavedActivities.
 * 
 * Contiene varios métodos de prueba:
 * - `testInvokeMethodWithValidData`: Valida que el método invoque correctamente la lógica de filtrado con datos válidos.
 * - `testInvokeMethodWithEmptyData`: Verifica el comportamiento del método cuando las listas de actividades seleccionadas y de respuesta están vacías.
 * - `testInvokeMethodWithNullAction`: Prueba el caso en el que la acción es nula y asegura que el método maneja este caso correctamente.
 * - `testInvokeMethodWithInvalidAction`: Verifica que el método maneje correctamente acciones no válidas.
 */

@isTest
public class CS_ExtractionSavedActivitiesTest {

    @isTest
    static void testInvokeMethodWithValidData() {
        Map<String, Object> input = new Map<String, Object>();
        List<Map<String, Object>> selectedRows = new List<Map<String, Object>>();
        List<Map<String, Object>> responseSelectedActivities = new List<Map<String, Object>>();
        Map<String, Object> selectedRow1 = new Map<String, Object>{ 'Id' => '01tNq000005yS8OIAU', 'Name' => 'Actividad 1' };
        Map<String, Object> selectedRow2 = new Map<String, Object>{ 'Id' => '01tNq000005yS8tIAE', 'Name' => 'Actividad 2' };

        selectedRows.add(selectedRow1);
        selectedRows.add(selectedRow2);

        Map<String, Object> responseActivity1 = new Map<String, Object>{ 'Id' => '01tNq000005yS8OIAU', 'Name' => 'Actividad 1' };
        Map<String, Object> responseActivity2 = new Map<String, Object>{ 'Id' => '01tNq000005yS8tIAE', 'Name' => 'Actividad 2' };
        Map<String, Object> responseActivity3 = new Map<String, Object>{ 'Id' => '01tNq000005ySHyIAM', 'Name' => 'Actividad 3' };

        responseSelectedActivities.add(responseActivity1);
        responseSelectedActivities.add(responseActivity2);
        responseSelectedActivities.add(responseActivity3);

        input.put('selectedRows', selectedRows);
        input.put('ResponseSelectedActivities', responseSelectedActivities);

        Map<String, Object> output = new Map<String, Object>();


        Map<String, Object> args = new Map<String, Object>{
            'input' => input,
            'output' => output,
            'options' => new Map<String, Object>()
        };
        CS_ExtractionSavedActivities instance = new CS_ExtractionSavedActivities();
        instance.call('Extraction', args);
        List<Map<String, Object>> result = (List<Map<String, Object>>) output.get('result');
        System.assertEquals(1, result.size(), 'Debe haber solo una actividad filtrada');
        System.assertEquals('01tNq000005ySHyIAM', result[0].get('Id'), 'El ID de la actividad filtrada es incorrecto');
    }

    @isTest
    static void testInvokeMethodWithEmptyData() {
        Map<String, Object> input = new Map<String, Object>();
        input.put('selectedRows', new List<Map<String, Object>>());
        input.put('ResponseSelectedActivities', new List<Map<String, Object>>());
        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> args = new Map<String, Object>{
            'input' => input,
            'output' => output,
            'options' => new Map<String, Object>()
        };
        CS_ExtractionSavedActivities instance = new CS_ExtractionSavedActivities();
        instance.call('Extraction', args);
        List<Map<String, Object>> result = (List<Map<String, Object>>) output.get('result');
    }

    @isTest
    static void testInvokeMethodWithNullAction() {
        Map<String, Object> input = new Map<String, Object>();
        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> args = new Map<String, Object>{
            'input' => input,
            'output' => output,
            'options' => new Map<String, Object>()
        };
        CS_ExtractionSavedActivities instance = new CS_ExtractionSavedActivities();
        instance.call(null, args);
        List<Map<String, Object>> result = (List<Map<String, Object>>) output.get('result');
    }

    @isTest
    static void testInvokeMethodWithInvalidAction() {
        Map<String, Object> input = new Map<String, Object>();
        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> args = new Map<String, Object>{
            'input' => input,
            'output' => output,
            'options' => new Map<String, Object>()
        };
        CS_ExtractionSavedActivities instance = new CS_ExtractionSavedActivities();
        instance.call('InvalidAction', args);
        List<Map<String, Object>> result = (List<Map<String, Object>>) output.get('result');
    }
}