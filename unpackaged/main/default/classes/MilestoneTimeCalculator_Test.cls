@isTest(SeeAllData=true)
private class MilestoneTimeCalculator_Test {
    static testMethod void testMilestoneTimeCalculator() {
       Schema.Location location = new Schema.Location(Name = 'casa' , LocationType = 'Sitio');
        insert location;
        
        Schema.Location locationQuery = [Select Id, Name, LocationType
                     from Location where Name = 'casa' and LocationType = 'Sitio'][0];
        
        System.debug('Location: ' + locationQuery.Id);
        
        Account account = new Account(
        							CS_TipoIdentificacionCP__pc = '1',
            						CS_NumeroIdentificacionCP__pc = '1013667126',
        							FirstName = 'Maria',
            						Middlename = 'Camila',
        							LastName = 'Castro',
            						suffix = 'VILLADA',
        							CS_IndicadorTratamientoDatos__pc = 'SI',
        							ShippingCity = '1318c000000qRKFAA2',
        							ShippingStreet = 'ALDEA KR 56 63 A 79',
        							PersonEmail = 'aipena6@misena.edu.co',
        							PHONE = '3016949560',
        							et4ae5__Mobile_Country_Code__pc = 'CO',
        							PersonMobilePhone = '3016949560',
        							AccountSource = '2',
        							CC_Producto_de_interes__c = '1',
        							CC_Tipo_de_Cuenta__c = 'Cuenta Cliente',
        							CS_Origen_del_Registro__c = 'Visual Time',
        							CS_ClienteActivo__c = True);
        								
        insert account;
        
        Account accountQuery = [Select Id
                     from Account where CS_NumeroIdentificacionCP__pc = '1013667126' and CS_TipoIdentificacionCP__pc = '1'][0];
        
        System.debug('accountQuery: ' + accountQuery.Id);
        		//Account Empresa
		Account accountEnterprise = new Account(
        							//RecordTypeId= Schema.sObjectType.Account.getRecordTypeInfosByName().get('Empresa').getRecordTypeId(),
        							Name = 'CamilaC',
        							Phone = '3104801304',
        							CC_Ciudad__c = location.Id);
		
        insert accountEnterprise;
        
        Account accountEnterpriseQuery = [Select Id
                     from Account where Phone = '3104801304' and Name = 'CamilaC'][0];
       
        System.debug('accountEnterpriseQuery: ' + accountEnterpriseQuery.Id);
        
        Contact contact = new Contact(
            							Salutation = 'Mrs.',
                                            FirstName = 'Camila',
                                            LastName = 'Castillo',
                                            AccountId = accountEnterpriseQuery.id,
                                            Email = 'das@asa.co',
                                            CS_Sexo__c = '1');
        
        insert contact;
        
        Contact contactQuery = [Select Id
                     from Contact where FirstName = 'Camila' and LastName = 'Castillo' and Email = 'das@asa.co'][0];
        
        System.debug('contactQuery: ' + contactQuery.Id);
        
        InsurancePolicy poliza = new InsurancePolicy(
            										Name = 'AP-2000022',
            										UniversalPolicyNumber = 'AP-2000022',
            										PolicyName = 'Poliza',
           											PolicyType='Contrato ARL',
            										NameInsuredId = accountQuery.Id,
            										ProductId='01t8c00000Q6EUVAA3',
            										RecordTypeId=Schema.sObjectType.InsurancePolicy.getRecordTypeInfosByName().get('Contrato ARL').getRecordTypeId());
        insert poliza;
        
        InsurancePolicy polizaQuery = [select Id,ProductId from InsurancePolicy where UniversalPolicyNumber = 'AP-2000022' and PolicyName = 'Poliza'];
        system.debug('ProductId: ' + polizaQuery.ProductId + 'Poliza: '+ polizaQuery.Id);
       
        Claim claim = new Claim(
            					Name = '13213122',
            					AccountId = accountQuery.Id,
            					PolicyNumberId = polizaQuery.Id
        						);
       	insert claim;
        
        Claim  claimQuery = [select Id, RecordType.Name from Claim where Name = '13213122'];
        
        system.debug('claimId' + claimQuery.Id);
        
        //////////////////////////////Fin Indemnizacion ////////////////////////////////////77
    
	    //Case    
        Case caseValidation = new Case(
            							AccountId = accountQuery.id,
            							ContactId = contactQuery.id,
            							CS_Pais__c = '170',
            							CS_Departamento__c = '11',
            							CS_Municipio__c = '11001',
            							CS_MacroMotivo__c = 'Asegurados',
            							CS_Submotivo__c = 'Actualización de datos',
            							Status = 'Escalado',
            							CS_FechaTentativaDeCierre__c = date.parse('06/6/2025'),
            							RecordTypeId = Schema.sObjectType.Case.getRecordTypeInfosByName().get('Novedad').getRecordTypeId(),
            							CS_Semaforotexto__c = '', 
        								Description = 'the body of email',
        								Subject = 'the Email Subject',
        								SuppliedEmail = 'foo@bar.com',
        								Origin = 'Internet',
        								CS_Subtipo__c = '2',
        								CS_ProductoM2__c = '123',
           							    ProductId = polizaQuery.ProductId);
         
           // When inserts the Case
        INSERT caseValidation;
        system.debug('caso id' + caseValidation);

            Case caso = [Select Id, CaseNumber, RecordType.Name, Description, CS_MacroMotivo__c, 
                    	CS_Submotivo__c, Status, CS_FechaTentativaDeCierre__c, CS_Semaforotexto__c, CS_Numero_de_ATEL__c From Case 
                     where CS_ProductoM2__c = '123' and Subject = 'the Email Subject' and Status = 'Escalado' and CS_Submotivo__c = 'Actualización de datos'];
        
        system.debug('caso id' + caso.Id);
        
        MilestoneType[] mtLst = [SELECT Id, Name FROM MilestoneType LIMIT 1];      
        if(mtLst.size() == 0) { return; }
        MilestoneType mt = mtLst[0];

        Test.startTest();
        MilestoneTimeCalculator calc = new MilestoneTimeCalculator();
        Integer result = calc.calculateMilestoneTriggerTime(caseValidation.Id, mt.Id);
        Test.stopTest();

        System.debug('Resultado del cálculo: ' + result);
        System.assert(result > 0, 'El tiempo calculado debe ser mayor que cero');
    }
}