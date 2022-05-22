/* -------------------------- insert function -------------------- */

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
var categoriesDiv = document.getElementById('categories');

//init
var globalIsAudioReady = true;
var globalAudioData = undefined;
var globalCategories = [];
document.getElementById("submit_button").addEventListener("click",submitPoi);
recordButton.addEventListener("mousedown", record);
recordButton.addEventListener("mouseup", stopRecord);
createCategoriesSection();

// initRecord()
//add events
if(document.getElementById("upload")) {
    document.getElementById("upload").addEventListener("change", handleFiles, false);
}


// The function verifies with the client his request
function submitPoi(){
        Swal.fire({
        title: "Are you sure?",
        text: "You won't be able to revert this!",
        icon: "warning",
        showCancelButton: true,
        confirmButtonColor: "#3085d6",
        cancelButtonColor: "#d33",
        confirmButtonText: "Yes, create it!",
    }).then((result) => {
        if (result.value) {
            Swal.close()
            sendPoiInfoToServer();
        } else {
            Swal.fire("Cancelled", "Your request to create new poi has not been sent", "error");
            // Swal.close()
        }
    });
}

// The function find the poi position (lat, lng)
function findPoiPosition() {
    var poiInfo = {
        _poiName : poiName.value,
        _language : select.options[select.selectedIndex].value,
    }
    var poiInfoJson= JSON.stringify(poiInfo);
    const Http = new XMLHttpRequest();
    const url=communication.uriBeginning + '/findPoiPosition';
    Http.open("POST", url);
    Http.withCredentials = false;
    Http.setRequestHeader("Content-Type", "application/json");
    Http.send(poiInfoJson);
    Http.onreadystatechange = (e) => {  
        if (Http.readyState == 4) { //if the operation is completed. 
            var response = Http.responseText
            if(response.length > 0) {
                console.log("response from the server is recieved")
                var jsonResponse = JSON.parse(Http.responseText);
                console.log(jsonResponse);
                lat = jsonResponse.latitude
                lng = jsonResponse.longitude
                latitude.value = lat
                longitude.value = lng
                res = addMarkerOnMap(lat,lng, poiName.value)
                if (res){
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

// The function returns the date of today
function getTodayDate(){
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
        _poiName : poiName.value,
        _longitude : parseFloat(longitude.value),
        _latitude : parseFloat(latitude.value),
        _source : source.value,
        _language : select.options[select.selectedIndex].value,
        _audio : audioData,
        _shortDesc : shortDesc.value,
        _Contributor : localStorage['userName'],
        _CreatedDate : getTodayDate(),
        _ApprovedBy : "ApprovedBy ??",
        _UpdatedBy : localStorage['userName'],
        _LastUpdatedDate : getTodayDate(),
        _Categories : getCheckedCategories()
    }
    poiArray = [poiInfo] //thats what the server expected
    objectToSend = {}
    objectToSend['poisArray'] = poiArray;
    communication.addTokensToObject(objectToSend);

    var poiInfoJson= JSON.stringify(objectToSend);
    const Http = new XMLHttpRequest();
    
    const url= '/createPois';
    Http.open("POST", url, true);
    Http.onerror = function(e){
        messages.showServerNotAccissableMessage();
    };
    Http.withCredentials = false;
    Http.setRequestHeader("Content-Type", "application/json");
    Http.send(poiInfoJson);
    messages.showLoadingMessage();
    Http.onreadystatechange = (e) => {  
        if (Http.readyState == 4) {
            if (Http.status == 200) {
                dataUploadingFinished();
                var response = Http.responseText;
                if(response.length > 0) {
                    console.log("response from the server is recieved")
                    console.log(jsonResponse)
                    var jsonResponse = JSON.parse(Http.responseText);
                    console.log(jsonResponse);
                }
            } else if (Http.status == 420) {
                poiAlreadyExist();
            }
        }
    }
    
}

function poiAlreadyExist() {
    messages.createPoiFailedAlreadyExist()
    // setTimeout(messages.deleteEverything, 1500);
}
function dataUploadingFinished() {
    messages.createPoiSeccess()
    setTimeout(messages.deleteEverything, 1500);
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
    if(globalMarker) {
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
          blobToArrayBuffer(audioBlob).then((buff)=>{globalAudioData = new Uint8Array(buff)
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
    if(mediaRecorder) {
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

function createCategoriesSection(){
    var lang = {
        language : "eng", //TODO::ADAPT LANGUAGE TO CATEGORIES LANGUAGE
    }
    var langJson= JSON.stringify(lang);
    const Http = new XMLHttpRequest();
    const url=communication.uriBeginning + 'getCategories';
    Http.open("POST", url);
    Http.withCredentials = false;
    Http.setRequestHeader("Content-Type", "application/json");
    Http.send(langJson);
    Http.onreadystatechange = (e) => {  
        if (Http.readyState == 4) { //if the operation is completed. 
            var response = Http.responseText
            if(response.length > 0) {
                console.log("response from the server is recieved")
                var jsonResponse = JSON.parse(Http.responseText);
                // console.log(jsonResponse);
                // console.log(Object.keys(jsonResponse));
                globalCategories = Object.keys(jsonResponse);
                addCategories();
            } else {
                messages.showNotFoundMessage()
            }
        }
    }
}

function addCategories(){
    console.log("globalCategories.length: " + globalCategories.length)
    for(var i=0, n=globalCategories.length;i<n;i++) {
        var checkbox = document.createElement('input');
        checkbox.type = "checkbox";
        checkbox.name = "category";
        checkbox.id = i;
        checkbox.onchange=function () {
            console.log("test clicked");
        };
        var label = document.createElement('lable');
        label.setAttribute("for",i);
        label.setAttribute("class","md-chip md-chip-clickable md-chip-hover");
        label.appendChild(document.createTextNode(" " + globalCategories[i] + " "));
        label.style.color = "white";
        categoriesDiv.appendChild(checkbox);
        categoriesDiv.appendChild(label);
    }
}

function toggle(source) {
    checkboxes = document.getElementsByName('category');
    for(var i=0, n=checkboxes.length;i<n;i++) {
      checkboxes[i].checked = source.checked;
    }
}

function getCheckedCategories(){
    checkedCategories = [];
    checkboxes = document.getElementsByName('category');
    for(var i=0, n=checkboxes.length;i<n;i++) {
        if(checkboxes[i].checked) {
            checkedCategories.push(globalCategories[i])
        }
    }
    return checkedCategories;
}


//TODO ADD CONDITION TO SEND POI IF AND ONLY IF AUDIO IS READY