
var gis = require('g-i-s');
var tokenGetter = require("../../services/serverTokenGetter");
var XMLHttpRequest = require('xhr2');
let fs = require("fs");
const gTTS = require('gtts');
var gtts = require('node-gtts')('en');
var path = require('path');

const serverUrl = 'https://autotripguide1.loca.lt';

// const serverUrl = 'http://localhost:5500'


//init
var globalTokenAndPermission = undefined


async function init() {
    globalTokenAndPermission = await tokenGetter.getToken('crawler@gmail.com', '1234', serverUrl)
}

async function getPoisWithNoPic() {
    const Http = new XMLHttpRequest();

    var queryParams = {PermissionToken: globalTokenAndPermission.PermissionToken, permissionStatus: globalTokenAndPermission.permissionStatus,
    relevantBounds: {northEast: {lat: 32.0, lng: 36.0}, southWest: {lat: 32.0, lng: 36.0}} ,searchOutsideTheBounds:true}
    queryParams['poiSearchParams'] = {}
    queryParams['poiSearchParams']['_language'] = 'en'
    queryParams['poiSearchParams']['_pic'] = 'no pic'



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


async function nameToPicUrl(name) {
    return new Promise((resolve, reject) => {
        gis(name, logResults);
        function logResults(error, results) {
            if (error) {
                reject(error)
            } else {
                resolve(results);
            }
        }
    })

}

// The function send the poi info request to the server
async function updatePoiOnServer(poi) {
    objectToSend = {}
    // objectToSend['replaceObj'] = {_pic: poi._pic};
    objectToSend['replaceObj'] = {_pic: '123456'};

    objectToSend['id'] = poi._id

    addTokensToObject(objectToSend);
    var poiInfoJson= JSON.stringify(objectToSend);
    const Http = new XMLHttpRequest();
    Http.onerror = function (e) {
        console.log(e);
    };
    const url = serverUrl +'/editPoiSpecific';
    // const url = '/editPois';
    Http.open("POST", url);
    Http.withCredentials = false;
    Http.setRequestHeader("Content-Type", "application/json");


    const picPromise = new Promise((resolve, reject) => {

        Http.onerror = function(error){
            console.error( error );
            reject(error)
        }

        Http.onreadystatechange = (e) => {
            if (Http.readyState == 4 && Http.status == 200) {
                resolve("finished to upload poi");
                console.log("finished to upload poi: " + poi._poiName)
                var response = Http.responseText;
                if (response.length > 0) {
                    //console.log("response from the server is recieved")
                    console.log('Add pic for ' + poi._poiName);
                    //var jsonResponse = JSON.parse(Http.responseText);
                    //console.log(jsonResponse);
                }
            } 
        }
    });
    Http.send(poiInfoJson);

    return audioPromise;

}

async function handleAllPois() {
    var poisWithNoPic = await getPoisWithNoPic();

    for (var i =0; i < poisWithNoPic.length; i++)
    {
        poi = poisWithNoPic[i]
        console.log('handle : ' + poi._poiName)
        try {
            pictures = await nameToPicUrl(poi._poiName)
            if (pictures.length >= 1) {
                poi._pic = pictures[0].url
                console.log(poi._poiName + ' add pic ')

                var res = await updatePoiOnServer(poi);
                console.log(res)
            }

        } catch {
            console.log('error in poi ' + poi._poiName)

        }
        

    }
    handleAllPois()
}

async function main() {
    sleep(100000000) // this fixes the bug that js exit when it waits for HTTP request

    console.log('start pic adder')
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

function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}