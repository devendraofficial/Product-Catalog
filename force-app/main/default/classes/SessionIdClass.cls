public class SessionIdClass {
    @AuraEnabled
    public static String fetchFilteredProducts(){
        String sessionId = '';
        String query = '';
        String vfContent = '';
        String hello = '';
        PageReference sessionIdPage = Page.SessionId;
        if(!test.isRunningTest()){
           vfContent = sessionIdPage.getContent().toString();
        }else{
           vfContent = 'Start112W123652WJHSHVNavEnd';
        }
        
        Integer startPosition = vfContent.indexOf('Start') + 'Start'.length(),endPosition = vfContent.indexOf('End');
        sessionId = vfContent.substring(startPosition, endPosition);
        System.debug('sessionId '+sessionId);
        ListView activelistView = [SELECT Id,Name,LastViewedDate 
                                   FROM ListView 
                                   WHERE Sobjecttype = 'Product2' AND IsSoqlCompatible = TRUE
                                   ORDER BY LastViewedDate DESC LIMIT 1];
        HttpRequest req = new HttpRequest();
        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        String endPoinURL = baseUrl+'/services/data/v32.0/sobjects/Product2/listviews/'+activelistView.Id+'/describe';
        req.setEndpoint(endPoinURL);
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer '+sessionId);
        Http http = new Http();
        HTTPResponse response = http.send(req);
        if(response.getStatusCode()!=200){
            system.debug('Status: '+response.getStatusCode()+' '+response.getStatus());
            return null;
        }else{
            Map<String, Object> tokenResponse = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            query = (String) tokenResponse.get('query');
            system.debug('query: '+query);
            return query;
        }
    }
}