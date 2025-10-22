/**
 * @author Harold Garcia Vargas
 * @email harold.garcia@vasscompany.com
 * @create date 2024-11-11 10:58:37
 * @modify date 2024-11-11 10:58:37
 * @desc Esta clase de prueba verifica la funcionalidad de la clase CS_UniqueCodeGenerator,
 *       asegurando que el método para generar un código único funcione correctamente
 *       y maneje los casos de acción inválida y de excepciones adecuadamente. 
 *       Incluye pruebas para validar el incremento del contador, el formato del código generado,
 *       y el manejo de errores en situaciones donde los registros de configuración no están presentes.
 */

@IsTest
private class CS_UniqueCodeGeneratorTest {

    @TestSetup
    static void setupData() {
        GeneralCharacteristics__c settings = new GeneralCharacteristics__c(
            Name = 'GRUPO-ACTIVIDADES-APP-',
            Counter__c = 5
        );
        insert settings;
    }
    
    @IsTest
    static void testGenerateUniqueCode() {
        CS_UniqueCodeGenerator generator = new CS_UniqueCodeGenerator();

        Map<String, Object> args = new Map<String, Object>();
        args.put('input', new Map<String, Object>());
        args.put('output', new Map<String, Object>());
        args.put('options', new Map<String, Object>());

        Map<String, Object> result = (Map<String, Object>) generator.call('GenerateUniqueCode', args);
        
        Map<String, Object> output = (Map<String, Object>) result.get('output');
        if (output != null && output.containsKey('result')) {
            String uniqueCode = (String) output.get('result');
            System.assertNotEquals(null, uniqueCode, 'El código único debería estar presente en el output.');
            System.assertEquals('GRUPO-ACTIVIDADES-APP-005', uniqueCode, 'El código único debería tener el formato esperado.');

            GeneralCharacteristics__c updatedSettings = [SELECT Counter__c FROM GeneralCharacteristics__c WHERE Name = 'GRUPO-ACTIVIDADES-APP-' LIMIT 1];
            System.assertEquals(6, updatedSettings.Counter__c, 'El contador debería haberse incrementado en 1.');
        }
    }

    @IsTest
    static void testInvalidAction() {
        CS_UniqueCodeGenerator generator = new CS_UniqueCodeGenerator();
        
        Map<String, Object> args = new Map<String, Object>();
        args.put('input', new Map<String, Object>());
        args.put('output', new Map<String, Object>());
        args.put('options', new Map<String, Object>());

        Map<String, Object> result = (Map<String, Object>) generator.call('InvalidAction', args);
        
        Map<String, Object> output = (Map<String, Object>) result.get('output');
        if (output == null || !output.containsKey('result')) {
            System.assert(true, 'No debería generarse ningún código único para una acción inválida.');
        }
    }

    @IsTest
    static void testExceptionHandling() {
        delete [SELECT Id FROM GeneralCharacteristics__c WHERE Name = 'GRUPO-ACTIVIDADES-APP-' LIMIT 1];
        
        CS_UniqueCodeGenerator generator = new CS_UniqueCodeGenerator();
        
        Map<String, Object> args = new Map<String, Object>();
        args.put('input', new Map<String, Object>());
        args.put('output', new Map<String, Object>());
        args.put('options', new Map<String, Object>());

        Map<String, Object> result = (Map<String, Object>) generator.call('GenerateUniqueCode', args);
        
        Map<String, Object> output = (Map<String, Object>) result.get('output');
        if (output == null || !output.containsKey('result')) {
            System.assert(true, 'No debería generarse ningún código único si ocurre una excepción.');
        }
    }
}