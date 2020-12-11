@isTest
private class TestClass {

    static testMethod void testEverything() {
        
		Profile p = [
            SELECT
                Id
            FROM
                Profile
            WHERE
                Name ='System Administrator' 
            LIMIT 1
        ];

		UserRole ur = [
            SELECT
                Id,
                Name
            FROM
                UserRole
            WHERE
                Name = 'CEO'
            LIMIT 1
        ];

        String x_name = 'bobjones';
        
		User u = new User(
	        alias = x_name.substring(0,7),
	        email = x_name + '=test.com@example.com',
	        emailencodingkey = 'UTF-8', 
            UserRoleId = ur.Id,
	        lastname = x_name,
	        languagelocalekey = 'en_US',
	        localesidkey = 'en_US', 
	        profileid = p.Id,
	        timezonesidkey = 'America/Chicago', 
	        username = x_name+'=test.com@example.com.testing'
		);
        
        insert u;

        System.runAs(u) {

			Test.startTest();
            
            Exchange__c testExchange = new Exchange__c(
                Exchange_Admin__c = UserInfo.getUserId(),
                Exchange_Date__c = System.today()
            );
            insert testExchange;
            System.debug(testExchange.Id);
            
            Assignment__c testAssignment = new Assignment__c(
                Exchange__c = testExchange.Id,
                OwnerId = UserInfo.getUserId()
            );
            insert testAssignment; 
            System.debug(testAssignment.OwnerId);

            Apexpages.StandardController sc = new Apexpages.StandardController(testExchange);

            EmailReminder em = new emailReminder(sc); 
            em.exchangeId = testExchange.Id;
            System.debug('Exchange ID ' + testExchange.Id);

            PageReference pageRef = em.sendEmail();

            List<Gift_Signup__c> signups = new List<Gift_Signup__c>();

            for(Integer i = 0; i < 5; i++) {
                signups.add(new Gift_Signup__c(
                    Exchange__c = testExchange.Id
                ));
            }

            insert signups;

            testExchange.Stage__c = 'Matching';
            update testExchange;
            
            testExchange = null;
            
            delete signups;

            try {
            	MatchingService.createAssignments(testExchange);    
            } catch(Exception e) { }
            
            testExchange = null;
            
            try {
            	MatchingService.createAssignments(testExchange);  
            } catch(Exception e) { }

            Test.stopTest();
        }
    }
}