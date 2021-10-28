public with sharing class BoxComIntegration {
    //Fetched from URL
    private String code ;
    private string key = '2yf03fjbtew7jvom7u8e7a7k10h1mos2';
    private string secret = 'uMmVONEdj1p9X87GyYNVA5AEwGK4e5QI' ;
    private string redirect_uri = 'https://tarasridev--datasync12--c.visualforce.com/apex/BoxAuthPage';
    
    public BoxComIntegration()
    {
        code = ApexPages.currentPage().getParameters().get('code') ;  
        //Get the access token once we have code
        if(code != '' && code != null)
        {
            system.debug('@@code: '+code);
            getAccessToken(code) ;
        }
        
    }
    
    public PageReference BoxAuth()
    {
        //Authenticating
        PageReference pg = new PageReference(BoxAuthUri (key , redirect_uri)) ;
        return pg ;
    }
    
    public String BoxAuthUri(String Clientkey,String redirect_uri)
    {
        String key = EncodingUtil.urlEncode(Clientkey,'UTF-8');
        String uri = EncodingUtil.urlEncode(redirect_uri,'UTF-8');
        String authuri = '';
        authuri = 'https://account.box.com/api/oauth2/authorize?response_type=code&client_id=2yf03fjbtew7jvom7u8e7a7k10h1mos2&redirect_uri=https://tarasridev--datasync12--c.visualforce.com/apex/BoxAuthPage';        
        return authuri;
    }
    
    
    public void getAccessToken(String code)
    {
        //Getting access token
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint('https://api.box.com/oauth2/token/');
        req.setTimeout(60*1000);
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        String payload = 'client_id='+EncodingUtil.urlEncode(key,'UTF-8')+'&client_secret='+EncodingUtil.urlEncode(secret,'UTF-8')+'&code='+code+'&grant_type=authorization_code';
        req.setBody(payload);
        Http h = new Http();
        String resp;
        HttpResponse res = h.send(req);
        resp = res.getBody();
        Map<String,object> responseMap =(Map<String,object>)JSON.deserializeUntyped(res.getBody()) ;  
        String accesstoken =  String.valueOf(responseMap.get('access_token'));
        String refreshtoken =  String.valueOf(responseMap.get('refresh_token'));
        system.debug('@@access token is: '+accesstoken); 
        system.debug('@@refresh token is: '+refreshtoken); 
    }
    public static void getAccessTokenwithRefreshToken(String refreshToken){
        
    }
}