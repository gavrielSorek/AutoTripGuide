/* -------------------------- search function -------------------- */

//variables definition
var resultArea = $("#results");
var searchBar = $("#searchBar");
var searchButton = $(".glyphicon-search");

// The function get the poi info according name
function getPoisInfoByName(nameOfPoi) {
    var poiInfo = {
        _poiName : nameOfPoi
    }
    var poiInfoJson= JSON.stringify(poiInfo);
    const Http = new XMLHttpRequest();
    const url='http://localhost:5500/searchPoiByName';
    Http.open("POST", url);
    Http.withCredentials = false;
    Http.setRequestHeader("Content-Type", "application/json");
    Http.send(poiInfoJson);
    Http.onreadystatechange = (e) => {
        if (Http.readyState == 4) { //if the operation is complete.
            var response = Http.responseText
            if (response.length > 0) {
                console.log("response from the server is recieved")
                var poisInfo = JSON.parse(Http.responseText);
                if(poisInfo.length == 0) {
                    showNotFoundMessage()
                    console.log("not found");
                    return
                }
                console.log(poisInfo);
                showPoisOnMap(poisInfo);
            } else {
                showNotFoundMessage();
                console.log("not found");
            }
        }
    }
}

// The function get the poi info according to contributor
function getPoisInfoByContributor(nameOfContributor) {
    var poiInfo = {
        _Contributor : nameOfContributor
    }
    var poiInfoJson= JSON.stringify(poiInfo);
    const Http = new XMLHttpRequest();
    const url='http://localhost:5500/searchPoiByContributor';
    Http.open("POST", url);
    Http.withCredentials = false;
    Http.setRequestHeader("Content-Type", "application/json");
    Http.send(poiInfoJson);
    Http.onreadystatechange = (e) => {
        if (Http.readyState == 4) { //if the operation is complete. 
            var response = Http.responseText
            if(response.length > 0) {
                console.log("response from the server is recieved")
                var poisInfo = JSON.parse(Http.responseText);
                if(poisInfo.length == 0) {
                    showNotFoundMessage()
                    console.log("not found");
                    return
                }
                console.log(poisInfo);
                showPoisOnMap(poisInfo);
            } else {
                showNotFoundMessage()
                console.log("not found");
            }
        }  
    }
}

// The function get the poi info according to the approver
function getPoisInfoByApprover(nameOfApprover) {
    var poiInfo = {
        _ApprovedBy : nameOfApprover
    }
    var poiInfoJson= JSON.stringify(poiInfo);
    const Http = new XMLHttpRequest();
    const url='http://localhost:5500/searchPoiByApprover';
    Http.open("POST", url);
    Http.withCredentials = false;
    Http.setRequestHeader("Content-Type", "application/json");
    Http.send(poiInfoJson);
    Http.onreadystatechange = (e) => {
        if (Http.readyState == 4) { //if the operation is complete. 
            var response = Http.responseText
            if(response.length > 0) {
                console.log("response from the server is recieved")
                var poisInfo = JSON.parse(Http.responseText);
                if(poisInfo.length == 0) {
                    showNotFoundMessage()
                    console.log("not found");
                    return
                }
                console.log(poisInfo);
                showPoisOnMap(poisInfo);
            } else {
                showNotFoundMessage()
                console.log("not found");
            }
        }  
    }
}

// The function get the poi info for pois that waiting for approval
function getPoisWaitingToApproval() {
    var poiInfo = {
        _ApprovedBy: 'ApprovedBy ??'
    }
    var poiInfoJson= JSON.stringify(poiInfo);
    const Http = new XMLHttpRequest();
    const url='http://localhost:5500/searchPoiWaitingToApproval';
    Http.open("POST", url);
    Http.withCredentials = false;
    Http.setRequestHeader("Content-Type", "application/json");
    Http.send(poiInfoJson);
    Http.onreadystatechange = (e) => {
        if (Http.readyState == 4) { //if the operation is complete. 
            var response = Http.responseText
            if(response.length > 0) {
                console.log("response from the server is recieved")
                var poisInfo = JSON.parse(Http.responseText);
                if(poisInfo.length == 0) {
                    showNotFoundMessage()
                    console.log("not found");
                    return
                }
                console.log(poisInfo);
                showPoisOnMap(poisInfo);
            } else {
                showNotFoundMessage()
                console.log("not found");
            }
        }  
    }
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

// The function show the pois on the map
function showPoisOnMap(poisArray) {
    poisArray.forEach((item) => {
        var lat = item._latitude;
        var lng = item._longitude;
        var name = item._poiName;
        var shortDesc = item._shortDesc;
        var approved = item._ApprovedBy;
        console.log(approved)
        if (approved.localeCompare("ApprovedBy ??") == 0) {
            res = addCircleOnMap(lat, lng, name, item)
        } else {
            res = addMarkerOnMap(lat,lng,name)
        }
        if(res) {
            map.panTo(new L.LatLng(lat, lng));
        } else {
            Swal.fire({
                icon: 'error',
                title: 'Oops...',
                text: 'Something wrong with the latitude or the longtitude values of ' + name,
              }).then((result) => {
                
              });
        }
      });
}

// The function add a mraker on the map
function addMarkerOnMap(lat, lng, name) {
    if (isNaN(lat) || isNaN(lng) || lat == null || lng == null) {
        console.log("lat or lng is NaN - for POI: " + name)
        return false
    }
    console.log("add marker to map")
    var marker = L.marker([lat, lng]).addTo(map);
    marker.bindPopup("<b>Welcome to </b><br>" + name);
    return true
}

// The function add a circle on the map
function addCircleOnMap(lat, lng, name, item) {
    if (isNaN(lat) || isNaN(lng) || lat == null || lng == null) {
        console.log("lat or lng is NaN - for POI: " + name)
        return false
    }
    console.log("add circle to map")
    var circleGroup = L.featureGroup();
    var circle = L.circle([lat, lng], {
        color: 'red',
        fillColor: '#f03',
        fillOpacity: 0.5,
        radius: 500
    }).addTo(circleGroup);
    map.addLayer(circleGroup);
    circle.bindPopup("<b>Welcome to </b><br>" + name)
    circle.on('click', function(){
        showPoi(item)
    })
    return true
}

// The function show the poi info
function showPoi(item) {
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
    
    elem1.append(elem2);
    resultArea.append(elem1);  
}

// The function perform the serach according to the user request
function getSearchInfo() {
    resultArea.empty();
    valueToSearch = document.getElementById('searchBar').value;
    console.log("the value to search is: " + valueToSearch)
    if(document.getElementById('Name').checked) {
        //Name radio button is checked
        console.log("Name radio button is checked")
        getPoisInfoByName(valueToSearch);
      }else if(document.getElementById('Contributor').checked) {
        //Contributor radio button is checked
        console.log("Contributor radio button is checked")
        getPoisInfoByContributor(valueToSearch);
      }else if(document.getElementById('Approved By').checked) {
        //Approved By radio button is checked
        console.log("Approved By radio button is checked")
        getPoisInfoByApprover(valueToSearch)
      }else if(document.getElementById('Waiting for approval').checked) {
        //Waiting for approval radio button is checked
        console.log("Waiting for approval radio button is checked")
        getPoisWaitingToApproval()
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

var map = L.map('map').setView([31.83303, 34.863443], 10);

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
