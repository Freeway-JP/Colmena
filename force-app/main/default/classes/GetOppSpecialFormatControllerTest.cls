@isTest
public with sharing class GetOppSpecialFormatControllerTest {

    @isTest
    private static void testToUpperCaseFormatting(){
        String extensionClass = 'GetOppSpecialFormatController'; // Typically set via configuration
        Decimal decimalTestValue = 10;

        // When
        Callable extension = 
            (Callable) Type.forName(extensionClass).newInstance();
        Map<String, Object> inputs = new Map<String, Object> { 
                'input' => new Map<String, Object>{
                    'arguments' => new List<Object>{'hello world'}
                },
                    'output' => new Map<String, Object>()
            };
        Boolean result = (Boolean) 
            extension.call('toUpperCaseFormatting', inputs);
		System.debug(inputs.get('output'));
        Map<String,Object> objResult = (Map<String,Object>)inputs.get('output');
        // Then
        Assert.areEqual('HELLO WORLD', (String)objResult.get('result'));
    }
    
    @isTest
    private static void testFormatTodayDate(){
        String extensionClass = 'GetOppSpecialFormatController'; // Typically set via configuration
        Decimal decimalTestValue = 10;

        // When
        Callable extension = 
            (Callable) Type.forName(extensionClass).newInstance();
        Map<String, Object> inputs = new Map<String, Object> { 
                'input' => new Map<String, Object>{},
                    'output' => new Map<String, Object>()
            };
        Boolean result = (Boolean) 
            extension.call('formatTodayDate', inputs);
		System.debug(inputs.get('output'));
        Map<String,Object> objResult = (Map<String,Object>)inputs.get('output');
        // Then
        GetOppSpecialFormatController dt = new GetOppSpecialFormatController();
        Assert.areEqual(dt.getDateFormatted(), (String)objResult.get('result'));
    }
    
    @isTest
    private static void testCurrencyFormat(){
        String extensionClass = 'GetOppSpecialFormatController'; // Typically set via configuration
        Decimal decimalTestValue = 10;

        // When
        Callable extension = 
            (Callable) Type.forName(extensionClass).newInstance();
        Map<String, Object> inputs = new Map<String, Object> { 
                'input' => new Map<String, Object>{
                    'arguments' => new List<Object>{'1540000'}
                },
                    'output' => new Map<String, Object>()
            };
        Boolean result = (Boolean) 
            extension.call('currencyFormat', inputs);
		System.debug(inputs.get('output'));
        Map<String,Object> objResult = (Map<String,Object>)inputs.get('output');
        // Then
        Assert.areEqual('$1.540.000', (String)objResult.get('result'));
    }
    
    @isTest
    private static void testCurrencyFormatWords(){
        String extensionClass = 'GetOppSpecialFormatController'; // Typically set via configuration
        Decimal decimalTestValue = 10;

        // When
        Callable extension = 
            (Callable) Type.forName(extensionClass).newInstance();
        Map<String, Object> inputs = new Map<String, Object> { 
                'input' => new Map<String, Object>{
                    'arguments' => new List<Object>{'154000'}
                },
                    'output' => new Map<String, Object>()
            };
        Boolean result = (Boolean) 
            extension.call('currencyFormatWords', inputs);
		System.debug(inputs.get('output'));
        Map<String,Object> objResult = (Map<String,Object>)inputs.get('output');
        // Then
        Assert.areEqual('CIENTO CINCUENTA Y CUATRO MIL  PESOS', (String)objResult.get('result'));
    }
    
}