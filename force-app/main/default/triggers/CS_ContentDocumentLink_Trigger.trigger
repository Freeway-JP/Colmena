/**
 * @description       :
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             :
 * @last modified on  : 07-29-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 **/
trigger CS_ContentDocumentLink_Trigger on ContentDocumentLink(before insert, before update) {
	if (Trigger.isBefore) {
		if (Trigger.isInsert) {
			//* BEFORE INSERT
			CS_ContentDocumentLinkTrigger_Handler.beforeInsert(Trigger.new);
		}
	}
}