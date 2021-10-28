public class MainCatalogController {
    
    @AuraEnabled
    public static list<productWrapper> queryFavProduct(String recordID)
    {	
        String query = '';
        if(!test.isRunningTest()){
            query = SessionIdClass.fetchFilteredProducts();
        }else{
            query = 'Select Id FROM Product2';
        }
        List<Product2> filteredList = Database.query(query);
        list<productWrapper> productsList = new list<productWrapper>();
        List<Favorite__c> favList = new List<Favorite__c>();
        Set<Id> productsId = new Set<Id>();
        if(!String.isEmpty(recordID)){
            String sobjectType = Id.valueOf(recordID).getSObjectType().getDescribe().getName();
            string fields = 'Id,Lead__c,Contact__c, Product__r.Name, Product__c, Price__c, Product__r.ProductCode, Product__r.Description,Product__r.Main_Image_Id__c';
            if(sobjectType.equalsIgnoreCase('contact')){
                favList = Database.query('SELECT '+fields +' FROM Favorite__c WHERE Contact__c =: recordID');
            }else{
                favList = Database.query('SELECT '+fields +' FROM Favorite__c WHERE Lead__c =: recordID');
            }
            Map<Id,Product2> mapProd = new Map<Id,Product2>( [ SELECT id, Name, Gross_Wt__c, Net_Wt__c, Design_Number__c, Dia_Wt__c, Flat_Dia_Wt__c, Stone_Wt__c,ProductCode, Description ,Main_Image_Id__c 
                                                              FROM Product2 WHERE Id IN :filteredList
                                                              ORDER BY Name] ); 
            For(Favorite__c fav: favList)
            {
                if(mapProd.containsKey(fav.Product__c)) 
                {	
                    productsId.add(fav.Product__c);
                }
            }       
            For(Product2 prod : mapProd.values()){
                if(productsId.contains(prod.Id)){
                    productWrapper favProd = prepareFavProduct(prod,true);
                    productsList.add(favProd);
                }else{
                    productWrapper favProd = prepareFavProduct(prod,false);
                    productsList.add(favProd);
                }
            }
        }
        return productsList;
    }
    
    public static productWrapper prepareFavProduct(Product2 currentProduct, Boolean isFav)
    {	
        productWrapper favProd = new productWrapper();
        favProd.Id =currentProduct.Id;
        favProd.productName = currentProduct.Name;
        favProd.productGross_Wt = currentProduct.Gross_Wt__c;
        favProd.productNet_Wt = currentProduct.Net_Wt__c;
        favProd.productDesign_Number = currentProduct.Design_Number__c;
        favProd.productDia_Wt = currentProduct.Dia_Wt__c;
        favProd.productFlat_Dia_Wt = currentProduct.Flat_Dia_Wt__c;
        favProd.productStone_Wt = currentProduct.Stone_Wt__c;
        favProd.productCode = currentProduct.ProductCode;
        favProd.productDescription = currentProduct.Description;
        favProd.productCatalogImage = currentProduct.Main_Image_Id__c;
        favProd.productFav = isFav;
        return favProd;
    }
    
    @AuraEnabled
    public static list<productWrapper> queryFavProduct2()
    { 	
        String query = '';
        if(!test.isRunningTest()){
            query = SessionIdClass.fetchFilteredProducts();
        }else{
            query = 'Select Id FROM Product2';
        }
        List<Product2> filteredList = Database.query(query);
        list<productWrapper> productsList = new list<productWrapper>();
        Map<Id,Product2> mapProd = new Map<Id,Product2>( [ SELECT id, Name, Gross_Wt__c, Net_Wt__c, Design_Number__c, Dia_Wt__c, Flat_Dia_Wt__c, Stone_Wt__c,ProductCode, Description ,Main_Image_Id__c
                                                          FROM Product2 WHERE Id IN:filteredList
                                                          ORDER BY Name] ); 
        For(Product2 prod : mapProd.values()){
            productWrapper favProd = prepareFavProduct(prod,false);
            productsList.add(favProd);
        }
        return productsList;
    }
    
    public class productWrapper
    {	
        @AuraEnabled public String Id {get;set;}
        @AuraEnabled public Boolean productFav {get;set;}
        @AuraEnabled public String productName {get;set;}
        @AuraEnabled public String productCatalogImage {get;set;}
        @AuraEnabled public String productDescription {get;set;}
        @AuraEnabled public Decimal  productGross_Wt {get;set;}
        @AuraEnabled public String productCode {get;set;}
        @AuraEnabled public Decimal  productNet_Wt {get;set;}
        @AuraEnabled public String productDesign_Number {get;set;}
        @AuraEnabled public Decimal  productDia_Wt {get;set;}
        @AuraEnabled public Decimal  productFlat_Dia_Wt {get;set;}
        @AuraEnabled public Decimal  productStone_Wt {get;set;}
    }
    
    @AuraEnabled
    public static void createLeadRecord(Lead leadObj){
        String msg = '';
        try{
            //Upsert Lead Record
            leadObj.Company = 'None';
            upsert leadObj; 
        }catch(DmlException e){
            //Get All DML Messages
            for (Integer i = 0; i < e.getNumDml(); i++) {
                //Get Validation Rule & Trigger Error Messages
                msg =+ e.getDmlMessage(i) +  '\n' ;
            }
            //throw DML exception message
            throw new AuraHandledException(msg);
            
        }
    } 
    
    
    @AuraEnabled
    public static Lead queryLeadRecord(String recordID){
        return[SELECT Id,Salutation,FirstName,LastName,Phone,Email FROM Lead WHERE Id =:recordID LIMIT 1];
    }
    
    public class productImageWrapper
    {
        @AuraEnabled public Product2 product {get;set;}
        @AuraEnabled public List<String> imageList {get;set;}
    }
    
    @AuraEnabled
    public static productImageWrapper getProductImages(String prodId){
        productImageWrapper wrap = new productImageWrapper();
        Product2 p = [SELECT Id,Name, Description,Category__c,Collection__c,Color_Stone__c,Design_Number__c,
                      Design_Style__c,Design_Title__c,Dia_Wt__c,Diamond_Type__c,Expertise_By__c,Flat_Dia_Wt__c,Gross_Wt__c,
                      Jewelry_Type__c,Metal__c,Net_Wt__c,Occasion__c,ProductCode,Purity__c,Stone_Wt__c,
                      Style__c,Type__c,Gender__c,Multiple_Image_Id__c,Main_Image_Id__c
                      FROM Product2 WHERE Id =:prodId LIMIT 1];
        wrap.product = p;
        List<String> idList = new List<String>();
        if(String.isNotBlank(p.Multiple_Image_Id__c)){
            idList.addAll(p.Multiple_Image_Id__c.split(','));
        }
        idList.add(p.Main_Image_Id__c);
        system.debug('idList: '+idList);
        wrap.imageList= idList;
        return wrap;
    }
    
    
    @AuraEnabled
    public static List<Favorite__c> queryFav(String recordId){
        Id myRecordId = recordId;
        String sObjName = myRecordId.getSObjectType().getDescribe().getName();
        String objectName = sObjName;
        List<Favorite__c> favList = new List<Favorite__c>();
        if(objectName!='Contact'){
            favList = [select Id,Lead__c, Product__r.Name, Product__c, Product__r.ProductCode, Product__r.Description,
                       Product__r.Collection__c,Product__r.Design_Number__c,Product__r.Design_Style__c,
                       Product__r.Design_Title__c,Product__r.Dia_Wt__c,Product__r.Diamond_Type__c,Product__r.Expertise_By__c,
                       Product__r.Flat_Dia_Wt__c,Product__r.Gross_Wt__c,Product__r.Jewelry_Type__c,Product__r.Metal__c,
                       Product__r.Net_Wt__c,Product__r.Occasion__c,Product__r.Purity__c,Product__r.Stone_Wt__c,
                       Product__r.Style__c,Product__r.Type__c,Product__r.Main_Image_Id__c
                       from Favorite__c
                       where Lead__c =: recordId
                       order by Name];
            
        }else{
            favList = [select Id, Product__r.Name, Product__c, Product__r.ProductCode, Product__r.Description,
                       Product__r.Product_Catalog_Image__c,Product__r.Collection__c,Product__r.Design_Number__c,Product__r.Design_Style__c,
                       Product__r.Design_Title__c,Product__r.Dia_Wt__c,Product__r.Diamond_Type__c,Product__r.Expertise_By__c,
                       Product__r.Flat_Dia_Wt__c,Product__r.Gross_Wt__c,Product__r.Jewelry_Type__c,Product__r.Metal__c,
                       Product__r.Net_Wt__c,Product__r.Occasion__c,Product__r.Purity__c,Product__r.Stone_Wt__c,
                       Product__r.Style__c,Product__r.Type__c,Product__r.Main_Image_Id__c
                       from Favorite__c
                       where Contact__c =: recordId
                       order by Name];
        }
        if(!favList.isEmpty()){
            return favList;
        }else{
            return null;
        }
    }
    
    @AuraEnabled
    public static List<Favorite__c> queryFavourites(String recordId){
        Id myRecordId = recordId;
        String sObjName = myRecordId.getSObjectType().getDescribe().getName();
        String objectName = sObjName;
        if(objectName=='Contact'){
            return  [select id, Product__r.Name, Price__c, Product__r.ProductCode, Product__r.Description,Product__r.Product_Catalog_Image__c,Product__r.Main_Image_Id__c
                     from Favorite__c
                     where Contact__c =: recordId
                     order by Name];
        }
        return  [select id, Product__r.Name, Price__c, Product__r.ProductCode, Product__r.Description,Product__r.Product_Catalog_Image__c,Product__r.Main_Image_Id__c
                 from Favorite__c
                 where Lead__c =: recordId
                 order by Name];
    }
    
    @AuraEnabled
    public static String saveFav(String productId,String recId){
        String msg = '';
        String sobjectType = Id.valueOf(recId).getSObjectType().getDescribe().getName();
        List<Favorite__c> tempList;
        if(sobjectType=='Contact'){
            tempList = [select id from Favorite__c where Contact__c =: recId and Product__c =: productId];
            if(tempList.size() == 0) {
                Favorite__c fav = new Favorite__c(Contact__c = recId,
                                                  Product__c = productId,
                                                  Source__c = 'Product Catalog');
                
                if(recId != null && productId != null){
                    try{
                        insert fav;
                        return 'Success';
                    }catch(Exception e){
                        //throw all other exception message
                        throw new AuraHandledException(e.getMessage());
                    }
                    
                }
            }
        }else{
            tempList = [select id from Favorite__c where Lead__c =: recId and Product__c =: productId];
            if(tempList.size() == 0) {
                Favorite__c fav = new Favorite__c(Lead__c = recId,
                                                  Product__c = productId,
                                                  Source__c = 'Product Catalog');
                
                if(recId != null && productId != null){
                    try{
                        insert fav;
                        return 'Success';
                    }catch(Exception e){
                        //throw all other exception message
                        throw new AuraHandledException(e.getMessage());
                    }
                    
                }
            }
        }
        
        return 'Product already exists in Favourite!!';
    }
    
    @AuraEnabled
    public static String deleteFav(String favId){
        String msg = '';
        try{
            delete new Favorite__c(Id = favId);
            return 'Success';
        }catch(Exception e){
            //throw all other exception message
            throw new AuraHandledException(e.getMessage());
        }        
    }
    
    public static list<productWrapper> convertProductIntoWrapper(List<Product2> productList){
        list<productWrapper> convertProductList = new list<productWrapper>();
        For(Product2 prod : productList){
            productWrapper favProd = new productWrapper();
            favProd.productName = prod.Name;
            favProd.productGross_Wt = prod.Gross_Wt__c;
            favProd.productNet_Wt = prod.Net_Wt__c;
            favProd.productDesign_Number = prod.Design_Number__c;
            favProd.productDia_Wt = prod.Dia_Wt__c;
            favProd.productFlat_Dia_Wt = prod.Flat_Dia_Wt__c;
            favProd.productStone_Wt = prod.Stone_Wt__c;
            favProd.productCode = prod.ProductCode;
            favProd.productDescription = prod.Description;
            favProd.productFav = false;
            favProd.Id =prod.Id;
            convertProductList.add(favProd);
        }
        return convertProductList;
    }
    
    //Lead Conversion method
    @AuraEnabled
    public static String createOpportunity(String recordID){
        String sobjectType = Id.valueOf(recordID).getSObjectType().getDescribe().getName(); 
        if(sobjectType.equalsIgnoreCase('Lead')){
            Database.LeadConvert lc = new Database.LeadConvert();
            Lead l = [SELECT Name FROM Lead WHERE Id =: recordID LIMIT 1];
            lc.setLeadId(recordID);
            
            LeadStatus convertStatus = [SELECT Id, MasterLabel, IsConverted FROM LeadStatus WHERE IsConverted=true limit 1];
            lc.setConvertedStatus(convertStatus.MasterLabel);
            
            Set<String> prodIds = new Set<String>();
            for(Favorite__c f : [select id, Product__c from Favorite__c where Lead__c =: recordID])
            {
                prodIds.add(f.Product__c);
            }
            
            List<PriceBook2> pbList = [select id from PriceBook2 where IsStandard = true];
            if(!pbList.isEmpty()){
                List<Product2> productList = [select id, Name, ProductCode, Description,
                                              (Select Id, UnitPrice from PricebookEntries where PriceBook2Id =: pbList[0].Id LIMIT 1)
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
                try{
                    Database.LeadConvertResult lcResults = Database.convertLead(lc);
                    update new Opportunity(Id = lcResults.getOpportunityId(), PriceBook2Id = pbList[0].Id,Name=l.name);
                    for(OpportunityLineItem oli : oliList)
                    {
                        oli.OpportunityId = lcResults.getOpportunityId();
                    }
                    
                    if(oliList.size() > 0)
                        insert oliList;
                    String url  = '/lightning/r/Opportunity/'+lcResults.getOpportunityId()+'/view';
                    return url;
                }catch(Exception e){
                    return e.getMessage();
                }
            }else{
                return null;
            }
            
        }else{
            List<OpportunityContactRole> ocrList = [SELECT ContactId FROM OpportunityContactRole 
                                                    WHERE ContactID =: recordID];
            Contact c = [SELECT Name FROM Contact WHERE ID =: recordID LIMIT 1];
            Opportunity o =  new Opportunity();
            o.Name = c.Name;
            o.StageName = 'Not yet Started';
            o.CloseDate = Date.newInstance(Date.Today().Year(), Date.Today().Month(), 30);
            try{
                insert o;
            }catch(Exception e){
                return e.getMessage();
            }
            OpportunityContactRole ocr = new OpportunityContactRole(ContactId = recordID, 
                                                                    OpportunityId = o.Id);
            try{
                insert ocr;
            }catch(Exception e){
                return e.getMessage();
            }
            Set<String> prodIds = new Set<String>();
            for(Favorite__c f : [select id, Product__c from Favorite__c where Contact__c =: recordID])
            {
                prodIds.add(f.Product__c);
            }
            List<PriceBook2> pbList = [select id from PriceBook2 where IsStandard = true];
            if(!pbList.isEmpty()){
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
                                                        OpportunityId = o.Id,
                                                        PricebookEntryId = p.PricebookEntries[0].Id));
                }
                try{
                    upsert oliList;
                    return '/lightning/r/Opportunity/'+o.Id+'/view';
                }catch(Exception e){
                    return e.getMessage();
                }
            }else{
                return null;
            }
        }
    }
}