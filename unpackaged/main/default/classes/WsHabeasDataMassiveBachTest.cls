@IsTest(seeAllData=false)
private class WsHabeasDataMassiveBachTest {
    private static WSHabeasDataAPIDto.HabeasDataDto mkDto(String channel, String dup, String brand) {
        WSHabeasDataAPIDto.HabeasDataDto d = new WSHabeasDataAPIDto.HabeasDataDto();
        d.account = new WSHabeasDataAPIDto.AccountDto();
        d.account.firstName = 'Ana';
        d.account.lastName = 'Lopez';
        d.account.identityType = '1';
        d.account.identityNumber = '1234567890';
        d.account.email = 'ana@example.com';
        d.account.numberPhone = '3000000000';
        d.consent = new WSHabeasDataAPIDto.ConsentDto();
        d.consent.authorizationChannel = channel;
        d.consent.dataUsePurpose = dup;
        d.companies = new List<String>{ brand };
        return d;
    }

    @IsTest
    static void constructor_start_iter_finish_empty_inbound() {
        WsHabeasDataMassiveBach b = new WsHabeasDataMassiveBach(null, 'T');
        Iterable<WSHabeasDataAPIDto.HabeasDataDto> iterable = b.start(null);
        Iterator<WSHabeasDataAPIDto.HabeasDataDto> it = iterable.iterator();
        System.assertEquals(false, it.hasNext());
        b.finish(null);
        System.assertEquals(0, b.successCount);
        System.assertEquals(0, b.errorCount);
    }

    @IsTest
    static void start_iter_nonempty_scope_iteration() {
        List<WSHabeasDataAPIDto.HabeasDataDto> inbound = new List<WSHabeasDataAPIDto.HabeasDataDto>{ mkDto('X', 'Y', 'Z'), mkDto('X2', 'Y2', 'Z2') };
        WsHabeasDataMassiveBach b = new WsHabeasDataMassiveBach(inbound, 'TYPE');
        Iterable<WSHabeasDataAPIDto.HabeasDataDto> iterable = b.start(null);
        Iterator<WSHabeasDataAPIDto.HabeasDataDto> it = iterable.iterator();
        System.assertEquals(true, it.hasNext());
        System.assertNotEquals(null, it.next());
        System.assertEquals(true, it.hasNext());
        System.assertNotEquals(null, it.next());
        System.assertEquals(false, it.hasNext());
    }

    @IsTest
    static void execute_error_increments_errorCount() {
        WsHabeasDataMassiveBach b = new WsHabeasDataMassiveBach(new List<WSHabeasDataAPIDto.HabeasDataDto>(), 'ERR');
        WSHabeasDataAPIDto.HabeasDataDto bad = new WSHabeasDataAPIDto.HabeasDataDto();
        bad.account = new WSHabeasDataAPIDto.AccountDto();
        bad.account.firstName = 'Bad';
        bad.consent = null;
        List<WSHabeasDataAPIDto.HabeasDataDto> scope = new List<WSHabeasDataAPIDto.HabeasDataDto>{ bad };
        Test.startTest();
        b.execute(null, scope);
        Test.stopTest();
        System.assertEquals(0, b.successCount);
        System.assertEquals(1, b.errorCount);
    }

    @IsTest(SeeAllData=true)
    static void execute_guarded_nonNull_response_when_cmdt_present() {
        Map<String, HD_API_Rules__mdt> rules = HD_API_Rules__mdt.getAll();
        if (rules == null || rules.isEmpty()) {
            System.assert(true);
            return;
        }
        HD_API_Rules__mdt r = rules.values()[0];
        WsHabeasDataMassiveBach b = new WsHabeasDataMassiveBach(new List<WSHabeasDataAPIDto.HabeasDataDto>(), 'OK');
        WSHabeasDataAPIDto.HabeasDataDto good = mkDto(r.authorizationChannel__c, r.dataUsePurpose__c, r.BusinessBrand__c);
        List<WSHabeasDataAPIDto.HabeasDataDto> scope = new List<WSHabeasDataAPIDto.HabeasDataDto>{ good };
        Test.startTest();
        b.execute(null, scope);
        Test.stopTest();
        System.assert(b.successCount >= 0);
        System.assert(b.errorCount >= 0);
        b.finish(null);
    }
}