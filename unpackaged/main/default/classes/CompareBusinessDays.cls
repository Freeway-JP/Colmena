global class CompareBusinessDays implements Callable {
    
    public Object call(String action, Map<String, Object> args) { Map<String, Object> input = (Map<String, Object>)args.get('input'); Map<String, Object> output = (Map<String, Object>)args.get('output'); Map<String, Object> options = (Map<String, Object>)args.get('options'); return invokeMethod(action, input, output, options); }
    
    global Boolean invokeMethod(String methodName, Map<String, Object> inputMap, Map<String, Object> outMap, Map<String, Object> options) {
        Map<String, Object> targetDate = (Map<String, Object>)inputMap.get('ClassificationMailbox');
        String fecha = String.valueOf(targetDate.get('AppoimentDate'));
        fecha = fecha.trim();
        Date target = Date.valueOf(fecha);
        Date fechaActual = System.Today();

            // Calcular la diferencia en milisegundos
            Long diffMillis = BusinessHours.diff(System.Label.PQRSOfficeScheduleId, fechaActual, target);

            // Convertir a días (1 día = 1000 ms * 60 s * 60 min * 24 h)
            Decimal dias = Decimal.valueOf(diffMillis) / (1000 * 60 * 60 * 24);

            Integer salida = Integer.valueOf(dias);
        outMap.put('totalDiasHabiles', salida);
        return true;
    }
}