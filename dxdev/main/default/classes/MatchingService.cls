public class MatchingService {

    public class MatchingServiceException extends Exception {}

    public static List<Gift_Signup__c> querySignups(Exchange__c ex) {
        List<Gift_Signup__c> signups = new List<Gift_Signup__c>();
        // conditional for security review
        if(Schema.sObjectType.Gift_Signup__c.isAccessible()
           && ex != null
           && ex.Id != null
        ) {
            signups = [
                SELECT  Id, OwnerId
                FROM    Gift_Signup__c
                WHERE   Exchange__c =:ex.Id
            ];
        }
        return signups; 
    }

    // Match maker, match maker make me a match!
    public static void createAssignments(Exchange__c ex) {
		
        // assignments will be added to this collection
        List<Assignment__c> assignments = new List<Assignment__c>();

        // grab list of signUps
        List<Gift_Signup__c> signUps = querySignups(ex);

        // check if you found it or if the exchange has sign ups
        if(ex == null || signUps == null || signUps.isEmpty()) {

            System.debug('Something went wrong...');

            if(ex == null) {
                throw new MatchingServiceException('did not find the exchange');
            } else if(signUps == null || signUps.isEmpty()) {
                throw new MatchingServiceException('No one is signed up for this exchange');
            }

        } else {
            // large conditional for security review
            if(Schema.sObjectType.Gift_Signup__c.fields.OwnerId.isAccessible()
               && Schema.sObjectType.Exchange__c.isUpdateable()
               && Schema.sObjectType.Exchange__c.fields.Stage__c.isUpdateable()
               && Schema.sObjectType.Assignment__c.isCreateable()
               && Schema.sObjectType.Assignment__c.fields.OwnerId.isCreateable()
               && Schema.sObjectType.Assignment__c.fields.Recipient__c.isCreateable()
               && Schema.sObjectType.Assignment__c.fields.Exchange__c.isCreateable()
            ) {
                // grab signups size
                Integer signUpSize = signUps.size()+0;
    
                // return matches
                List<Integer> matched = RandomUtil.shuffleMatch(signUpSize);
    
                // assign
                for(Integer i = 0; i < signUpSize; i++) {
                    assignments.add(new Assignment__c (
                        OwnerId = signUps.get(i).OwnerId,
                        Recipient__c = signUps.get(matched.get(i)).Id,
                        Exchange__c = ex.Id
                    ));
                }
    
                // if there are assignments, insert them
                if(assignments != null && !assignments.isEmpty()) {
                    System.debug('Creating ' + assignments.size()+ ' assignments');
                    insert assignments;
                    System.debug('Successfully created assignments!');
                    ex.Stage__c = 'Names Swapped';
                }
            }
        }
    }
}