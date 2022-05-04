
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

    var pois = poisPromise;
    return pois;
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
            // console.log(poi._poiName + " ---------------  will convert")
            poi._audio = await textToVoice(poi._shortDesc ,poi._language)
            poi._audio = new Uint8Array(poi._audio)
            //poi._audio = await textToVoice('This is a Demo' ,poi._language)
            var res = await updatePoiOnServer(poi);
            console.log(res)
        }

    }
    // poisWithNoVoice.forEach(async(poi) => {
    //     if(poi._language == 'en') {
    //         // console.log(poi._poiName + " ---------------  will convert")
    //         poi._audio = await textToVoice(poi._shortDesc ,poi._language)
    //         //poi._audio = await textToVoice('This is a Demo' ,poi._language)
    //         var res = await updatePoiOnServer(poi);
    //         console.log(res)
    //     }
    // });
    handleAllPois()
}

async function main() {
    await init();
    handleAllPois();
}
main();


// async function try1() {
//     var i = 0
//     while (i < 1){
//         textToVoice('The cliff of Masada is, geologically speaking, a horst.[7] As the plateau abruptly ends in cliffs steeply falling about 400 m (1,300 ft) to the east and about 90 m (300 ft) to the west, the natural approaches to the fortress are very difficult to navigate. The top of the mesa-like plateau is flat and rhomboid-shaped, about 550 m (1,800 ft) by 270 m (890 ft). Herod built a 4 m (13 ft) high casemate wall around the plateau totalling 1,300 m (4,300 ft) in length, reinforced by many towers. The fortress contained storehouses, barracks, an armory, a palace, and cisterns that were refilled by rainwater. Three narrow, winding paths led from below up to fortified gates.[citation needed]', 'en')
//         .then((data)=>{console.log(data)})
//         i++;
//         console.log(i)
//     }

// }
// try1()
// textToVoice('The cliff of Masada is, geologically speaking, a horst.[7] As the plateau abruptly ends in cliffs steeply falling about 400 m (1,300 ft) to the east and about 90 m (300 ft) to the west, the natural approaches to the fortress are very difficult to navigate. The top of the mesa-like plateau is flat and rhomboid-shaped, about 550 m (1,800 ft) by 270 m (890 ft). Herod built a 4 m (13 ft) high casemate wall around the plateau totalling 1,300 m (4,300 ft) in length, reinforced by many towers. The fortress contained storehouses, barracks, an armory, a palace, and cisterns that were refilled by rainwater. Three narrow, winding paths led from below up to fortified gates.[citation needed]', 'en')






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
