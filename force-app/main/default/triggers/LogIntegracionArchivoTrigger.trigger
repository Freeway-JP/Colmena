trigger LogIntegracionArchivoTrigger on Log_integracion_archivo__c (after insert, after update) {
	new LogIntegracionArchivoTriggerHandler().run();
}