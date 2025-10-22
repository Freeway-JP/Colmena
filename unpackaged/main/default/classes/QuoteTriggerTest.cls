@isTest
public class QuoteTriggerTest {

	@isTest
    static void testQuoteUpdateFromProductAndCoverageSpec() {
        RecordType rtQuote = [SELECT Id FROM RecordType WHERE SObjectType = 'Quote' AND DeveloperName = 'Quoting'];
        RecordType rtProduct = [SELECT Id FROM RecordType WHERE SObjectType = 'Product2' AND DeveloperName = 'Product'];
        RecordType rtCoverage = [SELECT Id FROM RecordType WHERE SObjectType = 'Product2' AND DeveloperName = 'CoverageSpec'];

       RecordType recordTypeOpp = [SELECT Id FROM RecordType WHERE SObjectType = 'Opportunity' and DeveloperName = 'Quoting'];
        
        Opportunity testOpportunity = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Diseño de Oferta',
            CloseDate = Date.valueOf('2024-10-04'),
            RecordTypeId = recordTypeOpp.Id
        );
        insert testOpportunity;

        Id standardPricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(
            Id = standardPricebookId,
            IsActive = true
        );
        
        update standardPricebook;

        Product2 prod = new Product2(
            Name = 'Test Product',
            Family = 'Test',
            IsActive = true,
            CS_Entidad_Producto__c = '2',
            RecordTypeId = rtProduct.Id
        );
        
        
        Product2 prod2 = new Product2(
            Name = 'Test Product',
            Family = 'Test',
            IsActive = true,
            CS_Entidad_Producto__c = '2',
            RecordTypeId = rtCoverage.Id
        );
        insert new List<Product2>{prod, prod2};

        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = standardPricebook.Id,
            Product2Id = prod.Id,
            UnitPrice = 1000,
            IsActive = true
        );
        insert pbe;

        Quote quote = new Quote(
            Name = 'Test Quote',
            Status = 'Draft',
            OpportunityId = testOpportunity.Id,
            RecordTypeId = rtQuote.Id,
            Pricebook2Id = standardPricebook.Id
        );
        insert quote;

        QuoteLineItem productQLI = new QuoteLineItem(
            QuoteId = quote.Id,
            Product2Id = prod.Id,
            Quantity = 1,
            UnitPrice = 1000,
            PricebookEntryId = pbe.Id,
            vlocity_ins__AttributeSelectedValues__c = JSON.serialize(new Map<String, Object>{
                'NumberInsureds' => 5,
                'InsuredGroupPremium' => 1500
            })
        );
        insert productQLI;

        QuoteLineItem coverageQLI1 = new QuoteLineItem(
            QuoteId = quote.Id,
            Product2Id = prod2.Id,
            Quantity = 1,
            UnitPrice = 1000,
            PricebookEntryId = pbe.Id,
            vlocity_ins__AttributeSelectedValues__c = JSON.serialize(new Map<String, Object>{
                'InsuredValue' => 8000000
            })
        );

        QuoteLineItem coverageQLI0 = new QuoteLineItem(
            QuoteId = quote.Id,
            Product2Id = prod2.Id,
            Quantity = 1,
            UnitPrice = 1000,
            PricebookEntryId = pbe.Id,
            vlocity_ins__AttributeSelectedValues__c = JSON.serialize(new Map<String, Object>{
                'InsuredValue' => 9000000
            })
        );

        insert new List<QuoteLineItem>{coverageQLI1, coverageQLI0};

        update quote;

        quote = [SELECT NumberOfInsured__c, TotalPremiumValue__c, TotalInsuredValue__c FROM Quote WHERE Id = :quote.Id];
        System.assertEquals(5, quote.NumberOfInsured__c, 'Debe tener 5 asegurados');
    }

}