@isTest 
public class BulkApprovalControllerTest {
    static testMethod void testBulkApprovalController() {
       Account acc = new Account(Name = 'test');
       insert acc;
       
       Opportunity opportunityToCreate = new Opportunity();
       
       // Do you recognize these fields?
       opportunityToCreate.StageName = 'Delivered';
       opportunityToCreate.CloseDate = date.today();
       opportunityToCreate.Approval_Status__c = 'Approval Due';
       opportunityToCreate.Bill_Lost_Date__c = date.today();
       opportunityToCreate.AccountId = acc.Id;
       opportunityToCreate.Bill_No__c = 'test';
       opportunityToCreate.Lost_Value__c = 22;
       opportunityToCreate.Points_Type__c = 'Gold';
       opportunityToCreate.Won_Value__c = 34;
       opportunityToCreate.Name = 'Test Opportunity Triggers';
       
       insert opportunityToCreate;
       
       BulkApprovalController cntrl = new BulkApprovalController();
       
       Set<String> tempSet = new Set<String>();
       tempSet.add(opportunityToCreate.Id);
       
       cntrl.fetch('Opportunity', tempSet);
       cntrl.piwiIds = '';
       cntrl.approveRejectRequests();
       cntrl.reassign();
       BulkApprovalController.readFieldSet('Approval_Fields', 'Opportunity');
       
       cntrl.selectedOp = '=';
       cntrl.selectedField = 'Opportunity:Name';
       cntrl.filterIndex = 0;
       cntrl.addFilter();
       cntrl.removeFilter();
       cntrl.removeAllFilter();
       cntrl.saveFilter();
       
       BulkApprovalController.ApprovalTypeWrapper w = new BulkApprovalController.ApprovalTypeWrapper(null, null, null);
       BulkApprovalController.ApprovalWrapper ww = new BulkApprovalController.ApprovalWrapper(null, null, null);
       
    }
}