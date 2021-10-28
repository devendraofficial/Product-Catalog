public class BulkApprovalController
{
    public List<ProcessInstanceWorkitem> piWorkItemList {get;set;}
    public List<ApprovalTypeWrapper> atwList {get;set;}
    public String approvalAction {get;set;}
    public String approvalComment {get;set;}
    public String userId {get;set;}
    public integer itemCount {get;set;}
    public Contact con {get;set;}
    public Map<String, String> fieldsMap {get;set;}
    public Map<String, String> filterTypeMap {get;set;}
    public List<SelectOption> soList {get;set;}
    public List<SelectOption> fields {get;set;}
    public String piwiIds {get;set;}
    
    public List<FilterWrapper> filters {get;set;}
    
    public BulkApprovalController()
    {
        filters = new List<FilterWrapper>();
        
        init();
    }
    
    public void init()
    {
        itemCount = 0;
        con = new Contact();
        fieldsMap = new Map<String, String>();
        filterTypeMap = new Map<String, String>();
        
        soList = new List<SelectOption>();
        soList.add(new SelectOption('=', 'equals'));
        soList.add(new SelectOption('!=', 'not equal to'));
        soList.add(new SelectOption('<', 'less than'));
        soList.add(new SelectOption('>', 'greater than'));
        soList.add(new SelectOption('<=', 'less or equal'));
        soList.add(new SelectOption('>=', 'greater or equal'));
        soList.add(new SelectOption('like', 'contains'));
        soList.add(new SelectOption('not like', 'does not contains'));
        soList.add(new SelectOption('sw', 'starts with'));
        
        filterTypeMap.put('=', 'equals');
        filterTypeMap.put('!=', 'not equal to');
        filterTypeMap.put('<', 'less than');
        filterTypeMap.put('>', 'greater than');
        filterTypeMap.put('<=', 'less or equal');
        filterTypeMap.put('>=', 'greater or equal');
        filterTypeMap.put('like', 'contains');
        filterTypeMap.put('not like', 'does not contains');
        filterTypeMap.put('sw', 'starts with');
        
        piWorkItemList = new List<ProcessInstanceWorkitem>();
        
        atwList = new List<ApprovalTypeWrapper>();
        
        piWorkItemList = queryApprovals();
        
        Map<String, List<ApprovalWrapper>> awMap = new Map<String, List<ApprovalWrapper>>();
        
        Set<String> targetObjIds = new Set<String>();
        
        if(piWorkItemList.size() > 0)
        {
            Map<String, Set<String>> objListMap = new Map<String, Set<String>>();
            Map<String, sObject> sObjectMap = new Map<String, sObject>();
            
            for(ProcessInstanceWorkitem rec : piWorkItemList)
            {
                String sObjName = rec.ProcessInstance.TargetObjectId.getSObjectType().getDescribe().getName();
                
                Set<String> tempSet = objListMap.get(sObjName);
                
                if(tempSet == null) tempSet = new Set<String>();
                
                tempSet.add(rec.ProcessInstance.TargetObjectId);
                
                objListMap.put(sObjName, tempSet);
                
                targetObjIds.add(rec.ProcessInstance.TargetObjectId);
            }
            
            
            for(String s : objListMap.keySet())
            {
                List<sObject> sObList = fetch(s, objListMap.get(s));
                
                for(sObject ob : sObList)
                {
                    sObjectMap.put(ob.Id, ob);
                }
            }
            
            
            
            Map<String, String> tempMap = queryCommentsMap(targetObjIds);
            
            for(ProcessInstanceWorkitem rec : piWorkItemList)
            {
                String sObjName = rec.ProcessInstance.TargetObjectId.getSObjectType().getDescribe().getName();
                
                List<ApprovalWrapper> tempList = awMap.get(sObjName);
                
                if(tempList == null) tempList = new List<ApprovalWrapper>();
                
                String comments = '';
                
                if(tempMap.containskey(rec.ProcessInstance.TargetObjectId)) comments = tempMap.get(rec.ProcessInstance.TargetObjectId);
                
                sObject sobj = sObjectMap.get(rec.ProcessInstance.TargetObjectId);//fetch(sObjName, rec.ProcessInstance.TargetObjectId);
                
                if(sobj != null)
                {
                    ApprovalWrapper aw = new ApprovalWrapper(rec, sobj, comments);
                    
                    tempList.add(aw);
                    
                    awMap.put(sObjName, tempList);
                    
                    itemCount++;
                }
            }
            
            for(String rec : awMap.keyset())
            {
                List<ApprovalWrapper> tempList = awMap.get(rec);
                
                atwList.add(new ApprovalTypeWrapper(rec, tempList, readFieldSet('Approval_Fields', rec)));
            }
        }
        
        fields = new List<SelectOption>();
        
        Set<String> fieldSet = fieldsMap.keyset();
        List<String> fieldList = new List<String>();
        
        fieldList.addAll(fieldSet);
        fieldList.sort();
        
        for(String s : fieldList)
        {
            fields.add(new SelectOption(s, fieldsMap.get(s)));
        }
    }
    
    public static List<ProcessInstanceWorkitem> queryApprovals()
    {
        return  [SELECT ActorId, Actor.Name, CreatedDate, Id, OriginalActorId, ProcessInstance.CreatedDate,
                 ProcessInstanceId, SystemModstamp, ProcessInstance.TargetObjectId
                 FROM ProcessInstanceWorkitem 
                 WHERE ACTORID =: UserInfo.getUserId()];
    }
    
    public static Map<String, String> queryCommentsMap(Set<String> targetObjIds)
    {
        Map<String, String> tempMap = new Map<String, String>();
        for(ProcessInstanceStep p : [select id, ActorId, Actor.Name, Comments, CreatedDate, ProcessInstance.TargetObjectId 
                                     from ProcessInstanceStep
                                     where ProcessInstance.TargetObjectId in: targetObjIds
                                     and Comments != null
                                     order by CreatedDate desc])
        {
            String s = tempMap.get(p.ProcessInstance.TargetObjectId);
            
            if(s == null) s = '';
            
            s += '<b>' + p.Actor.Name + ' on ' + p.CreatedDate.format() + '</b><br/>';
            s += p.Comments+'<br/><br/>';
            
            tempMap.put(p.ProcessInstance.TargetObjectId, s);
        }
        
        return tempMap;
    }
    
    public List<sObject> fetch(String objectApiName, Set<String> objId)
    {
        String SobjectApiName = objectApiName;
        
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectField> fieldMap = schemaMap.get(SobjectApiName).getDescribe().fields.getMap();
 
        String commaSepratedFields = '';
        for(String fieldName : fieldMap.keyset()){
            String fType = fieldMap.get(fieldName).getDescribe().getType()+'';
            
            if(commaSepratedFields == null || commaSepratedFields == ''){
                commaSepratedFields = fieldName;
            }else{
                commaSepratedFields = commaSepratedFields + ', ' + fieldName;
            }
            
            if(fType == 'REFERENCE' && fieldName != 'contactid' && !fieldName.contains('historyid'))
            {
                system.debug('fieldName :::::' + fieldName);
                commaSepratedFields = commaSepratedFields + ', ' + (fieldName.endsWith('__c') ? fieldName.replace('__c', '__r')+'.Name' : fieldName.replace('id', '')+'.Name');
            }
            
            fieldsMap.put(objectApiName+':'+fieldName, objectApiName+': '+ fieldMap.get(fieldName).getDescribe().getLabel());
        }
        
        String filterQuery = '';
        
        for(FilterWrapper fw : filters)
        {
            if(fw.objectName == objectApiName)
            {
                if(fw.filter == 'sw')
                {
                    fw.fieldValue = '%'+fw.fieldValue;
                    fw.filter = 'like';
                }
                
                if(fw.filter == 'like')
                    fw.fieldValue = '%'+fw.fieldValue+'%';
                    
                filterQuery += ' and ' + fw.fieldName + ' ' + fw.filter + ' \'' + fw.fieldValue + '\'';
            }
        }
        
        system.debug('commaSepratedFields  :::::' + commaSepratedFields);
        String query = 'select ' + commaSepratedFields + ' from ' + SobjectApiName + ' where id in: objId ' + filterQuery;
        
        List<sObject> sObjList = Database.query(query);
        
        if(sObjList.size() > 0) return sObjList;
        
        return null;
    }
    
    public void approveRejectRequests()
    {
        List<Approval.ProcessWorkitemRequest> requests = new List<Approval.ProcessWorkitemRequest>();
        
        /*for(ApprovalTypeWrapper rec : atwList)
        {
            for(ApprovalWrapper inRec : rec.awList)
            {   
                if(inRec.isSelected)
                {
                    Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
                    req.setWorkitemId(inRec.piwi.Id);
                    req.setAction(approvalAction);
                    req.setComments(approvalComment);
                    requests.add(req);
                }
            }
        }*/
        
        for(String id : piwiIds.split('~~~'))
        {
            if(id.trim() != '')
            {
                Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
                req.setWorkitemId(id);
                req.setAction(approvalAction);
                req.setComments(approvalComment);
                requests.add(req);
            }
        }
        
        if(requests.size() > 0)
        {                                           
            Approval.ProcessResult[] processResults = Approval.process(requests);
            system.debug(processResults[0].getErrors());
            init();
        }
    }
    
    public void reassign(){
        List<ProcessInstanceWorkItem> workItemList = new List<ProcessInstanceWorkItem>();
        
        if(userId != null)
        {
            for(String id : piwiIds.split('~~~'))
            {
                if(id.trim() != '')
                {
                    ProcessInstanceWorkItem piwi = new ProcessInstanceWorkItem(id = id,
                                                                               ActorId = userId);
                    workItemList.add(piwi);
                }
            }
            /*for(ApprovalTypeWrapper rec : atwList)
            {
                for(ApprovalWrapper inRec : rec.awList)
                {   
                    if(inRec.isSelected)
                    {
                        inRec.piwi.ActorId = userId;
                        
                        workItemList.add(inRec.piwi);
                    }
                }
            }*/
            
            if(workItemList.size() > 0)
            {                                           
                update workItemList;
                init();
            }
        }
    }
    
    public static List<FieldWrapper> readFieldSet(String fieldSetName, String ObjectName)
    {
        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(ObjectName);
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
    
        Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName);
        
        List<FieldWrapper> fwList = new List<FieldWrapper>();
        
        if(fieldSetObj != null)
        {
            for(Schema.FieldSetMember fieldSetMemberObj : fieldSetObj.getFields())
            {
                if(fieldSetMemberObj.getType()+'' != 'REFERENCE')
                    fwList.add(new FieldWrapper(fieldSetMemberObj.getLabel(), fieldSetMemberObj.getFieldPath(), fieldSetMemberObj.getType()+''));
                else
                {
                    fwList.add(new FieldWrapper(fieldSetMemberObj.getLabel(), fieldSetMemberObj.getFieldPath().replace('__c', '__r').replace('Id', '')+'.Name', fieldSetMemberObj.getType()+''));
                }
            }
        }
        
        return fwList; 
    }  
    
    public class ApprovalTypeWrapper {
        public String approvalType {get;set;}
        public List<FieldWrapper> fwList {get;set;}
        public List<ApprovalWrapper> awList {get;set;}
        
        public ApprovalTypeWrapper(String approvalType, List<ApprovalWrapper> awList, List<FieldWrapper> fwList)
        {
            this.approvalType = approvalType;
            this.awList = awList;
            this.fwList = fwList;
        }
    }
    
    public class FieldWrapper
    {
        public String fieldLabel {get;set;}
        public String fieldName {get;set;}
        public String fieldType {get;set;}
        
        public FieldWrapper(String fieldLabel, String fieldName, String fieldType)
        {
            this.fieldLabel = fieldLabel;
            this.fieldName = fieldName;
            this.fieldType = fieldType;
        }
    }
    
    public class ApprovalWrapper
    {
        public ProcessInstanceWorkitem piwi {get;set;}
        public sObject obj {get;set;}
        public boolean isSelected {get;set;}
        public String comments {get;set;}
        
        public ApprovalWrapper(ProcessInstanceWorkitem piwi, sObject obj, String comments)
        {
            this.piwi = piwi;
            this.obj = obj;
            isSelected = false;
            this.comments = comments;
            
            this.piwi = piwi;
            this.obj = obj;
            isSelected = false;
            this.comments = comments;
            
            this.piwi = piwi;
            this.obj = obj;
            isSelected = false;
            this.comments = comments;
            
            this.piwi = piwi;
            this.obj = obj;
            isSelected = false;
            this.comments = comments;
            
            this.piwi = piwi;
            this.obj = obj;
            isSelected = false;
            this.comments = comments;
            
            this.piwi = piwi;
            this.obj = obj;
            isSelected = false;
            this.comments = comments;
            
            this.piwi = piwi;
            this.obj = obj;
            isSelected = false;
            this.comments = comments;
        }
    }
    
    public String selectedOp {get;set;}
    public String selectedField {get;set;}
    public String selectedVal {get;set;}
    public class FilterWrapper
    {
        public String objectName {get;set;}
        public String fieldName {get;set;}
        public String fieldLabel {get;set;}
        public String fieldValue {get;set;}
        public String filter {get;set;}
        public String filterLabel {get;set;}
        
        public FilterWrapper(String objectName,
                             String fieldName,
                             String fieldLabel,
                             String fieldValue,
                             String filter,
                             String filterLabel)
        {
            this.objectName = objectName;
            this.fieldName = fieldName;
            this.fieldLabel = fieldLabel;
            this.fieldValue = fieldValue;
            this.filter = filter;
            this.filterLabel = filterLabel;
            
            this.objectName = objectName;
            this.fieldName = fieldName;
            this.fieldLabel = fieldLabel;
            this.fieldValue = fieldValue;
            this.filter = filter;
            this.filterLabel = filterLabel;
            
            this.objectName = objectName;
            this.fieldName = fieldName;
            this.fieldLabel = fieldLabel;
            this.fieldValue = fieldValue;
            this.filter = filter;
            this.filterLabel = filterLabel;
            
            this.objectName = objectName;
            this.fieldName = fieldName;
            this.fieldLabel = fieldLabel;
            this.fieldValue = fieldValue;
            this.filter = filter;
            this.filterLabel = filterLabel;
            
            this.objectName = objectName;
            this.fieldName = fieldName;
            this.fieldLabel = fieldLabel;
            this.fieldValue = fieldValue;
            this.filter = filter;
            this.filterLabel = filterLabel;
            
            this.objectName = objectName;
            this.fieldName = fieldName;
            this.fieldLabel = fieldLabel;
            this.fieldValue = fieldValue;
            this.filter = filter;
            this.filterLabel = filterLabel;
            
            this.objectName = objectName;
            this.fieldName = fieldName;
            this.fieldLabel = fieldLabel;
            this.fieldValue = fieldValue;
            this.filter = filter;
            this.filterLabel = filterLabel;
            this.objectName = objectName;
            this.fieldName = fieldName;
            this.fieldLabel = fieldLabel;
            this.fieldValue = fieldValue;
            this.filter = filter;
            this.filterLabel = filterLabel;
            this.objectName = objectName;
            this.fieldName = fieldName;
            this.fieldLabel = fieldLabel;
            this.fieldValue = fieldValue;
            this.filter = filter;
            this.filterLabel = filterLabel;
            
            this.objectName = objectName;
            this.fieldName = fieldName;
            this.fieldLabel = fieldLabel;
            this.fieldValue = fieldValue;
            this.filter = filter;
            this.filterLabel = filterLabel;
            
            this.objectName = objectName;
            this.fieldName = fieldName;
            this.fieldLabel = fieldLabel;
            this.fieldValue = fieldValue;
            this.filter = filter;
            this.filterLabel = filterLabel;
            
            this.objectName = objectName;
            this.fieldName = fieldName;
            this.fieldLabel = fieldLabel;
            this.fieldValue = fieldValue;
            this.filter = filter;
            this.filterLabel = filterLabel;
            
            this.objectName = objectName;
            this.fieldName = fieldName;
            this.fieldLabel = fieldLabel;
            this.fieldValue = fieldValue;
            this.filter = filter;
            this.filterLabel = filterLabel;
            
            this.objectName = objectName;
            this.fieldName = fieldName;
            this.fieldLabel = fieldLabel;
            this.fieldValue = fieldValue;
            this.filter = filter;
            this.filterLabel = filterLabel;
            
            this.objectName = objectName;
            this.fieldName = fieldName;
            this.fieldLabel = fieldLabel;
            this.fieldValue = fieldValue;
            this.filter = filter;
            this.filterLabel = filterLabel;
            
            this.objectName = objectName;
            this.fieldName = fieldName;
            this.fieldLabel = fieldLabel;
            this.fieldValue = fieldValue;
            this.filter = filter;
            this.filterLabel = filterLabel;
            this.objectName = objectName;
            this.fieldName = fieldName;
            this.fieldLabel = fieldLabel;
            this.fieldValue = fieldValue;
            this.filter = filter;
            this.filterLabel = filterLabel;
            this.objectName = objectName;
            this.fieldName = fieldName;
            this.fieldLabel = fieldLabel;
            this.fieldValue = fieldValue;
            this.filter = filter;
            this.filterLabel = filterLabel;
            
            this.objectName = objectName;
            this.fieldName = fieldName;
            this.fieldLabel = fieldLabel;
            this.fieldValue = fieldValue;
            this.filter = filter;
            this.filterLabel = filterLabel;
            
            this.objectName = objectName;
            this.fieldName = fieldName;
            this.fieldLabel = fieldLabel;
            this.fieldValue = fieldValue;
            this.filter = filter;
            this.filterLabel = filterLabel;
            
            this.objectName = objectName;
            this.fieldName = fieldName;
            this.fieldLabel = fieldLabel;
            this.fieldValue = fieldValue;
            this.filter = filter;
            this.filterLabel = filterLabel;
            
            this.objectName = objectName;
            this.fieldName = fieldName;
            this.fieldLabel = fieldLabel;
            this.fieldValue = fieldValue;
            this.filter = filter;
            this.filterLabel = filterLabel;
            
            this.objectName = objectName;
            this.fieldName = fieldName;
            this.fieldLabel = fieldLabel;
            this.fieldValue = fieldValue;
            this.filter = filter;
            this.filterLabel = filterLabel;
            
            this.objectName = objectName;
            this.fieldName = fieldName;
            this.fieldLabel = fieldLabel;
            this.fieldValue = fieldValue;
            this.filter = filter;
            this.filterLabel = filterLabel;
            
            this.objectName = objectName;
            this.fieldName = fieldName;
            this.fieldLabel = fieldLabel;
            this.fieldValue = fieldValue;
            this.filter = filter;
            this.filterLabel = filterLabel;
            this.objectName = objectName;
            this.fieldName = fieldName;
            this.fieldLabel = fieldLabel;
            this.fieldValue = fieldValue;
            this.filter = filter;
            this.filterLabel = filterLabel;
            this.objectName = objectName;
            this.fieldName = fieldName;
            this.fieldLabel = fieldLabel;
            this.fieldValue = fieldValue;
            this.filter = filter;
            this.filterLabel = filterLabel;
        }
    }
    
    public integer filterIndex {get;set;}
    public void addFilter()
    {
        system.debug('selectedOp ::::::' + selectedOp);
        if(selectedOp != null && selectedField != null)
        {
            List<String> fList = selectedField.split(':');
            
            filters.add(new FilterWrapper(fList[0],
                                          fList[1],
                                          fList[1].replace('__c', '').replace('_', ''),
                                          selectedVal,
                                          selectedOp,
                                          filterTypeMap.get(selectedOp)));
        }
        
        selectedOp = selectedField = selectedVal = null;
    }
    
    public void removeFilter()
    {
        List<FilterWrapper> tempList = new List<FilterWrapper>();
        
        for(integer i=0 ; i < filters.size(); i++)
        {
            if(i != filterIndex)
            {
                tempList.add(filters[i]);
            }
        }
        
        filters = new List<FilterWrapper>();
        
        filters.addAll(tempList);
    }
    
    public void removeAllFilter()
    {
        filters = new List<FilterWrapper>();
    }
    
    public void saveFilter()
    {
        init();
    }
}