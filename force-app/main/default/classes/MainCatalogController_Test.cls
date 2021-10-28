@IsTest
public class MainCatalogController_Test {
    static testMethod void testCase1(){
        Lead ld = new Lead();
        ld.FirstName = 'Test';
        ld.LastName = 'LastName';
        ld.Company = 'None';
        insert ld;
        
        COntact c =  new Contact();
        c.LastName = 'Test';
        insert c;
        
        Product2 p = new Product2();
        p.Description='Test Product Entry For Product';
        p.productCode = 'P-123';
        p.isActive = true;
        p.Name = 'Test';
        p.Design_Number__c = '1.1';
        p.Design_Title__c = 'Style';
        p.Main_Image_Id__c = '12345';
        p.Multiple_Image_Id__c = '1122';
        insert p;
        
        Product2 p2 = new Product2();
        p2.Description='Test Product Entry For Product';
        p2.productCode = 'P-123';
        p2.isActive = true;
        p2.Name = 'Test2';
        p2.Design_Number__c = '1.1';
        p2.Design_Title__c = 'Style';
        p2.Main_Image_Id__c = '12345';
        p2.Multiple_Image_Id__c = '1122';
        insert p2;
        
        // insert pricebook entry for the product
        PricebookEntry standardPrice = new PricebookEntry();
        standardPrice.Pricebook2Id = Test.getStandardPricebookId();
        standardPrice.Product2Id = p.Id;
        standardPrice.UnitPrice = 100;
        standardPrice.IsActive = true;
        standardPrice.UseStandardPrice = false;
        //insert standardPrice ;      
        
        Favorite__c fv = new Favorite__c();
        fv.Lead__c = ld.Id;
        fv.Product__c = p.Id;
        insert fv;
        
        Favorite__c fv2 = new Favorite__c();
        fv2.Contact__c = c.Id;
        fv2.Product__c = p.Id;
        insert fv2;
        //MainCatalogController.getFilterType();
        MainCatalogController.queryFavProduct(ld.Id);
        MainCatalogController.queryFav(ld.Id);
        MainCatalogController.queryFav(c.Id);
        MainCatalogController.queryFavourites(ld.Id);
        MainCatalogController.queryFavourites(c.Id);
        MainCatalogController.prepareFavProduct(p,true);
        MainCatalogController.queryFavProduct2();
        List<Product2> productList = new List<Product2>();
        productList.add(p);
        MainCatalogController.convertProductIntoWrapper(productList);
        Lead led = new Lead();
        led.FirstName = 'Test';
        led.LastName = 'LastName';
        led.Company = 'None';
        MainCatalogController.createLeadRecord(led);
        MainCatalogController.queryLeadRecord(led.id);
        MainCatalogController.getProductImages(p.Id);
        MainCatalogController.saveFav(p2.Id,ld.Id);
        MainCatalogController.saveFav(p2.Id,c.Id);
        MainCatalogController.saveFav(p.Id,c.Id);
        MainCatalogController.saveFav(p.Id,c.Id);
        MainCatalogController.createOpportunity(c.Id);
        MainCatalogController.createOpportunity(ld.Id);
        MainCatalogController.deleteFav(fv.Id);
    }
    
    @IsTest
    static void tesSessionIdClass(){
        Test.setMock(HttpCalloutMock.class, new SessionIdMock());
        SessionIdClass.fetchFilteredProducts();
    }
}