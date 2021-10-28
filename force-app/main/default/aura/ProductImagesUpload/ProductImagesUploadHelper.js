({
	helperInit : function(component, event, helper) {
		var action = component.get("c.queryProducts");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set('v.productList', result);
            }
        });
        $A.enqueueAction(action);
	}
})