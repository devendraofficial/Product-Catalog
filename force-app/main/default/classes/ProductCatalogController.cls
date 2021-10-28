public class ProductCatalogController {
    
    public Lead lead {get;set;}
    public Product2 product {get;set;}
    public Product2 productDetail {get;set;}
    public List<Product2> productList {get;set;}
    public List<Favorite__c> favList {get;set;}
    
    public List<FieldWrapper> fwList {get;set;}
    public List<FieldWrapper> fwDetailList {get;set;}
    public String leadId {get;set;}
    public String productId {get;set;}
    public String favId {get;set;}
    public boolean showFav {get;set;}
    public double amount {get;set;}
    public double unitPrice {get;set;}
    
    public ProductCatalogController()
    {
        showFav = false;
        lead = new Lead();
        leadId = ApexPages.currentPage().getParameters().get('id');
        
        product = new Product2();
        productDetail = new Product2();
        fwList = new List<FieldWrapper>();
        fwDetailList = new List<FieldWrapper>();
        
        fwList = readFieldSet('Filters', 'Product2');
        fwDetailList = readFieldSet('Details', 'Product2');
        
        productList = new List<Product2>();
        productList = [select id, Name, ProductCode, Description, Product_Catalog_Image__c,
                      (Select Id, UnitPrice from PricebookEntries),
                      (Select Id, ContentDocument.LatestPublishedVersionId
                       from ContentDocumentLinks)
                       from Product2 
                       order by Name];
                       
        favList = new List<Favorite__c>();
        
        if(leadId != null)
        {
            lead = [select id, Name, FirstName, LastName, Email, Phone, MobilePhone, Description 
                    from Lead 
                    where id =: leadId];
            
            queryFav();
            showFav = false;
        }
    }
    
    public void queryProduct()
    {
        productDetail = new Product2();
        List<Product2> productList = new List<Product2>();
        productList = database.query('select ' + showFields('Product2') + ', (Select Id, UnitPrice from PricebookEntries), (Select Id, ContentDocument.LatestPublishedVersionId from ContentDocumentLinks) from Product2 where id =: productId');
        
        if(productList.size() > 0) productDetail = productList[0];
        
        if(productDetail.PricebookEntries.size() > 0) 
            unitPrice = productDetail.PricebookEntries[0].UnitPrice;
    }
    
    public String showFields(String selectedObject) {
        List<String> lstfieldname = new List<String>();
        Map <String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(selectedObject).getDescribe().fields.getMap();
        for(Schema.SObjectField sfield : fieldMap.Values())
        {
            schema.describefieldresult dfield = sfield.getDescribe();
            lstfieldname.add(dfield.getname());
        }
        
        return String.join(lstfieldname, ',');
    }
    
    public void queryFav()
    {
        showFav = (showFav ? false : true);
        favList = new List<Favorite__c>();
        favList = [select id, Product__r.Name, Product__c, Price__c, Product__r.ProductCode, Product__r.Description, Product__r.Product_Catalog_Image__c 
                   from Favorite__c
                   where Lead__c =: leadId
                   order by Name];
    }
    
    public void saveFav()
    {
        List<Favorite__c> tempList = [select id from Favorite__c where Lead__c =: leadId and Product__c =: productId];
        
        if(tempList.size() == 0)
        {
            Favorite__c fav = new Favorite__c(Lead__c = leadId,
                                              Product__c = productId,
                                              Price__c = amount,
                                              Source__c = 'Product Catalog');
                                              
            if(leadId != null && productId != null)
            {
                insert fav;
                
                favList = new List<Favorite__c>();
                favList = [select id, Product__r.Name, Price__c, Product__r.ProductCode, Product__r.Description
                           from Favorite__c
                           where Lead__c =: leadId
                           order by Name];
            }
        }
    }
    
    public void deleteFav()
    {
        delete new Favorite__c(Id = favId);
            
        favList = new List<Favorite__c>();
        favList = [select id, Product__r.Name, Price__c, Product__r.ProductCode, Product__r.Description
                   from Favorite__c
                   where Lead__c =: leadId
                   order by Name];
    }
    
    @AuraEnabled
    public static List<Favorite__c> queryFav(String recordId)
    {
        return  [select id, Product__r.Name, Price__c, Product__r.ProductCode, Product__r.Description,Product__r.Product_Catalog_Image__c
                   from Favorite__c
                   where Lead__c =: recordId
                   order by Name];
    }
    
    @AuraEnabled
    public static List<Product2> queryProducts()
    {
        return  [select id, Name, ProductCode, Description
                 from Product2
                 order by Name
                 limit 50000];
    }
    
    public PageReference saveNewLead()
    {
        lead.Check_in_Date__c = date.today();
        lead.Company = lead.FirstName + ' ' + lead.LastName;
        insert lead;
        
        leadId = lead.Id;
        return new PageReference('/apex/ProductCatalog?id='+lead.Id).setRedirect(true);
    }
    
    public PageReference convertLeadApex()
    {
        Database.LeadConvert lc = new Database.LeadConvert();

        lc.setLeadId(leadId);
        
        LeadStatus convertStatus = [SELECT Id, MasterLabel, IsConverted FROM LeadStatus WHERE IsConverted=true limit 1];
        lc.setConvertedStatus(convertStatus.MasterLabel);
        
        Set<String> prodIds = new Set<String>();
        for(Favorite__c f : [select id, Product__c from Favorite__c where Lead__c =: leadId])
        {
            prodIds.add(f.Product__c);
        }
        
        List<PriceBook2> pbList = [select id from PriceBook2 where IsStandard = true];
        
        List<Product2> productList = [select id, Name, ProductCode, Description,
                                      (Select Id, UnitPrice from PricebookEntries where PriceBook2Id =: pbList[0].Id)
                                       from Product2 
                                       where id in : prodIds
                                       order by Name];
        
        List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
        for(Product2 p : productList)
        {
            oliList.add(new OpportunityLineItem(Quantity = 1,
                                                UnitPrice = p.PricebookEntries[0].UnitPrice,
                                                PricebookEntryId = p.PricebookEntries[0].Id));
        }
        
        Database.LeadConvertResult lcResults = Database.convertLead(lc);
        
        update new Opportunity(Id = lcResults.getOpportunityId(), PriceBook2Id = pbList[0].Id);
        
        for(OpportunityLineItem oli : oliList)
        {
            oli.OpportunityId = lcResults.getOpportunityId();
        }
        
        if(oliList.size() > 0)
            insert oliList;
    
        return new PageReference('/lightning/r/Opportunity/'+lcResults.getOpportunityId()+'/view').setRedirect(true);
    }
    
    public class FieldWrapper
    {
        public String fieldLabel {get;set;}
        public String fieldName {get;set;}
        public String fieldType {get;set;}
        public List<String> pValues {get;set;}
        
        public FieldWrapper(String fieldLabel, String fieldName, String fieldType, List<String> pValues)
        {
            this.fieldLabel = fieldLabel;
            this.fieldName = fieldName;
            this.fieldType = fieldType;
            this.pValues = pValues;
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
                String fType = fieldSetMemberObj.getType()+'';
                
                List<String> tempList = new List<String>();
                if(fType == 'MULTIPICKLIST' || fType == 'PICKLIST')
                {
                    tempList = getPicklistValues(ObjectName, fieldSetMemberObj.getFieldPath());
                }
                
                fwList.add(new FieldWrapper(fieldSetMemberObj.getLabel(), fieldSetMemberObj.getFieldPath(), fType, tempList));
            }
        }
        
        return fwList; 
    }  
    
    public static List<String> getPicklistValues(String objectName, String fieldName)
    {
        Schema.SObjectType s = Schema.getGlobalDescribe().get(objectName) ;
        Schema.DescribeSObjectResult r = s.getDescribe() ;
        Map<String,Schema.SObjectField> fields = r.fields.getMap() ;
        Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        List<String> tempList = new List<String>();
        
        for( Schema.PicklistEntry pickListVal : ple){
            tempList.add(pickListVal.getValue());
        }    
        
        return tempList;
    }
    
    @RemoteAction
    public static String saveColumn(decimal column)
    {
        RowsColumns__c rc = [Select id, Columns__c from RowsColumns__c limit 1];
        
        rc.put('Columns__c', column);
        
        update rc;
        
        return 'Success';
    }
}