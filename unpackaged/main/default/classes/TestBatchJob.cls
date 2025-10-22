/**
 * @description Simple batch job for testing purposes
 * This class is used in test classes to create AsyncApexJob records
 */
@IsTest
public class TestBatchJob implements Database.Batchable<Integer> {

    public List<Integer> start(Database.BatchableContext bc) {
        return new List<Integer>{1};
    }

    public void execute(Database.BatchableContext bc, List<Integer> scope) {
        // Do nothing - this is just for testing
    }

    public void finish(Database.BatchableContext bc) {
        // Do nothing - this is just for testing
    }
}