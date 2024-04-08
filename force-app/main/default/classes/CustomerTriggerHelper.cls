public without sharing class CustomerTriggerHelper {
    
    public void checkProfileCompleted(List<Customer__c> newCustomerList,
                                      Map<Id, SObject> newCustomerMap,
                                      Map<Id, SObject> oldCustomerMap)
    {
        List<String> justProfileCompletedCustomerList = new List<String>();
        for(Customer__c customerObj: newCustomerList){
            if(customerObj.Status__c=='Profile Completed' && 
               ((Customer__c) newCustomerMap.get(customerObj.Id)).Status__c 
               != ((Customer__c) oldCustomerMap.get(customerObj.Id)).Status__c)
            {
                justProfileCompletedCustomerList.add(customerObj.Id);
            }
        }
        if(justProfileCompletedCustomerList.size()>0){
            doExternalCallout(justProfileCompletedCustomerList);
        }
    }
    
    @future(callout=true)
    public static void doExternalCallout(List<String> justProfileCompletedCustomerList){
        List<Customer__c> customerList = [select Id, Name, Date_of_Birth__c,
                                          Email__c, First_Name__c, Last_Name__c,
                                          Phone_Number__c, Shoe_Size__c,
                                          TShirt_Size__c 
                                          from Customer__c
                                          where Id =: justProfileCompletedCustomerList];
        for(Customer__c customerObj: customerList){
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('https://integrations.commutatus.com/webhook/719ce78d-c2c5-47a8-986a-39d7e7a5652d');
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json;charset=UTF-8');
            PostRequestJSON jsonObj = new PostRequestJSON(customerObj.Email__c, 
                                                          customerObj.TShirt_Size__c, 
                                                          customerObj.Shoe_Size__c);
            request.setBody(JSON.serialize(jsonObj));
            HttpResponse response = http.send(request);
            // If the request is successful, parse the JSON response.
            if(response.getStatusCode() == 200) {
                Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                String customerId = String.valueOf((Integer) result.get('customer_id'));
                customerObj.Customer_ID__c = customerId;
                customerObj.Status__c = 'Request Success';	
            } else {
                customerObj.Status__c = 'Request Failed';
            }
        }
        update customerList;
    }
    
    public void createUniqueId(List<Customer__c> newCustomerList){
        String customerRecordTypeId = Schema.getGlobalDescribe()
            .get('Customer__c').getDescribe().getRecordTypeInfosByName()
            .get('Customer').getRecordTypeId();
        
        for(Customer__c customerObj: newCustomerList){
            customerObj.Unique_Id__c = generateUniqueId();
            customerObj.RecordTypeId = customerRecordTypeId;
        }
    }
    public static String generateUniqueId(){
        String uniqueId = '';
        String[] validLetters = 'a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z'.split(',');
        Integer validLettersLength = validLetters.size();
        Integer location = null;
        String timeNow = String.valueOf(DateTime.now().getTime());
        Integer timeNowLength = timeNow.length();
        String myChar;
        
        for(Integer i=0; i<15; i++){
            location = (Integer) Math.floor(Math.random() * validLettersLength);
            uniqueId = uniqueId + '' + String.valueOf(validLetters[location]);
        }
        
        for(Integer i=0; i<10; i++){
            location = (Integer) Math.floor(Math.random() * timeNowLength);
            myChar = String.fromCharArray( new List<integer> { timeNow.charAt(location) });
            uniqueId = uniqueId + '' + myChar;
        }
        
        for(Integer i=0; i<15; i++){
            location = (Integer) Math.floor(Math.random() * validLettersLength);
            uniqueId = uniqueId + '' + String.valueOf(validLetters[location]);
        }
        
        return uniqueId;
    }
    public class PostRequestJSON {
        public String email {get; set;}
        public String tshirtSize {get; set;}
        public String shoeSize {get; set;}
        public PostRequestJSON(String em, String ts, String ss){
            this.email = em;
            this.tshirtSize = ts;
            this.shoeSize = ss;
        }
    }
}