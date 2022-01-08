
(function (global) {
    const uriBeginningTemp = 'http://127.0.0.1:5500';
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
        var quaryParamsJson = JSON.stringify(quaryParams);
        const Http = new XMLHttpRequest();
        const url = communication.uriBeginning + '/searchPois';
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
        var poiInfoJson = JSON.stringify(poiInfo);
        const Http = new XMLHttpRequest();
        const url = communication.uriBeginning + '/searchPoiAudioById';
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

    // default bounds
    function getDefaultBounds() {
        var relevantBounds = {}
        relevantBounds['southWest'] = { lat: 31.31610138349565, lng: 35.35400390625001 }
        relevantBounds['northEast'] = { lat: 31.83303, lng: 36.35400390625001 }
        return relevantBounds;
    }
}(window))