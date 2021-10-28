({
    doInit: function(component, event, helper){
        if(component.get('v.recordId')){
            helper.showProductsSobjectType(component, event, helper);
        }else{
            helper.showProducts(component, event, helper);
        }
    },
    callLeadModalBox : function(component, event, helper) {
        var menuItem = event.getParam("value");
        var objCompB = component.find('leadComp');
        if(menuItem == 'createLead'){
            objCompB.leadModalBoxMethod("createLead");
        }else{
            objCompB.leadModalBoxMethod("showLeadDetails");
        }
    },
    callImagesModalBox : function(component, event, helper) {
        var prodId = event.currentTarget.dataset.id;
        var objCompB = component.find('imagesComp');
        objCompB.imagesModalBoxMethod(prodId);
    },
    showFavourites : function(component, event, helper) {
        var objCompB = component.find('favComp');
        var recordID = component.get("v.recordId");
        if(recordID){
            objCompB.favModalBoxMethod(recordID);
        }else{
            alert('There is no Favourite!');
        }
    },
    showHomePage: function(component, event, helper){
        window.open('/lightning/page/home','_self');
    },
    showFilterCtrl: function(component, event, helper){
        console.log("showFilter "+component.get('v.showFilter'));
        if(component.get('v.showFilter')){
            component.set('v.showFilter', false); 
            component.set('v.showFilterClass', 'slds-is-close'); 
        } else{
            component.set('v.showFilterClass', 'slds-is-open'); 
            component.set('v.showFilter', true); 
            //
            //helper.filterHelper(component, event, helper);
        }
        
    },
    onCheck :function(component, event, helper){
        var filterList = component.get('v.filterList');
        var Label = event.getSource().get("v.name");
        var Value = event.getSource().get("v.checked");
        var lst = filterList;
        if(Value){
            lst.push(Label);
        }else{
            for (var i=lst.length-1; i>=0; i--) {
                if (lst[i] === Label) {
                    lst.splice(i, 1);
                }
            }
        }
        console.log('filterList :'+lst);
        component.set("v.filterList",lst);
        // if(lst.length > 0){
        //    helper.filterQueryHelper(component, event, helper);
        // }else{
        //     helper.showProducts(component, event, helper);
        // }
    },
    onclickFav:function(component, event, helper){
        var prodId = event.currentTarget.dataset.id;
        var recordID = component.get("v.recordId");
        if(recordID){
            helper.addtoFavourite(component, event, helper, prodId, recordID);
        }else{
            alert('Please create Lead!!');
        }
    },
    onclickFilter:function(component, event, helper){
        var filterList = component.get('v.filterList');
        component.set('v.showFilter', false); 
        component.set('v.showFilterClass', 'slds-is-close'); 
        if(filterList.length > 0){
            helper.filterQueryHelper(component, event, helper);
        }else{
            helper.showProducts(component, event, helper);
        }
    },
     itemsChange: function(component, event, helper) {
        console.log("old value: " + component.get('v.recordId'));
         if(component.get('v.recordId')){
             helper.showProductsSobjectType(component, event, helper);
         }
    },
    setRowsToDisplay: function(component, event, helper) {
        var numberSelected = event.getParam("value");
        if(numberSelected==3){
            numberSelected = 4;
        }else if(numberSelected==4){
            numberSelected = 3;
        }else if(numberSelected==2){
            numberSelected = 6;
        }else if(numberSelected==1){
            //var cmpTarget = component.find('imageDivCard');
            //$A.util.addClass(cmpTarget, 'row1CSS');
            numberSelected = 12;
        }
        component.set("v.layoutItem",numberSelected);
    }
})