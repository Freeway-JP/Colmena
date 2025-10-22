/***************************************************************************************************************************
 * Nombre de la Clase Apex : GenerateDigestStringTest
 * Versión                 : 1.0
 * Fecha de Creación       : 1/09/2024
 * Funcionalidad           : Generación de datos para pruebas para clase GenerateDigestString
 *--------------------------------------------------------------------------------------------------------------------------
 **************************************************************************************************************************/
@isTest
public class GenerateDigestStringTest {
    
    @isTest
    static void testGenerateMD5Encode() {
        // Crear los datos de entrada para la prueba
        GenerateDigestString.InputVariables input = new GenerateDigestString.InputVariables();
        input.encodeString = 'IdLlamada=0&Cedula=79642631&IdTipoDocumento=1&Documento=79642631&ProvieneDe=10';
        input.cryptoKey = 'U8+)1K1=?,#8*Gbgu{)k[:RZad0#{ZG7';
        input.vector = 't:_R6u_g?g}VdRSm';
        // Lista de entrada
        List<GenerateDigestString.InputVariables> inputList = new List<GenerateDigestString.InputVariables>();
        inputList.add(input);
        
        // Invocar el método GenerateDigestString
        Test.startTest();
        List<GenerateDigestString.ReturnVariables> result = GenerateDigestString.GenerateDigestString(inputList);
        Test.stopTest();
        
        // Verificar que el resultado no sea nulo
        System.assertNotEquals(null, result);
        
        // Verificar que el resultado contenga el texto encriptado
        System.assertNotEquals(null, result[0].codifiedString, 'El texto encriptado no debería ser nulo');
        
    }
    
}