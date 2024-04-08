trigger CustomerTrigger on Customer__c (before insert, after update) {
    TriggerHandler handler = new CustomerTriggerHandler(Trigger.isExecuting, Trigger.size);
    switch on Trigger.operationType {
        when BEFORE_INSERT {
            handler.beforeInsert(Trigger.new);
        } 
        when AFTER_UPDATE {
            handler.afterUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
        }
    }
}