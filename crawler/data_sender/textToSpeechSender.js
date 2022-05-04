
var tokenGetter = require("./services/serverTokenGetter");
var XMLHttpRequest = require('xhr2');
// Imports the Google Cloud client library
// const client = new textToSpeech.TextToSpeechClient();
// var Speech = require('speak-tts') //if you use es5
let fs = require("fs");
// let wav = require("node-wav");
const gTTS = require('gtts');
var gtts = require('node-gtts')('en');
var path = require('path');

// const serverUrl = 'https://autotripguide.loca.lt';

const serverUrl = 'http://2a34-77-126-184-189.ngrok.io'


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
    const url = serverUrl + '/searchPois';
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
    return poisPromise;
}


async function textToVoice(text, language) {

    const chunks = [];
    return new Promise((resolve, reject) => {
        var stream = gtts.stream(text)
        stream.on('data', (chunk) => chunks.push(Buffer.from(chunk)));
        stream.on('error', (err) => reject(err));
        stream.on('end', () => resolve(Buffer.concat(chunks)));
    })
    
      
    //   const result = await streamToString(stream)

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
    const url = serverUrl +'/editPois';
    // const url = '/editPois';
    Http.open("POST", url);
    Http.withCredentials = false;
    Http.setRequestHeader("Content-Type", "application/json");
    Http.send(poiInfoJson);
    Http.onerror((e)=>console.log(e))

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
    return audioPromise;

}

async function handleAllPois() {
    var poisWithNoVoice = await getPoisWithNoVoice();

    for (var i =0; i < poisWithNoVoice.length; i++)
    {
        poi = poisWithNoVoice[i]
        if(poi._language == 'en') {
            console.log('handle : ' + poi._poiName)
            poiShortDesc = poi._shortDesc.replace(/ *\([^)]*\) */g, ""); //remove parenthesis
            poi._audio = await textToVoice(poi._shortDesc ,poi._language)
            poi._audio = new Uint8Array(poi._audio)
            console.log(poi._poiName + ' converted')

            var res = await updatePoiOnServer(poi);
            console.log(res)

        }

    }
    handleAllPois()
}

async function main() {
    console.log('start text to speech')
    await init();
    await handleAllPois();
    console.log('finished')
}
main();


addTokensToObject = function (object) {
    query = {}
    object['PermissionToken'] = globalTokenAndPermission['PermissionToken'];
    object['permissionStatus'] = globalTokenAndPermission['permissionStatus'];
}
