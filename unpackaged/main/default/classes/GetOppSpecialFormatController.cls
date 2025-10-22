global with sharing class GetOppSpecialFormatController implements Callable {

    private final Map<String, String> MONTHSTRANSLATED = new Map<String, String>{
            'January' => 'Enero',
            'February' => 'Febrero',
            'March' => 'Marzo',
            'April' => 'Abril',
            'May' => 'Mayo',
            'June' => 'Junio',
            'July' => 'Julio',
            'August' => 'Agosto',
            'September' => 'Septiembre',
            'October' => 'Octubre',
            'November' => 'Noviembre',
            'December' => 'Diciembre'
    };
    public Object call(String action, Map<String, Object> args) {

        Map<String, Object> input = (Map<String, Object>)args.get('input');
        Map<String, Object> output = (Map<String, Object>)args.get('output');
        Map<String, Object> options = (Map<String, Object>)args.get('options');

        return invokeMethod(action, input, output, options);
    }

    global Boolean invokeMethod(String methodName, Map<String, Object> inputs, Map<String, Object> output, Map<String, Object> options)
    {
        if ( methodName == 'toUpperCaseFormatting') {
            List<Object> arguments = (List<Object>)inputs.get('arguments');
            output.put('result', toUpperCaseFormatting(arguments));
        } else if ( methodName == 'formatTodayDate') {
            output.put('result', getDateFormatted());
        } else if ( methodName == 'currencyFormat') {
            List<Object> arguments = (List<Object>)inputs.get('arguments');
            output.put('result', currencyFormat(arguments));
        } else if ( methodName == 'currencyFormatWords') {
            List<Object> arguments = (List<Object>)inputs.get('arguments');
            output.put('result', currencyFormatWords(arguments));
        }
        return true;
    }
     
    

    public String toUpperCaseFormatting(List<Object> arguments)
	{
            System.debug(arguments[0]);
            String accountName = arguments[0].toString();
            return accountName.toUpperCase();
    }

    public String getDateFormatted() {

        datetime dt = system.today();
        String fechaFormateada = dt.format('dd \'de\' MMMM yyyy'); // Formato en español
        String month = dt.format('MMMM');
        // Agregar "de" entre día, mes y año
        fechaFormateada = fechaFormateada.replace(month, MONTHSTRANSLATED.get(month));//.replaceFirst(' ', ' de ').replace(' ', ' de ');

        System.debug(fechaFormateada);
        return fechaFormateada;
    }

    public String currencyFormat(List<Object> arguments)
	{
            System.debug(arguments[0]);
            String currencyString = arguments[0]?.toString();
            Decimal currencyNumber = 0;
            if (currencyString!=null) {
                currencyNumber = Decimal.valueOf(currencyString);
            }
            String output = '$' + String.valueOf(currencyNumber.format());
            System.debug(output);
            return output;
    }

    public String currencyFormatWords(List<Object> arguments)
	{
        String currencyString = arguments[0]?.toString();
        Double currencyNumber = 0;
        NumbersToWordsConversionClass num2text = new NumbersToWordsConversionClass('PESO', 'PESOS', 'CÉNTIMO', 'CÉNTIMOS', true);
        if (currencyString!=null) {
            currencyNumber = Double.valueOf(currencyString);
        }
        return num2text.convert(currencyNumber);
    }
    
}