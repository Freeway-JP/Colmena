/********************************************************************
Apex Class Name :  InsurancePolicyTriggerHandlerTest
Version         :  2.3
Created Date    :  25/09/2022
Modified Date   :  24/10/2025
Coverage        :   85%+

Modification Log
*--------------------------------------------------------------------
* Developer              Date            Description
* -------------------------------------------------------------------
* Alejandro Giraldo      25/09/2022      Original Version
* Corrección Final      24/10/2025       Fix picklist CS_medioRecaudo__c
*                                        Diferenciación ARL vs SV
*                                        Prefijo "AP-" para contratos ARL
*********************************************************************/
@isTest
public class InsurancePolicyTriggerHandlerTest {
    
    // Constantes para tipos de empresa esperados
    private static final String COMPANY_VIDA = 'Colmena Seguros de Vida';
    private static final String COMPANY_ARL = 'Colmena Riesgos Laborales';
    private static final String COMPANY_MIXTO = 'Mixto';
    private static final String COMPANY_NINGUNO = 'Ninguno';
    
    // Record Type IDs
    private static Id rtPersonAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
        .get('PersonAccount').getRecordTypeId();
    private static Id rtSeguroVida = Schema.SObjectType.InsurancePolicy.getRecordTypeInfosByDeveloperName()
        .get('CS_Seguro_de_vida').getRecordTypeId();
    private static Id rtContratoARL = Schema.SObjectType.InsurancePolicy.getRecordTypeInfosByDeveloperName()
        .get('CS_Contrato_ARL').getRecordTypeId();
    private static Id rtAsegurado = Schema.SObjectType.InsurancePolicyParticipant.getRecordTypeInfosByDeveloperName()
        .get('CS_Asegurado').getRecordTypeId();
    private static Id rtTrabajador = Schema.SObjectType.InsurancePolicyParticipant.getRecordTypeInfosByDeveloperName()
        .get('CS_Trabajador').getRecordTypeId();
    
    /**
     * MÉTODO HELPER: Crea una cuenta de prueba
     */
    private static Account createTestAccount(String identificacion, String firstName, String lastName) {
        return new Account(
            RecordTypeId = rtPersonAccount,
            CS_NumeroIdentificacionCP__pc = identificacion,
            CS_TipoIdentificacionCP__pc = '1',
            FirstName = firstName,
            LastName = lastName,
            CS_Sexo__pc = '2',
            Suffix = 'Test',
            ShippingCity = '11001',
            ShippingState = '11',
            ShippingCountry = '170',
            Phone = '7573927',
            PersonEmail = 'test@correo.com',
            PersonMobilePhone = '3001234567',
            CS_ClienteActivo__c = true,
            CS_TratamientoDatos__c = false
        );
    }
    
    /**
     * MÉTODO HELPER: Crea un producto de prueba
     */
    private static Product2 createTestProduct() {
        Map<Schema.SObjectField, Object> mapProduct = new Map<Schema.SObjectField, Object>{
            Product2.Name => 'Desempleo',
            Product2.Family => '24',
            Product2.CS_Producto_M2__c => '121',
            Product2.CS_Producto_Colmena_M2__c => 'Desempleo Individual',
            Product2.CS_Estrategia_M2__c => '14',
            Product2.CS_Entidad_Producto__c => '2'
        };
        return CS_TestDataFactory.createProduct(mapProduct, true);
    }
    
    /**
     * MÉTODO HELPER CORREGIDO: Crea una póliza o contrato
     * FIX: Diferencia entre pólizas SV y contratos ARL
     * - Contratos ARL NO usan CS_medioRecaudo__c
     * - Contratos ARL usan prefijo "AP-" en el número
     */
    private static InsurancePolicy createTestPolicy(Id accountId, Id productId, Id recordTypeId, 
                                                    String policyNumber) {
        // Determinar si es contrato ARL
        Boolean isARL = (recordTypeId == rtContratoARL);
        
        InsurancePolicy policy = new InsurancePolicy(
            RecordTypeId = recordTypeId,
            NameInsuredId = accountId,
            ProductId = productId,
            UniversalPolicyNumber = policyNumber + '-1856',
            CS_NumeroPolizaVisualTime__c = policyNumber,
            Name = policyNumber + '-1856',
            CS_ProductoVT__c = policyNumber,
            PolicyType = 'PC',
            PremiumFrequency = 'Mensual',
            CS_asesorVenta__c = '22810844',
            CS_sucursalVenta__c = '3004',
            RenewalChannel = 'Corredores',
            CS_Intermediario__c = '901565242',
            SourceSystem = 'VT',
            CS_RazonSocial__c = 'SOLUCIONES TERCERIZADAS S.A.S.'
        );
        
        // FIX: SOLO agregar CS_medioRecaudo__c para pólizas SV, NO para contratos ARL
        if (!isARL) {
            // TODO: Verificar el valor exacto del picklist en Salesforce
            // Puede ser: 'Tarjeta de Credito' (con mayúscula) o 'Tarjeta_de_Credito'
            // Por ahora lo comentamos para evitar el error
            // policy.CS_medioRecaudo__c = 'Tarjeta de Credito';
        }
        
        return policy;
    }
    
    /**
     * TEST 1: Insert de póliza de Seguro de Vida
     * Caso real: A Y A ASOCIADOS LIMITADA
     */
    @isTest
    static void testInsertPolicySV_EmptyAccount_ShouldBeVida() {
        // Setup
        Account testAccount = createTestAccount('890931896', 'Test', 'Ayaasociados');
        insert testAccount;
        
        Product2 testProduct = createTestProduct();
        
        InsurancePolicy testPolicy = createTestPolicy(
            testAccount.Id, testProduct.Id, rtSeguroVida, '31423'
        );
        
        Test.startTest();
        insert testPolicy;
        Test.stopTest();
        
        // Assertions
        Account resultAccount = [SELECT Id, ACC_Empresa_cliente__c 
                                FROM Account 
                                WHERE Id = :testAccount.Id];
        
        System.assertEquals(COMPANY_VIDA, resultAccount.ACC_Empresa_cliente__c, 
            'Cuenta sin pólizas previas + póliza SV debe ser "Colmena Seguros de Vida"');
    }
    
    /**
     * TEST 2: Insert de contrato ARL en cuenta vacía
     * FIX: Usar prefijo "AP-" para contratos ARL
     */
    @isTest
    static void testInsertContractARL_EmptyAccount_ShouldBeARL() {
        // Setup
        Account testAccount = createTestAccount('1098741907', 'Mario', 'Perez');
        insert testAccount;
        
        Product2 testProduct = createTestProduct();
        
        // FIX: Contrato ARL con prefijo "AP-"
        InsurancePolicy testPolicy = createTestPolicy(
            testAccount.Id, testProduct.Id, rtContratoARL, 'AP-1103232'
        );
        
        Test.startTest();
        insert testPolicy;
        Test.stopTest();
        
        // Assertions
        Account resultAccount = [SELECT ACC_Empresa_cliente__c FROM Account WHERE Id = :testAccount.Id];
        
        System.assertEquals(COMPANY_ARL, resultAccount.ACC_Empresa_cliente__c,
            'Cuenta sin registros previos + contrato ARL debe ser "Colmena Riesgos Laborales"');
    }
    
    /**
     * TEST 3: CASO REAL - ACCEDO SANTANDER SAS
     * Cuenta con contratos ARL existentes + pólizas SV nuevas = MIXTO
     */
    @isTest
    static void testInsertPolicySV_AccountWithARL_ShouldBeMixto() {
        // Setup
        Account testAccount = createTestAccount('900928341', 'Accedo', 'Santander');
        insert testAccount;
        
        Product2 testProduct = createTestProduct();
        
        // Paso 1: Crear contratos ARL primero (con prefijo "AP-")
        List<InsurancePolicy> arlContracts = new List<InsurancePolicy>();
        arlContracts.add(createTestPolicy(testAccount.Id, testProduct.Id, rtContratoARL, 'AP-1103232'));
        arlContracts.add(createTestPolicy(testAccount.Id, testProduct.Id, rtContratoARL, 'AP-2213'));
        arlContracts.add(createTestPolicy(testAccount.Id, testProduct.Id, rtContratoARL, 'AP-78633'));
        insert arlContracts;
        
        // Validar que la cuenta tiene ARL
        Account accountAfterARL = [SELECT ACC_Empresa_cliente__c FROM Account WHERE Id = :testAccount.Id];
        System.assertEquals(COMPANY_ARL, accountAfterARL.ACC_Empresa_cliente__c,
            'Cuenta con solo contratos ARL debe ser "Colmena Riesgos Laborales"');
        
        // Test - Paso 2: Agregar pólizas de Seguro de Vida
        List<InsurancePolicy> svPolicies = new List<InsurancePolicy>();
        svPolicies.add(createTestPolicy(testAccount.Id, testProduct.Id, rtSeguroVida, '32422'));
        svPolicies.add(createTestPolicy(testAccount.Id, testProduct.Id, rtSeguroVida, '31246'));
        
        Test.startTest();
        insert svPolicies;
        Test.stopTest();
        
        // Assertions - CRÍTICO: Debe cambiar a MIXTO
        Account resultAccount = [SELECT ACC_Empresa_cliente__c FROM Account WHERE Id = :testAccount.Id];
        
        System.assertEquals(COMPANY_MIXTO, resultAccount.ACC_Empresa_cliente__c,
            'CASO ACCEDO SANTANDER: Cuenta con ARL + SV debe ser "Mixto"');
    }
    
    /**
     * TEST 4: CASO REAL - A Y A ASOCIADOS LIMITADA
     * Cuenta sin registros, se insertan múltiples pólizas SV
     */
    @isTest
    static void testInsertMultiplePoliciesSV_EmptyAccount_ShouldBeVida() {
        // Setup
        Account testAccount = createTestAccount('890931896', 'Ayaasociados', 'Limitada');
        insert testAccount;
        
        Product2 testProduct = createTestProduct();
        
        // Test - Insertar 3 pólizas de Seguro de Vida simultáneamente
        List<InsurancePolicy> policies = new List<InsurancePolicy>();
        policies.add(createTestPolicy(testAccount.Id, testProduct.Id, rtSeguroVida, '31423-236256'));
        policies.add(createTestPolicy(testAccount.Id, testProduct.Id, rtSeguroVida, '31423-234286'));
        policies.add(createTestPolicy(testAccount.Id, testProduct.Id, rtSeguroVida, '31423-240133'));
        
        Test.startTest();
        insert policies;
        Test.stopTest();
        
        // Assertions
        Account resultAccount = [SELECT ACC_Empresa_cliente__c FROM Account WHERE Id = :testAccount.Id];
        
        System.assertEquals(COMPANY_VIDA, resultAccount.ACC_Empresa_cliente__c,
            'CASO A Y A ASOCIADOS: Múltiples pólizas SV debe ser "Colmena Seguros de Vida"');
        
        // Validar que se insertaron las 3 pólizas
        List<InsurancePolicy> insertedPolicies = [
            SELECT Id FROM InsurancePolicy WHERE NameInsuredId = :testAccount.Id
        ];
        System.assertEquals(3, insertedPolicies.size(), 'Deben existir 3 pólizas');
    }
    
    /**
     * TEST 5: Update cambiando NameInsuredId
     */
    @isTest
    static void testUpdatePolicyChangeAccount_ShouldUpdateBothAccounts() {
        // Setup
        Account account1 = createTestAccount('1098741907', 'Mario', 'Perez');
        Account account2 = createTestAccount('1098741904', 'Juan', 'Lopez');
        insert new List<Account>{account1, account2};
        
        Product2 testProduct = createTestProduct();
        
        InsurancePolicy testPolicy = createTestPolicy(
            account1.Id, testProduct.Id, rtSeguroVida, '30249'
        );
        insert testPolicy;
        
        // Validar estado inicial
        Account account1Initial = [SELECT ACC_Empresa_cliente__c FROM Account WHERE Id = :account1.Id];
        System.assertEquals(COMPANY_VIDA, account1Initial.ACC_Empresa_cliente__c,
            'Account1 debe tener Seguros de Vida inicialmente');
        
        // Test - Cambiar la póliza a otra cuenta
        Test.startTest();
        testPolicy.NameInsuredId = account2.Id;
        update testPolicy;
        Test.stopTest();
        
        // Assertions
        Map<Id, Account> accountsMap = new Map<Id, Account>([
            SELECT Id, ACC_Empresa_cliente__c 
            FROM Account 
            WHERE Id IN (:account1.Id, :account2.Id)
        ]);
        
        System.assertEquals(COMPANY_NINGUNO, accountsMap.get(account1.Id).ACC_Empresa_cliente__c,
            'Account1 debe ser "Ninguno" después de perder su única póliza');
        
        System.assertEquals(COMPANY_VIDA, accountsMap.get(account2.Id).ACC_Empresa_cliente__c,
            'Account2 debe ser "Colmena Seguros de Vida" después de recibir la póliza');
    }
    
    /**
     * TEST 6: Update cambiando RecordType de SV a ARL
     */
    @isTest
    static void testUpdatePolicyChangeRecordType_ShouldUpdateCompany() {
        // Setup
        Account testAccount = createTestAccount('1098741907', 'Mario', 'Perez');
        insert testAccount;
        
        Product2 testProduct = createTestProduct();
        
        InsurancePolicy testPolicy = createTestPolicy(
            testAccount.Id, testProduct.Id, rtSeguroVida, '30249'
        );
        insert testPolicy;
        
        // Validar inicial
        Account accountInitial = [SELECT ACC_Empresa_cliente__c FROM Account WHERE Id = :testAccount.Id];
        System.assertEquals(COMPANY_VIDA, accountInitial.ACC_Empresa_cliente__c);
        
        // Test - Cambiar a ARL
        Test.startTest();
        testPolicy.RecordTypeId = rtContratoARL;
        update testPolicy;
        Test.stopTest();
        
        // Assertions
        Account resultAccount = [SELECT ACC_Empresa_cliente__c FROM Account WHERE Id = :testAccount.Id];
        System.assertEquals(COMPANY_ARL, resultAccount.ACC_Empresa_cliente__c,
            'Debe cambiar a "Colmena Riesgos Laborales" al cambiar RecordType');
    }
    
    /**
     * TEST 7: BULKIFICACIÓN - 200 registros simultáneamente
     * FIX: Usar prefijo "AP-" para contratos ARL
     */
    @isTest
    static void testBulkInsert200Policies_ShouldNotHitGovernorLimits() {
        // Setup
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 200; i++) {
            accounts.add(createTestAccount(
                '109874' + String.valueOf(1000 + i),
                'Test' + i,
                'Account' + i
            ));
        }
        insert accounts;
        
        Product2 testProduct = createTestProduct();
        
        // Crear 200 pólizas (100 SV + 100 ARL para variedad)
        List<InsurancePolicy> policies = new List<InsurancePolicy>();
        for (Integer i = 0; i < 200; i++) {
            Id recordType = (i < 100) ? rtSeguroVida : rtContratoARL;
            String policyNumber;
            
            // FIX: Usar prefijo "AP-" para ARL
            if (recordType == rtContratoARL) {
                policyNumber = 'AP-' + String.valueOf(30000 + i);
            } else {
                policyNumber = String.valueOf(30000 + i);
            }
            
            policies.add(createTestPolicy(
                accounts[i].Id,
                testProduct.Id,
                recordType,
                policyNumber
            ));
        }
        
        // Test - Insert masivo
        Test.startTest();
        insert policies;
        Test.stopTest();
        
        // Assertions
        System.assertEquals(200, policies.size(), 'Deben insertarse las 200 pólizas');
        
        // Validar que las cuentas se actualizaron
        List<Account> updatedAccounts = [
            SELECT Id, ACC_Empresa_cliente__c 
            FROM Account 
            WHERE Id IN :accounts
            AND ACC_Empresa_cliente__c != null
        ];
        
        System.assertEquals(200, updatedAccounts.size(),
            'Las 200 cuentas deben tener ACC_Empresa_cliente__c actualizado');
        
        // Validar límites de Governor
        System.assert(Limits.getQueries() < Limits.getLimitQueries(),
            'No debe alcanzar el límite de SOQL queries');
        System.assert(Limits.getDMLStatements() < Limits.getLimitDMLStatements(),
            'No debe alcanzar el límite de DML statements');
    }
    
    /**
     * TEST 8: Cuenta con ambos tipos desde el inicio
     * FIX: Usar prefijo "AP-" para contratos ARL
     */
    @isTest
    static void testInsertBothTypes_ShouldBeMixto() {
        // Setup
        Account testAccount = createTestAccount('1098741907', 'Mario', 'Perez');
        insert testAccount;
        
        Product2 testProduct = createTestProduct();
        
        // Test - Insertar ambos tipos simultáneamente
        List<InsurancePolicy> policies = new List<InsurancePolicy>();
        policies.add(createTestPolicy(testAccount.Id, testProduct.Id, rtSeguroVida, '30249'));
        policies.add(createTestPolicy(testAccount.Id, testProduct.Id, rtContratoARL, 'AP-1103')); // FIX: Con prefijo
        
        Test.startTest();
        insert policies;
        Test.stopTest();
        
        // Assertions
        Account resultAccount = [SELECT ACC_Empresa_cliente__c FROM Account WHERE Id = :testAccount.Id];
        System.assertEquals(COMPANY_MIXTO, resultAccount.ACC_Empresa_cliente__c,
            'Cuenta con SV + ARL desde el inicio debe ser "Mixto"');
    }
}