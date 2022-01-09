
(function (global) {
    console.log(localStorage)
    const uriBeginningTemp = 'http:127.0.0.1:5500';
    global.communication = {}
    global.communication.uriBeginning = uriBeginningTemp

    // This function get the poi info according name
    global.communication.getPoisInfo = function (poiParameter, valueOfParameter, relevantBounds = undefined, searchOutsideTheBounds, successCallbackFunc, failureCallbackFunc = undefined) {
        if (!relevantBounds) {
            relevantBounds = getDefaultBounds();
        }
        var poiInfo = {
            poiParameter: valueOfParameter
        }
        var quaryParams = {}
        quaryParams['poiParameter'] = poiParameter
        quaryParams['relevantBounds'] = relevantBounds
        quaryParams['poiInfo'] = poiInfo
        quaryParams['searchOutsideTheBounds'] = searchOutsideTheBounds
        communication.addTokensToObject(quaryParams)
        // communication.addTokensToObject(quaryParams) //add tokens
        var quaryParamsJson = JSON.stringify(quaryParams);
        const Http = new XMLHttpRequest();
        const url = '/searchPois';
        Http.onerror = function(e){
            failureCallbackFunc();
        };
        Http.open("POST", url);
        Http.withCredentials = false;
        Http.setRequestHeader("Content-Type", "application/json");
        console.log(quaryParamsJson)
        Http.send(quaryParamsJson);
        Http.onreadystatechange = (e) => {
            if (Http.readyState == 4 && Http.status == 200) { //if the operation is complete.
                var response = Http.responseText
                if (response.length > 0) {
                    successCallbackFunc(JSON.parse(Http.responseText));
                } else {
                    if (failureCallbackFunc) { failureCallbackFunc() }
                }
            }
        }
    }

    // The function get the poi info for pois that waiting for approval
    global.communication.getAudioById = function (id, successCallbackFunc, failureCallbackFunc = undefined) {
        var poiInfo = {
            _id: id
        }
        communication.addTokensToObject(poiInfo)
        var poiInfoJson = JSON.stringify(poiInfo);
        const Http = new XMLHttpRequest();
        const url = '/searchPoiAudioById';
        Http.open("POST", url);
        Http.withCredentials = false;
        Http.setRequestHeader("Content-Type", "application/json");
        Http.send(poiInfoJson);
        Http.onreadystatechange = (e) => {
            if (Http.readyState == 4 && Http.status == 200) { //if the operation is complete. 
                var response = Http.responseText
                if (response.length > 0) {
                    console.log("response from the server is recieved")
                    var poisInfo = JSON.parse(Http.responseText);
                    console.log(poisInfo);
                    if (poisInfo.length == 0) {
                        if (failureCallbackFunc) { failureCallbackFunc(); }
                    }
                    successCallbackFunc(poisInfo)
                } else {
                    failureCallbackFunc();
                }
            }
        }
    }

     // The function get the poi info for pois that waiting for approval
     global.communication.openEditPage = function (poiId, successCallbackFunc, failureCallbackFunc = undefined) {
        var url = communication.uriBeginning + '/editPoi';
        var params = "id=" + poiId;
        var params = {}
        communication.addTokensToObject(params)
        params = JSON.stringify(params);
        var http = new XMLHttpRequest();
        http.open("GET", url+"?"+params, true);
        http.onreadystatechange = function()
        {
            if(http.readyState == 4 && http.status == 200) {
                successCallbackFunc(http.responseText);
            }
        }
        http.send(params);
    }

    // login page
    global.communication.openSearchPage = function (successCallbackFunc, failureCallbackFunc = undefined) {
        var url = communication.uriBeginning + '/searchPage';
        var params = {}
        communication.addTokensToObject(params)
        params = JSON.stringify(params);
        var http = new XMLHttpRequest();
        http.open("GET", url, true);
        http.onreadystatechange = function()
        {
            if(http.readyState == 4 && http.status == 200) {
                successCallbackFunc(http.responseText);
            }
        }
        http.send(params);
    }

    
    global.communication.addTokensToObject = function (object) {
        query = {}
        object['PermissionToken'] = localStorage['PermissionToken'];
        object['permissionStatus'] = localStorage['permissionStatus'];
    }
    global.communication.addTokensToUrl = function (url) {
        let newUrl = new URL(url);
        newUrl.searchParams.append('PermissionToken', localStorage['PermissionToken'])
        newUrl.searchParams.append('permissionStatus', localStorage['permissionStatus'])
        return newUrl;
    }
    global.communication.createUrl = function (url) {
        let newUrl = new URL(url);
        return newUrl;
    }
    global.communication.openHomePage = function(){

        var newUrl = communication.addTokensToUrl(communication.uriBeginning + '/searchPoisPage')
        window.location.href = newUrl.href;
    }
    
    global.communication.openDataInPage = function openDataInPage(){
        var newUrl = communication.addTokensToUrl(communication.uriBeginning + '/dataInPage')
        window.location.href = newUrl.href;
    }
    
    global.communication.openAboutPage = function openAboutPage(){
        var newUrl = communication.createUrl(communication.uriBeginning + '/aboutUsPage')
        window.location.href = newUrl.href;
    }
    
    global.communication.openContactPage = function openContactPage(){
        var newUrl = communication.createUrl(communication.uriBeginning + '/contactPage')
        window.location.href = newUrl.href;
    }
    // default bounds
    function getDefaultBounds() {
        var relevantBounds = {}
        relevantBounds['southWest'] = { lat: 31.31610138349565, lng: 35.35400390625001 }
        relevantBounds['northEast'] = { lat: 31.83303, lng: 36.35400390625001 }
        return relevantBounds;
    }

}(window))