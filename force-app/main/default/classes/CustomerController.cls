public without sharing class CustomerController {
    @AuraEnabled
    public static Customer__c checkURLParams(String urlId, String urlUid){
        Customer__c customer = [select Id, Name, Date_of_Birth__c,
                                Email__c, First_Name__c, Last_Name__c,
                                Phone_Number__c, Shoe_Size__c,
                                TShirt_Size__c 
                                from Customer__c
                                where Id =: urlId 
                                and Unique_Id__c =: urlUid];
        return customer;
    }
    @AuraEnabled
    public static String updateCustomerDetails(Customer__c customerData){
        try{
            customerData.Status__c = 'Profile Completed';
            update customerData;
            return 'Success';
        } catch (Exception ex){
            throw new AuraHandledException('Error! '+ex.getMessage());
        }
    }
}