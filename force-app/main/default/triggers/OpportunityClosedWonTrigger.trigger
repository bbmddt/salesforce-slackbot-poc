trigger OpportunityClosedWonTrigger on Opportunity (after update) {
    List<Task> tasksToInsert = new List<Task>();

    for (Opportunity newOpportunity : Trigger.new) {
        Opportunity oldOpportunity = Trigger.oldMap.get(newOpportunity.Id);

        if (
            oldOpportunity.StageName != 'Closed Won' &&
            newOpportunity.StageName == 'Closed Won'
        ) {
            tasksToInsert.add(new Task(
                Subject = 'Follow up after Closed Won',
                OwnerId = newOpportunity.OwnerId,
                WhatId = newOpportunity.Id,
                Status = 'Not Started',
                Priority = 'Normal'
            ));
        }
    }

    if (!tasksToInsert.isEmpty()) {
        insert tasksToInsert;
    }
}
