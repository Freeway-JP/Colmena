public class HabeasDataBatch implements Database.Batchable<Map<String, String>>, Database.Stateful {

    private List<Map<String, String>> csvRows;
    private Integer successCount = 0;
    private Integer errorCount = 0;
    private Id caseRecordTypeId; // Cache del RecordType para casos
    private List<ErrorDetail> errorDetails = new List<ErrorDetail>(); // Lista de errores para el correo

    public HabeasDataBatch(List<Map<String, String>> rows) {
        this.csvRows = rows;
    }

    /**
     * Excepción personalizada para errores en creación de casos
     */
    public class CaseCreationException extends Exception {}

    /**
     * Inner class para manejar resultados de validación
     */
    private class ValidationResult {
        Boolean isValid = true;
        List<String> errors = new List<String>();

        void addError(String error) {
            this.isValid = false;
            this.errors.add(error);
        }
    }

    /**
     * Inner class para almacenar detalles de errores
     */
    private class ErrorDetail {
        Integer rowNumber;
        String errorType;
        String errorMessage;
        String identityInfo;

        ErrorDetail(Integer rowNum, String type, String message, String identity) {
            this.rowNumber = rowNum;
            this.errorType = type;
            this.errorMessage = message;
            this.identityInfo = identity;
        }
    }

    public Iterable<Map<String, String>> start(Database.BatchableContext bc) {
        System.debug('═══════════════════════════════════════════════════════');
        System.debug('Iniciando batch - Total de filas a procesar: ' + csvRows.size());
        System.debug('═══════════════════════════════════════════════════════');

        // Obtener y cachear el RecordType para casos
        try {
            caseRecordTypeId = [
                SELECT Id
                FROM RecordType
                WHERE SobjectType = 'Case'
                  AND DeveloperName = 'Novelty_PQRS'
                LIMIT 1
            ].Id;
            System.debug('✅ RecordType cacheado: ' + caseRecordTypeId);
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, '❌ Error obteniendo RecordType Novelty_PQRS: ' + e.getMessage());
            // No lanzar excepción aquí, se manejará en cada ejecución
        }

        return csvRows;
    }

    public void execute(Database.BatchableContext bc, List<Map<String, String>> scope) {
        System.debug('───────────────────────────────────────────────────────');
        System.debug('Procesando lote de ' + scope.size() + ' filas');

        Integer rowNumber = successCount + errorCount + 1;

        for (Map<String, String> csvRow : scope) {
            try {
                System.debug('════════════════════════════════════════════════════════════════');
                System.debug('FILA #' + rowNumber);
                System.debug('════════════════════════════════════════════════════════════════');

                processRow(csvRow, rowNumber);

                successCount++;
                rowNumber++;
            } catch (IllegalArgumentException e) {
                // Error de validación - loguear información detallada y guardar para el correo
                errorCount++;
                System.debug(LoggingLevel.ERROR, '⚠️ VALIDACIÓN FALLIDA: ' + e.getMessage());
                System.debug(LoggingLevel.ERROR, 'Datos de la fila rechazada: ' + JSON.serializePretty(csvRow));

                // Guardar detalles del error para el correo
                String identityInfo = csvRow.get('identityType') + ' ' + csvRow.get('identityNumber');
                errorDetails.add(new ErrorDetail(rowNumber, 'Error de validación', e.getMessage(), identityInfo));

                rowNumber++;
                // NO relanzar la excepción - continuar con el siguiente registro
            } catch (Exception e) {
                // Error genérico de procesamiento - loguear y guardar para el correo
                errorCount++;
                System.debug(LoggingLevel.ERROR, '❌ Error procesando fila #' + rowNumber + ': ' + e.getMessage());
                System.debug(LoggingLevel.ERROR, 'Stack trace: ' + e.getStackTraceString());
                System.debug(LoggingLevel.ERROR, 'Datos de la fila: ' + JSON.serializePretty(csvRow));

                // Guardar detalles del error para el correo
                String identityInfo = csvRow.get('identityType') + ' ' + csvRow.get('identityNumber');
                errorDetails.add(new ErrorDetail(rowNumber, 'Error procesando', e.getMessage(), identityInfo));

                rowNumber++;
                // NO relanzar la excepción - continuar con el siguiente registro
            }
        }
    }

    public void finish(Database.BatchableContext bc) {
        System.debug('═══════════════════════════════════════════════════════');
        System.debug('Batch finalizado');
        System.debug('Total procesados exitosamente: ' + successCount);
        System.debug('Total con errores: ' + errorCount);
        System.debug('═══════════════════════════════════════════════════════');

        // Enviar correo al usuario que ejecutó el batch
        sendCompletionEmail(bc);
    }

    /**
     * Envía un correo de confirmación al usuario que ejecutó el batch
     * @param bc BatchableContext
     */
    private void sendCompletionEmail(Database.BatchableContext bc) {
        try {
            // Obtener información del job y del usuario que lo ejecutó
            AsyncApexJob job = [
                SELECT Id, CreatedBy.Email, CreatedBy.Name, CompletedDate, Status
                FROM AsyncApexJob
                WHERE Id = :bc.getJobId()
            ];

            // Crear el correo
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

            // IMPORTANTE: No guardar como actividad (evita errores de permisos en batch)
            email.setSaveAsActivity(false);

            // Buscar y usar la dirección organizacional
            try {
                // Obtener el correo desde la metadata configurable
                SendEmailPQRS__mdt config = SendEmailPQRS__mdt.getInstance('Notify_Mass_Upload_Renewals');

                if (config != null && String.isNotBlank(config.EntityEmail__c)) {
                    OrgWideEmailAddress owea = [
                        SELECT Id, Address, DisplayName
                        FROM OrgWideEmailAddress
                        WHERE Address = :config.EntityEmail__c
                        LIMIT 1
                    ];

                    email.setOrgWideEmailAddressId(owea.Id);
                    System.debug('✅ Usando dirección organizacional: ' + owea.DisplayName + ' <' + owea.Address + '>');
                } else {
                    System.debug(LoggingLevel.WARN, '⚠️ No se encontró la configuración de metadata Notify_Mass_Upload_Renewals');
                    System.debug(LoggingLevel.WARN, '   El correo se enviará sin dirección organizacional');
                }

            } catch (QueryException qe) {
                System.debug(LoggingLevel.WARN, '⚠️ No se encontró la dirección organizacional configurada en la metadata');
                System.debug(LoggingLevel.WARN, '   El correo se enviará sin dirección organizacional');
            }

            // Destinatario: usuario que ejecutó el batch
            email.setToAddresses(new String[] { job.CreatedBy.Email });

            // Asunto
            String subject = errorCount > 0
                ? 'Proceso de Habeas Data completado con errores'
                : 'Confirmación: Proceso de Habeas Data completado';
            email.setSubject(subject);

            // Cuerpo del correo (simple y en texto plano)
            String emailBody = 'Hola ' + job.CreatedBy.Name + ',\n\n';
            emailBody += 'El proceso de Habeas Data ha finalizado.\n\n';
            emailBody += 'Resumen de ejecución:\n';
            emailBody += '- Registros procesados exitosamente: ' + successCount + '\n';
            emailBody += '- Registros con errores: ' + errorCount + '\n';
            emailBody += '- Estado del batch: ' + job.Status + '\n';
            emailBody += '- Fecha de finalización: ' + job.CompletedDate + '\n\n';

            // Agregar detalle de errores si existen
            if (errorCount > 0 && !errorDetails.isEmpty()) {
                emailBody += '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n';
                emailBody += 'DETALLE DE ERRORES:\n';
                emailBody += '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n';

                // Limitar a 15 errores en el correo
                Integer maxErrors = Math.min(errorDetails.size(), 15);
                for (Integer i = 0; i < maxErrors; i++) {
                    ErrorDetail error = errorDetails[i];
                    emailBody += 'Fila #' + error.rowNumber + ' - [' + error.identityInfo + '] - ' + error.errorType + '\n';
                    emailBody += 'Motivo: ' + error.errorMessage + '\n\n';
                }

                // Si hay más de 15 errores, mostrar resumen
                if (errorDetails.size() > 15) {
                    emailBody += '... y ' + (errorDetails.size() - 15) + ' error(es) adicional(es).\n';
                    emailBody += 'Por favor revise los logs del batch para ver el detalle completo.\n\n';
                }
            }

            emailBody += 'Saludos,\n';
            emailBody += 'Sistema de Habeas Data';

            email.setPlainTextBody(emailBody);

            // Enviar el correo
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });

            System.debug('✅ Correo de confirmación enviado a: ' + job.CreatedBy.Email);

        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, '❌ Error enviando correo de confirmación: ' + e.getMessage());
            System.debug(LoggingLevel.ERROR, 'Stack trace: ' + e.getStackTraceString());
            // No relanzar la excepción para que no falle el batch
        }
    }

    /**
     * Valida una fila del CSV antes de procesarla
     * @param csvRow - Fila del CSV a validar
     * @return ValidationResult con el resultado de la validación
     */
    private ValidationResult validateRow(Map<String, String> csvRow) {
        ValidationResult result = new ValidationResult();
        String dataUsePurpose = csvRow.get('dataUsePurpose');

        // Debug de valores recibidos
        System.debug('🔍 VALIDACIÓN - dataUsePurpose: [' + dataUsePurpose + ']');
        System.debug('🔍 VALIDACIÓN - medicalHistoryVida RAW: [' + csvRow.get('medicalHistoryVida') + ']');
        System.debug('🔍 VALIDACIÓN - medicalHistoryARL RAW: [' + csvRow.get('medicalHistoryARL') + ']');

        // Validación: Cliente Representante Legal NO puede tener medicalHistory en true
        if (dataUsePurpose != null &&
            dataUsePurpose.trim().equalsIgnoreCase('Cliente Representante Legal')) {

            System.debug('🔍 VALIDACIÓN - Se detectó Cliente Representante Legal, validando medicalHistory...');

            // Debug del resultado del parse
            Boolean vidaValue = parseBooleanValue(csvRow.get('medicalHistoryVida'));
            Boolean arlValue = parseBooleanValue(csvRow.get('medicalHistoryARL'));
            System.debug('🔍 VALIDACIÓN - vidaValue PARSED: ' + vidaValue);
            System.debug('🔍 VALIDACIÓN - arlValue PARSED: ' + arlValue);

            // Validar medicalHistoryVida
            if (vidaValue) {
                System.debug('⚠️ VALIDACIÓN - ERROR DETECTADO: medicalHistoryVida es TRUE');
                result.addError(
                    'Cliente Representante Legal no puede tener "Historia Médica" activada para Seguro de Vida'
                );
            }

            // Validar medicalHistoryARL
            if (arlValue) {
                System.debug('⚠️ VALIDACIÓN - ERROR DETECTADO: medicalHistoryARL es TRUE');
                result.addError(
                    'Cliente Representante Legal no puede tener "Historia Médica" activada para ARL'
                );
            }
        } else {
            System.debug('🔍 VALIDACIÓN - NO es Cliente Representante Legal, se omite validación de medicalHistory');
        }

        return result;
    }

    /**
     * Procesa una fila del CSV
     */
    private void processRow(Map<String, String> csvRow, Integer rowNumber) {
        System.debug('📋 Procesando fila #' + rowNumber);

        // PASO 1: Validar la fila antes de procesarla
        ValidationResult validation = validateRow(csvRow);

        if (!validation.isValid) {
            // Si la validación falla, lanzar excepción con detalles
            String errorDetails = String.join(validation.errors, '; ');
            String identityInfo = csvRow.get('identityType') + ' ' + csvRow.get('identityNumber');
            throw new IllegalArgumentException(
                'Fila #' + rowNumber + ' [' + identityInfo + '] - ' + errorDetails
            );
        }

        // PASO 2: Transformar la fila CSV a la estructura del servicio
        Map<String, Object> transformedData = transformCSVToServiceFormat(csvRow);

        // Debug del resultado transformado
        System.debug('════════════════════════════════════════════════════════════════');
        System.debug('JSON TRANSFORMADO FILA #' + rowNumber + ':');
        System.debug(JSON.serializePretty(transformedData));
        System.debug('════════════════════════════════════════════════════════════════');

        // Convertir a DTO usando JSON
        String jsonData = JSON.serialize(transformedData);
        WSHabeasDataExtendWrapper.HabeasDataDto habeasRequest =
            (WSHabeasDataExtendWrapper.HabeasDataDto) JSON.deserialize(
                jsonData,
                WSHabeasDataExtendWrapper.HabeasDataDto.class
            );

        // Llamar al servicio para procesar
        WSHabeasDataService habeasService = new WSHabeasDataService();
        WSHabeasDataExtendWrapper.HabeasDataResponseDto response =
            habeasService.processAuth_V2(habeasRequest);

        // Log resultado exitoso
        System.debug('✅ Fila #' + rowNumber + ' procesada exitosamente');
        System.debug('Identidad: ' + transformedData.get('identityType') + ' ' + transformedData.get('identityNumber'));
        System.debug('Respuesta del servicio: ' + JSON.serializePretty(response));

        // PASO 3: Crear caso para el tratamiento procesado
        try {
            String caseId = createCaseForTreatment(csvRow, rowNumber);
            System.debug('✅ Caso creado exitosamente: ' + caseId);
        } catch (Exception caseException) {
            System.debug(LoggingLevel.ERROR, '⚠️ Error creando caso para fila #' + rowNumber + ': ' + caseException.getMessage());
            System.debug(LoggingLevel.ERROR, 'Stack trace: ' + caseException.getStackTraceString());
            // No relanzar la excepción para que el tratamiento se considere exitoso
            // pero el error queda registrado en los logs
        }

        System.debug('════════════════════════════════════════════════════════════════');
    }

    /**
     * Transforma una fila del CSV al formato esperado por el servicio
     */
    private Map<String, Object> transformCSVToServiceFormat(Map<String, String> csvRow) {
        Map<String, Object> result = new Map<String, Object>();

        // Campos que vienen del CSV directamente
        result.put('identityType', csvRow.get('identityType'));
        result.put('identityNumber', csvRow.get('identityNumber'));

        // dataUsePurpose desde CSV
        String dataUsePurpose = csvRow.get('dataUsePurpose');
        result.put('dataUsePurpose', String.isNotBlank(dataUsePurpose) ? dataUsePurpose : 'Cliente');

        // Datos personales
        result.put('firstName', csvRow.get('firstName'));
        result.put('secondName', csvRow.get('secondName'));
        result.put('lastName', csvRow.get('lastName'));
        result.put('secondLastName', csvRow.get('secondLastName'));
        result.put('sex', csvRow.get('sex'));
        result.put('email', csvRow.get('email'));
        result.put('numberPhone', csvRow.get('numberPhone'));

        // Contacto (Representante Legal)
        result.put('contactFirstName', csvRow.get('contactFirstName'));
        result.put('contactLastName', csvRow.get('contactLastName'));
        result.put('contactIdType', csvRow.get('contactIdType'));
        result.put('contactIdNumber', csvRow.get('contactIdNumber'));

        // Validación de identidad
        result.put('identityValidationType', csvRow.get('identityValidationType'));
        result.put('identityValidationStatus', csvRow.get('identityValidationStatus'));
        result.put('identityValidationSource', csvRow.get('identityValidationSource'));
        result.put('identityValidationResult', csvRow.get('identityValidationResult'));
        result.put('identityValidationNoData', parseBooleanValue(csvRow.get('identityValidationNoData')));

        // Canal y proceso
        result.put('process', csvRow.get('process'));
        result.put('origin', csvRow.get('origin'));
        result.put('channelType', csvRow.get('channelType'));
        result.put('businessCoverage', csvRow.get('businessCoverage'));
        result.put('authorizationChannel', csvRow.get('authorizationChannel'));
        result.put('collectionMethodType', csvRow.get('collectionMethodType'));

        // IDs (por ahora null, se llenarán después del proceso)
        result.put('subjectId', null);
        result.put('idIndividual', null);
        result.put('idIdentityValidation', null);
        result.put('idClient', null);
        result.put('idAccountLR', null);

        // Construir companies (siempre crea las 3 aseguradoras)
        List<Map<String, Object>> companies = new List<Map<String, Object>>();
        companies.add(buildCompany('Seguro de Vida', csvRow, 'Vida'));
        companies.add(buildCompany('ARL', csvRow, 'ARL'));
        companies.add(buildCompany('Seguros Generales', csvRow, 'Generales'));

        result.put('companies', companies);

        return result;
    }

    /**
     * Construye el objeto company para una aseguradora específica
     */
    private Map<String, Object> buildCompany(String companyName, Map<String, String> csvRow, String suffix) {
        Map<String, Object> company = new Map<String, Object>();

        company.put('notEssentialFunctionalities', null);
        company.put('name', companyName);
        company.put('medicalHistory', parseBooleanValue(csvRow.get('medicalHistory' + suffix)));
        company.put('generalProcessingData', parseBooleanValue(csvRow.get('generalProcessingData' + suffix)));
        company.put('generalCommercialOffer', parseBooleanValue(csvRow.get('generalCommercialOffer' + suffix)));
        company.put('dataMarketing', parseBooleanValue(csvRow.get('dataMarketing' + suffix)));

        // Construir authorization2300
        List<Map<String, Object>> authorization2300 = new List<Map<String, Object>>();

        // Obtener email y teléfono para contactPoint
        String email = (String) csvRow.get('email');
        String phone = (String) csvRow.get('numberPhone');

        // DirectMarketing (Ofrecimiento Comercial-2300)
        String directMarketingValue = csvRow.get('DirectMarketing' + suffix);
        Set<String> directMarketingChannels = parseChannels(directMarketingValue);

        authorization2300.add(buildAuthorization2300(
            'Ofrecimiento Comercial-2300',
            'WhatsApp',
            phone,
            directMarketingChannels.contains('WhatsApp')
        ));
        authorization2300.add(buildAuthorization2300(
            'Ofrecimiento Comercial-2300',
            'correo electrónico',
            email,
            directMarketingChannels.contains('correo electrónico')
        ));
        authorization2300.add(buildAuthorization2300(
            'Ofrecimiento Comercial-2300',
            'celular',
            phone,
            directMarketingChannels.contains('celular')
        ));
        authorization2300.add(buildAuthorization2300(
            'Ofrecimiento Comercial-2300',
            'mensaje de texto',
            phone,
            directMarketingChannels.contains('mensaje de texto')
        ));

        // DebtCollection (Gestión Cartera-2300)
        String debtCollectionValue = csvRow.get('DebtCollection' + suffix);
        Set<String> debtCollectionChannels = parseChannels(debtCollectionValue);

        authorization2300.add(buildAuthorization2300(
            'Gestión Cartera-2300',
            'WhatsApp',
            phone,
            debtCollectionChannels.contains('WhatsApp')
        ));
        authorization2300.add(buildAuthorization2300(
            'Gestión Cartera-2300',
            'correo electrónico',
            email,
            debtCollectionChannels.contains('correo electrónico')
        ));
        authorization2300.add(buildAuthorization2300(
            'Gestión Cartera-2300',
            'celular',
            phone,
            debtCollectionChannels.contains('celular')
        ));
        authorization2300.add(buildAuthorization2300(
            'Gestión Cartera-2300',
            'mensaje de texto',
            phone,
            debtCollectionChannels.contains('mensaje de texto')
        ));

        company.put('authorization2300', authorization2300);

        return company;
    }

    /**
     * Construye un objeto de autorización 2300
     */
    private Map<String, Object> buildAuthorization2300(String dataUsePurpose, String contactPointType, String contactPoint, Boolean value) {
        Map<String, Object> auth = new Map<String, Object>();
        auth.put('value', value);
        auth.put('dataUsePurpose', dataUsePurpose);
        auth.put('contactPointType', contactPointType);
        auth.put('contactPoint', contactPoint);
        return auth;
    }

    /**
     * Parsea una cadena de canales separados por coma
     * Ejemplo: "WhatsApp,correo electrónico" → Set{'WhatsApp', 'correo electrónico'}
     */
    private Set<String> parseChannels(String channelsString) {
        Set<String> channels = new Set<String>();

        if (String.isBlank(channelsString)) {
            return channels;
        }

        // Dividir por coma y limpiar espacios
        List<String> channelList = channelsString.split(',');
        for (String channel : channelList) {
            String trimmedChannel = channel.trim();
            if (String.isNotBlank(trimmedChannel)) {
                channels.add(trimmedChannel);
            }
        }

        return channels;
    }

    /**
     * Convierte un string a boolean (acepta '1', 'true', 'TRUE', 'verdadero', 'VERDADERO', etc.)
     */
    private Boolean parseBooleanValue(String value) {
        if (String.isBlank(value)) {
            return false;
        }

        value = value.trim().toLowerCase();

        return value == '1' ||
               value == 'true' ||
               value == 'verdadero' ||
               value == 'sí' ||
               value == 'si' ||
               value == 'yes' ||
               value == 'x';
    }

    /**
     * Busca el Individual relacionado según el tipo de cliente y documento de identidad
     * @param csvRow - Fila del CSV con datos del cliente
     * @return Individual encontrado o null si no existe
     */
    private Individual findRelatedIndividual(Map<String, String> csvRow) {
        String dataUsePurpose = csvRow.get('dataUsePurpose');
        String identityType;
        String identityNumber;

        // Determinar qué campos usar según tipo de cliente
        if (dataUsePurpose != null && dataUsePurpose.trim().equalsIgnoreCase('Cliente')) {
            // Cliente: usar identityType e identityNumber
            identityType = csvRow.get('identityType');
            identityNumber = csvRow.get('identityNumber');
        } else if (dataUsePurpose != null && dataUsePurpose.trim().equalsIgnoreCase('Cliente Representante Legal')) {
            // Cliente Representante Legal: usar contactIdType y contactIdNumber
            identityType = csvRow.get('contactIdType');
            identityNumber = csvRow.get('contactIdNumber');
        } else {
            System.debug('⚠️ dataUsePurpose no reconocido: ' + dataUsePurpose);
            return null;
        }

        System.debug('🔍 Buscando Individual para ' + dataUsePurpose);
        System.debug('   Tipo: ' + identityType + ', Número: ' + identityNumber);

        Individual individual = null;

        try {
            List<Individual> individuals = [
                SELECT Id,
                       Name,
                       CS_TipoIdentificacion__c,
                       CS_NumeroIdentificacion__c
                FROM Individual
                WHERE CS_TipoIdentificacion__c = :identityType
                  AND CS_NumeroIdentificacion__c = :identityNumber
                LIMIT 1
            ];

            if (!individuals.isEmpty()) {
                individual = individuals[0];
                System.debug('✅ Individual encontrado: ' + individual.Id + ' (' + individual.Name + ')');
            } else {
                System.debug('❌ No se encontró Individual para ' + dataUsePurpose + ' con identidad ' + identityType + ' ' + identityNumber);
            }

        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, '❌ Error buscando Individual: ' + e.getMessage());
            System.debug(LoggingLevel.ERROR, 'Stack trace: ' + e.getStackTraceString());
        }

        return individual;
    }

    /**
     * Busca el contacto relacionado según el tipo de cliente y documento de identidad
     * @param csvRow - Fila del CSV con datos del cliente
     * @return Contact encontrado o null si no existe
     */
    private Contact findRelatedContact(Map<String, String> csvRow) {
        String dataUsePurpose = csvRow.get('dataUsePurpose');
        String identityType;
        String identityNumber;

        // Determinar qué campos usar según tipo de cliente
        if (dataUsePurpose != null && dataUsePurpose.trim().equalsIgnoreCase('Cliente')) {
            // Cliente: usar identityType e identityNumber
            identityType = csvRow.get('identityType');
            identityNumber = csvRow.get('identityNumber');
        } else if (dataUsePurpose != null && dataUsePurpose.trim().equalsIgnoreCase('Cliente Representante Legal')) {
            // Cliente Representante Legal: usar contactIdType y contactIdNumber
            identityType = csvRow.get('contactIdType');
            identityNumber = csvRow.get('contactIdNumber');
        } else {
            System.debug('⚠️ dataUsePurpose no reconocido: ' + dataUsePurpose);
            return null;
        }

        System.debug('🔍 Buscando contacto para ' + dataUsePurpose);
        System.debug('   Tipo: ' + identityType + ', Número: ' + identityNumber);

        Contact contact = null;

        try {
            List<Contact> contacts = [
                SELECT Id,
                       Name,
                       CS_TipoIdentificacionCP__c,
                       CS_NumeroIdentificacionCP__c
                FROM Contact
                WHERE CS_TipoIdentificacionCP__c = :identityType
                  AND CS_NumeroIdentificacionCP__c = :identityNumber
                LIMIT 1
            ];

            if (!contacts.isEmpty()) {
                contact = contacts[0];
                System.debug('✅ Contacto encontrado: ' + contact.Id + ' (' + contact.Name + ')');
            } else {
                System.debug('❌ No se encontró contacto para ' + dataUsePurpose + ' con identidad ' + identityType + ' ' + identityNumber);
            }

        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, '❌ Error buscando contacto: ' + e.getMessage());
            System.debug(LoggingLevel.ERROR, 'Stack trace: ' + e.getStackTraceString());
        }

        return contact;
    }

    /**
     * Busca la cuenta relacionada según el tipo de cliente y documento de identidad
     * @param csvRow - Fila del CSV con datos del cliente
     * @return Account encontrada o null si no existe
     */
    private Account findRelatedAccount(Map<String, String> csvRow) {
        String dataUsePurpose = csvRow.get('dataUsePurpose');
        String identityType = csvRow.get('identityType');
        String identityNumber = csvRow.get('identityNumber');

        System.debug('🔍 Buscando cuenta para ' + dataUsePurpose);
        System.debug('   Tipo: ' + identityType + ', Número: ' + identityNumber);

        Account account = null;

        try {
            if (dataUsePurpose != null && dataUsePurpose.trim().equalsIgnoreCase('Cliente')) {
                // Cliente Personal - Buscar por campos PersonAccount
                List<Account> accounts = [
                    SELECT Id,
                           RecordType.DeveloperName,
                           Name,
                           CS_TipoIdentificacion__c,
                           CS_NumeroIdentificacion__c,
                           CS_TipoIdentificacionCP__pc,
                           CS_NumeroIdentificacionCP__pc
                    FROM Account
                    WHERE CS_TipoIdentificacionCP__pc = :identityType
                      AND CS_NumeroIdentificacionCP__pc = :identityNumber
                      AND RecordType.DeveloperName = 'PersonAccount'
                    LIMIT 1
                ];

                if (!accounts.isEmpty()) {
                    account = accounts[0];
                }

            } else if (dataUsePurpose != null && dataUsePurpose.trim().equalsIgnoreCase('Cliente Representante Legal')) {
                // Cliente Representante Legal - Buscar por campos cuenta jurídica
                List<Account> accounts = [
                    SELECT Id,
                           RecordType.DeveloperName,
                           Name,
                           CS_TipoIdentificacion__c,
                           CS_NumeroIdentificacion__c,
                           CS_TipoIdentificacionCP__pc,
                           CS_NumeroIdentificacionCP__pc
                    FROM Account
                    WHERE CS_TipoIdentificacion__c = :identityType
                      AND CS_NumeroIdentificacion__c = :identityNumber
                      AND RecordType.DeveloperName = 'CS_Juridico'
                    LIMIT 1
                ];

                if (!accounts.isEmpty()) {
                    account = accounts[0];
                }
            }

            if (account != null) {
                System.debug('✅ Cuenta encontrada: ' + account.Id + ' (' + account.Name + ')');
                System.debug('   RecordType: ' + account.RecordType.DeveloperName);
            } else {
                System.debug('❌ No se encontró cuenta para ' + dataUsePurpose + ' con identidad ' + identityType + ' ' + identityNumber);
            }

        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, '❌ Error buscando cuenta: ' + e.getMessage());
            System.debug(LoggingLevel.ERROR, 'Stack trace: ' + e.getStackTraceString());
        }

        return account;
    }

    /**
     * Crea un caso para el tratamiento procesado
     * @param csvRow - Fila del CSV con datos del cliente
     * @param rowNumber - Número de fila para logging
     * @return Id del caso creado
     */
    private String createCaseForTreatment(Map<String, String> csvRow, Integer rowNumber) {
        System.debug('📋 Iniciando creación de caso para fila #' + rowNumber);

        // Validar que tengamos el RecordType cacheado
        if (caseRecordTypeId == null) {
            throw new CaseCreationException('RecordType Novelty_PQRS no está disponible. No se puede crear el caso.');
        }

        // Buscar la cuenta relacionada
        Account account = findRelatedAccount(csvRow);

        if (account == null) {
            String dataUsePurpose = csvRow.get('dataUsePurpose');
            String identityType = csvRow.get('identityType');
            String identityNumber = csvRow.get('identityNumber');

            throw new CaseCreationException(
                'No se encontró cuenta para ' + dataUsePurpose +
                ' con identidad ' + identityType + ' ' + identityNumber
            );
        }

        // Buscar el Individual relacionado (donde se guardan las autorizaciones)
        Individual individual = findRelatedIndividual(csvRow);

        if (individual == null) {
            System.debug(LoggingLevel.WARN, '⚠️ No se encontró Individual para esta fila. El caso se creará sin Individual__c.');
        }

        // Buscar el contacto relacionado
        Contact contact = findRelatedContact(csvRow);

        if (contact == null) {
            System.debug(LoggingLevel.WARN, '⚠️ No se encontró contacto para esta fila. El caso se creará sin ContactId.');
        }

        // Crear el caso
        Case newCase = new Case();
        newCase.AccountId = account.Id;
        newCase.ContactId = (contact != null) ? contact.Id : null;
        newCase.Individual__c = (individual != null) ? individual.Id : null;
        newCase.RecordTypeId = caseRecordTypeId;
        newCase.Priority = 'Medio';
        newCase.Status = 'Cerrado Atendido';
        newCase.FilingDate__c = Date.today();
        newCase.Subject = 'Habeas Data';
        newCase.Description = 'Revocación automática de tratamiento de datos';
        newCase.Reason = 'Habeas Data';
        newCase.SubReason__c = 'Actualización Habeas Data';
        newCase.FinalAnswer__c = 'Se ha procesado la solicitud de actualización de autorizaciones de tratamiento de datos personales de acuerdo con la Ley 1581 de 2012 y el Decreto 1377 de 2013. Las preferencias del titular han sido actualizadas en el sistema.';
        newCase.Tiene_Respuesta_fianal__c = true; // Requerido por regla de validación para cerrar caso como "Cerrado Atendido"
        newCase.Entity__c = csvRow.get('entity');
        newCase.Origin = 'RNE (Registro Nacional de Excluidos)';
        newCase.Closing_on_first_contact__c = true;

        System.debug('📋 Insertando caso con los siguientes datos:');
        System.debug('   AccountId: ' + newCase.AccountId);
        System.debug('   ContactId: ' + newCase.ContactId);
        System.debug('   Individual__c: ' + newCase.Individual__c);
        System.debug('   RecordTypeId: ' + newCase.RecordTypeId);
        System.debug('   Priority: ' + newCase.Priority);
        System.debug('   Status: ' + newCase.Status);
        System.debug('   Subject: ' + newCase.Subject);
        System.debug('   FinalAnswer__c: ' + newCase.FinalAnswer__c);
        System.debug('   Tiene_Respuesta_fianal__c: ' + newCase.Tiene_Respuesta_fianal__c);

        try {
            insert newCase;
            System.debug('✅ Caso insertado exitosamente con Id: ' + newCase.Id);
            return newCase.Id;
        } catch (DmlException dmlEx) {
            System.debug(LoggingLevel.ERROR, '❌ Error DML insertando caso: ' + dmlEx.getMessage());
            System.debug(LoggingLevel.ERROR, 'Stack trace: ' + dmlEx.getStackTraceString());
            throw new CaseCreationException('Error insertando caso: ' + dmlEx.getMessage());
        }
    }
}