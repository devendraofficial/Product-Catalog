({
	helperInit : function(component, event, helper) {
		var action = component.get("c.queryFav");
        action.setParams({
            'recordId' : component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set('v.favList', result);
            }
        });
        $A.enqueueAction(action);
	}
})