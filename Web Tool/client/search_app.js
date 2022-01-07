/* -------------------------- search function -------------------- */

//variables definition
var resultArea = $("#results");
var searchBar = $("#searchBar");
var searchButton = $(".glyphicon-search");

//map features
var currentMapBounds = undefined;
var lastMapZoom = undefined;
var lastMapCenter = undefined

//user query/ last function
var lastUserQuery = undefined
var lastParameterSearched = undefined
var isUserTrigeredLastFunction = false

//init
globalMarker = undefined
lastShownPoi = undefined
var map = L.map('map').setView([31.83303, 34.863443], 10);
var redMarkerGroup = L.featureGroup();
var markerSet = new Set() 
var greenMarkerGroup = L.featureGroup();
const maxMarkersOnMap = 500
const secClipRange = 0.1 //#secure clipping range (clip pois in secure distance)
const uriBeginning = 'http://127.0.0.1:5500/'

// The function get the poi info according name
function getPoisInfo(poiParameter, valueOfParameter, searchOutsideTheBounds) {
    var poiInfo = {
        poiParameter : valueOfParameter
    }
    var quaryParams = {}
    quaryParams['poiParameter'] = poiParameter
    quaryParams['relevantBounds'] = getRelevantBounds()
    quaryParams['poiInfo'] = poiInfo
    quaryParams['searchOutsideTheBounds'] = searchOutsideTheBounds
    var quaryParamsJson= JSON.stringify(quaryParams);
    const Http = new XMLHttpRequest();
    const url = uriBeginning + 'searchPois';
    Http.open("POST", url);
    Http.withCredentials = false;
    Http.setRequestHeader("Content-Type", "application/json");
    console.log(quaryParamsJson)
    Http.send(quaryParamsJson);
    Http.onreadystatechange = (e) => {
        if (Http.readyState == 4) { //if the operation is complete.
            var response = Http.responseText
            if (response.length > 0) {
                console.log("response from the server is recieved")
                var poisInfo = JSON.parse(Http.responseText);
                if(poisInfo.length == 0) {
                    userShowNotFoundMessage()
                    console.log("not found");
                    return
                } else {
                console.log(poisInfo);
                showPoisOnMap(poisInfo);
                }
            } else {
                userShowNotFoundMessage();
                console.log("not found");
            }
        }
    }
}

//not showing the messaage if user doesnt trigered the request
function userShowNotFoundMessage() {
    if(isUserTrigeredLastFunction){
        showNotFoundMessage()
    }
}

// The function get the poi info for pois that waiting for approval
function getAudioById(id) {
    var poiInfo = {
        _id : id
    }
    var poiInfoJson= JSON.stringify(poiInfo);
    const Http = new XMLHttpRequest();
    const url= uriBeginning + 'searchPoiAudioById';
    Http.open("POST", url);
    Http.withCredentials = false;
    Http.setRequestHeader("Content-Type", "application/json");
    Http.send(poiInfoJson);
    Http.onreadystatechange = (e) => {
        if (Http.readyState == 4) { //if the operation is completed. 
            var response = Http.responseText
            if(response.length > 0) {
                console.log("response from the server is recieved")
                var poisInfo = JSON.parse(Http.responseText);
                console.log(poisInfo);
                if(poisInfo.length == 0) {
                    console.log("not found");
                }
                loadAudio(poisInfo)
            } else {
                console.log("not found");
            }
        }
    }
}

function loadAudio(poiAudioFromDB) {
    console.log("inside load audio")
    console.log(poiAudioFromDB.data)
    var uint8Array1 = new Uint8Array(poiAudioFromDB.data)
    var arrayBuffer = uint8Array1.buffer; 
    console.log(arrayBuffer)
    poiAudio.src = window.URL.createObjectURL(new Blob([uint8Array1], {type: 'audio/ogg'}))
    poiAudio.load();
}


// The function delete the data from the page
function deleteEverything() {
    localStorage.clear();
    location.reload();
}

// The function show a not found message when the user ask for a poi that not exist
function showNotFoundMessage() {
    Swal.fire({
        icon: 'error',
        title: 'Oops...',
        text: 'The POI according to your request is not found',
      }).then((result) => {
        setTimeout(deleteEverything, 500);
      });
}

function showPoisOnMap(poisArray) {
    if (markerSet.size >= maxMarkersOnMap) {
        markerSet.clear()
        greenMarkerGroup.clearLayers();
        redMarkerGroup.clearLayers();
    }
    poisArray.forEach((item) => {
        //TODO TO CHANGE LOGIC
        if (markerSet.has(item._poiName)) { //continue if alredy in marker set
            return
        } else {
            markerSet.add(item._poiName)
        }
        var lat = item._latitude;
        var lng = item._longitude;
        var name = item._poiName;
        var approved = item._ApprovedBy;
        if (isNaN(lat) || isNaN(lng) || lat == null || lng == null) {
            console.log("lat or lng is NaN - for POI: " + name)
            return false
        }
        var marker = undefined
        if (approved.localeCompare("ApprovedBy ??") == 0) {
            marker = L.marker([lat, lng], {icon: redIcon}).addTo(redMarkerGroup);
        } else {
            marker = L.marker([lat, lng], {icon: greenIcon}).addTo(greenMarkerGroup);
        }
        marker.bindPopup("<b>Welcome to </b><br>" + name)
        marker.on('click', function(){
            showPoi(item)
        })
    });   
    //add the layers to the map
    map.addLayer(redMarkerGroup);
    map.addLayer(greenMarkerGroup);
    if (!isUserTrigeredLastFunction) {return} //if not the user initiate the request dont pin/ write errors
    arraySize = poisArray.length;
    if(arraySize > 0) {
        globalMarker = poisArray[arraySize - 1]
        map.panTo(new L.LatLng(globalMarker._latitude, globalMarker._longitude));
    }
}




//icons for markers
var redIcon = new L.Icon({
    iconUrl: 'https://raw.githubusercontent.com/pointhi/leaflet-color-markers/master/img/marker-icon-2x-red.png',
    shadowUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/0.7.7/images/marker-shadow.png',
    iconSize: [25, 41],
    iconAnchor: [12, 41],
    popupAnchor: [1, -34],
    shadowSize: [41, 41]
  });

var greenIcon = new L.Icon({
    iconUrl: 'https://raw.githubusercontent.com/pointhi/leaflet-color-markers/master/img/marker-icon-2x-green.png',
    shadowUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/0.7.7/images/marker-shadow.png',
    iconSize: [25, 41],
    iconAnchor: [12, 41],
    popupAnchor: [1, -34],
    shadowSize: [41, 41]
  });

var poiAudio = document.createElement('audio');
poiAudio.id = 'audio'
poiAudio.controls = 'controls';
    //poiAudio.src = 'media/Blue Browne.mp3';

// The function show the poi info
function showPoi(item) {
    lastShownPoi = item
    keyword = searchBar.val();
    resultArea.empty();
    var elem0 = $('<li>');
    elem0.append($('<h3>').text("searching..."));
    resultArea.append(elem0);
    $("footer").empty();
    // displayResults(); 
    $("#searchBox").animate({'padding-top':"30vh"}, 600);
    $(".container-fluid").animate({height:"80vh"}, 600);

    resultArea.empty();
    var elem1 = $('<a>');
    elem1.attr("target","_blank");
    var elem2 = $('<li>');
    elem2.append($('<h3>').text(item._poiName));
    elem2.append($('<p>').text("Name: " + item._poiName));
    elem2.append($('<p>').text("Latitude: " + item._latitude));
    elem2.append($('<p>').text("Longtitude: " + item._longitude));
    elem2.append($('<p>').text("Short Description: " + item._shortDesc));
    elem2.append($('<p>').text("Language: " + item._language));
    elem2.append($('<p>').text("Source: " + item._source));
    elem2.append($('<p>').text("Contributor: " + item._Contributor));
    elem2.append($('<p>').text("Created Date: " + item._CreatedDate));
    elem2.append($('<p>').text("Approved By: " + item._ApprovedBy));
    elem2.append($('<p>').text("Updated By: " + item._UpdatedBy));
    elem2.append($('<p>').text("Last Updated Date: " + item._LastUpdatedDate));
    //audio
    audio = item._audio
    if (audio == "no audio") {
        console.log("no audio for this poi")
    } else {
        //elem2.append($('<audio controls>'));
        audioFromDb = getAudioById(item._id)
        elem2.append(poiAudio);
    }
    elem2.append($('<div style="white-space: pre">'));
    elem2.append($('<button id="edit_button" class="button button1">').text("Edit: " + item._poiName));
    elem1.append(elem2);
    resultArea.append(elem1); 
    //add edit button listener
    $('button').click(editButtonClicked)
}
// edit button clicked
function editButtonClicked() {
    if (!lastShownPoi) {return}
    basicUrl = uriBeginning + 'editPoi';
    let url = new URL(basicUrl);
    url.searchParams.append('id', lastShownPoi._id)
    location.href = url.href;
}

// The function perform the search according to the user request
function getSearchInfo() {
    isUserTrigeredLastFunction = true // indicate that the user call to search functions 
    console.log("-------------------------------------------")
    console.log(globalMarker)
    if(globalMarker) {
        markerSet.clear()
        greenMarkerGroup.clearLayers();
        redMarkerGroup.clearLayers();
    }
    resultArea.empty();
    valueToSearch = document.getElementById('searchBar').value;
    lastUserQuery = valueToSearch;
    console.log("the value to search is: " + valueToSearch)
    if(document.getElementById('Name').checked) {
        //Name radio button is checked
        console.log("Name radio button is checked")
        //save usage data
        lastParameterSearched = '_poiName'
        getPoisInfo('_poiName', valueToSearch, true);
        // getPoisInfoByName(valueToSearch, true);
      }else if(document.getElementById('Contributor').checked) {
        //Contributor radio button is checked
        console.log("Contributor radio button is checked")
        lastParameterSearched = '_Contributor'
        getPoisInfo('_Contributor', valueToSearch, true);
      }else if(document.getElementById('Approved By').checked) {
        //Approved By radio button is checked
        console.log("Approved By radio button is checked")
        lastParameterSearched = '_ApprovedBy'
        getPoisInfo('_ApprovedBy', valueToSearch, true);
      }else if(document.getElementById('Waiting for approval').checked) {
        //Waiting for approval radio button is checked
        console.log("Waiting for approval radio button is checked")
        lastParameterSearched = '_ApprovedBy'
        lastUserQuery = 'ApprovedBy ??'
        getPoisInfo('_ApprovedBy', 'ApprovedBy ??', true);
      }else if(document.getElementById('All').checked) {
        //All radio button is checked
        console.log("All radio button is checked")
      }
}

// searchButton.click(function(){
//     keyword = searchBar.val();
//     resultArea.empty();
//     var elem0 = $('<li>');
//     elem0.append($('<h3>').text("searching..."));
//     resultArea.append(elem0);
//     $("footer").empty();
//     // displayResults(); 
//     $("#searchBox").animate({'padding-top':"0"}, 600);
//     $(".container-fluid").animate({height:"30vh"}, 600);
//   });

/* -------------------------- map function -------------------- */
function getRelevantBounds() {
    var relevantBounds = {}
    relevantBounds['northEast'] = currentMapBounds._northEast
    relevantBounds['southWest'] = currentMapBounds._southWest
    // add secure range
    relevantBounds['northEast'].lat += secClipRange
    relevantBounds['northEast'].lng += secClipRange
    relevantBounds['southWest'].lat -= secClipRange
    relevantBounds['southWest'].lng -= secClipRange
    console.log("======================================")
    console.log(relevantBounds['northEast'])
    return relevantBounds;
}

function updatePoisOnMap() {

    if (lastParameterSearched) { //if already the user searched in the map
        getPoisInfo(lastParameterSearched,lastUserQuery, false)
    }
    
    console.log(currentMapBounds)
    console.log(lastMapZoom)

}

console.log(map.getCenter())
//init
lastMapCenter = map.getCenter()
currentMapBounds = map.getBounds()
lastMapZoom = map.getZoom()


map.on('moveend', function(e) { //the map moved
    if (isUserTrigeredLastFunction) { //this occure when the map move to pin thats why we dont do nothing
        isUserTrigeredLastFunction = false
        return;
    }
    var epsilon = 0.01 //TODO FIND BETTER LOGIC
    var zooRangeSightChanged = 2
    currentMapBounds = map.getBounds()
    var currentZoom = map.getZoom()
    var currentCenter = map.getCenter()
    console.log(currentCenter)
    console.log(lastMapCenter)
    if (Math.abs(lastMapCenter.lat - currentCenter.lat) >= epsilon || Math.abs(lastMapCenter.lng - currentCenter.lng) >= epsilon ||
        Math.abs(currentZoom - lastMapZoom) >= zooRangeSightChanged) {
        isUserTrigeredLastFunction = false
        updatePoisOnMap();
        lastMapCenter = currentCenter
        lastMapZoom = currentZoom
    } else {
        console.log("close position")
    }
});

var tiles = L.tileLayer('https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token={accessToken}', {
        maxZoom: 18,
        // attribution: 'Map data &copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors, ' +
        //     'Imagery © <a href="https://www.mapbox.com/">Mapbox</a>',
        id: 'mapbox/streets-v11',
        tileSize: 512,
        accessToken: 'pk.eyJ1Ijoic2FwaXJkYXZpZCIsImEiOiJja3dycGEwMWIwNXg4MnltaDFmcXg2eXJsIn0.SrGOND6EW7ihfxfbbWp1NA',
        zoomOffset: -1
}).addTo(map);

// The function enable to search by enter 
var input = document.getElementById("searchBar");
if(input) {
    input.addEventListener("keyup", function(event) {
        if (event.keyCode === 13) {
            event.preventDefault();
            document.getElementById("searchicon").click();
        }
    });
}

function openHomePage(){
    window.location.href = "search.html";
}

function openDataInPage(){
    window.location.href = "dataIn.html";
}

function openAboutPage(){
    window.location.href = "about.html";
}

function openContactPage(){
    window.location.href = "contact.html";
}
