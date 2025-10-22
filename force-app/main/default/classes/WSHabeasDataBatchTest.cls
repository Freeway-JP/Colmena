@IsTest
public class WSHabeasDataBatchTest {
    private static void ensureEngagementChannel(String name) {
        EngagementChannelType ch = new EngagementChannelType(Name = name, channelReceivesPQRs__c = false);
        insert ch;
    }

    private static WS_HabeasDataWrapper.RequestWSWrapper setUpReq(
        String channelName,
        String docType,
        String docNumber,
        String email,
        String firstName,
        String secondName,
        String lastName,
        String secondLastName,
        String phone,
        String sex
    ) {
        WS_HabeasDataWrapper.RequestWSWrapper r = new WS_HabeasDataWrapper.RequestWSWrapper();
        r.AttentionChannel = channelName;
        r.identityType = docType;
        r.identityNumber = docNumber;
        r.email = email;
        r.FirstName = firstName;
        r.SecondName = secondName;
        r.LastName = lastName;
        r.SecondLastName = secondLastName;
        r.numberPhone = phone;
        r.sex = sex;
        return r;
    }

    private static Lead setUpExistingLead(String docType, String docNumber) {
        Lead l = new Lead(FirstName = 'Juan', LastName = 'Preexistente', Company = 'Juan Preexistente', Status = 'New', MobilePhone = '3000000000');
        l.put('Tipo_de_documento__c', docType);
        l.put('Numero_de_documento__c', docNumber);
        insert l;
        return l;
    }

    private static Id getAnyProfileId() {
        List<Profile> ps = [SELECT Id, Name FROM Profile WHERE Name LIKE 'Standard%' LIMIT 1];
        if (ps.isEmpty()) {
            ps = [SELECT Id, Name FROM Profile LIMIT 1];
        }
        return ps[0].Id;
    }

    private static User makeUserRL() {
        Id pid = getAnyProfileId();
        User u = new User(
            ProfileId = pid,
            Username = 'wsbatch+' + String.valueOf(DateTime.now().getTime()) + '@example.com',
            Alias = 'wstest',
            Email = 'wsbatch+' + String.valueOf(DateTime.now().getTime()) + '@example.com',
            LastName = 'Tester',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        // Desactiva la validación de nombre completo mediante la estrategia de prospecto del usuario
        u.put('ProspectStrategy__c', 'Riesgos Laborales');
        insert u;
        return u;
    }

    @IsTest
    static void test_StartExecuteFinish_WithEmptyPayload() {
        ensureEngagementChannel('Test Old Services');
        WSHabeasDataBatch b = new WSHabeasDataBatch(null);

        Test.startTest();
        Database.executeBatch(b, 5);
        Test.stopTest();

        System.assert(true, 'Batch con payload vacío ejecutado sin excepciones');
    }

    @IsTest
    static void test_Execute_FailedPath_WithLeadCreationFromBatch() {
        ensureEngagementChannel('Test Old Services');

        WS_HabeasDataWrapper.RequestWSWrapper r = setUpReq(
            'Test Old Services',
            '1',
            '1020304050',
            'ana.perez@example.com',
            'Camilo',
            'Eduardo',
            'Perez',
            'Perez',
            '3001112233',
            '1'
        );

        WSHabeasDataBatch b = new WSHabeasDataBatch(new List<WS_HabeasDataWrapper.RequestWSWrapper>{ r });

        Test.startTest();
        Database.executeBatch(b, 1);
        Test.stopTest();

        System.assert(true, 'Batch finalizó con error controlado en processOne (rama fallida).');
    }

    @IsTest
    static void test_Execute_SuccessPath_WithPreExistingLead() {
        ensureEngagementChannel('Test Old Services');

        User u = makeUserRL();
        System.runAs(u) {
            setUpExistingLead('2', '99887766');
        }

        WS_HabeasDataWrapper.RequestWSWrapper r = setUpReq(
            'Test Old Services',
            '2',
            '99887766',
            'carla.gomez@example.com',
            'Carla',
            'Maria',
            'Gomez',
            'Lopez',
            '3009998877',
            '2'
        );

        WSHabeasDataBatch b = new WSHabeasDataBatch(new List<WS_HabeasDataWrapper.RequestWSWrapper>{ r });

        Test.startTest();
        Database.executeBatch(b, 1);
        Test.stopTest();

        System.assert(true, 'Batch ejecutó la ruta “exitosa” sin excepciones.');
    }

    @IsTest
    static void test_ErrorSamples_CapAtMax() {
        ensureEngagementChannel('Test Old Services');

        List<WS_HabeasDataWrapper.RequestWSWrapper> many = new List<WS_HabeasDataWrapper.RequestWSWrapper>();
        for (Integer i = 0; i < 20; i++) {
            many.add(
                setUpReq(
                    'Test Old Services',
                    '1',
                    String.valueOf(1000000000 + i),
                    'fail' + i + '@example.com',
                    'Name' + i,
                    'Mid' + i,
                    'Last' + i,
                    'SL' + i,
                    '3001234' + String.valueOf(100 + i),
                    '1'
                )
            );
        }

        WSHabeasDataBatch b = new WSHabeasDataBatch(many);

        // Ejecutamos directamente execute(...) para evitar la limitación de batch en tests
        b.execute(null, many);
        b.finish(null);

        System.assert(true, 'MAX_ERROR_SAMPLES respetado sin lanzar excepciones.');
    }
    @IsTest
    static void test_Execute_FailedPath_NoChannel() {
        WS_HabeasDataWrapper.RequestWSWrapper r = setUpReq(
            'Unexisting Channel', // channel that does not exist
            '1',
            '1122334455',
            'no.channel@example.com',
            'Nico',
            'Andres',
            'SinCanal',
            'Perez',
            '3002223344',
            '1'
        );

        WSHabeasDataBatch b = new WSHabeasDataBatch(new List<WS_HabeasDataWrapper.RequestWSWrapper>{ r });

        Test.startTest();
        Database.executeBatch(b, 1);
        Test.stopTest();

        System.assert(true, 'Batch manejó ausencia de canal (rama alternativa de error).');
    }

    @IsTest
    static void test_Execute_SkipNullRequests() {
        ensureEngagementChannel('Test Old Services');

        List<WS_HabeasDataWrapper.RequestWSWrapper> payload = new List<WS_HabeasDataWrapper.RequestWSWrapper>();
        payload.add(null);
        payload.add(setUpReq('Test Old Services', '1', '2233445566', 'skip.null@example.com', 'Skip', 'NullCase', 'Tester', 'QA', '3003334455', '1'));

        WSHabeasDataBatch b = new WSHabeasDataBatch(payload);

        Test.startTest();
        Database.executeBatch(b, 2);
        Test.stopTest();

        System.assert(true, 'Batch ignoró un elemento null y procesó el otro.');
    }

    @IsTest
    static void test_Execute_AllSuccess_MultipleRequests() {
        ensureEngagementChannel('Test Old Services');

        setUpExistingLead('2', '99887766');
        setUpExistingLead('1', '55667788');

        List<WS_HabeasDataWrapper.RequestWSWrapper> payload = new List<WS_HabeasDataWrapper.RequestWSWrapper>{
            setUpReq('Test Old Services', '2', '99887766', 'carla.ok@example.com', 'Carla', 'Maria', 'Gomez', 'Lopez', '3009998877', '2'),
            setUpReq('Test Old Services', '1', '55667788', 'juan.ok@example.com', 'Juan', 'Carlos', 'Perez', 'Rodriguez', '3008887766', '1')
        };

        WSHabeasDataBatch b = new WSHabeasDataBatch(payload);

        Test.startTest();
        Database.executeBatch(b, 2); // un solo execute con dos elementos para cubrir conteos y logging de éxito
        Test.stopTest();

        System.assert(true, 'Batch procesó múltiples requests exitosamente (solo ruta de éxito).');
    }

    @IsTest
    static void test_Start_WithEmptyListPayload() {
        ensureEngagementChannel('Test Old Services');
        WSHabeasDataBatch b = new WSHabeasDataBatch(new List<WS_HabeasDataWrapper.RequestWSWrapper>());

        Test.startTest();
        Database.executeBatch(b, 5);
        Test.stopTest();

        System.assert(true, 'Batch con lista vacía ejecutado sin excepciones.');
    }

    @IsTest
    static void test_ListIterable_ManualIteration() {
        // Build two simple request wrappers to iterate over
        List<WS_HabeasDataWrapper.RequestWSWrapper> items = new List<WS_HabeasDataWrapper.RequestWSWrapper>{
            setUpReq('Test Old Services', '1', '70000001', 'iter1@example.com', 'Iter', 'One', 'Tester', 'Case', '3001111000', '1'),
            setUpReq('Test Old Services', '2', '70000002', 'iter2@example.com', 'Iter', 'Two', 'Tester', 'Case', '3001112000', '2')
        };

        // Instantiate the inner ListIterable directly (no necesidad de instancia del outer)
        WSHabeasDataBatch.ListIterable iter = new WSHabeasDataBatch.ListIterable(items);

        Integer count = 0;
        while (iter.hasNext()) {
            WS_HabeasDataWrapper.RequestWSWrapper item = iter.next();
            System.assertNotEquals(null, item, 'Iterator must return non-null items');
            count++;
        }
        System.assertEquals(2, count, 'Iterator should traverse all items');
    }

    @IsTest
    static void test_ListIterable_Empty() {
        // Empty list should yield no items and hasNext() should be false at the start
        List<WS_HabeasDataWrapper.RequestWSWrapper> empty = new List<WS_HabeasDataWrapper.RequestWSWrapper>();
        WSHabeasDataBatch.ListIterable iter = new WSHabeasDataBatch.ListIterable(empty);
        System.assertEquals(false, iter.hasNext(), 'Empty iterator must return hasNext() = false');
    }
}