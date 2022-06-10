
(function (global) {
    const uriBeginningTemp = 'https://autotripguide.loca.lt/';
    global.communication = {}
    global.communication.uriBeginning = uriBeginningTemp

    // This function get the poi info according name
    global.communication.getPoisInfo = function (poiParameter, valueOfParameter, relevantBounds = undefined, searchOutsideTheBounds, successCallbackFunc, failureCallbackFunc = undefined) {
        if (!relevantBounds) {
            relevantBounds = getDefaultBounds();
        }
        // var poiInfo = {
        //     poiParameter: valueOfParameter
        // }
        var quaryParams = {}
        quaryParams['poiSearchParams'] = {}
        quaryParams['poiSearchParams'][poiParameter] = valueOfParameter;
        // quaryParams['poiParameter'] = poiParameter
        quaryParams['relevantBounds'] = relevantBounds
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
            } else if(Http.readyState == 4 && Http.status == 553) {
                communication.openLoginPage()
            }
        }
    }

    // The function get the poi info for pois that waiting for approval
    global.communication.getAudioById = function (id, successCallbackFunc, failureCallbackFunc = undefined) {
        poiInfo = {_id: id}

        communication.addTokensToObject(poiInfo)
        var poiInfoJson = JSON.stringify(poiInfo);
        const Http = new XMLHttpRequest();
        const url = 'searchPoiAudioById';
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
            } else if(Http.readyState == 4 && Http.status == 553) { //if no permission
                communication.openLoginPage()
            }
        }
    }

    // The function edit poi
    global.communication.editPoi = function(poi, successCallbackFunc = undefined, failureCallbackFunc = undefined) {
            poiArray = [poi] //thats what the server expected
            objectToSend = {}
            objectToSend['poisArray'] = poiArray;
            communication.addTokensToObject(objectToSend);
            var poiInfoJson= JSON.stringify(objectToSend);
            const Http = new XMLHttpRequest();
            Http.onerror = function (e) {
                if (failureCallbackFunc)
                    failureCallbackFunc()
            };
            const url = '/editPois';
            Http.open("POST", url);
            Http.withCredentials = false;
            Http.setRequestHeader("Content-Type", "application/json");
            Http.send(poiInfoJson);
            messages.showLoadingMessage ();
            Http.onreadystatechange = (e) => {
                if (Http.readyState == 4 && Http.status == 200) {
                    messages.closeMessages()
                    var response = Http.responseText;
                    if (response.length > 0) {
                        console.log("response from the server is recieved")
                        var jsonResponse = JSON.parse(Http.responseText);
                        console.log(jsonResponse);
                        if (successCallbackFunc) {
                            successCallbackFunc()
                        }
                    }
                } else if(Http.readyState == 4 && Http.status == 553) { //if no permission
                    communication.openLoginPage()
            }
        }
    }

     // The function edit poi
     global.communication.approvePoi = function(id, apprverName, successCallbackFunc = undefined, failureCallbackFunc = undefined) {
        objectToSend = {}
        objectToSend['_ApprovedBy'] = apprverName;
        objectToSend['_id'] = id;
        communication.addTokensToObject(objectToSend);
        var poiInfoJson= JSON.stringify(objectToSend);
        const Http = new XMLHttpRequest();
        Http.onerror = function (e) {
            if (failureCallbackFunc)
                failureCallbackFunc()
        };
        const url = '/approvePoi';
        Http.open("POST", url);
        Http.withCredentials = false;
        Http.setRequestHeader("Content-Type", "application/json");
        Http.send(poiInfoJson);
        messages.showLoadingMessage ();
        Http.onreadystatechange = (e) => {
            if (Http.readyState == 4 && Http.status == 200) {
                messages.closeMessages()
                if (successCallbackFunc) {
                    successCallbackFunc()
                }
            } else if(Http.readyState == 4 && Http.status == 553) { //if no permission
                communication.openLoginPage()
        }
    }
}

     // The function get the poi info for pois that waiting for approval
     global.communication.openEditPage = function (poiId) { //TODO need to fix
        basicUrl = communication.uriBeginning + 'editPoi';
        var url = communication.addTokensToUrl(basicUrl)
        url.searchParams.append('id', poiId)
        location.href = url.href;
    }

    // login page
    global.communication.openSearchPage = function () { //TODO need to fix
        var newUrl = communication.addTokensToUrl(communication.uriBeginning + 'searchPoisPage')
        window.location.href = newUrl.href;
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
    global.communication.openLoginPage = function(){

        var newUrl = communication.addTokensToUrl(communication.uriBeginning)
        window.location.href = newUrl.href;
    }
    global.communication.openHomePage = function(){

        var newUrl = communication.addTokensToUrl(communication.uriBeginning + 'searchPoisPage')
        window.location.href = newUrl.href;
    }
    
    global.communication.openDataInPage = function openDataInPage(){
        var newUrl = communication.addTokensToUrl(communication.uriBeginning + 'dataInPage')
        window.location.href = newUrl.href;
    }
    
    global.communication.openAboutPage = function openAboutPage(){
        var newUrl = communication.createUrl(communication.uriBeginning + 'aboutUsPage')
        window.location.href = newUrl.href;
    }
    
    global.communication.openContactPage = function openContactPage(){
        var newUrl = communication.createUrl(communication.uriBeginning + 'contactPage')
        window.location.href = newUrl.href;
    }
    global.communication.loginPage = function openLoginPage(){
        window.localStorage.clear();
        var newUrl = communication.createUrl(communication.uriBeginning)
        window.location.href = newUrl.href;
    }
    global.communication.permissionsManagement = function openPermissionManagementPage(){
        var newUrl = communication.addTokensToUrl(communication.uriBeginning + 'permissionManagementPage')
        window.location.href = newUrl.href;
    }
    
    // default bounds
    function getDefaultBounds() {
        var relevantBounds = {}
        relevantBounds['southWest'] = { lat: 31.31610138349565, lng: 35.35400390625001 }
        relevantBounds['northEast'] = { lat: 31.83303, lng: 36.35400390625001 }
        return relevantBounds;
    }




    /**************** messages for communication purposes ****************/

    // The function show a Loading message.
    if (!global.messages) {global.messages = {}}
    global.messages.showLoadingMessage = function () {
        Swal.fire({
            title: 'Please Wait !',
            html: 'data uploading',
            allowOutsideClick: false,
            onBeforeOpen: () => {
                Swal.showLoading()
            },
        });
    }
    // close messages
    global.messages.closeMessages = function () {
        swal.close()
    }

}(window))