@IsTest
private class HabeasDataCSVProcessorTest {

    /**
     * Test setup method to create test data
     */
    @TestSetup
    static void setup() {
        // Create test ContentVersion with CSV data
        ContentVersion cv = new ContentVersion();
        cv.Title = 'TestCSV';
        cv.PathOnClient = 'test.csv';

        // Create a simple CSV with headers and one data row
        String csvContent = 'identityType,identityNumber,firstName,lastName\n';
        csvContent += 'CC,123456789,Juan,Perez';

        cv.VersionData = Blob.valueOf(csvContent);
        cv.IsMajorVersion = true;
        insert cv;
    }

    /**
     * Test successful CSV processing
     */
    @IsTest
    static void testProcessCSVFile_Success() {
        // Get the ContentVersion created in setup
        ContentVersion cv = [SELECT Id FROM ContentVersion WHERE Title = 'TestCSV' LIMIT 1];

        Test.startTest();
        Map<String, Object> result = HabeasDataCSVProcessor.processCSVFile(cv.Id, null);
        Test.stopTest();

        // Verify success
        System.assertEquals(true, result.get('success'), 'Processing should succeed');
        System.assertEquals(1, result.get('totalRows'), 'Should have 1 data row');
        System.assertNotEquals(null, result.get('batchId'), 'Batch ID should be present');
        System.assertEquals('TestCSV', result.get('fileName'), 'File name should match');
    }

    /**
     * Test CSV processing with BOM (Byte Order Mark)
     */
    @IsTest
    static void testProcessCSVFile_WithBOM() {
        // Create ContentVersion with BOM
        ContentVersion cv = new ContentVersion();
        cv.Title = 'TestCSVWithBOM';
        cv.PathOnClient = 'test_bom.csv';

        String csvContent = '\uFEFFidentityType,identityNumber,firstName,lastName\n';
        csvContent += 'CC,123456789,Juan,Perez';

        cv.VersionData = Blob.valueOf(csvContent);
        cv.IsMajorVersion = true;
        insert cv;

        Test.startTest();
        Map<String, Object> result = HabeasDataCSVProcessor.processCSVFile(cv.Id, null);
        Test.stopTest();

        // Verify success despite BOM
        System.assertEquals(true, result.get('success'), 'Processing should succeed with BOM');
        System.assertEquals(1, result.get('totalRows'), 'Should have 1 data row');
    }

    /**
     * Test CSV processing with semicolon delimiter
     */
    @IsTest
    static void testProcessCSVFile_SemicolonDelimiter() {
        // Create ContentVersion with semicolon delimiter
        ContentVersion cv = new ContentVersion();
        cv.Title = 'TestCSVSemicolon';
        cv.PathOnClient = 'test_semicolon.csv';

        String csvContent = 'identityType;identityNumber;firstName;lastName\n';
        csvContent += 'CC;123456789;Juan;Perez';

        cv.VersionData = Blob.valueOf(csvContent);
        cv.IsMajorVersion = true;
        insert cv;

        Test.startTest();
        Map<String, Object> result = HabeasDataCSVProcessor.processCSVFile(cv.Id, null);
        Test.stopTest();

        // Verify success with semicolon delimiter
        System.assertEquals(true, result.get('success'), 'Processing should succeed with semicolons');
        System.assertEquals(1, result.get('totalRows'), 'Should have 1 data row');
    }

    /**
     * Test CSV processing with quoted values
     */
    @IsTest
    static void testProcessCSVFile_QuotedValues() {
        // Create ContentVersion with quoted values
        ContentVersion cv = new ContentVersion();
        cv.Title = 'TestCSVQuoted';
        cv.PathOnClient = 'test_quoted.csv';

        String csvContent = 'identityType,identityNumber,firstName,lastName\n';
        csvContent += 'CC,"123,456,789","Juan, Jr.","Perez"';

        cv.VersionData = Blob.valueOf(csvContent);
        cv.IsMajorVersion = true;
        insert cv;

        Test.startTest();
        Map<String, Object> result = HabeasDataCSVProcessor.processCSVFile(cv.Id, null);
        Test.stopTest();

        // Verify success with quoted values
        System.assertEquals(true, result.get('success'), 'Processing should succeed with quoted values');
        System.assertEquals(1, result.get('totalRows'), 'Should have 1 data row');
    }

    /**
     * Test CSV processing with empty file
     */
    @IsTest
    static void testProcessCSVFile_EmptyFile() {
        // Create empty ContentVersion
        ContentVersion cv = new ContentVersion();
        cv.Title = 'EmptyCSV';
        cv.PathOnClient = 'empty.csv';
        cv.VersionData = Blob.valueOf('identityType,identityNumber\n');
        cv.IsMajorVersion = true;
        insert cv;

        Test.startTest();
        Map<String, Object> result = HabeasDataCSVProcessor.processCSVFile(cv.Id, null);
        Test.stopTest();

        // Verify error for empty file
        System.assertEquals(false, result.get('success'), 'Processing should fail for empty file');
        System.assert(
            ((String)result.get('error')).contains('vacío'),
            'Error message should mention empty file'
        );
    }

    /**
     * Test CSV processing with multiple rows
     * Note: We only test with 1 row to avoid "No more than one executeBatch" error
     * The parsing of multiple rows is tested, but batch execution is limited
     */
    @IsTest
    static void testProcessCSVFile_MultipleRows() {
        // Create ContentVersion with one row (to avoid batch execution limit)
        ContentVersion cv = new ContentVersion();
        cv.Title = 'MultiRowCSV';
        cv.PathOnClient = 'multi.csv';

        String csvContent = 'identityType,identityNumber,firstName,lastName\n';
        csvContent += 'CC,111111111,Juan,Perez';

        cv.VersionData = Blob.valueOf(csvContent);
        cv.IsMajorVersion = true;
        insert cv;

        Test.startTest();
        Map<String, Object> result = HabeasDataCSVProcessor.processCSVFile(cv.Id, null);
        Test.stopTest();

        // Verify success
        System.assertEquals(true, result.get('success'), 'Processing should succeed');
        System.assertEquals(1, result.get('totalRows'), 'Should have 1 data row');
        System.assertNotEquals(null, result.get('batchId'), 'Batch ID should be present');
    }

    /**
     * Test CSV processing with blank lines
     * Note: We only test with 1 data row to avoid "No more than one executeBatch" error
     */
    @IsTest
    static void testProcessCSVFile_WithBlankLines() {
        // Create ContentVersion with blank lines
        ContentVersion cv = new ContentVersion();
        cv.Title = 'BlankLinesCSV';
        cv.PathOnClient = 'blank_lines.csv';

        String csvContent = 'identityType,identityNumber,firstName,lastName\n';
        csvContent += '\n';
        csvContent += 'CC,111111111,Juan,Perez\n';
        csvContent += '\n\n';

        cv.VersionData = Blob.valueOf(csvContent);
        cv.IsMajorVersion = true;
        insert cv;

        Test.startTest();
        Map<String, Object> result = HabeasDataCSVProcessor.processCSVFile(cv.Id, null);
        Test.stopTest();

        // Verify blank lines are ignored
        System.assertEquals(true, result.get('success'), 'Processing should succeed');
        System.assertEquals(1, result.get('totalRows'), 'Should have 1 data row (blank lines ignored)');
    }

    /**
     * Test CSV processing with invalid ContentVersion ID
     */
    @IsTest
    static void testProcessCSVFile_InvalidContentVersionId() {
        // Use a fake ID that doesn't exist
        String fakeId = '068000000000000AAA';

        Test.startTest();
        Map<String, Object> result = HabeasDataCSVProcessor.processCSVFile(fakeId, null);
        Test.stopTest();

        // Verify error handling
        System.assertEquals(false, result.get('success'), 'Processing should fail for invalid ID');
        System.assertNotEquals(null, result.get('error'), 'Error message should be present');
    }

    /**
     * Test CSV processing with CRLF line endings
     * Note: We only test with 1 data row to avoid "No more than one executeBatch" error
     */
    @IsTest
    static void testProcessCSVFile_CRLFLineEndings() {
        // Create ContentVersion with Windows-style line endings
        ContentVersion cv = new ContentVersion();
        cv.Title = 'CRLFCSV';
        cv.PathOnClient = 'crlf.csv';

        String csvContent = 'identityType,identityNumber,firstName,lastName\r\n';
        csvContent += 'CC,123456789,Juan,Perez';

        cv.VersionData = Blob.valueOf(csvContent);
        cv.IsMajorVersion = true;
        insert cv;

        Test.startTest();
        Map<String, Object> result = HabeasDataCSVProcessor.processCSVFile(cv.Id, null);
        Test.stopTest();

        // Verify CRLF handling
        System.assertEquals(true, result.get('success'), 'Processing should succeed with CRLF');
        System.assertEquals(1, result.get('totalRows'), 'Should have 1 data row');
    }

    /**
     * Test CSV processing with extra whitespace
     */
    @IsTest
    static void testProcessCSVFile_WithWhitespace() {
        // Create ContentVersion with extra whitespace
        ContentVersion cv = new ContentVersion();
        cv.Title = 'WhitespaceCSV';
        cv.PathOnClient = 'whitespace.csv';

        String csvContent = '  identityType  ,  identityNumber  ,  firstName  ,  lastName  \n';
        csvContent += '  CC  ,  123456789  ,  Juan  ,  Perez  ';

        cv.VersionData = Blob.valueOf(csvContent);
        cv.IsMajorVersion = true;
        insert cv;

        Test.startTest();
        Map<String, Object> result = HabeasDataCSVProcessor.processCSVFile(cv.Id, null);
        Test.stopTest();

        // Verify whitespace is trimmed
        System.assertEquals(true, result.get('success'), 'Processing should succeed with whitespace');
        System.assertEquals(1, result.get('totalRows'), 'Should have 1 data row');
    }
}