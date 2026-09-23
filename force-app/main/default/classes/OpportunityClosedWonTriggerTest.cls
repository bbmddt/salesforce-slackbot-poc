@IsTest
private class OpportunityClosedWonTriggerTest {
    @IsTest
    static void createsFollowUpTaskWhenOpportunityBecomesClosedWon() {
        Opportunity opportunity = new Opportunity(
            Name = 'Slackbot PoC Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30)
        );
        insert opportunity;

        Test.startTest();
        opportunity.StageName = 'Closed Won';
        update opportunity;
        Test.stopTest();

        List<Task> followUpTasks = [
            SELECT Subject, OwnerId, WhatId, Status, Priority
            FROM Task
            WHERE WhatId = :opportunity.Id
        ];

        Assert.areEqual(1, followUpTasks.size(), 'One follow-up task should be created.');
        Assert.areEqual('Follow up after Closed Won', followUpTasks[0].Subject);
        Assert.areEqual(UserInfo.getUserId(), followUpTasks[0].OwnerId);
        Assert.areEqual('Not Started', followUpTasks[0].Status);
        Assert.areEqual('Normal', followUpTasks[0].Priority);
    }

    @IsTest
    static void doesNotCreateTaskWhenOpportunityRemainsOpen() {
        Opportunity opportunity = new Opportunity(
            Name = 'Open Slackbot PoC Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30)
        );
        insert opportunity;

        Test.startTest();
        opportunity.StageName = 'Qualification';
        update opportunity;
        Test.stopTest();

        Integer followUpTaskCount = [
            SELECT COUNT()
            FROM Task
            WHERE WhatId = :opportunity.Id
        ];

        Assert.areEqual(0, followUpTaskCount, 'No task should be created before Closed Won.');
    }
}
