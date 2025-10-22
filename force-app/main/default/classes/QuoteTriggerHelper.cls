public class QuoteTriggerHelper {
    
    public void updateQuoteFields(List<Quote> quotes) {
        
        if (TriggerControl.quoteRunning) return;
        TriggerControl.quoteRunning = true;
        
        try {
            Set<Id> quoteIds = new Set<Id>();
            for (Quote q : quotes) {
                if (q.vlocity_ins__RecordTypeName__c == 'Quoting' && !q.IsSyncing) {
                    quoteIds.add(q.Id);
                }
            }
            
            if (quoteIds.isEmpty()) return;
            
            List<QuoteLineItem> qlis = [
                SELECT QuoteId, vlocity_ins__RecordTypeName__c, vlocity_ins__ProductChildItemSequence__c, vlocity_ins__AttributeSelectedValues__c
                FROM QuoteLineItem
                WHERE QuoteId IN :quoteIds
                AND (vlocity_ins__RecordTypeName__c = 'Product' OR vlocity_ins__RecordTypeName__c = 'CoverageSpec')
            ];
            
            Map<Id, QuoteLineItem> productItems = new Map<Id, QuoteLineItem>();
            Map<Id, QuoteLineItem> coverageItems = new Map<Id, QuoteLineItem>();
            
            for (QuoteLineItem item : qlis) {
                if (item.vlocity_ins__RecordTypeName__c == 'Product') {
                    productItems.put(item.QuoteId, item);
                } else if (item.vlocity_ins__RecordTypeName__c == 'CoverageSpec') {
                    if (!coverageItems.containsKey(item.QuoteId) ||
                        item.vlocity_ins__ProductChildItemSequence__c < coverageItems.get(item.QuoteId).vlocity_ins__ProductChildItemSequence__c) {
                            coverageItems.put(item.QuoteId, item);
                        }
                }
            }
            
            List<Quote> quotesToUpdate = new List<Quote>();
            for (Quote q : quotes) {
                if (!productItems.containsKey(q.Id)) continue;
                
                QuoteLineItem productItem = productItems.get(q.Id);
                QuoteLineItem coverageItem = coverageItems.get(q.Id);
                
                Integer insureds = 0;
                Decimal premium = 0;
                Decimal insuredValue = 0;
                Decimal totalInsured = 0;
                
                String jsonProduct = productItem.vlocity_ins__AttributeSelectedValues__c;
                if (!String.isBlank(jsonProduct)) {
                    try {
                        Map<String, Object> parsed = (Map<String, Object>) System.JSON.deserializeUntyped(jsonProduct);
                        if (parsed.containsKey('NumberInsureds')) {
                            insureds = Integer.valueOf(String.valueOf(parsed.get('NumberInsureds')));
                        }
                        if (parsed.containsKey('InsuredGroupPremium')) {
                            premium = Decimal.valueOf(String.valueOf(parsed.get('InsuredGroupPremium')));
                        }
                    } catch (Exception e) {
                        System.debug('Error parsing Product JSON: ' + e.getMessage());
                    }
                }
                
                if (coverageItem != null && !String.isBlank(coverageItem.vlocity_ins__AttributeSelectedValues__c)) {
                    try {
                        Map<String, Object> coverageParsed = (Map<String, Object>) System.JSON.deserializeUntyped(coverageItem.vlocity_ins__AttributeSelectedValues__c);
                        if (coverageParsed.containsKey('InsuredValue')) {
                            insuredValue = Decimal.valueOf(String.valueOf(coverageParsed.get('InsuredValue')));
                        }
                    } catch (Exception e) {
                        System.debug('Error parsing Coverage JSON: ' + e.getMessage());
                    }
                }
                
                totalInsured = insureds * insuredValue;
                
                if (q.NumberOfInsured__c != insureds ||
                    q.TotalPremiumValue__c != premium ||
                    q.TotalInsuredValue__c != totalInsured) {
                        
                        Quote quoteToUpdate = new Quote(
                            Id = q.Id,
                            NumberOfInsured__c = insureds,
                            TotalPremiumValue__c = premium,
                            TotalInsuredValue__c = totalInsured
                        );
                        quotesToUpdate.add(quoteToUpdate);
                    }
            }
            
            if (!quotesToUpdate.isEmpty()) {
                update quotesToUpdate;
            }
        } finally {
            TriggerControl.quoteRunning = false;
        }
    }
    
}