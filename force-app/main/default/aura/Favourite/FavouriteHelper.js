({
    showFav : function(component, event, helper,recId) {
        var action = component.get("c.queryFav");
        action.setParams({
            recordId : recId
        });
        action.setCallback(helper, function(response){                   
            var state = response.getState();
            var resp = response.getReturnValue();
            if(state === "SUCCESS"){
                if(resp){
                    component.set("v.isModalOpen", true);
                    component.set("v.favList", resp);
                    component.set("v.totalItems", resp.length);
                }else{
                    alert('Please add Favorite Products!!');
                }
            } else if (state === "ERROR"){
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        alert("Error message: " + 
                              errors[0].message);
                    }
                } else {
                    alert("Unknown error");
                }
            }	
        });
        $A.enqueueAction(action);
    },
    deleteFavItem : function(component, event, helper,recId) {
        var action = component.get("c.deleteFav");
        action.setParams({
            favId : recId
        });
        action.setCallback(helper, function(response){                   
            var state = response.getState();
            var resp = response.getReturnValue();
            if(state === "SUCCESS"){
                if(resp=='Success'){
                    //alert("Product is removed from the Favourite!");
                    var recId = component.get("v.recID");
                    helper.showFav(component,event,helper,recId);
                }
            } else if (state === "ERROR"){
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        alert("Error message: " + 
                              errors[0].message);
                    }
                } else {
                    alert("Unknown error");
                }
            }	
        });
        $A.enqueueAction(action);
    },
    leadConversionHelper : function(component, event, helper) {
        var action = component.get("c.createOpportunity");
        action.setParams({
            recordID : component.get("v.recID")
        });
        action.setCallback(helper, function(response){                   
            var state = response.getState();
            var resp = response.getReturnValue();
            if(state === "SUCCESS"){
                if(resp.includes("ConvertLead failed")){
                    alert("Convert Lead failed, DUPLICATES LEAD DETECTED");
                }else if(resp.includes("Opportunity Already ")){
                    alert("Opportunity Already Exists For This Contact");
                }else{
                    component.set("v.isModalOpen", false);
                    var end = Date.now() + (15 * 100);
                    var interval = setInterval(function() {
                        if (Date.now() > end) {
                            return clearInterval(interval);
                        }
                        confetti({
                            particleCount : 500,
                            startVelocity: 30,
                            spread: 400,
                            ticks: 60,
                            origin:{
                                x: Math.random(),
                                y: Math.random() 
                            },    
                        });
                    }, 300);
                    window.open(resp,'_self');
                }
            } else if (state === "ERROR"){
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        alert("Error message: " + 
                              errors[0].message);
                    }
                } else {
                    alert("Unknown error");
                }
            }	
        });
        $A.enqueueAction(action);
    }
})