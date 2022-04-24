
var tokenGetter = require("./services/serverTokenGetter");
var XMLHttpRequest = require('xhr2');
// Imports the Google Cloud client library
// const client = new textToSpeech.TextToSpeechClient();
// var Speech = require('speak-tts') //if you use es5
let fs = require("fs");
// let wav = require("node-wav");
const gTTS = require('gtts');

// const serverUrl = 'https://autotripguide.loca.lt';

const serverUrl = 'https://autotripguide.loca.lt/'


//init
var globalTokenAndPermission = undefined


async function init() {
    globalTokenAndPermission = await tokenGetter.getToken('crawler@gmail.com', '1234', serverUrl)
}

async function getPoisWithNoVoice() {
    const Http = new XMLHttpRequest();

    var queryParams = {PermissionToken: globalTokenAndPermission.PermissionToken, permissionStatus: globalTokenAndPermission.permissionStatus,
    relevantBounds: {northEast: {lat: 32.0, lng: 36.0}, southWest: {lat: 32.0, lng: 36.0}} ,searchOutsideTheBounds:true}
    queryParams['poiSearchParams'] = {}
    queryParams['poiSearchParams']['_language'] = 'en'
    queryParams['poiSearchParams']['_audio'] = 'no audio'



    var queryParamsJson = JSON.stringify(queryParams);
    const url = serverUrl + 'searchPois';
    Http.open("POST", url);
    Http.withCredentials = false;
    Http.setRequestHeader("Content-Type", "application/json");
    // console.log(queryParamsJson)
    Http.send(queryParamsJson);

    const poisPromise = new Promise((resolve, reject) => {
        Http.onreadystatechange = (e) => {
            if(Http.readyState == 4 && Http.status == 553) { //if no permission
                communication.openLoginPage()
            } else if (Http.readyState == 4) { //if the operation is complete.
                var response = Http.responseText
                if (response.length > 0) {
                    //console.log("response from the server is recieved")
                    var poisInfo = JSON.parse(Http.responseText);
                    if(poisInfo.length == 0) {
                        console.log("not found");
                    } else {
                        // console.log(poisInfo);
                        resolve(poisInfo);
                    }
                } else {
                    console.log("not found");
                }
            } 
        }   
    });

    var pois = poisPromise;
    return pois;
}


async function textToVoice(text, language) {
    const audioPromise = new Promise((resolve, reject) => {
        var gtts = new gTTS(text, language);
        gtts.save(__dirname + '/Voic123.mp3', function (err, result){
            if(err) { reject(err); }
            console.log("Text to speech converted!");
            fs.readFile( __dirname + '/Voic123.mp3', function (err, data) {
                if (err) {
                    reject(err); 
                }
                var voiceData = new Uint8Array(data)
                resolve(voiceData);
            });
        });
    });
    return audioPromise;
}

    // The function send the poi info request to the server
async function updatePoiOnServer(poi) {
    poiArray = [poi] //thats what the server expected
    objectToSend = {}
    objectToSend['poisArray'] = poiArray;
    addTokensToObject(objectToSend);
    var poiInfoJson= JSON.stringify(objectToSend);
    const Http = new XMLHttpRequest();
    Http.onerror = function (e) {
        console.log(e);
    };
    const url = serverUrl +'editPois';
    Http.open("POST", url);
    Http.withCredentials = false;
    Http.setRequestHeader("Content-Type", "application/json");
    Http.send(poiInfoJson);

    const audioPromise = new Promise((resolve, reject) => {
        Http.onreadystatechange = (e) => {
            if (Http.readyState == 4 && Http.status == 200) {
                resolve("finished to upload poi");
                console.log("finished to upload poi: " + poi._poiName)
                var response = Http.responseText;
                if (response.length > 0) {
                    //console.log("response from the server is recieved")
                    console.log('Add voice for ' + poi._poiName);
                    //var jsonResponse = JSON.parse(Http.responseText);
                    //console.log(jsonResponse);
                }
            } 
        }
    });
    return await audioPromise;

}

async function handleAllPois() {
    var poisWithNoVoice = await getPoisWithNoVoice();
    poisWithNoVoice.forEach(async(poi) => {
        if(poi._language == 'en') {
            // console.log(poi._poiName + " ---------------  will convert")
            //poi._audio = await textToVoice(poi._shortDesc ,poi._language)
            poi._audio = await textToVoice('This is a Demo' ,poi._language)
            var res = await updatePoiOnServer(poi);
            console.log('q')
        }
    
    });
    handleAllPois()
}


async function main() {
    await init();
    handleAllPois();

}
main();






    // {
    //     "PermissionToken": "kjsklfjadlkgheesd347ejdske3jd4534654864ekfjdkf4359fldjfkdjgdgm",
    //     "permissionStatus": "crawler",
    //     "poiParameter": "_poiName",
    //     "poiInfo": 
    //         {
    //         "poiParameter": "masada"
    //         },
    //     "relevantBounds" :{"northEast": {"lat": 32.0, "lng": 36.0}, "southWest": {"lat": 32.0, "lng": 36.0}},
    //     "searchOutsideTheBounds" :true
    // }

addTokensToObject = function (object) {
    query = {}
    object['PermissionToken'] = globalTokenAndPermission['PermissionToken'];
    object['permissionStatus'] = globalTokenAndPermission['permissionStatus'];
}
