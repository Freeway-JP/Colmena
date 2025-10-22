/**
* =======================================================================================================================================================================================
* Developer:             VASS COMPANY
* Creation Date:         08/04/2024
* Created by:            edwinc.martinez@oc.vasscompany.com
* Description:           Creation of the controller class for the visualforce page Generate PDF where the necessary fields of the OpportunityLineItem are brought to show in the PDF.
* Last Modified by:      edwinc.martinez@oc.vasscompany.com (08/04/2024)
* Changes (Versions)

* -------------------------------------
* No.     Date        Author                  Description
* ------  ----------  ---------------------   ---------------
* 1.1     08/04/2024  Edwin Camilo Martinez   Initial version where the variables and constructor that contains the query to bring the fields are declared.
* =======================================================================================================================================================================================
*/
public class GenerarPDFQuoteController {
    public Opportunity opportunity { get; set; }
    public Quote quote { get; set; }
    public QuoteLineItem  quoteLineItem{ get; set; }
    
    public GenerarPDFQuoteController(ApexPages.StandardController controller) {
        String opportunityId = ApexPages.currentPage().getParameters().get('id');
        System.debug('Oportunidad Id: ' + opportunityId);
        
        // Consulta para obtener campos de la oportunidad 
        opportunity = [SELECT Id, Name, Account.Name, AccountNameRL__c, TypeAgreement__c, ValidityProjection__c, CollectionMeans__c, Collectioncharge__c,
                       Comments__c, Intermediary1__c, NameIntermediary1__c, CommissionPercentageIntermediary1__c, Intermediary2__c,
                       NameIntermediary2__c, CommissionPercentageIntermediary2__c, SponsorReturn__c, ReturnPercentage__c,
                       CommercialIncentive__c, CommercialIncentivePercentage__c, Costo_Fijo_Asociado__c, FirstYear__c,
                       SecondYear__c, ThirdYear__c, FourthYear__c, FifthYear__c, TotalTargetPopulation__c, EstimatedpenetrationpercentageNew__c,
                       estimatedpenetrationCurrentPortfolio__c, Geographiccoverageofthetargetcustomer__c, EstimatedpenetrationunitsNew__c,
                       EstimatedPenetrationUnitsCurrentPortfoli__c, DistributionEconomicActivityEmployees__c,
                       IndependentEconomicActDistribution__c, DistributionGenderWomen__c, DistributionGenderMen__c,
                       Men18to30Years__c, Men31to40Years__c, Men41to50Years__c, Men51to60Years__c, Men61to70Years__c,
                       Men70Years__c, Women18to30Years__c, Women31to40Years__c, Women41to50Years__c, Women51to60Years__c,
                       Women61to70Years__c, Women70Years__c,YearsToConsiderRunoff__c
                       FROM Opportunity WHERE Id = :opportunityId LIMIT 1];
        
        // Consulta para obtener los campos de la oportunidad
        quote = [SELECT id,ProductModality__c,ProductAimedCustomers__c,PaymentFrequency__c,PremiumCalculation__c,MarketingChannel__c,MarketingManager__c,TentativeEffectiveDate__c,DescriptionInsuranceObject__c,
                 CoveragesProtectionsAssistance__c,SpecialConditions__c,InsuredValues__c,FeeType__c,AnnualorMonthlyInterestRate__c, AnnualCustomerCancellationRate__c,TotalBalance__c,TotalNumberofCredits0_12months__c,
                 TotalNumberofCredits13_18months__c,TotalNumberofCredits19_24months__c,TotalNumberofCredits25_30months__c,TotalNumberofCredits31_36months__c,TotalNumberofCredits37_42months__c,
                 TotalNumberofCredits43_48months__c,TotalNumberofCredits49_54months__c,TotalNumberofCredits55_60months__c,TotalNumberofCreditsmorethan60months__c,TotalBalance_60months__c, TotalBalance0_12months__c, TotalBalance13_18months__c,
                 TotalBalance19_24months__c, TotalBalance25_30months__c, TotalBalance31_36months__c, TotalBalance37_42months__c, TotalBalance43_48months__c, TotalBalance49_54months__c,
                 TotalBalance55_60months__c, Disabilitywaitingperiod__c, DisabilityWaitPeriod__c, DisabilityBenefitPayment__c, DefinitionoftheBenefitIncapQuotas__c, UnemploymentWaitingPeriod__c, UnemploymentWaitPeriod__c, DefinitionofBenefitDesemFees__c,
                 UnemploymentBenefitPayment__c, Description, CreditAmountMinimum__c, CreditAmountAverage__c, CreditAmountMaxima__c,
                 CreditServiceTermMinimum__c, CreditServiceTermAverage__c, CreditTermserviceMaxima__c, MonthlyFeeMinimum__c, MonthlyFeeAverage__c, MonthlyFeeMaximum__c,
                 MonthlyPaymentsforProtectionMinimum__c, ProtectionMonthlyPaymentsAverage__c, MonthlyPaymentsforProtectionMaxima__c,TargetRateCurrentBusinessRate__c,TotalCredits__c,
                 TransferOriginCompany__c, TotalNumberofCredits__c, CreditsNumber0_12Months__c, CreditsNumber13_18Months__c, CreditsNumber19_24Months__c, CreditsNumber25_30Months__c, CreditsNumber31_36Months__c,
                 CreditsNumber37_42Months__c, CreditsNumber43_48Months__c, CreditsNumber49_54Months__c, CreditsNumber55_60Months__c, CreditsNumber_60Months__c
                 FROM Quote WHERE OpportunityId = :opportunityId AND IsSyncing=True LIMIT 1];

        // Consulta para obtener el producto de oferta relacionado.
        quoteLineItem = [SELECT id,RequiredProduct__c,PolicyType__c FROM QuoteLineItem WHERE QuoteId= :quote.id LIMIT 1];


    }
    
    public String getFormattedFirstYear() {
        return formatDecimal(opportunity.FirstYear__c);
    }
    
    public String getFormattedSecondYear() {
        return formatDecimal(opportunity.SecondYear__c);
    }
    
    public String getFormattedThirdYear() {
        return formatDecimal(opportunity.ThirdYear__c);
    }
    
    public String getFormattedFourthYear() {
        return formatDecimal(opportunity.FourthYear__c);
    }
    
    public String getFormattedFifthYear() {
        return formatDecimal(opportunity.FifthYear__c);
    }
    
    public String getFormattedTotalBalance0a12months() {
        return formatDecimal(Quote.TotalBalance0_12months__c);
    }
    
    public String getFormattedTotalBalance13a18months() {
        return formatDecimal(Quote.TotalBalance13_18months__c);
    }
    
    public String getFormattedTotalBalance19a24months() {
        return formatDecimal(Quote.TotalBalance19_24months__c);
    }
    
    public String getFormattedTotalBalance25a30months() {
        return formatDecimal(Quote.TotalBalance25_30months__c);
    }
    
    public String getFormattedTotalBalance31a36months() {
        return formatDecimal(Quote.TotalBalance31_36months__c);
    }
    
    public String getFormattedTotalBalance37a42months() {
        return formatDecimal(Quote.TotalBalance37_42months__c);
    }
    
    public String getFormattedTotalBalance43a48months() {
        return formatDecimal(Quote.TotalBalance43_48months__c);
    }
    
    public String getFormattedTotalBalance49a54months() {
        return formatDecimal(Quote.TotalBalance49_54months__c);
    }
    
    public String getFormattedTotalBalance55a60months() {
        return formatDecimal(Quote.TotalBalance55_60months__c);
    }
    
    public String getFormattedTotalBalancemorethan60months() {
        return formatDecimal(Quote.TotalBalance_60months__c);
    }
    
    public String getFormattedTotalMonths() {
        return formatDecimal(Quote.TotalBalance__c);
    }
    
     public String getFormattedCreditAmountMinimum() {
        return formatDecimal(Quote.CreditAmountMinimum__c);
    }
    
    public String getFormattedCreditAmountAverage() {
        return formatDecimal(Quote.CreditAmountAverage__c);
    }
    
    public String getFormattedCreditAmountMaxima() {
        return formatDecimal(Quote.CreditAmountMaxima__c);
    }
    
    public String getFormattedCreditServiceTermMinimum() {
        return formatDecimal(Quote.CreditServiceTermMinimum__c);
    }
    
    public String getFormattedCreditServiceTermAverage() {
        return formatDecimal(Quote.CreditServiceTermAverage__c);
    }
    
    public String getFormattedCreditServiceTermMaxima() {
        return formatDecimal(Quote.CreditTermserviceMaxima__c);
    }
    
    public String getFormattedMonthlyFeeMinimum() {
        return formatDecimal(Quote.MonthlyFeeMinimum__c);
    }
    
    public String getFormattedMonthlyFeeAverage() {
        return formatDecimal(Quote.MonthlyFeeAverage__c);
    }
    
    public String getFormattedMonthlyFeeMaximum() {
        return formatDecimal(Quote.MonthlyFeeMaximum__c);
    }
    
    public String getFormattedMonthlyPaymentsforProtectionMinimum() {
        return formatDecimal(Quote.MonthlyPaymentsforProtectionMinimum__c);
    }
    
    public String getFormattedProtectionMonthlyPaymentsAverage() {
        return formatDecimal(Quote.ProtectionMonthlyPaymentsAverage__c);
    }
    
    public String getFormattedMonthlyPaymentsforProtectionMaxima() {
        return formatDecimal(Quote.MonthlyPaymentsforProtectionMaxima__c);
    }
    
    private String formatDecimal(Decimal value) {
        if (value == null) return '';
        return value.setScale(2, RoundingMode.HALF_UP).format();
    }
    
}