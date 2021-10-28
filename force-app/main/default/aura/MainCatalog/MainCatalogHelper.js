({
    spinner: {
        disabled: false, 
        show: function (component) {                       
            if (!this.disabled) component.set('v.isProcessing', true);
        },
        hide: function (component) {
            component.set('v.isProcessing', false);            
        }
    },
    showProducts : function(component, event, helper){
        var action = component.get("c.queryFavProduct2");
        action.setCallback(helper, function(response){                   
            helper.spinner.hide(component);
            helper.spinner.disabled = false;
            var state = response.getState();
            var resp = response.getReturnValue();
            if(state === "SUCCESS"){
                component.set("v.productList", resp);
                if(resp != null || resp != undefined){
                    component.set("v.totalProducts", resp.length);
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
        helper.spinner.show(component);
        $A.enqueueAction(action);
    },
    showProductsSobjectType : function(component, event, helper){
        var action = component.get("c.queryFavProduct");
        action.setParams({ 
            recordID : component.get("v.recordId")
        });
        action.setCallback(helper, function(response){                   
            helper.spinner.hide(component);
            helper.spinner.disabled = false;
            var state = response.getState();
            var resp = response.getReturnValue();
            if(state === "SUCCESS"){
                component.set("v.productList", resp);
                if(resp != null || resp != undefined){
                    component.set("v.totalProducts", resp.length);
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
        helper.spinner.show(component);
        $A.enqueueAction(action);
    },
    filterHelper : function(component, event, helper){
        var action = component.get("c.getFilterType");
        action.setCallback(helper, function(response){                   
            helper.spinner.hide(component);
            helper.spinner.disabled = false;
            var state = response.getState();
            var resp = response.getReturnValue();
            if(state === "SUCCESS"){
                component.set("v.filterWrapper", resp);
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
        helper.spinner.show(component);
        $A.enqueueAction(action);
    },
    addtoFavourite : function(component, event, helper, prodId, recordID){
        var action = component.get("c.saveFav");
        action.setParams({
            productId : prodId,
            recId : recordID
        });
        action.setCallback(helper, function(response){                   
            helper.spinner.hide(component);
            helper.spinner.disabled = false;
            var state = response.getState();
            var resp = response.getReturnValue();
            if(state === "SUCCESS"){
                if(resp=="Success"){
                    var cmpTarget = document.getElementById(prodId);
                    if(cmpTarget){
                        $A.util.addClass(cmpTarget, 'favRed'); 
                    }
                    //alert("Product Added to Favourites");
                }else{
                    alert(resp);
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
        helper.spinner.show(component);
        $A.enqueueAction(action);
    },
    filterQueryHelper : function(component, event, helper){
        var action = component.get("c.queryFilter");
        action.setParams({ 
            valueAsList : component.get("v.filterList")
        });
        action.setCallback(helper, function(response){                   
            helper.spinner.hide(component);
            helper.spinner.disabled = false;
            var state = response.getState();
            var resp = response.getReturnValue();
            if(state === "SUCCESS"){
                console.log("Product Added to Favourites" +resp.length);
                if(resp.length < 3){
                    console.log("Product Added to Favourites if " +resp.length);
                    component.set("v.layoutItem", 0);
                }
                component.set("v.productList", resp);
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
        helper.spinner.show(component);
        $A.enqueueAction(action);
    },
})