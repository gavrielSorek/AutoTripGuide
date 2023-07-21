
var tokenGetter = require("./serverTokenGetter");
var XMLHttpRequest = require('xhr2');

module.exports = { sendPoisToServer, getServerUrl };

// const serverUrl = 'https://autotripguide.loca.lt/';
const serverUrl = 'https://getjourn.ai:5500';

//const serverUrl = 'http://localhost:5500';
// The function send the poi info request to the server
async function sendPoisToServer(pois, tokenAndPermission = undefined) {
    const Http = new XMLHttpRequest();
    const url = serverUrl + '/createPois';
    Http.open("POST", url);
    Http.withCredentials = false;
    Http.setRequestHeader("Content-Type", "application/json");
    var objectToSend = {}
    if (!tokenAndPermission) {
        var tokenAndPermission = await tokenGetter.getToken('crawler@gmail.com', '1234', serverUrl)
    }
    objectToSend["poisArray"] = pois
    objectToSend["permissionStatus"] = tokenAndPermission.permissionStatus
    objectToSend["PermissionToken"] = tokenAndPermission.PermissionToken

    var poisInfoJson = JSON.stringify(objectToSend);
    Http.send(poisInfoJson);
    Http.onreadystatechange = (e) => {  
        var response = Http.responseText;
        if (Http.readyState == XMLHttpRequest.DONE && Http.status == 200) {
            // successful
            console.log("all the data was sent");
        }
        if (Http.readyState == XMLHttpRequest.DONE && Http.status == 420) {
            // successful
            console.log("some of the pois already exist");
        }
    }
}
function getServerUrl() {
    return serverUrl;
}