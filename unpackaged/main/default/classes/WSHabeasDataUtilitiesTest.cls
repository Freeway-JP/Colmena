@IsTest
public class WSHabeasDataUtilitiesTest {
    // Helper: DTO base con TODOS los campos relevantes poblados
    private static WSHabeasDataExtendWrapper.HabeasDataDto baseDto() {
        WSHabeasDataExtendWrapper.HabeasDataDto d = new WSHabeasDataExtendWrapper.HabeasDataDto();
        // Campos usados por validateContactRequestData
        d.contactFirstName = 'Jane';
        d.contactLastName = 'Doe';
        d.contactIdType = 'CC';
        d.contactIdNumber = '987654321';

        // Campos usados por validateRequiredFields (CONTROLLER_MANDATORY_FIELDS)
        d.secondLastName = 'JR';
        d.identityType = 'CC';
        d.identityNumber = '987654321';
        d.email = 'jane.doe@test.com';
        d.numberPhone = '6012345678';
        d.dataUsePurpose = 'Cliente'; // valor cualquiera; aquí no hay picklist DML
        d.authorizationChannel = 'Portal de proveedores'; // idem

        // Lista para probar List<> en isBlankish
        WSHabeasDataExtendWrapper.CompanyDTO c = new WSHabeasDataExtendWrapper.CompanyDTO();
        c.name = 'ARL';
        d.companies = new List<WSHabeasDataExtendWrapper.CompanyDTO>{ c };
        return d;
    }

    @IsTest
    static void test_validateContactRequestData_null_and_missing_fields() {
        // null -> false
        System.assertEquals(false, WSHabeasDataUtilities.validateContactRequestData(null));

        // Todos presentes -> true
        WSHabeasDataExtendWrapper.HabeasDataDto dto = baseDto();
        System.assertEquals(true, WSHabeasDataUtilities.validateContactRequestData(dto));

        // Iterar faltantes (blank) -> false
        for (String f : WSHabeasDataUtilities.CONTACT_MANDATORY_FIELDS) {
            WSHabeasDataExtendWrapper.HabeasDataDto d = baseDto();
            if (f == 'contactFirstName')
                d.contactFirstName = '   '; // whitespace -> blank
            else if (f == 'contactLastName')
                d.contactLastName = '';
            else if (f == 'contactIdType')
                d.contactIdType = null;
            else if (f == 'contactIdNumber')
                d.contactIdNumber = null;
            System.assertEquals(false, WSHabeasDataUtilities.validateContactRequestData(d), 'Debe ser false cuando falta: ' + f);
        }
    }

    @IsTest
    static void test_validateRequiredFields_all_present_and_each_missing() {
        // all-present -> false
        WSHabeasDataExtendWrapper.HabeasDataDto dto = baseDto();
        System.assertEquals(false, WSHabeasDataUtilities.validateRequiredFields(dto, WSHabeasDataUtilities.CONTROLLER_MANDATORY_FIELDS));

        // each missing -> true
        for (String f : WSHabeasDataUtilities.CONTROLLER_MANDATORY_FIELDS) {
            WSHabeasDataExtendWrapper.HabeasDataDto d = baseDto();
            // set field to blank/null según tipo conocido
            if (f == 'secondLastName')
                d.secondLastName = '';
            else if (f == 'identityType')
                d.identityType = null;
            else if (f == 'identityNumber')
                d.identityNumber = null;
            else if (f == 'email')
                d.email = '   ';
            else if (f == 'numberPhone')
                d.numberPhone = '';
            else if (f == 'dataUsePurpose')
                d.dataUsePurpose = null;
            else if (f == 'authorizationChannel')
                d.authorizationChannel = null;

            System.assertEquals(true, WSHabeasDataUtilities.validateRequiredFields(d, new List<String>{ f }), 'Debe ser true si falta/está blank: ' + f);
        }
    }

    @IsTest
    static void test_validateRequiredFields_list_blankish_cases() {
        // companies vacía -> true (List branch en isBlankish)
        WSHabeasDataExtendWrapper.HabeasDataDto d1 = baseDto();
        d1.companies = new List<WSHabeasDataExtendWrapper.CompanyDTO>();
        System.assertEquals(true, WSHabeasDataUtilities.validateRequiredFields(d1, new List<String>{ 'companies' }));

        // companies con un elemento -> false
        WSHabeasDataExtendWrapper.HabeasDataDto d2 = baseDto();
        System.assertEquals(false, WSHabeasDataUtilities.validateRequiredFields(d2, new List<String>{ 'companies' }));
    }
}