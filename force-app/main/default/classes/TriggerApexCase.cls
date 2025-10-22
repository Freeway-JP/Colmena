public class TriggerApexCase {

    @InvocableMethod (label='Create or Update in Senda Case'
                      description='Create or Update Cases of salesforce in SENDA'
    )
    public static void createOrUpdateCaseSenda(List<String> idString){
        //sendCaseSenda.createOrUpdateCaseSenda(idString[0]);
        System.enqueueJob(new sendCaseSendaQueueable(idString[0]));
	}
    
}