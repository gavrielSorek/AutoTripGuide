/* -------------------------- insert function -------------------- */
//variables definition
var poiName = document.getElementById("PoiName");
var longitude = document.getElementById("longitude");
var latitude = document.getElementById("latitude");
var shortDesc = document.getElementById("shortDesc");
var language = document.getElementById("language");
var audio = document.getElementById("audio");
var source = document.getElementById("source");

//add events
if(document.getElementById("upload")) {
    document.getElementById("upload").addEventListener("change", handleFiles, false);
}

// The function delete the data from the page
function deleteEverything() {
    localStorage.clear();
    location.reload();
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
            sendPoiInfoToServer();
            Swal.fire("Created!", "Your request to create new poi has been sent.", "success");
            setTimeout(deleteEverything, 1000);
        } else {
            Swal.fire("Cancelled", "Your request to create new poi has not been sent", "error");
        }
    });
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
    var audioFile = document.getElementById("upload").files[0]
    var audioData = undefined
    if (audioFile) {
        audioData = await readFileAsData(document.getElementById("upload").files[0])
    }
    var poiInfo = {
        _poiName : poiName.value,
        _longitude : longitude.value,
        _latitude : latitude.value,
        _source : source.value,
        _language : language.value,
        _audio : audioData,
        _shortDesc : shortDesc.value,
        _Contributor : "Contributor name ??",
        _CreatedDate : getTodayDate(),
        _ApprovedBy : "ApprovedBy ??",
        _UpdatedBy : "UpdatedBy ??",
        _LastUpdatedDate : getTodayDate()
    }
    var poiInfoJson= JSON.stringify(poiInfo);
    const Http = new XMLHttpRequest();
    const url='http://localhost:5500/createPoi';
    Http.open("POST", url);
    Http.withCredentials = false;
    Http.setRequestHeader("Content-Type", "application/json");
    Http.send(poiInfoJson);
    Http.onreadystatechange = (e) => {  
        var response = Http.responseText;
        if(response.length > 0) {
            console.log("response from the server is recieved")
            var jsonResponse = JSON.parse(Http.responseText);
            console.log(jsonResponse);
        }
    }
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

/* -------------------------- audio function -------------------- */

//when audio file added load audio to html
function handleFiles(event) {
    var files = event.target.files;
    $("#src").attr("src", URL.createObjectURL(files[0]));
    document.getElementById("audio").load();
}

// let data = await readFileAsData(document.getElementById("upload").files[0])
//read data from file
async function readFileAsData(file) {
    let result = await new Promise((resolve) => {
        let fileReader = new FileReader();
        fileReader.onload = (event) => resolve(event.currentTarget.result);
        fileReader.readAsText(file);
    });
    return result;
}



