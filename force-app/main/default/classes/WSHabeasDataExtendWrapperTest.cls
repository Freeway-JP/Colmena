@IsTest(seeAllData=false)
private class WSHabeasDataExtendWrapperTest {
    private static WSHabeasDataExtendWrapper.HabeasDataDto makeDto(Boolean withCompanies, Boolean with2300) {
        WSHabeasDataExtendWrapper.HabeasDataDto d = new WSHabeasDataExtendWrapper.HabeasDataDto();
        d.firstName = 'Ana';
        d.secondName = 'Mar';
        d.lastName = 'Lopez';
        d.secondLastName = 'Vega';
        d.identityType = 'CC';
        d.identityNumber = '123456';
        d.email = 'ana@example.com';
        d.numberPhone = '3000000000';
        d.sex = 'F';
        d.subjectId = 'SUBJ-1';
        d.dataUsePurpose = 'Prospecto';
        d.authorizationChannel = 'APP_WEB';
        d.channelType = 'Digital';
        d.process = 'Onboarding';
        d.businessCoverage = 'BrandA;BrandB';
        d.origin = 'Direct';
        d.collectionMethodType = 'SELF';
        d.contactFirstName = 'Laura';
        d.contactLastName = 'Gomez';
        d.contactIdType = 'CC';
        d.contactIdNumber = '998877';
        d.identityValidationNoData = false;
        d.identityValidationStatus = 'OK';
        d.identityValidationResult = 'pass';
        d.identityValidationSource = 'MANUAL';
        d.identityValidationType = 'BASICA';
        d.idClient = '001xx0000000001';
        d.idIndividual = '0PKxx0000000001';
        if (withCompanies) {
            d.companies = new List<WSHabeasDataExtendWrapper.CompanyDTO>();
            WSHabeasDataExtendWrapper.CompanyDTO c1 = new WSHabeasDataExtendWrapper.CompanyDTO();
            c1.name = 'BrandA';
            c1.medicalHistory = true;
            c1.dataMarketing = false;
            c1.generalCommercialOffer = true;
            c1.generalProcessingData = true;
            c1.notEssentialFunctionalities = new List<String>{ 'A', 'B' };
            if (with2300) {
                c1.authorization2300 = new List<WSHabeasDataExtendWrapper.Auth2300>();
                WSHabeasDataExtendWrapper.Auth2300 a1 = new WSHabeasDataExtendWrapper.Auth2300();
                a1.value = true;
                a1.contactPointType = 'EMAIL';
                a1.contactPoint = 'brand@ex.com';
                a1.dataUsePurpose = 'Prospecto';
                c1.authorization2300.add(a1);
            }
            WSHabeasDataExtendWrapper.CompanyDTO c2 = new WSHabeasDataExtendWrapper.CompanyDTO();
            c2.name = 'BrandB';
            c2.medicalHistory = false;
            c2.dataMarketing = true;
            c2.generalCommercialOffer = false;
            c2.generalProcessingData = true;
            d.companies.add(c1);
            d.companies.add(c2);
        }
        return d;
    }

    @IsTest
    static void test_Constructors_And_Properties() {
        WSHabeasDataExtendWrapper root = new WSHabeasDataExtendWrapper();
        System.assertNotEquals(null, root);
        WSHabeasDataExtendWrapper.HabeasDataDto d = makeDto(true, true);
        System.assertEquals('Ana', d.firstName);
        System.assertEquals('Vega', d.secondLastName);
        System.assertEquals('CC', d.identityType);
        System.assertEquals('123456', d.identityNumber);
        System.assertEquals('ana@example.com', d.email);
        System.assertEquals('3000000000', d.numberPhone);
        System.assertEquals('F', d.sex);
        System.assertEquals('SUBJ-1', d.subjectId);
        System.assertEquals('Prospecto', d.dataUsePurpose);
        System.assertEquals('APP_WEB', d.authorizationChannel);
        System.assertEquals('Digital', d.channelType);
        System.assertEquals('Onboarding', d.process);
        System.assertEquals('BrandA;BrandB', d.businessCoverage);
        System.assertEquals('Direct', d.origin);
        System.assertEquals('SELF', d.collectionMethodType);
        System.assertEquals('Laura', d.contactFirstName);
        System.assertEquals('Gomez', d.contactLastName);
        System.assertEquals('CC', d.contactIdType);
        System.assertEquals('998877', d.contactIdNumber);
        System.assertEquals(false, d.identityValidationNoData);
        System.assertEquals('OK', d.identityValidationStatus);
        System.assertEquals('pass', d.identityValidationResult);
        System.assertEquals('MANUAL', d.identityValidationSource);
        System.assertEquals('BASICA', d.identityValidationType);
        System.assertEquals('001xx0000000001', d.idClient);
        System.assertEquals('0PKxx0000000001', d.idIndividual);
        System.assertEquals(2, d.companies.size());
        System.assertEquals('BrandA', d.companies[0].name);
        System.assertEquals(true, d.companies[0].medicalHistory);
        System.assertEquals(false, d.companies[0].dataMarketing);
        System.assertEquals(true, d.companies[0].generalCommercialOffer);
        System.assertEquals(true, d.companies[0].generalProcessingData);
        System.assertEquals(2, d.companies[0].notEssentialFunctionalities.size());
        System.assertEquals('A', d.companies[0].notEssentialFunctionalities[0]);
        System.assertEquals(1, d.companies[0].authorization2300.size());
        System.assertEquals(true, d.companies[0].authorization2300[0].value);
        System.assertEquals('EMAIL', d.companies[0].authorization2300[0].contactPointType);
        System.assertEquals('brand@ex.com', d.companies[0].authorization2300[0].contactPoint);
        System.assertEquals('Prospecto', d.companies[0].authorization2300[0].dataUsePurpose);
    }

    @IsTest
    static void test_JSON_RoundTrip_Full() {
        WSHabeasDataExtendWrapper.HabeasDataDto d = makeDto(true, true);
        String json = JSON.serialize(d);
        WSHabeasDataExtendWrapper.HabeasDataDto e = (WSHabeasDataExtendWrapper.HabeasDataDto) System.JSON.deserialize(
            json,
            WSHabeasDataExtendWrapper.HabeasDataDto.class
        );
        System.assertNotEquals(null, e);
        System.assertEquals('Ana', e.firstName);
        System.assertEquals('Prospecto', e.dataUsePurpose);
        System.assertEquals(2, e.companies.size());
        System.assertEquals(true, e.companies[0].authorization2300[0].value);
    }

    @IsTest
    static void test_JSON_RoundTrip_Minimal() {
        WSHabeasDataExtendWrapper.HabeasDataDto d = makeDto(false, false);
        d.firstName = null;
        d.secondName = null;
        d.lastName = null;
        d.secondLastName = null;
        d.identityType = null;
        d.identityNumber = null;
        d.email = null;
        d.numberPhone = null;
        d.sex = null;
        d.subjectId = null;
        d.dataUsePurpose = null;
        d.authorizationChannel = null;
        d.channelType = null;
        d.process = null;
        d.businessCoverage = null;
        d.origin = null;
        d.collectionMethodType = null;
        d.contactFirstName = null;
        d.contactLastName = null;
        d.contactIdType = null;
        d.contactIdNumber = null;
        d.identityValidationNoData = true;
        d.identityValidationStatus = null;
        d.identityValidationResult = null;
        d.identityValidationSource = null;
        d.identityValidationType = null;
        d.companies = null;
        d.idClient = null;
        d.idIndividual = null;
        String json = JSON.serialize(d);
        WSHabeasDataExtendWrapper.HabeasDataDto e = (WSHabeasDataExtendWrapper.HabeasDataDto) System.JSON.deserialize(
            json,
            WSHabeasDataExtendWrapper.HabeasDataDto.class
        );
        System.assertEquals(true, e.identityValidationNoData);
        System.assertEquals(null, e.companies);
        System.assertEquals(null, e.firstName);
        System.assertEquals(null, e.authorizationChannel);
    }

    @IsTest
    static void test_MassiveDto() {
        WSHabeasDataExtendWrapper.HabeasDataDto d1 = makeDto(true, false);
        WSHabeasDataExtendWrapper.HabeasDataDto d2 = makeDto(false, false);
        WSHabeasDataExtendWrapper.HabeasDataMassiveDto m = new WSHabeasDataExtendWrapper.HabeasDataMassiveDto();
        m.massiveAuth = new List<WSHabeasDataExtendWrapper.HabeasDataDto>{ d1, d2 };
        m.massiveAuthType = 'BATCH_TEST';
        System.assertEquals(2, m.massiveAuth.size());
        System.assertEquals('BATCH_TEST', m.massiveAuthType);
    }

    @IsTest
    static void test_MassiveResponseDto_Constructors() {
        WSHabeasDataExtendWrapper.HabeasDataMassiveResponseDto dflt = new WSHabeasDataExtendWrapper.HabeasDataMassiveResponseDto();
        System.assertEquals(null, dflt.jobId);
        dflt.jobId = null;
        dflt.responseCode = 202;
        dflt.message = 'accepted';
        System.assertEquals(202, dflt.responseCode);
        WSHabeasDataExtendWrapper.HabeasDataMassiveResponseDto prm = new WSHabeasDataExtendWrapper.HabeasDataMassiveResponseDto(null, 201, 'queued');
        System.assertEquals(null, prm.jobId);
        System.assertEquals(201, prm.responseCode);
        System.assertEquals('queued', prm.message);
    }
}