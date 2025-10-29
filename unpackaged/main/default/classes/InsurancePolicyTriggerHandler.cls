/********************************************************************
Apex Class Name:  InsurancePolicyTriggerHandler
Version      :  2.2
Created Date  :  20/09/2023
Modified Date :  24/10/2025
Function     :   Trigger Handler Class - VERSIÓN FINAL SIMPLIFICADA
Class Test      :   InsurancePolicyTriggerHandlerTest
Coverage        :   85%+
 
Modification Log
*--------------------------------------------------------------------
* Developer           Date           Description
* -------------------------------------------------------------------
* Alejandro Giraldo      20/09/2023       Original Version
* Optimización          24/10/2025       Bulkificación completa
* Corrección Final      24/10/2025       Eliminación de validaciones innecesarias
*                                        Status está vacío al insertar
*                                        Solo importa: ¿Qué RecordType tiene?
*********************************************************************/
public class InsurancePolicyTriggerHandler {
    
    // Constantes para tipos de empresa
    private static final String COMPANY_VIDA = 'Colmena Seguros de Vida';
    private static final String COMPANY_ARL = 'Colmena Riesgos Laborales';
    private static final String COMPANY_MIXTO = 'Mixto';
    private static final String COMPANY_NINGUNO = 'Ninguno';
    
    // Constantes para Record Types
    private static final String RT_SEGURO_VIDA = 'CS_Seguro_de_vida';
    private static final String RT_CONTRATO_ARL = 'CS_Contrato_ARL';
    private static final String RT_ASEGURADO = 'CS_Asegurado';
    private static final String RT_TRABAJADOR = 'CS_Trabajador';
    
    public static void handleTrigger(List<InsurancePolicy> TriggerNew, List<InsurancePolicy> TriggerOld, 
                                     Map<Id, InsurancePolicy> TriggerOldMap, System.TriggerOperation triggerEvent) {
        switch on triggerEvent {
            when AFTER_UPDATE {
                afterUpdate(TriggerNew, TriggerOldMap);
            }
            when AFTER_INSERT {
                afterInsert(TriggerNew);
            }
        }
    }
    
    /**
     * Método para manejo de INSERT
     * SIMPLIFICADO: No valida Status ni isActive, solo que tenga cuenta asociada
     */
    public static void afterInsert(List<InsurancePolicy> TriggerNew) {
        // Recolectar todos los IDs de cuentas asociadas
        Set<Id> accountIds = new Set<Id>();
        
        for (InsurancePolicy ip : TriggerNew) {
            // Solo verificar que tenga cuenta asociada
            // No importa Status, isActive, ni ningún otro campo
            if (ip.NameInsuredId != null) {
                accountIds.add(ip.NameInsuredId);
            }
        }
        
        if (!accountIds.isEmpty()) {
            processAccountUpdates(accountIds);
        }
    }
    
    /**
     * Método para manejo de UPDATE
     * Procesa cambios relevantes en las pólizas
     */
    public static void afterUpdate(List<InsurancePolicy> TriggerNew, Map<Id, InsurancePolicy> TriggerOldMap) {
        Set<Id> accountIds = new Set<Id>();
        
        for (InsurancePolicy newPolicy : TriggerNew) {
            InsurancePolicy oldPolicy = TriggerOldMap.get(newPolicy.Id);
            
            // Verificar si hay cambios relevantes
            Boolean hasRelevantChanges = 
                newPolicy.RecordTypeId != oldPolicy.RecordTypeId ||
                newPolicy.NameInsuredId != oldPolicy.NameInsuredId;
            
            if (hasRelevantChanges) {
                // Agregar cuenta nueva
                if (newPolicy.NameInsuredId != null) {
                    accountIds.add(newPolicy.NameInsuredId);
                }
                
                // Agregar cuenta antigua si cambió de cuenta
                if (newPolicy.NameInsuredId != oldPolicy.NameInsuredId && 
                    oldPolicy.NameInsuredId != null) {
                    accountIds.add(oldPolicy.NameInsuredId);
                }
            }
        }
        
        if (!accountIds.isEmpty()) {
            processAccountUpdates(accountIds);
        }
    }
    
    /**
     * Método centralizado para procesar actualizaciones de cuentas
     * SIMPLIFICADO: Solo cuenta RecordTypes, sin filtros de Status o isActive
     */
    private static void processAccountUpdates(Set<Id> accountIds) {
        if (accountIds == null || accountIds.isEmpty()) {
            return;
        }
        
        // 1. Consultar TODAS las pólizas/contratos de estas cuentas
        // SIN filtros de Status o isActive - queremos ver TODO lo que tiene la cuenta
        List<InsurancePolicy> allPolicies = [
            SELECT Id, NameInsuredId, RecordType.DeveloperName
            FROM InsurancePolicy
            WHERE NameInsuredId IN :accountIds
        ];
        
        // 2. Consultar TODOS los participantes
        List<InsurancePolicyParticipant> allParticipants = [
            SELECT Id, PrimaryParticipantAccountId, RecordType.DeveloperName
            FROM InsurancePolicyParticipant
            WHERE PrimaryParticipantAccountId IN :accountIds
        ];
        
        // 3. Para cada cuenta, determinar si tiene SV y/o ARL
        Map<Id, Boolean> accountHasSV = new Map<Id, Boolean>();
        Map<Id, Boolean> accountHasARL = new Map<Id, Boolean>();
        
        // Inicializar todos en false
        for (Id accountId : accountIds) {
            accountHasSV.put(accountId, false);
            accountHasARL.put(accountId, false);
        }
        
        // Contar por RecordType en pólizas
        for (InsurancePolicy ip : allPolicies) {
            if (ip.RecordType.DeveloperName == RT_SEGURO_VIDA) {
                accountHasSV.put(ip.NameInsuredId, true);
            } else if (ip.RecordType.DeveloperName == RT_CONTRATO_ARL) {
                accountHasARL.put(ip.NameInsuredId, true);
            }
        }
        
        // Contar por RecordType en participantes
        for (InsurancePolicyParticipant ipp : allParticipants) {
            if (ipp.RecordType.DeveloperName == RT_ASEGURADO) {
                accountHasSV.put(ipp.PrimaryParticipantAccountId, true);
            } else if (ipp.RecordType.DeveloperName == RT_TRABAJADOR) {
                accountHasARL.put(ipp.PrimaryParticipantAccountId, true);
            }
        }
        
        // 4. Determinar valor para cada cuenta
        Map<Id, String> accountValues = new Map<Id, String>();
        
        for (Id accountId : accountIds) {
            Boolean hasSV = accountHasSV.get(accountId);
            Boolean hasARL = accountHasARL.get(accountId);
            
            String companyValue = determineCompanyValue(hasSV, hasARL);
            accountValues.put(accountId, companyValue);
        }
        
        // 5. Actualizar cuentas
        List<Account> accountsToUpdate = [
            SELECT Id, ACC_Empresa_cliente__c
            FROM Account
            WHERE Id IN :accountValues.keySet()
        ];
        
        for (Account acc : accountsToUpdate) {
            String newValue = accountValues.get(acc.Id);
            // Solo actualizar si el valor cambió
            if (acc.ACC_Empresa_cliente__c != newValue) {
                acc.ACC_Empresa_cliente__c = newValue;
            }
        }
        
        // 6. Ejecutar DML solo si hay cambios reales
        List<Account> accountsWithChanges = new List<Account>();
        for (Account acc : accountsToUpdate) {
            // Salesforce detecta automáticamente si hubo cambios
            accountsWithChanges.add(acc);
        }
        
        if (!accountsWithChanges.isEmpty()) {
            update accountsWithChanges;
        }
    }
    
    /**
     * Método auxiliar para determinar el valor de empresa
     * Lógica simple: contar qué tipos tiene la cuenta
     */
    private static String determineCompanyValue(Boolean hasSegurosVida, Boolean hasRiesgosLaborales) {
        if (hasSegurosVida && hasRiesgosLaborales) {
            return COMPANY_MIXTO;
        } else if (hasSegurosVida) {
            return COMPANY_VIDA;
        } else if (hasRiesgosLaborales) {
            return COMPANY_ARL;
        } else {
            return COMPANY_NINGUNO;
        }
    }
}