({
    showLeadInfo : function(component) {
        if(!component.get("v.recordId")){
            alert('Please create Lead first!');
        }else{
            var action = component.get("c.queryLeadRecord");
            action.setParams({ 
                recordID : component.get("v.recordId")
            });
            action.setCallback(this,function(response){
                var state = response.getState();
                if(state === "SUCCESS"){
                    component.set("v.isModalOpen2", true);
                    component.set("v.leadObj",response.getReturnValue());
                    var recId = response.getReturnValue().Id;
                    component.set("v.recordId",recId);
                } else if(state === "ERROR"){
                    var errors = action.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            alert(errors[0].message);
                        }
                    }
                }else if (status === "INCOMPLETE") {
                    alert('No response from server or client is offline.');
                }
            });       
            $A.enqueueAction(action);
        }
    }
})