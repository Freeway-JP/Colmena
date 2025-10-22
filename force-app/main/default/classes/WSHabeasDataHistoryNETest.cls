@IsTest(SeeAllData=false)
private class WSHabeasDataHistoryNETest {
    /**
     * @description Crea un Individual válido para pruebas de dispatcher/call; el historial se inyecta vía hook para no depender de la org.
     * @author Charlie
     * @date 2025-10-09
     */
    @TestSetup
    static void setup() {
        Schema.DescribeFieldResult tiDescribe = Individual.CS_TipoIdentificacion__c.getDescribe();
        List<Schema.PicklistEntry> tiVals = tiDescribe.getPicklistValues();
        String ti = tiVals.isEmpty() ? null : tiVals[0].getValue();

        Individual ind = new Individual();
        ind.LastName = 'Test';
        ind.CS_TipoIdentificacion__c = ti;
        ind.CS_NumeroIdentificacion__c = '999999999';
        insert ind;
    }

    /**
     * @description Obtiene el Id del Individual creado en @TestSetup para usarlo como recordId en pruebas de call().
     * @author Charlie
     * @date 2025-10-09
     */
    private static Id getIndividualId() {
        return [SELECT Id FROM Individual ORDER BY CreatedDate DESC LIMIT 1].Id;
    }

    /**
     * @description Inyecta filas como List<Map<String,Object>> para cubrir makeRow y helpers sin usar IndividualHistory ni stripInaccessible en test.
     * @author Charlie
     * @date 2025-10-09
     */
    @IsTest
    static void testBuildJsonAndSchemaAndPresence_withOverride() {
        Schema.DescribeFieldResult tiDescribe = Individual.CS_TipoIdentificacion__c.getDescribe();
        List<Schema.PicklistEntry> tiVals = tiDescribe.getPicklistValues();
        String ti = tiVals.isEmpty() ? null : tiVals[0].getValue();

        Map<String, Object> indSub = new Map<String, Object>{ 'CS_TipoIdentificacion__c' => ti, 'CS_NumeroIdentificacion__c' => '999999999' };

        Datetime base = Datetime.now();
        List<Map<String, Object>> rowsMaps = new List<Map<String, Object>>{
            new Map<String, Object>{
                'Field' => 'notEssentialFunctionalitiesARL_H__c',
                'NewValue' => 'FNE1 ;  FNE2 ; FNE3',
                'CreatedDate' => base,
                'Individual' => indSub
            },
            new Map<String, Object>{
                'Field' => 'notEssentialFunctionalitiesSegGen_H__c',
                'NewValue' => null,
                'CreatedDate' => base.addSeconds(1),
                'Individual' => indSub
            },
            new Map<String, Object>{
                'Field' => 'notEssentialFunctionalitiesSegVida_H__c',
                'NewValue' => 'FNE2',
                'CreatedDate' => base.addSeconds(2),
                'Individual' => indSub
            }
        };

        WSHabeasDataHistoryNE.testRowsOverrideMaps = rowsMaps;

        Id anyId = [SELECT Id FROM Individual ORDER BY CreatedDate DESC LIMIT 1].Id;
        Test.startTest();
        List<Object> payload = WSHabeasDataHistoryNE.buildJson(anyId);
        Test.stopTest();

        System.assertNotEquals(null, payload);
        System.assertEquals(3, payload.size());

        Boolean sawARL = false;
        Boolean sawSegGenCleared = false;
        Boolean sawSegVida = false;
        Boolean sawAtLeastOneNO = false;
        Boolean sawTipoIdent = false;
        Boolean sawNumeroIdent = false;

        for (Object o : payload) {
            Map<String, Object> m = (Map<String, Object>) o;
            System.assert(m.containsKey('CreatedDate'));
            System.assert(String.valueOf(m.get('CreatedDate')).contains('T'));
            System.assert(m.containsKey('Aseguradora'));
            System.assert(m.containsKey('NoEsencial1'));
            System.assert(m.containsKey('NoEsencial2'));
            System.assert(m.containsKey('NoEsencial3'));
            System.assert(m.containsKey('Nombre'));
            System.assert(m.containsKey('TipoIdentificacion'));
            System.assert(m.containsKey('NumeroIdentificacion'));

            if (m.get('TipoIdentificacion') != null)
                sawTipoIdent = true;
            if ('999999999'.equals(m.get('NumeroIdentificacion')))
                sawNumeroIdent = true;

            String aseg = (String) m.get('Aseguradora');
            if (aseg == 'ARL') {
                sawARL = true;
                System.assertNotEquals('NO', m.get('NoEsencial1'));
            }
            if (aseg == 'Seguros Generales') {
                if (m.get('NoEsencial1') == 'NO' && m.get('NoEsencial2') == 'NO' && m.get('NoEsencial3') == 'NO') {
                    sawSegGenCleared = true;
                }
            }
            if (aseg == 'Seguro de Vida') {
                sawSegVida = true;
            }
            if (m.get('NoEsencial1') == 'NO' || m.get('NoEsencial2') == 'NO' || m.get('NoEsencial3') == 'NO') {
                sawAtLeastOneNO = true;
            }
        }

        System.assertEquals(true, sawARL);
        System.assertEquals(true, sawSegGenCleared);
        System.assertEquals(true, sawSegVida);
        System.assertEquals(true, sawAtLeastOneNO);
        System.assertEquals(true, sawTipoIdent);
        System.assertEquals(true, sawNumeroIdent);

        WSHabeasDataHistoryNE.testRowsOverrideMaps = null;
    }

    /**
     * @description Ruta feliz del dispatcher; verifica consents en salida sin depender de historial real del org gracias a la cobertura anterior de buildJson/makeRow.
     * @author Charlie
     * @date 2025-10-09
     */
    @IsTest
    static void testCallSuccessPath() {
        Id indId = getIndividualId();
        WSHabeasDataHistoryNE svc = new WSHabeasDataHistoryNE();
        Map<String, Object> input = new Map<String, Object>{ 'recordId' => indId };
        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();

        Test.startTest();
        Boolean ok = (Boolean) svc.call('getHistoryNE', new Map<String, Object>{ 'input' => input, 'output' => output, 'options' => options });
        Test.stopTest();

        System.assertEquals(true, ok);
        System.assert(output.containsKey('consents'));
        System.assertNotEquals(null, output.get('consents'));
    }

    /**
     * @description Fallos controlados del dispatcher: acción desconocida y en blanco; valida flags de error y mensaje en output.
     * @author Charlie
     * @date 2025-10-09
     */
    @IsTest
    static void testDispatcherFailurePaths() {
        WSHabeasDataHistoryNE svc = new WSHabeasDataHistoryNE();

        Map<String, Object> out1 = new Map<String, Object>();
        Boolean ok1 = (Boolean) svc.call(
            'nope',
            new Map<String, Object>{ 'input' => new Map<String, Object>(), 'output' => out1, 'options' => new Map<String, Object>() }
        );
        System.assertEquals(false, ok1);
        System.assertEquals(true, out1.get('error'));

        Map<String, Object> out2 = new Map<String, Object>();
        Boolean ok2 = (Boolean) svc.call(
            '',
            new Map<String, Object>{ 'input' => new Map<String, Object>(), 'output' => out2, 'options' => new Map<String, Object>() }
        );
        System.assertEquals(false, ok2);
        System.assertEquals(true, out2.get('error'));
    }

    /**
     * @description Caso recordId ausente; consents vacío y ejecución de los guards de fetch/buildJson con Id nulo.
     * @author Charlie
     * @date 2025-10-09
     */
    @IsTest
    static void testCallWithMissingRecordId() {
        WSHabeasDataHistoryNE svc = new WSHabeasDataHistoryNE();
        Map<String, Object> out = new Map<String, Object>();
        Boolean ok = (Boolean) svc.call(
            'getHistoryNE',
            new Map<String, Object>{ 'input' => new Map<String, Object>(), 'output' => out, 'options' => new Map<String, Object>() }
        );
        System.assertEquals(true, ok);
        System.assert(out.containsKey('consents'));
        List<Object> cons = (List<Object>) out.get('consents');
        System.assertEquals(true, cons.isEmpty());
    }

    /**
     * @description Id inválido para forzar excepción y seteo de claves 'error' y 'message' en el output del dispatcher.
     * @author Charlie
     * @date 2025-10-09
     */
    @IsTest
    static void testCallWithInvalidId() {
        WSHabeasDataHistoryNE svc = new WSHabeasDataHistoryNE();
        Map<String, Object> input = new Map<String, Object>{ 'recordId' => 'BAD_ID' };
        Map<String, Object> out = new Map<String, Object>();
        Boolean ok = (Boolean) svc.call('getHistoryNE', new Map<String, Object>{ 'input' => input, 'output' => out, 'options' => new Map<String, Object>() });
        System.assertEquals(false, ok);
        System.assertEquals(true, out.get('error'));
        System.assertNotEquals(null, out.get('message'));
    }

    /**
     * @description buildJson(null) devuelve lista vacía cubriendo guardas de fetch().
     * @author Charlie
     * @date 2025-10-09
     */
    @IsTest
    static void testBuildJsonWithNullId() {
        List<Object> payload = WSHabeasDataHistoryNE.buildJson(null);
        System.assertEquals(true, payload.isEmpty());
    }
}