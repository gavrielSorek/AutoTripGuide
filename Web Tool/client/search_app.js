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
var isLastQueryWasSuccess = false
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


// The function get the poi info according name
function getPoisInfo(poiParameter, valueOfParameter, searchOutsideTheBounds = false, relevantBounds = undefined, suceessCallBack = undefined) { //TODO use in communication method instead
    var poiInfo = {
        poiParameter : valueOfParameter
    }
    var quaryParams = {}
    quaryParams['poiParameter'] = poiParameter
    if (searchOutsideTheBounds == false) {
        quaryParams['relevantBounds'] = relevantBounds
    }
    else {
        // set default bounds while searchOutsideTheBounds = true
        quaryParams['relevantBounds'] = getRelevantBounds(secClipRange)
    }
    quaryParams['poiInfo'] = poiInfo
    quaryParams['searchOutsideTheBounds'] = searchOutsideTheBounds
    communication.addTokensToObject(quaryParams)
    var quaryParamsJson= JSON.stringify(quaryParams);
    const Http = new XMLHttpRequest();
    const url = communication.uriBeginning + 'searchPois';
    Http.open("POST", url);
    Http.withCredentials = false;
    Http.setRequestHeader("Content-Type", "application/json");
    console.log(quaryParamsJson)
    Http.send(quaryParamsJson);
    Http.onreadystatechange = (e) => {
        if(Http.readyState == 4 && Http.status == 553) { //if no permission
            communication.openLoginPage()
        } else if (Http.readyState == 4) { //if the operation is complete.
            var response = Http.responseText
            if (response.length > 0) {
                console.log("response from the server is recieved")
                var poisInfo = JSON.parse(Http.responseText);
                if(poisInfo.length == 0) {
                    userShowNotFoundMessage()
                    console.log("not found");
                } else {
                console.log(poisInfo);
                showPoisOnMap(poisInfo);
                if(suceessCallBack) {
                    console.log("pppppppppppp")
                    suceessCallBack()}              
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
    // location.reload();
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
    elem2.append($('<div style="white-space: pre">'));
    elem2.append($('<h3>').text(item._poiName));
    if (permissions.isPermitted('approver')) {
        elem2.append($('<button id="edit_button" class="button edit_button">').text("EDIT"));
        //add edit button listener
    }
    if (permissions.isPermitted('approver')) {
        elem2.append($('<button id="approve_button" class="button approve_button">').text("APPROVE"));
        //add edit button listener
    }
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
        // audioFromDb = getAudioById(item._id)
        communication.getAudioById(item._id, loadAudio, undefined)
        
        elem2.append(poiAudio);
    }
    // elem2.append($('<div style="white-space: pre">'));
    // if (permissions.isPermitted('approver')) {
    //     elem2.append($('<button id="edit_button" class="button edit_button">').text("Edit: " + item._poiName));
    //     //add edit button listener
    // }
    elem1.append(elem2);
    resultArea.append(elem1); 
    if (permissions.isPermitted('approver')) {
        $('button').click(editButtonClicked)
    }
}

// edit button clicked
function editButtonClicked() {
    if (!lastShownPoi) {return}
    communication.openEditPage(lastShownPoi._id)
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
    valueToSearch = valueToSearch.toLowerCase();
    lastUserQuery = valueToSearch;
    console.log("the value to search is: " + valueToSearch)
    if(document.getElementById('Name').checked) {
        //Name radio button is checked
        console.log("Name radio button is checked")
        //save usage data
        lastParameterSearched = '_poiName'
        // poiParameter, valueOfParameter, searchOutsideTheBounds = false, relevantBounds = undefined, suceessCallBack = undefined
        getPoisInfo('_poiName', valueToSearch, searchOutsideTheBounds=true, relevantBounds=undefined,suceessCallBack = ()=>{
            center = {lat : parseFloat(globalMarker._latitude), lng : parseFloat(globalMarker._longitude) }
            getPoisInfo(undefined, undefined, false, getBoundsAroundCenter(center,0.07)), undefined, undefined});
        // getPoisInfoByName(valueToSearch, true);
      }else if(document.getElementById('Contributor').checked) {
        //Contributor radio button is checked
        console.log("Contributor radio button is checked")
        lastParameterSearched = '_Contributor'
        getPoisInfo('_Contributor', valueToSearch, searchOutsideTheBounds=true);
      }else if(document.getElementById('Approved By').checked) {
        //Approved By radio button is checked
        console.log("Approved By radio button is checked")
        lastParameterSearched = '_ApprovedBy'
        getPoisInfo('_ApprovedBy', valueToSearch, searchOutsideTheBounds=true);
      }else if(document.getElementById('Waiting for approval').checked) {
        //Waiting for approval radio button is checked
        console.log("Waiting for approval radio button is checked")
        lastParameterSearched = '_ApprovedBy'
        lastUserQuery = 'ApprovedBy ??'
        getPoisInfo('_ApprovedBy', 'ApprovedBy ??', searchOutsideTheBounds=true);
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
function getRelevantBounds(dist) {
    var relevantBounds = {}
    relevantBounds['northEast'] = currentMapBounds._northEast
    relevantBounds['southWest'] = currentMapBounds._southWest
    // add secure range
    relevantBounds['northEast'].lat += dist
    relevantBounds['northEast'].lng += dist
    relevantBounds['southWest'].lat -= dist
    relevantBounds['southWest'].lng -= dist
    console.log("======================================")
    return relevantBounds;
}

function updatePoisOnMap() {

    if (lastParameterSearched) { //if already the user searched in the map
        getPoisInfo(lastParameterSearched,lastUserQuery, false, getRelevantBounds(secClipRange))
    }
    
    console.log(currentMapBounds)
    console.log(lastMapZoom)

}

console.log(map.getCenter())
//init
lastMapCenter = map.getCenter()
currentMapBounds = map.getBounds()
lastMapZoom = map.getZoom()

// return the bounds around the some center location accordingly to given distance
function getBoundsAroundCenter(center, dist) {
    var relevantBounds = {}
    relevantBounds['northEast'] = {lat: center.lat, lng: center.lng}
    relevantBounds['southWest'] = {lat: center.lat, lng: center.lng}
    // add secure range
    relevantBounds['northEast'].lat += dist
    relevantBounds['northEast'].lng += dist
    relevantBounds['southWest'].lat -= dist
    relevantBounds['southWest'].lng -= dist
    return relevantBounds;

}

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



