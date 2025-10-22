public with sharing class HabeasDataCSVProcessor {

    @AuraEnabled
    public static Map<String, Object> processCSVFile(String contentVersionId, String recordId) {
        Map<String, Object> result = new Map<String, Object>();

        try {
            // 1. Obtener el archivo CSV desde ContentVersion
            ContentVersion cv = [
                SELECT VersionData, Title
                FROM ContentVersion
                WHERE Id = :contentVersionId
                LIMIT 1
            ];

            // 2. Convertir a String y limpiar BOM si existe
            String csvData = cv.VersionData.toString();
            csvData = removeBOM(csvData);

            // 3. Parsear CSV
            List<Map<String, String>> parsedData = parseCSV(csvData);

            // 4. Validar que tenga datos
            if (parsedData.isEmpty()) {
                result.put('success', false);
                result.put('error', 'El archivo CSV está vacío o no tiene datos válidos');
                return result;
            }

            // Validación de columnas eliminada - se procesan todas las columnas que vengan

            // 6. Crear preview de los primeros 3 registros para mostrar al usuario
            List<Map<String, String>> preview = new List<Map<String, String>>();
            Integer previewLimit = Math.min(3, parsedData.size());
            for (Integer i = 0; i < previewLimit; i++) {
                preview.add(parsedData[i]);
            }

            result.put('success', true);
            result.put('totalRows', parsedData.size());
            result.put('fileName', cv.Title);
            result.put('message', 'Archivo procesado correctamente. Total de registros: ' + parsedData.size() + '. Iniciando procesamiento batch.');

            // Log para debugging
            System.debug('CSV Procesado - Total Rows: ' + parsedData.size());
            System.debug('Primera fila de ejemplo: ' + JSON.serializePretty(parsedData[0]));
            if (parsedData.size() > 1) {
                System.debug('Segunda fila de ejemplo: ' + JSON.serializePretty(parsedData[1]));
            }

            // Iniciar batch para procesar los datos (1 fila a la vez)
            HabeasDataBatch batch = new HabeasDataBatch(parsedData);
            Id batchId = Database.executeBatch(batch, 1); // Procesa 1 fila por lote

            System.debug('Batch iniciado con ID: ' + batchId);
            result.put('batchId', batchId);

        } catch (Exception e) {
            result.put('success', false);
            result.put('error', 'Error procesando archivo: ' + e.getMessage());
            System.debug(LoggingLevel.ERROR, 'Error en processCSVFile: ' + e.getMessage() + ' - ' + e.getStackTraceString());
        }

        return result;
    }

    /**
     * Remueve el BOM (Byte Order Mark) si existe en el archivo
     */
    private static String removeBOM(String csvData) {
        if (csvData.startsWith('\uFEFF')) {
            return csvData.substring(1);
        }
        return csvData;
    }

    /**
     * Valida que el CSV tenga las columnas esperadas
     */
    private static Map<String, String> validateCSVStructure(Map<String, String> firstRow) {
        Map<String, String> result = new Map<String, String>();

        List<String> requiredColumns = new List<String>{
            'identityType',
            'identityNumber'
        };

        for (String column : requiredColumns) {
            if (!firstRow.containsKey(column)) {
                result.put('error', 'Falta la columna requerida: ' + column);
                return result;
            }
        }

        result.put('success', 'true');
        return result;
    }

    /**
     * Parsea un string CSV a una lista de mapas
     * Cada mapa representa una fila con key=header, value=valor de la celda
     */
    private static List<Map<String, String>> parseCSV(String csvData) {
        List<Map<String, String>> result = new List<Map<String, String>>();

        // Dividir por líneas (manejar tanto \r\n como \n)
        csvData = csvData.replace('\r\n', '\n');
        List<String> lines = csvData.split('\n');

        if (lines.isEmpty()) {
            return result;
        }

        // Primera línea = headers
        String headerLine = lines[0].trim();

        // Detectar el delimitador (coma o punto y coma)
        String delimiter = detectDelimiter(headerLine);
        System.debug('Delimitador detectado: ' + delimiter);

        List<String> headers = parseCSVLine(headerLine, delimiter);

        // Limpiar headers de espacios extra
        for (Integer i = 0; i < headers.size(); i++) {
            headers[i] = headers[i].trim();
        }

        System.debug('Headers detectados (' + headers.size() + '): ' + headers);

        // Procesar las filas de datos (desde línea 1 en adelante)
        for (Integer i = 1; i < lines.size(); i++) {
            String line = lines[i].trim();

            // Ignorar líneas vacías
            if (String.isBlank(line)) {
                continue;
            }

            List<String> values = parseCSVLine(line, delimiter);

            // Crear mapa de esta fila
            Map<String, String> rowMap = new Map<String, String>();
            for (Integer j = 0; j < headers.size(); j++) {
                String header = headers[j];
                String value = j < values.size() ? values[j].trim() : '';
                rowMap.put(header, value);
            }

            result.add(rowMap);

            // Log de cada fila procesada
            System.debug('────────────────────────────────────────────────');
            System.debug('Fila ' + (result.size()) + ' procesada:');
            System.debug(JSON.serializePretty(rowMap));
        }

        System.debug('════════════════════════════════════════════════');
        System.debug('Total de filas procesadas: ' + result.size());
        System.debug('════════════════════════════════════════════════');

        return result;
    }

    /**
     * Detecta si el CSV usa comas o punto y coma como delimitador
     */
    private static String detectDelimiter(String line) {
        Integer commaCount = 0;
        Integer semicolonCount = 0;

        for (Integer i = 0; i < line.length(); i++) {
            String ch = line.substring(i, i + 1);
            if (ch == ',') {
                commaCount++;
            } else if (ch == ';') {
                semicolonCount++;
            }
        }

        // Retornar el delimitador más frecuente
        return semicolonCount > commaCount ? ';' : ',';
    }

    /**
     * Parsea una línea CSV manejando valores entre comillas
     */
    private static List<String> parseCSVLine(String line, String delimiter) {
        List<String> result = new List<String>();
        Boolean inQuotes = false;
        String currentValue = '';

        for (Integer i = 0; i < line.length(); i++) {
            String currentChar = line.substring(i, i + 1);

            if (currentChar == '"') {
                // Toggle el estado de comillas
                inQuotes = !inQuotes;
            } else if (currentChar == delimiter && !inQuotes) {
                // Es un separador, agregar el valor actual
                result.add(currentValue.trim());
                currentValue = '';
            } else {
                // Agregar caracter al valor actual
                currentValue += currentChar;
            }
        }

        // Agregar el último valor
        result.add(currentValue.trim());

        return result;
    }
}