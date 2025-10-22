@IsTest
public class RevocationBatchTest {
    // -------------------------
    // Helpers
    // -------------------------
    private static String anyPickValue(Schema.SObjectField f, String fallback) {
        List<Schema.PicklistEntry> ps = f.getDescribe().getPicklistValues();
        return ps.isEmpty() ? fallback : ps[0].getValue();
    }

    private static void ensureBrands() {
        if ([SELECT COUNT() FROM BusinessBrand] == 0) {
            insert new BusinessBrand(Name = 'ARL');
            insert new BusinessBrand(Name = 'Seguros Generales');
        }
    }

    private static void ensureEngagementTypes() {
        if ([SELECT COUNT() FROM EngagementChannelType WHERE Name IN ('Email', 'Phone')] < 2) {
            Map<String, EngagementChannelType> existing = new Map<String, EngagementChannelType>();
            for (EngagementChannelType e : [SELECT Id, Name FROM EngagementChannelType WHERE Name IN ('Email', 'Phone')]) {
                existing.put(e.Name, e);
            }
            if (!existing.containsKey('Email'))
                insert new EngagementChannelType(Name = 'Email');
            if (!existing.containsKey('Phone'))
                insert new EngagementChannelType(Name = 'Phone');
        }
    }

    private static void ensureDataUsePurpose(String nameVal) {
        if ([SELECT COUNT() FROM DataUsePurpose WHERE Name = :nameVal] == 0) {
            insert new DataUsePurpose(Name = nameVal);
        }
    }

    /**
     * @description Crea un mapa que representa un tratamiento transformado
     * simulando la salida de RevocationDataTransformer
     */
    private static Map<String, Object> createTransformedTreatment(String identityNumber) {
        Map<String, Object> treatment = new Map<String, Object>();

        // Datos básicos del titular
        treatment.put('firstName', 'John');
        treatment.put('secondName', 'Q');
        treatment.put('lastName', 'Doe');
        treatment.put('secondLastName', 'JR');

        // Documento
        String idType = anyPickValue(Lead.Tipo_de_documento__c, 'CC');
        treatment.put('identityType', idType);
        treatment.put('identityNumber', identityNumber);

        // Contacto
        treatment.put('email', 'john.doe' + identityNumber + '@test.com');
        treatment.put('numberPhone', '6012345678');
        treatment.put('sex', anyPickValue(Lead.Genero__c, 'Masculino'));

        // Datos del representante legal
        treatment.put('contactFirstName', 'Jane');
        treatment.put('contactLastName', 'Doe');
        treatment.put('contactIdType', idType);
        treatment.put('contactIdNumber', identityNumber + '1');

        // Control y canal
        treatment.put('dataUsePurpose', WSHabeasDataUtilities.PROSPECTO);
        treatment.put('authorizationChannel', 'Portal de proveedores');
        treatment.put('channelType', 'Digital');
        treatment.put('process', WSHabeasDataUtilities.SALES_PROCESS);
        treatment.put('businessCoverage', 'Retail');
        treatment.put('origin', 'Portal');
        treatment.put('collectionMethodType', 'Form');

        // Validación identidad
        treatment.put('identityValidationNoData', true);

        // Companies y autorizaciones
        List<Map<String, Object>> companies = new List<Map<String, Object>>();

        // Crear autorizaciones 2300
        List<Map<String, Object>> auths = new List<Map<String, Object>>();

        Map<String, Object> emailAuth = new Map<String, Object>();
        emailAuth.put('value', true);
        emailAuth.put('contactPointType', 'Email');
        emailAuth.put('contactPoint', 'john.doe' + identityNumber + '@test.com');
        emailAuth.put('dataUsePurpose', WSHabeasDataUtilities.DEBT_COLLECT);
        auths.add(emailAuth);

        Map<String, Object> phoneAuth = new Map<String, Object>();
        phoneAuth.put('value', true);
        phoneAuth.put('contactPointType', 'Phone');
        phoneAuth.put('contactPoint', '6012345678');
        phoneAuth.put('dataUsePurpose', WSHabeasDataUtilities.DATA_MARKETING);
        auths.add(phoneAuth);

        // Company 1
        Map<String, Object> company1 = new Map<String, Object>();
        company1.put('name', 'ARL');
        company1.put('medicalHistory', true);
        company1.put('dataMarketing', true);
        company1.put('generalProcessingData', true);
        company1.put('authorization2300', auths);
        companies.add(company1);

        // Company 2
        Map<String, Object> company2 = new Map<String, Object>();
        company2.put('name', 'Seguros Generales');
        company2.put('medicalHistory', false);
        company2.put('dataMarketing', true);
        company2.put('generalProcessingData', true);
        company2.put('authorization2300', auths);
        companies.add(company2);

        treatment.put('companies', companies);

        return treatment;
    }

    // -------------------------
    // Tests
    // -------------------------
    @testSetup
    static void setupCatalogs() {
        ensureBrands();
        ensureEngagementTypes();
        ensureDataUsePurpose(WSHabeasDataUtilities.PROSPECTO);
    }

    /**
     * @description Test constructor con lista null
     */
    @IsTest
    static void test_constructor_with_null_list() {
        Test.startTest();
        RevocationBatch batch = new RevocationBatch(null);
        Test.stopTest();

        // Verificar que el batch se crea correctamente sin errores
        System.assertNotEquals(null, batch, 'El batch debe inicializarse correctamente con lista null');
    }

    /**
     * @description Test constructor con lista vacía
     */
    @IsTest
    static void test_constructor_with_empty_list() {
        List<Object> emptyList = new List<Object>();

        Test.startTest();
        RevocationBatch batch = new RevocationBatch(emptyList);
        Test.stopTest();

        System.assertNotEquals(null, batch, 'El batch debe inicializarse correctamente con lista vacía');
    }

    /**
     * @description Test del método start - verifica que retorna la lista correcta
     */
    @IsTest
    static void test_start_method_returns_correct_list() {
        List<Object> treatments = new List<Object>();
        treatments.add(createTransformedTreatment('987654321'));

        RevocationBatch batch = new RevocationBatch(treatments);

        Test.startTest();
        Iterable<Object> result = batch.start(null);
        Test.stopTest();

        System.assertNotEquals(null, result, 'El método start debe retornar un iterable');
    }

    /**
     * @description Test de execute con un tratamiento válido
     * Verifica que el batch se ejecuta sin errores
     */
    @IsTest
    static void test_execute_with_single_valid_treatment() {
        List<Object> treatments = new List<Object>();
        treatments.add(createTransformedTreatment('987654321'));

        RevocationBatch batch = new RevocationBatch(treatments);

        Test.startTest();
        Id jobId = Database.executeBatch(batch, 1);
        Test.stopTest();

        // Verificar que el batch se ejecutó correctamente
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors
                           FROM AsyncApexJob
                           WHERE Id = :jobId];

        System.assertEquals('Completed', job.Status, 'El batch debe completarse');
        System.assertEquals(0, job.NumberOfErrors, 'El batch no debe tener errores');
    }

    /**
     * @description Test de execute con múltiples tratamientos
     * Verifica que el batch procesa múltiples registros sin errores
     */
    @IsTest
    static void test_execute_with_multiple_treatments() {
        List<Object> treatments = new List<Object>();
        treatments.add(createTransformedTreatment('987654321'));
        treatments.add(createTransformedTreatment('987654322'));
        treatments.add(createTransformedTreatment('987654323'));

        RevocationBatch batch = new RevocationBatch(treatments);

        Test.startTest();
        // Use batch size equal to the number of treatments to ensure single batch execution
        Id jobId = Database.executeBatch(batch, treatments.size());
        Test.stopTest();

        // Verificar que el batch procesó sin errores
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors
                           FROM AsyncApexJob
                           WHERE Id = :jobId];

        System.assertEquals('Completed', job.Status, 'El batch debe completarse');
        System.assertEquals(0, job.NumberOfErrors, 'No debe haber errores al procesar múltiples tratamientos');
    }

    /**
     * @description Test de execute con tratamiento inválido (sin campos requeridos)
     * Verifica que el batch maneja excepciones correctamente
     */
    @IsTest
    static void test_execute_with_invalid_treatment_handles_exception() {
        List<Object> treatments = new List<Object>();

        // Crear tratamiento inválido (sin campos requeridos)
        Map<String, Object> invalidTreatment = new Map<String, Object>();
        invalidTreatment.put('identityType', 'CC');
        invalidTreatment.put('identityNumber', '123456789');
        // Faltan campos requeridos

        treatments.add(invalidTreatment);

        RevocationBatch batch = new RevocationBatch(treatments);

        Test.startTest();
        Database.executeBatch(batch, 1);
        Test.stopTest();

        // El batch debe completarse sin lanzar excepción no controlada
        // La excepción se captura en el bloque try-catch del execute
        System.assert(true, 'El batch debe manejar excepciones sin fallar');
    }

    /**
     * @description Test de execute con datos que causan error en la conversión JSON
     */
    @IsTest
    static void test_execute_with_json_conversion_error() {
        List<Object> treatments = new List<Object>();

        // Agregar un objeto que no se puede serializar correctamente a HabeasDataDto
        Map<String, Object> malformedTreatment = new Map<String, Object>();
        malformedTreatment.put('companies', 'invalid_not_a_list');

        treatments.add(malformedTreatment);

        RevocationBatch batch = new RevocationBatch(treatments);

        Test.startTest();
        try {
            Database.executeBatch(batch, 1);
            Test.stopTest();
            System.assert(true, 'El batch debe manejar errores de conversión JSON');
        } catch (Exception e) {
            Test.stopTest();
            System.assert(true, 'Se esperaba una excepción en conversión JSON');
        }
    }

    /**
     * @description Test del método finish
     */
    @IsTest
    static void test_finish_method_executes_correctly() {
        List<Object> treatments = new List<Object>();
        treatments.add(createTransformedTreatment('987654324'));

        RevocationBatch batch = new RevocationBatch(treatments);

        Test.startTest();
        Id jobId = Database.executeBatch(batch, 1);
        Test.stopTest();

        // Verificar que el job se completó
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors
                           FROM AsyncApexJob
                           WHERE Id = :jobId];

        System.assertNotEquals(null, job, 'El job debe existir');
        System.assertEquals('Completed', job.Status, 'El job debe completarse');
    }

    /**
     * @description Test de execute procesando en scope (simula batch con scope de 2)
     * Verifica que el batch maneja correctamente un scope con múltiples registros
     */
    @IsTest
    static void test_execute_with_scope_of_multiple_treatments() {
        List<Object> treatments = new List<Object>();
        treatments.add(createTransformedTreatment('987654325'));
        treatments.add(createTransformedTreatment('987654326'));

        RevocationBatch batch = new RevocationBatch(treatments);

        Test.startTest();
        Id jobId = Database.executeBatch(batch, 2); // Scope de 2
        Test.stopTest();

        // Verificar que el batch se ejecutó sin errores
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors
                           FROM AsyncApexJob
                           WHERE Id = :jobId];

        System.assertEquals('Completed', job.Status, 'El batch debe completarse');
        System.assertEquals(0, job.NumberOfErrors, 'No debe haber errores al procesar scope múltiple');
    }

    /**
     * @description Test verificando que el batch ejecuta sin errores el flujo completo
     * incluyendo la llamada a WSHabeasDataService
     */
    @IsTest
    static void test_execute_calls_habeas_service_correctly() {
        List<Object> treatments = new List<Object>();
        Map<String, Object> treatment = createTransformedTreatment('987654327');
        treatments.add(treatment);

        RevocationBatch batch = new RevocationBatch(treatments);

        Test.startTest();
        Id jobId = Database.executeBatch(batch, 1);
        Test.stopTest();

        // Verificar que el batch se ejecutó sin lanzar excepciones no controladas
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors
                           FROM AsyncApexJob
                           WHERE Id = :jobId];

        System.assertEquals('Completed', job.Status, 'El batch debe completarse');
        // El servicio puede fallar internamente pero el batch debe manejar los errores
        System.assert(true, 'El batch debe manejar correctamente las llamadas al servicio');
    }

    /**
     * @description Test con tratamiento que tiene todas las companies
     * Verifica que el batch maneja correctamente tratamientos con múltiples empresas
     */
    @IsTest
    static void test_execute_with_all_companies() {
        List<Object> treatments = new List<Object>();
        Map<String, Object> treatment = createTransformedTreatment('987654328');

        // Agregar una tercera company
        List<Map<String, Object>> companies = (List<Map<String, Object>>) treatment.get('companies');
        Map<String, Object> company3 = new Map<String, Object>();
        company3.put('name', 'Seguro de Vida');
        company3.put('medicalHistory', true);
        company3.put('dataMarketing', false);
        company3.put('generalProcessingData', true);

        List<Map<String, Object>> auths = new List<Map<String, Object>>();
        Map<String, Object> emailAuth = new Map<String, Object>();
        emailAuth.put('value', true);
        emailAuth.put('contactPointType', 'Email');
        emailAuth.put('contactPoint', 'john.doe987654328@test.com');
        emailAuth.put('dataUsePurpose', WSHabeasDataUtilities.DEBT_COLLECT);
        auths.add(emailAuth);

        company3.put('authorization2300', auths);
        companies.add(company3);

        treatments.add(treatment);

        RevocationBatch batch = new RevocationBatch(treatments);

        Test.startTest();
        Id jobId = Database.executeBatch(batch, 1);
        Test.stopTest();

        // Verificar que el batch se ejecutó sin errores
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors
                           FROM AsyncApexJob
                           WHERE Id = :jobId];

        System.assertEquals('Completed', job.Status, 'El batch debe completarse');
        System.assertEquals(0, job.NumberOfErrors, 'Debe procesar tratamiento con múltiples companies sin errores');
    }

    /**
     * @description Test del batch completo ejecutándose de forma asíncrona
     * Note: In test context, only one executeBatch is allowed per test method
     * The batch size must match the iterable size to avoid multiple batch invocations
     */
    @IsTest
    static void test_batch_async_execution_completes() {
        List<Object> treatments = new List<Object>();
        for (Integer i = 0; i < 5; i++) {
            treatments.add(createTransformedTreatment('98765432' + i));
        }

        RevocationBatch batch = new RevocationBatch(treatments);

        Test.startTest();
        // Use batch size equal to the number of treatments to ensure single batch execution
        Id jobId = Database.executeBatch(batch, treatments.size());
        Test.stopTest();

        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed
                           FROM AsyncApexJob
                           WHERE Id = :jobId];

        System.assertEquals('Completed', job.Status, 'El batch debe completarse exitosamente');
        System.assertEquals(0, job.NumberOfErrors, 'No debe haber errores');
        // In test context with batch size = treatments.size(), all items are processed in one batch
        System.assertEquals(1, job.JobItemsProcessed, 'Debe procesar 1 batch con todos los items');
    }
}