@IsTest(seeAllData=false)
private class WS_HabeasDataWrapperTest {
    private static WS_HabeasDataWrapper.RequestWSWrapper makeFullRequest(Boolean withCompanies, Boolean withNEF) {
        WS_HabeasDataWrapper.RequestWSWrapper r = new WS_HabeasDataWrapper.RequestWSWrapper();
        r.FirstName = 'Ana';
        r.SecondName = 'Mar';
        r.LastName = 'Lopez';
        r.SecondLastName = 'Vega';
        r.identityType = 'CC';
        r.identityNumber = '123456';
        r.email = 'ana@example.com';
        r.numberPhone = '3000000000';
        r.sex = 'F';
        r.AttentionChannel = 'APP_WEB';
        r.TypeObjectCreate = 'Prospecto';
        r.IdClient = '001xx0000000001';
        r.idIndividual = '0PKxx0000000001';
        r.idContactPoints = new List<String>{ '0PRxx0000000001', '0PRxx0000000002' };
        if (withCompanies) {
            r.companies = new List<WS_HabeasDataWrapper.CompaniesWrapper>();
            WS_HabeasDataWrapper.CompaniesWrapper c1 = new WS_HabeasDataWrapper.CompaniesWrapper();
            c1.name = 'BrandA';
            c1.essentialFunctionalities = true;
            c1.MedicalHistory = true;
            c1.notEssentialFunctionalities = withNEF ? new List<String>{ 'A', 'B' } : new List<String>();
            WS_HabeasDataWrapper.CompaniesWrapper c2 = new WS_HabeasDataWrapper.CompaniesWrapper();
            c2.name = 'BrandB';
            c2.essentialFunctionalities = false;
            c2.MedicalHistory = false;
            c2.notEssentialFunctionalities = withNEF ? new List<String>{ 'C' } : null;
            r.companies.add(c1);
            r.companies.add(c2);
        }
        r.ClientController = 'OK';
        r.HabeasDataController = 'OK';
        return r;
    }

    @IsTest
    static void test_Request_Construct_And_Properties() {
        WS_HabeasDataWrapper.RequestWSWrapper r = makeFullRequest(true, true);
        System.assertEquals('Ana', r.FirstName);
        System.assertEquals('Mar', r.SecondName);
        System.assertEquals('Lopez', r.LastName);
        System.assertEquals('Vega', r.SecondLastName);
        System.assertEquals('CC', r.identityType);
        System.assertEquals('123456', r.identityNumber);
        System.assertEquals('ana@example.com', r.email);
        System.assertEquals('3000000000', r.numberPhone);
        System.assertEquals('F', r.sex);
        System.assertEquals('APP_WEB', r.AttentionChannel);
        System.assertEquals('Prospecto', r.TypeObjectCreate);
        System.assertEquals('001xx0000000001', r.IdClient);
        System.assertEquals('0PKxx0000000001', r.idIndividual);
        System.assertEquals(2, r.idContactPoints.size());
        System.assertEquals(2, r.companies.size());
        System.assertEquals('BrandA', r.companies[0].name);
        System.assertEquals(true, r.companies[0].essentialFunctionalities);
        System.assertEquals(true, r.companies[0].MedicalHistory);
        System.assertEquals(2, r.companies[0].notEssentialFunctionalities.size());
        System.assertEquals(false, r.companies[1].essentialFunctionalities);
        System.assertEquals(false, r.companies[1].MedicalHistory);
        System.assertEquals(1, r.companies[1].notEssentialFunctionalities.size());
        System.assertEquals('OK', r.ClientController);
        System.assertEquals('OK', r.HabeasDataController);
    }

    @IsTest
    static void test_Request_JSON_RoundTrip_Full() {
        WS_HabeasDataWrapper.RequestWSWrapper r = makeFullRequest(true, true);
        String json = JSON.serialize(r);
        WS_HabeasDataWrapper.RequestWSWrapper s = (WS_HabeasDataWrapper.RequestWSWrapper) System.JSON.deserialize(
            json,
            WS_HabeasDataWrapper.RequestWSWrapper.class
        );
        System.assertNotEquals(null, s);
        System.assertEquals('Ana', s.FirstName);
        System.assertEquals('BrandA', s.companies[0].name);
        System.assertEquals(2, s.companies.size());
        System.assertEquals(2, s.idContactPoints.size());
    }

    @IsTest
    static void test_Request_JSON_RoundTrip_Minimal_And_Edges() {
        WS_HabeasDataWrapper.RequestWSWrapper r = makeFullRequest(false, false);
        r.FirstName = null;
        r.SecondName = null;
        r.LastName = null;
        r.SecondLastName = null;
        r.identityType = null;
        r.identityNumber = null;
        r.email = null;
        r.numberPhone = null;
        r.sex = null;
        r.AttentionChannel = null;
        r.TypeObjectCreate = null;
        r.IdClient = null;
        r.idIndividual = null;
        r.idContactPoints = null;
        r.companies = null;
        r.ClientController = null;
        r.HabeasDataController = null;
        String json = JSON.serialize(r);
        WS_HabeasDataWrapper.RequestWSWrapper s = (WS_HabeasDataWrapper.RequestWSWrapper) System.JSON.deserialize(
            json,
            WS_HabeasDataWrapper.RequestWSWrapper.class
        );
        System.assertEquals(null, s.FirstName);
        System.assertEquals(null, s.companies);
        System.assertEquals(null, s.idContactPoints);
        System.assertEquals(null, s.AttentionChannel);
    }

    @IsTest
    static void test_ResponseWSWrapper_Properties() {
        WS_HabeasDataWrapper.ResponseWSWrapper resp = new WS_HabeasDataWrapper.ResponseWSWrapper();
        resp.status = 'Success';
        resp.error = false;
        resp.responseCode = '200';
        resp.message = 'ok';
        System.assertEquals('Success', resp.status);
        System.assertEquals(false, resp.error);
        System.assertEquals('200', resp.responseCode);
        System.assertEquals('ok', resp.message);
    }

    @IsTest
    static void test_ResponseWsWrapperMassive_Constructors() {
        WS_HabeasDataWrapper.ResponseWsWrapperMassive dflt = new WS_HabeasDataWrapper.ResponseWsWrapperMassive();
        System.assertEquals(null, dflt.jobId);
        dflt.jobId = null;
        dflt.responseCode = 202;
        dflt.message = 'accepted';
        System.assertEquals(202, dflt.responseCode);
        WS_HabeasDataWrapper.ResponseWsWrapperMassive prm = new WS_HabeasDataWrapper.ResponseWsWrapperMassive(null, 201, 'queued');
        System.assertEquals(null, prm.jobId);
        System.assertEquals(201, prm.responseCode);
        System.assertEquals('queued', prm.message);
    }

    @IsTest
    static void test_Companies_Edge_Combinations() {
        WS_HabeasDataWrapper.RequestWSWrapper r = makeFullRequest(true, false);
        r.companies[0].notEssentialFunctionalities = new List<String>();
        r.companies[1].notEssentialFunctionalities = null;
        String json = System.JSON.serialize(r);
        WS_HabeasDataWrapper.RequestWSWrapper s = (WS_HabeasDataWrapper.RequestWSWrapper) System.JSON.deserialize(
            json,
            WS_HabeasDataWrapper.RequestWSWrapper.class
        );
        System.assertEquals(0, s.companies[0].notEssentialFunctionalities.size());
        System.assertEquals(null, s.companies[1].notEssentialFunctionalities);
    }
}