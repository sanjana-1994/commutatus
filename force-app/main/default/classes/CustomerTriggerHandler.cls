public class CustomerTriggerHandler implements TriggerHandler {
	private boolean triggerIsExecuting;
    private integer triggerSize;
    public CustomerTriggerHelper helper;
    public CustomerTriggerHandler(boolean triggerIsExecuting, integer triggerSize) {
        this.triggerIsExecuting = triggerIsExecuting;
        this.triggerSize = triggerSize;
        this.helper = new CustomerTriggerHelper();
    }
    public void beforeInsert(List<Customer__c> newCustomers) {
        this.helper.createUniqueId(newCustomers);
    }
    public void beforeUpdate(List<Customer__c> oldCustomers, List<Customer__c> newCustomers, Map<ID, SObject> oldCustomerMap, Map<ID, SObject> newCustomerMap) {
    }
    public void beforeDelete(List<Customer__c> oldCustomers, Map<ID, SObject> oldCustomerMap) {
    }
    public void afterInsert(List<Customer__c> newCustomers, Map<ID, SObject> newCustomerMap) {
    }
    public void afterUpdate(List<Customer__c> oldCustomers, List<Customer__c> newCustomers, Map<ID, SObject> oldCustomerMap, Map<ID, SObject> newCustomerMap) {
    	this.helper.checkProfileCompleted(newCustomers, newCustomerMap, oldCustomerMap);
    }
    public void afterDelete(List<Customer__c> oldCustomers, Map<ID, SObject> oldCustomerMap) {
    }
    public void afterUndelete(List<Customer__c> newCustomers, Map<ID, SObject> newCustomerMap) {
    }
}