@isTest
global class SessionIdMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"query": "SELECT ID FROM PRODUCT2"}');
        response.setStatusCode(200);
        return response; 
    }
}