trigger ExchangeTrigger on Exchange__c (before update) {
    for(Exchange__c ex:Trigger.new) {
        if(ex.Stage__c == 'Matching' && ex.Stage__c != Trigger.oldMap.get(ex.Id).Stage__c) {
            MatchingService.createAssignments(ex);
        }
    }    
}