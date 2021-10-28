({
	helperInit : function(component, event, helper) {
		var action = component.get("c.queryFavourites");
        action.setParams({
            'recordId' : component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set('v.favList', result);
                if(result && result.length > 0){
                    var alllist = result;
                    component.set('v.total', result.length);
                }
            }
        });
        $A.enqueueAction(action);
	}
})