/* -------------------------- insert function -------------------- */
// const db = require("./serverCommunication");
//variables definition
var poiName = document.getElementById("PoiName");
var longitude = document.getElementById("longitude");
var latitude = document.getElementById("latitude");
var shortDesc = document.getElementById("shortDesc");
var language = document.getElementById("language");
var audio = document.getElementById("audio");
var source = document.getElementById("source");
var select = document.getElementById("languages");
var recordButton = document.getElementById("record_button");
var deleteCheckbox = document.getElementById('deletePoi')


//init
var globalIsAudioReady = true;
var globalAudioData = undefined;
var globalContributor = undefined;
var globalApprover = undefined;

document.getElementById("submit_button").addEventListener("click", submitPoi);
recordButton.addEventListener("mousedown", record);
recordButton.addEventListener("mouseup", stopRecord);


// initRecord()
//add events
if (document.getElementById("upload")) {
    document.getElementById("upload").addEventListener("change", handleFiles, false);
}

// The function delete the data from the page
function deleteEverything() {
    localStorage.clear();
    location.reload();
}

// The function verifies with the client his request
function submitPoi() {
    Swal.fire({
        title: "Are you sure?",
        text: "You won't be able to revert this!",
        icon: "warning",
        showCancelButton: true,
        confirmButtonColor: "#3085d6",
        cancelButtonColor: "#d33",
        confirmButtonText: "Yes, edit it!",
    }).then((result) => {
        if (result.value) {
            sendPoiInfoToServer();
        } else {
            Swal.fire("Cancelled", "Your request to edit poi has not been sent", "error");
        }
    });
}

// The function find the poi position (lat, lng)
function findPoiPosition() {
    var poiInfo = {
        _poiName: poiName.value,
        _language: select.options[select.selectedIndex].value,
    }
    var poiInfoJson = JSON.stringify(poiInfo);
    const Http = new XMLHttpRequest();
    const url = '/findPoiPosition';
    Http.open("POST", url);
    Http.withCredentials = false;
    Http.setRequestHeader("Content-Type", "application/json");
    Http.send(poiInfoJson);
    Http.onreadystatechange = (e) => {
        if (Http.readyState == 4) { //if the operation is complete. 
            var response = Http.responseText
            if (response.length > 0) {
                console.log("response from the server is recieved")
                var jsonResponse = JSON.parse(Http.responseText);
                console.log(jsonResponse);
                lat = jsonResponse.latitude
                lng = jsonResponse.longitude
                latitude.value = lat
                longitude.value = lng
                res = addMarkerOnMap(lat, lng, poiName.value)
                if (res) {
                    map.panTo(new L.LatLng(lat, lng));
                } else {
                    messages.showNotFoundMessage()
                }
            } else {
                messages.showNotFoundMessage()
            }
        }
    }
}

// // The function show a not found message when the user ask for a poi that not exist
// function showNotFoundMessage() {
//     Swal.fire({
//         icon: 'error',
//         title: 'Oops...',
//         text: 'The POI according to your request is not found',
//       }).then((result) => {
//         setTimeout(deleteEverything, 500);
//       });
// }

// The function returns the date of today
function getTodayDate() {
    var today = new Date();
    var dd = String(today.getDate()).padStart(2, '0');
    var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
    var yyyy = today.getFullYear();

    today = dd + '/' + mm + '/' + yyyy;
    return today
}

// The function send the poi info request to the server
async function sendPoiInfoToServer() {
    var audioData = "no audio"
    if (globalAudioData) {
        audioData = globalAudioData
    }
    var poiInfo = {
        _id: poiName.name,
        _poiName: poiName.value,
        _longitude: longitude.value,
        _latitude: latitude.value,
        _source: source.value,
        _language: select.options[select.selectedIndex].value,
        _audio: audioData,
        _shortDesc: shortDesc.value,
        _Contributor: getContributor(),
        _CreatedDate: getTodayDate(),
        _ApprovedBy: getApprover(),
        _UpdatedBy: localStorage['userName'],
        _LastUpdatedDate: getTodayDate()
    }
    if (deleteCheckbox.checked) { // if user wants to delete the poi
        poiInfo['_delete'] = 'true'
    }
    poiArray = [poiInfo] //thats what the server expected
    objectToSend = {}
    objectToSend['poisArray'] = poiArray;
    communication.addTokensToObject(objectToSend);
    var poiInfoJson= JSON.stringify(objectToSend);
    const Http = new XMLHttpRequest();
    Http.onerror = function (e) {
        messages.showServerNotAccissableMessage();
    };
    const url = '/editPois';
    Http.open("POST", url);
    Http.withCredentials = false;
    Http.setRequestHeader("Content-Type", "application/json");
    Http.send(poiInfoJson);
    messages.showLoadingMessage ();
    Http.onreadystatechange = (e) => {
        if (Http.readyState == 4 && Http.status == 200) {
            dataUploadingFinished();
            var response = Http.responseText;
            if (response.length > 0) {
                console.log("response from the server is recieved")
                var jsonResponse = JSON.parse(Http.responseText);
                console.log(jsonResponse);
            }
        } else if(Http.readyState == 4 && Http.status == 553) { //if no permission
            communication.openLoginPage()
        }
    }
}

function getContributor(){
    if (globalContributor) {
        return globalContributor;
    }
    return "Contributor name ??";
}
function getApprover() {
    if (globalApprover) {
        return globalApprover;
    }
    return "ApprovedBy ??";
}

/* -------------------------- map function -------------------- */

var map = L.map('map').setView([31.83303, 34.863443], 10);

var tiles = L.tileLayer('https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token={accessToken}', {
    maxZoom: 18,
    id: 'mapbox/streets-v11',
    tileSize: 512,
    accessToken: 'pk.eyJ1Ijoic2FwaXJkYXZpZCIsImEiOiJja3dycGEwMWIwNXg4MnltaDFmcXg2eXJsIn0.SrGOND6EW7ihfxfbbWp1NA',
    zoomOffset: -1
}).addTo(map);

var popup = L.popup();

// The function show message with the lat,lng on the map according the click location
function onMapClick(e) {
    popup
        .setLatLng(e.latlng)
        .setContent("You clicked the map at " + e.latlng.toString())
        .openOn(map);
    updateLatLng(e);
}

function updateLatLng(e) {
    var LatLng = popup.getLatLng();
    latitude.value = LatLng.lat
    longitude.value = LatLng.lng
}

map.on('click', onMapClick);

globalMarker = null
// The function add a mraker on the map
function addMarkerOnMap(lat, lng, name) {
    //check if old marker exist, if exist - remove it
    if (globalMarker) {
        map.removeLayer(globalMarker)
    }
    if (isNaN(lat) || isNaN(lng) || lat == null || lng == null) {
        console.log("lat or lng is NaN - for POI: " + name)
        return false
    }
    console.log("add marker to map")
    var marker = L.marker([lat, lng]);
    marker.bindPopup("<b>Welcome to </b><br>" + name);
    globalMarker = marker
    map.addLayer(marker);
    map.panTo(new L.LatLng(lat, lng));
    return true
}

/* -------------------------- audio function -------------------- */

//when audio file added load audio to html
async function handleFiles(event) {
    var files = event.target.files;
    $("#src").attr("src", URL.createObjectURL(files[0]));
    document.getElementById("audio").load();
    globalIsAudioReady = false;
    globalAudioData = await readFileAsData(document.getElementById("upload").files[0])
    globalIsAudioReady = true;
}

// let data = await readFileAsData(document.getElementById("upload").files[0])
//read data from file
async function readFileAsData(file) {
    let result = await new Promise((resolve) => {
        let fileReader = new FileReader();
        fileReader.onload = (event) => resolve(event.currentTarget.result);
        fileReader.readAsArrayBuffer(file);
    });
    bytesRes = new Int8Array(result);
    return bytesRes;
}


var mediaRecorder = undefined
var audioChunks = [];
//record 
async function initRecord() {
    await navigator.mediaDevices.getUserMedia({ audio: true })
        .then(stream => {
            mediaRecorder = new MediaRecorder(stream);
            //store data
            mediaRecorder.addEventListener("dataavailable", event => {
                audioChunks.push(event.data);
            });
            mediaRecorder.addEventListener("stop", () => {
                globalIsAudioReady = false;
                const audioBlob = new Blob(audioChunks);
                // load audio that has been collected
                audio.src = window.URL.createObjectURL(audioBlob)
                audio.load();
                //assign the audio to global audio
                blobToArrayBuffer(audioBlob).then((buff) => {
                    globalAudioData = new Uint8Array(buff)
                    globalIsAudioReady = true;
                })

            });
        });
}

async function record() {
    if (!mediaRecorder) {
        await initRecord();
    }
    audioChunks = [];
    mediaRecorder.start();
    recordButton.style = "background-color: cyan;"
    console.log("media recorder started")
}

function stopRecord() {
    if (mediaRecorder) {
        mediaRecorder.stop();
    }
    recordButton.style = "background-color: cornsilk;"
}



async function blobToArrayBuffer(blob) {
    if ('arrayBuffer' in blob) return await blob.arrayBuffer();
    return new Promise((resolve, reject) => {
        const reader = new FileReader();
        reader.onload = () => resolve(reader.result);
        reader.onerror = () => reject;
        reader.readAsArrayBuffer(blob);
    });
}

function dataDownloadingFinished() {
    messages.closeMessages()
}
function dataUploadingFinished() {
    messages.editPoiSeccess()
    setTimeout(communication.openHomePage, 1000);
}
//TODO ADD CONDITION TO SEND POI IF AND ONLY IF AUDIO IS READY
function setPoiDataOnPage(poi) {
    messages.closeMessages(); //close loading data
    if (!poi) {
        console.log('error in setPoiDataOnPage')
    }
    // console.log(poi)
    if (poi[0]) {
        globalContributor = poi[0]._Contributor
        globalApprover = poi[0]._ApprovedBy
        console.log(poi[0])
        document.getElementById("PoiName").defaultValue = poi[0]._poiName;
        document.getElementById("latitude").defaultValue = poi[0]._latitude;
        document.getElementById("longitude").defaultValue = poi[0]._longitude;
        document.getElementById("source").defaultValue = poi[0]._source;
        document.getElementById("shortDesc").defaultValue = poi[0]._shortDesc;
        document.getElementById('languages').value = poi[0]._language;
        
        addMarkerOnMap(poi[0]._latitude, poi[0]._longitude, poi[0]._poiName)

        if (poi[0]._audio != "no audio") {
            communication.getAudioById(poiId, setAudio, undefined)
        } else {
            dataDownloadingFinished()
        }
    }

}
function faiedToGetData() {
    messages.showServerNotAccissableMessage();

}
function setAudio(audioData) {
    console.log("inside set audio")
    console.log(audioData.data)
    var uint8Array1 = new Uint8Array(audioData.data)
    var arrayBuffer = uint8Array1.buffer;
    console.log(arrayBuffer)
    audio.src = window.URL.createObjectURL(new Blob([uint8Array1], { type: 'audio/ogg' }))
    audio.load();
    dataDownloadingFinished()

}
function startEditLogic() {
    messages.showLoadingMessage();
    poiId = document.getElementById("PoiName").name
    communication.getPoisInfo('_id', poiId, undefined, true, setPoiDataOnPage, faiedToGetData);
    messages.showLoadingMessage();

    console.log(communication)

}

startEditLogic();



