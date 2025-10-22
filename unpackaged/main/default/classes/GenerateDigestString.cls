/***************************************************************************************************************************
 * Nombre de la Clase Apex : GenerateDigestString
 * Versión                 : 1.0
 * Fecha de Creación       : 1/09/2024
 * Funcionalidad           : Codifica una cadena bajo método de encripción CHECKSUM.
 * Clase Test			   : GenerateDigestStringTest
 *--------------------------------------------------------------------------------------------------------------------------
 **************************************************************************************************************************/
public class GenerateDigestString {
    public class InputVariables{
        @InvocableVariable(label='Texto a encriptar' description='Este es el texto a encriptar')
        public String encodeString;
        @InvocableVariable(label='Clave de encriptación' description='Esta es la llave de encriptación')
        public String cryptoKey;
        @InvocableVariable(label='Vector de inicialización' description='Este es el vector de inicialización')
        public String vector;
    }

    public class ReturnVariables{
        @InvocableVariable(label='Texto encriptado' description='Este es el texto encriptado')
        public String codifiedString;
    }

    @invocableMethod(label='GenerateMD5Encode' description='Permite encriptar un texto bajo protocolo AES256')
    public static List<ReturnVariables> GenerateDigestString(List<InputVariables> inputVariables){
        InputVariables textIn = inputVariables.get(0);
	//Encrypt string with the crypto key received
        Blob key = Blob.valueOf(textIn.cryptoKey);
        Blob textToEncrypt = Blob.valueOf(textIn.encodeString);
    //Initialization vector
        Blob vectorIv = Blob.valueOf(textIn.vector); 
        Blob encryptedData = Crypto.encrypt('AES256', key, vectorIv, textToEncrypt);
        String result = EncodingUtil.base64Encode(encryptedData);
//        String UrlResult = EncodingUtil.urlEncode(result, 'UTF-8');
        ReturnVariables resp = new ReturnVariables();
//        resp.codifiedString = UrlResult;
        resp.codifiedString = result;
        List<ReturnVariables> answer = new List<ReturnVariables>();
        answer.add(resp);
        return answer;
    }
}