@IsTest(SeeAllData = false)
private class TaskWrapperTest {

    // Test method to verify the behavior of the constructor
    @isTest
    static void testTaskWrapperTest() {
        
        /////////////////////////// Creando Case Inicio
        
        //location
        Schema.Location location = new Schema.Location(Name = 'casa' , LocationType = 'Sitio');
        insert location;
        
        Schema.Location locationQuery = [Select Id, Name, LocationType
                     from Location where Name = 'casa' and LocationType = 'Sitio'][0];
        
        System.debug('Location: ' + locationQuery.Id);
               
        Account account = new Account(
        							CS_TipoIdentificacionCP__pc = '1',
            						CS_NumeroIdentificacionCP__pc = '10224285377',
        							//Salutation = 'Mr.',
        							FirstName = 'JuanD',
            						Middlename = 'MARIA',
        							LastName = 'LastName',
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
                     from Account where CS_NumeroIdentificacionCP__pc = '10224285377' and CS_TipoIdentificacionCP__pc = '1'][0];
        
        System.debug('accountQuery: ' + accountQuery.Id);
        		//Account Empresa
		Account accountEnterprise = new Account(
        							
        							Name = 'JuanD',
        							Phone = '1234133',
        							CC_Ciudad__c = location.Id);
		
        insert accountEnterprise;
        
        Account accountEnterpriseQuery = [Select Id
                     from Account where Phone = '1234133' and Name = 'JuanD'][0];
       
        System.debug('accountEnterpriseQuery: ' + accountEnterpriseQuery.Id);
        
        //Contact
        //
        
        Contact contact = new Contact(
            							Salutation = 'Mr.',
                                            FirstName = 'Juan',
                                            LastName = 'Holguin',
                                            AccountId = accountEnterpriseQuery.id,
                                            Email = 'das@asa.co',
                                            CS_Sexo__c = '2');
        
        insert contact;
        
        Contact contactQuery = [Select Id
                     from Contact where FirstName = 'Juan' and LastName = 'Holguin' and Email = 'das@asa.co'][0];
        
        System.debug('contactQuery: ' + contactQuery.Id);

           ///////////////////////////// Inicio Indemnizacion /////////////////////////////////7
        
         InsurancePolicy poliza = new InsurancePolicy(
            										Name = '12312',
            										UniversalPolicyNumber = '12312',
            										PolicyName = 'Poliza',
            										NameInsuredId = accountQuery.Id
        												);

        insert poliza;
        
        InsurancePolicy polizaQuery = [select Id,ProductId from InsurancePolicy where UniversalPolicyNumber = '12312' and PolicyName = 'Poliza'];
        
        Claim claim = new Claim(
            					Name = '13213122',
            					AccountId = accountQuery.Id,
            					PolicyNumberId = polizaQuery.Id,
            					RecordTypeId = Schema.sObjectType.Claim.getRecordTypeInfosByName().get('AT').getRecordTypeId()
        						);
       	insert claim;
        
        Claim  claimQuery = [select Id, Name, RecordType.Name from Claim where Name = '13213122'];
        
        system.debug('claimId' + claimQuery.Id);
        
        //////////////////////////////Fin Indemnizacion ////////////////////////////////////

	    //Case    
        Case caseValidation = new Case(
            							AccountId = accountQuery.id,
            							ContactId = contactQuery.id,
            							CS_Pais__c = '170',
            							CS_Departamento__c = '11',
            							CS_Municipio__c = '11001',
            							RecordTypeId = Schema.sObjectType.Case.getRecordTypeInfosByName().get('Incidente').getRecordTypeId(),
            							Status = 'Escalado',
            							CS_Semaforotexto__c = '', 
        								Description = 'the body of email',
        								Subject = 'the Email Subject123',
        								SuppliedEmail = 'foo@bar.com',
        								Origin = 'Internet',
            							CS_Numero_de_ATEL__c=claimQuery.Id,
            							ProductId = polizaQuery.ProductId);
        								
        // When inserts the Case
        INSERT caseValidation;
        
        
        
   
         Case caso = [Select Id, CaseNumber, RecordType.Name, Description, CS_MacroMotivo__c, 
                    	CS_Submotivo__c, Status, CS_FechaTentativaDeCierre__c, CS_Semaforotexto__c, CS_Numero_de_ATEL__c,CS_Fecha_de_radicacion_en_la_Compania__c From Case 
                     where Subject = 'the Email Subject123'][0];
        
        
        ///////////////////////// Creando Case Fin
        //
    	
       // Sample data
       string subject = 'Llamada Prueba';
       string status = 'Abierto';
       string description = 'Lorem Ipsum es simplemente';
       Task testTask = new Task(
           WhatId = caso.Id,
           subject = subject,         
           Description = description, 
           OwnerId = '0058c000009ZKtjAAG',
           Status = status, 
           ActivityDate = Date.today().addDays(7),
           //RecordTypeId = '0128c000001z636AAA'
           RecordTypeId = Schema.sObjectType.Task.getRecordTypeInfosByName().get('Tareas').getRecordTypeId()
       );
       insert testTask;
       Task tarea = [Select Id, WhatId, subject,
                      Description, ActivityDate, OwnerId, Owner.Name, Status, CreatedDate, RecordType.name
                     From Task where subject = :subject][0];
        
        //call Method
       TaskWrapper taskWrapper = new TaskWrapper(tarea);

        // Test
        System.assertEquals(description, tarea.Description, 'Las descripciones coinciden');
        System.assertEquals(subject, tarea.subject);
        
		system.debug('Fin');
        
       
    }
}