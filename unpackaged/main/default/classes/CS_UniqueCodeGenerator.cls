/**
 * @author Harold Garcia Vargas
 * @email harold.garcia@vasscompany.com
 * @create date 2024-10-11 19:21:29
 * @modify date 2024-10-11 19:21:29
 * @desc Esta clase global con sharing implementa la interfaz Callable y se utiliza para generar un código único 
 * basado en la configuración almacenada en el objeto UniqueCodeSettings__c.
 */

 global with sharing class CS_UniqueCodeGenerator implements Callable {

    public Object call(String action, Map<String, Object> args) {
        Map<String, Object> input = (Map<String, Object>) args.get('input');
        Map<String, Object> output = (Map<String, Object>) args.get('output');
        Map<String, Object> options = (Map<String, Object>) args.get('options');
        return invokeMethod(action, input, output, options);
    }
    
    private Object invokeMethod(String action, Map<String, Object> input, 
                                Map<String, Object> output, Map<String, Object> options) {  
        if(action != null && action == 'GenerateUniqueCode'){
            try {
                GeneralCharacteristics__c settings;
                List<GeneralCharacteristics__c> settingsList = [SELECT Id, Name, Counter__c FROM GeneralCharacteristics__c WHERE Name LIKE 'GRUPO-ACTIVIDADES-APP-%' LIMIT 1];
                
                if (settingsList.isEmpty()) {
                    settings = new GeneralCharacteristics__c(Name = 'GRUPO-ACTIVIDADES-APP-', Counter__c = 1);
                    insert settings;
                } else {
                    settings = settingsList[0];
                }

                Integer currentCounter = settings.Counter__c != null ? settings.Counter__c.intValue() : 1;
                String prefix = settings.Name;

                String formattedCounter = currentCounter < 10 ? '00' + currentCounter : (currentCounter < 100 ? '0' + currentCounter : String.valueOf(currentCounter));

                String uniqueCode = prefix + formattedCounter;

                settings.Counter__c = currentCounter + 1;
                update settings;

                System.debug('Generated Unique Code: ' + uniqueCode);
                
                output.put('result', uniqueCode);
            } catch (Exception e) {
                System.debug('Se produjo una excepción: ' + e.getMessage());
            }
        } else {
            System.debug('action es nulo o no válido.');
        }

        return output;
    }
}