({
    doAction : function(component, event, helper) {
        var params = event.getParam('arguments');
        if (params) {
            var msg = params.actionMsg;
            if(msg == 'createLead'){
                component.set("v.showFooter",true);
                component.set("v.modalTitle", "New Lead");
                component.set("v.isModalOpen", true);
                component.set("v.isDisabled", false);
            }else{
                component.set("v.modalTitle", "Lead Information");
                helper.showLeadInfo(component);
            }
        }
    },
    openModel: function(component, event, helper) {
        // Set isModalOpen attribute to true
        component.set("v.isModalOpen", true);
    },
    
    closeModel: function(component, event, helper) {
        // Set isModalOpen attribute to false  
        component.set("v.isModalOpen", false);
        var blankInfo = {'sobjectType':'lead','FirstName':'',
                         'LastName':'','Phone':'','Email':''};
        component.set("v.leadObj",blankInfo);
    },
    closeModel2: function(component, event, helper) {
        component.set("v.isModalOpen2", false);
    },
    handleOnSubmit: function(component, event, helper) {
        event.preventDefault(); //Prevent default submit
        var eventFields = event.getParam("fields"); //get the fields
        eventFields["Company"] = 'None';
        component.find('leadCreateForm').submit(eventFields); //Submit Form
    },
    handleOnSuccess : function(component, event, helper) {
        var params = event.getParams(); //get event params
        var recordId = params.response.id; //get record id
        component.set("v.recordId",recordId);
        component.set("v.isModalOpen", false);
        confetti({
            particleCount: 200,
            startVelocity: 60,
            spread: 150,
            origin:{
                y: 0.9
            },
        });
        alert('Lead is Created Successfully');
        window.open('/c/ProductCatalogContainerApp.app?id='+recordId,'_self');
    },
    handleOnError: function(component, event, helper) {
        alert('There is an error occurred while creating a lead');
    }
})