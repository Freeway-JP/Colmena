trigger NewOrDeletedFileEventTrigger on New_Or_Deleted_File_Event__e (after insert) {
	new NewOrDeletedFileEventTriggerHandler().run();
}