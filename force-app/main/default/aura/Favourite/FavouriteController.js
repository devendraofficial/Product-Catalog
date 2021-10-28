({
    doInit : function(component, event, helper){
        var params = event.getParam('arguments');
        if (params) {
            var recId = params.leadId;
            component.set("v.recID",recId);
            helper.showFav(component, event, helper,recId);
        }
        
    },
    closeModel: function(component, event, helper) {
        // Set isModalOpen attribute to false  
        component.set("v.isModalOpen", false);
    },
    deleteItem: function(component, event, helper) {
        var recId = event.currentTarget.dataset.id;
        helper.deleteFavItem(component, event, helper,recId);
    },
    leadConversionMethod:function(component, event, helper) {
        helper.leadConversionHelper(component, event, helper);
    }
})