({
    openModel: function(component, event, helper) {
        // Set isModalOpen attribute to true
        component.set("v.isModalOpen", true);
    },
    
    closeModel: function(component, event, helper) {
        // Set isModalOpen attribute to false  
        component.set("v.isModalOpen", false);
    },
    doAction: function(component, event, helper) {
        component.set("v.productObj",'');
        component.set("v.imageList", []);
        var params = event.getParam('arguments');
        var pId = params.actionMsg;
        component.set("v.isModalOpen", true);
        var action = component.get("c.getProductImages");
        action.setParams({
            prodId : pId
        });
        action.setCallback(helper, function(response){                   
            var state = response.getState();
            var resp = response.getReturnValue();
            if(state === "SUCCESS"){
                var obj = resp.product;
                component.set("v.productObj", resp.product);
                if(!resp.imageList || resp.imageList == ''){
                    var imgArray = [];
                    imgArray.push('czxgsudvakepx25mcncqifvr5n0q0x0f');
                    component.set("v.imageList", imgArray);
                }else{
                    component.set("v.imageList", resp.imageList);
                }
                
            } else if (state === "ERROR"){
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        alert("Error message: " + 
                              errors[0].message);
                        component.set("v.isModalOpen", false);
                    }
                } else {
                    alert("Unknown error");
                }
            }	
        });
        $A.enqueueAction(action);
    }
})