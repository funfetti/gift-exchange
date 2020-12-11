public with sharing class EmailReminder {

    private ApexPages.StandardController standardController;

    public Id exchangeId {get; set;}

    public EmailReminder(ApexPages.StandardController standardController) {
        this.standardController = standardController;
        exchangeId  = ApexPages.CurrentPage().getparameters().get('id');
        System.debug('The exchange record: ' + exchangeId);
    }

    public PageReference sendEmail() {
        // conditional for security review
        if(Schema.sObjectType.Assignment__c.fields.OwnerId.isAccessible()
           && Schema.sObjectType.Exchange__c.fields.Email_Template_Name__c.isAccessible()
           && Schema.sObjectType.EmailTemplate.fields.Id.isAccessible()
        ) {
            List<Assignment__c> listUsers = [
                SELECT
                    OwnerId 
                FROM 
                    Assignment__c
                WHERE
                    Exchange__c =: exchangeId 
            ];
    
            List<Id> listIds = new List<Id>();
            System.debug(listUsers.size());
    
            for(Assignment__c a:listUsers) {
                listIds.add(a.OwnerId);
                system.debug(a.OwnerId);
            }
    
            String emailTemplateName = 'Sales: New Customer Email';
    
            List<Exchange__c> templateNameOnExchange = [
                SELECT
                    Email_Template_Name__c
                FROM
                    Exchange__c 
                WHERE
                    Id =: exchangeId
            ];
    
            if(templateNameOnExchange != null && !templateNameOnExchange.isEmpty()) {
                emailTemplateName = templateNameOnExchange[0].Email_Template_Name__c;
            }

            EmailTemplate et = [
                SELECT
                    Id
                FROM
                    EmailTemplate
                WHERE
                    Name =: emailTemplateName 
                LIMIT 1
            ];

            Messaging.MassEmailMessage mail = new Messaging.MassEmailMessage();
            mail.setTargetObjectIds(listIds);
            mail.setSenderDisplayName('Gift Exchange Admin');
            mail.setTemplateId(et.Id);
            mail.setSaveAsActivity(false);
            Messaging.sendEmail(new Messaging.MassEmailMessage[] { mail });
        }

		PageReference pageRef = new PageReference('/' + exchangeId);
        pageRef.setRedirect(true);

        // Redirects to Exchange page
        return pageRef;
    }
}