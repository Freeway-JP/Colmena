/********************************************************************
Apex Class Name	:	CS_QueueSyncAuthorizationClaimItems
Version			:	1.0
Created Date	:	17/07/2025
Function 		: 	<>
Test Class		:	CS_QueueSyncAuthorizationClaimItemsTest

Modification Log
*--------------------------------------------------------------------
* Developer		     	Date			   	Description
* -------------------------------------------------------------------
* Frank Tovar    	 17/07/2025			Original Version
*********************************************************************/
public with sharing class CS_QueueSyncAuthorizationClaimItems implements Queueable, Database.AllowsCallouts {
    
    private Id claimItemIds;
    private static final String RECORDTYPE_DEVNAME_AUTH = 'Authorization';
    private static final String RECORDTYPE_DEVNAME_AUTH_SERVICE = 'AuthorizationService';
    private static final String OMNI_IP_NAME = 'Request_CreateAuthorizationAT';

    /**
     * Constructor que recibe los IDs de ClaimItems a procesar.
     * 
     * @param claimItemIds Lista de Ids de ClaimItem con fallas de creación.
     */
    public CS_QueueSyncAuthorizationClaimItems(Id claimItemIds) {
        this.claimItemIds = claimItemIds;
    }

    /**
     * Método principal que ejecuta la lógica cuando se lanza la cola.
     */
    public void execute(QueueableContext context) {
        try {
            List<ClaimItem> claimItemsToProcess = [
                SELECT Id, 
                    Claim.CS_numeroLinea__c, 
                    IsCommercial__c, 
                    ObservationsClaimAuthorization__c, 
                    ProviderPerformer__r.IdServiceProvider__c, 
                    ProviderRequester__r.IdServiceProvider__c 
                FROM ClaimItem
                WHERE Id = :claimItemIds
                AND RecordType.DeveloperName = :RECORDTYPE_DEVNAME_AUTH
            ];
            for (ClaimItem ci : claimItemsToProcess) {
                syncAuthorization(ci);
            }
        } catch (Exception ex) {
            System.debug('*** Error en Queueable: ' + ex.getMessage());
        }
    }

    /**
     * Procesa un único ClaimItem y ejecuta la Integration Procedure.
     * 
     * @param ci ClaimItem a procesar
     */
    private void syncAuthorization(ClaimItem ci) {
        try {
            Map<String, Object> requestBody = buildRequestBody(ci);
            List<Map<String, Object>> servicesList = buildServices(ci.Id);
            requestBody.put('services', servicesList);
            Map<String, Object> ipInput = new Map<String, Object>{
                'ClaimItemId' => ci.Id,
                'requestBody' => JSON.serialize(requestBody)
            };
            Map<String, Object> ipOptions = new Map<String, Object>();
            Map<String, Object> ipOutput = (Map<String, Object>) omnistudio.IntegrationProcedureService.runIntegrationService(
                OMNI_IP_NAME,
                ipInput,
                ipOptions
            );
            System.debug('ipOutput => ' + ipOutput);
        } catch (Exception ex) {
            System.debug('*** Error sincronizando ClaimItem <Authorization> ' + ci.Id + ': ' + ex.getMessage());
            System.debug('*** StackTrace *** ' + ex.getStackTraceString());
        }
    }

    /**
     * Construye el cuerpo del request (sin servicios) para enviar a la Integration Procedure.
     * 
     * @param ci ClaimItem base
     * @return Mapa con los campos requeridos por la IP
     */
    private Map<String, Object> buildRequestBody(ClaimItem ci) {
        return new Map<String, Object>{
            'numberAt' => String.valueOf(ci.Claim.CS_numeroLinea__c),
            'requestingProviderCode' => String.valueOf(ci.ProviderRequester__r.IdServiceProvider__c),
            'performingProviderCode' => String.valueOf(ci.ProviderPerformer__r.IdServiceProvider__c),
            'networkUser' => System.Label.NetworkUserSyncAuthorizations,
            'isComercial' => ci.IsCommercial__c,
            'observation' => ci.ObservationsClaimAuthorization__c,
            'isItContingency' => true 
        };
    }

    /**
     * Construye la lista de servicios asociados a un ClaimItem principal.
     * 
     * @param parentClaimItemId Id del ClaimItem padre
     * @return Lista de mapas con los datos de cada servicio
     */
    private List<Map<String, Object>> buildServices(Id parentClaimItemId) {
        List<ClaimItem> services = [
            SELECT Amount__c, 
                   AuthorizationServices__r.ServiceCode__c, 
                   AuthorizationServices__r.ServiceType__c, 
                   AuthorizationServices__r.UnitPrice__c, 
                   AuthorizationServices__r.Description__c
            FROM ClaimItem
            WHERE ParentId__c = :parentClaimItemId
            AND RecordType.DeveloperName = :RECORDTYPE_DEVNAME_AUTH_SERVICE
        ];

        List<Map<String, Object>> serviceList = new List<Map<String, Object>>();

        for (ClaimItem s : services) {
            Map<String, Object> serviceMap = new Map<String, Object>{
                'serviceCode' => String.valueOf(s.AuthorizationServices__r.ServiceCode__c),
                'serviceType' => String.valueOf(s.AuthorizationServices__r.ServiceType__c),
                'quantity' => s.Amount__c != null ? Integer.valueOf(s.Amount__c.intValue()) : 0,
                'unitPrice' => s.AuthorizationServices__r.UnitPrice__c != null 
                                ? Integer.valueOf(s.AuthorizationServices__r.UnitPrice__c.intValue()) 
                                : 0,
                'description' => s.AuthorizationServices__r.Description__c
            };
            serviceList.add(serviceMap);
        }

        return serviceList;
    }

}