/* -------------------------- insert function -------------------- */

//variables definition
var poiName = document.getElementById("Name");
var longitude = document.getElementById("longitude");
var latitude = document.getElementById("latitude");
var shortDesc = document.getElementById("shortDesc");
var language = document.getElementById("language");
var audio = document.getElementById("audio");
var source = document.getElementById("source");

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
function sendPoiInfoToServer() {
    var poiInfo = {
        _poiName : poiName.value,
        _longitude : longitude.value,
        _latitude : latitude.value,
        _source : source.value,
        _language : language.value,
        _audio : audio.value,
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

/* -------------------------- search function -------------------- */

//variables definition
var resultArea = $("#results");
var searchBar = $("#searchBar");
var searchButton = $(".glyphicon-search");

// The function get the poi info according name
function getPoisInfoByName(nameOfPoi) {
    console.log("-------check-------")
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

// The function get the poi info according name
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

function deleteEverything() {
    localStorage.clear();
    location.reload();
}

function showNotFoundMessage() {
    console.log("inside showNotFoundMessage")
    Swal.fire({
        icon: 'error',
        title: 'Oops...',
        text: 'The POI according to your request is not found',
      }).then((result) => {
        setTimeout(deleteEverything, 500);
      });
}

function showPoisOnMap(poisArray) {
    poisArray.forEach((item) => {
        var lat = item._latitude;
        var lng = item._longitude;
        var name = item._poiName;
        var approved = item._ApprovedBy;
        console.log(approved)
        if (approved.localeCompare("ApprovedBy ??") == 0) {
            addCircleOnMap(lat, lng, name)
        } else {
            addMarkerOnMap(lat,lng,name)
        }
        map.panTo(new L.LatLng(lat, lng));
      });
}

function addMarkerOnMap(lat, lng, name) {
    if (isNaN(lat) || isNaN(lng)) {
        console.log("lat or lng is NaN - for POI: " + name)
        return
    }
    console.log("add marker to map")
    var marker = L.marker([lat, lng]).addTo(map);
    marker.bindPopup("<b>Welcome to </b><br>" + name);
}

function addCircleOnMap(lat, lng, name) {
    if (isNaN(lat) || isNaN(lng)) {
        console.log("lat or lng is NaN - for POI: " + name)
        return
    }
    console.log("add circle to map")
    var circle = L.circle([lat, lng], {
        color: 'red',
        fillColor: '#f03',
        fillOpacity: 0.5,
        radius: 500
    }).addTo(map);
    circle.bindPopup("<b>Welcome to </b><br>" + name);
}

function showPois(poisArray) {
    resultArea.empty();
    poisArray.forEach((item) => {
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
      });
}



function getSearchInfo() {
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
      }else if(document.getElementById('Created Date').checked) {
        //Created Date radio button is checked
        console.log("Created Date radio button is checked")
      }else if(document.getElementById('Approved By').checked) {
        //Approved By radio button is checked
        console.log("Approved By radio button is checked")
      }else if(document.getElementById('Language').checked) {
        //Language radio button is checked
        console.log("Language radio button is checked")
      }
}

searchButton.click(function(){
    keyword = searchBar.val();
    resultArea.empty();
    var elem0 = $('<li>');
    elem0.append($('<h3>').text("searching..."));
    resultArea.append(elem0);
    $("footer").empty();
    // displayResults(); 
    $("#searchBox").animate({'padding-top':"0"}, 600);
    $(".container-fluid").animate({height:"30vh"}, 600);
  });

/* -------------------------- Lat Lng Choise function -------------------- */

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

var popup = L.popup();

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








// $(document).ready(function(){
//     var keyword = "";
//     var resultArea = $("#results");
//     var searchBar = $("#searchBar");
//     var searchButton = $(".glyphicon-search");
//     var searchUrl = "https://en.wikipedia.org/w/api.php";
//     var displayResults = function(){
//       $.ajax({
//         url: searchUrl,
//         dataType: 'jsonp',
//         data: {
//           action: 'query',
//           format: 'json',
//           generator: 'search',
//             gsrsearch: keyword,
//             gsrnamespace: 0,
//             gsrlimit: 2,
//           prop:'extracts|pageimages',
//             exchars: 200,
//             exlimit: 'max',
//             explaintext: true,
//             exintro: true,
//             piprop: 'thumbnail',
//             pilimit: 'max',
//             pithumbsize: 200
//         },
//         success: function(json){
//           var results = json.query.pages;
//           $.map(results, function(result){
//             var link = "http://en.wikipedia.org/?curid="+result.pageid;
//             var elem1 = $('<a>');
//             elem1.attr("href",link);
//             elem1.attr("target","_blank");
//             var elem2 = $('<li>');
//             elem2.append($('<h3>').text(result.title));
//             //if(result.thumbnail) elem.append($('<img>').attr('width',150).attr('src',result.thumbnail.source));
//             elem2.append($('<p>').text(result.extract));
//             elem1.append(elem2);
//             resultArea.append(elem1);
//           });
//           $("footer").append("<p>----x--------x----</p>");
//         }
//       });   
//     };
//    /* 
//     searchBar.autocomplete({
//           source: function (request, response) {
//               $.ajax({
//                   url: searchUrl,
//                   dataType: 'jsonp',
//                   data: {
//                       'action': "opensearch",
//                       'format': "json",
//                       'search': request.term
//                   },
//                   success: function (data) {
//                       response(data[1]);
//                   }
//               });
//           }
//       });
//     */
//     searchButton.click(function(){
//       keyword = searchBar.val();
//       resultArea.empty();
//       $("footer").empty();
//       displayResults(); 
//       $("#searchBox").animate({'padding-top':"0"}, 600);
//       $(".container-fluid").animate({height:"30vh"}, 600);
//     });
    
//     searchBar.keypress(function(e){
//         if(e.keyCode==13)
//         $(searchButton).click();
//     });
  
//   });



// async function getDB() {
//     try {
//         await dbClient.connect();
//         console.log("Connected to DB")
//         await listDatabases(dbClient)
//     } catch (e) {
//         console.error(e); 
//     } finally {
//        await dbClient.close();
//     }
// }

// async function createNewPoi() {
//     const uri = "mongodb+srv://root:root@autotripguide.swdtr.mongodb.net/myFirstDatabase?retryWrites=true&w=majority";
//     const dbClient = new MongoClient(uri);
//     try {
//         await dbClient.connect();
//         console.log("Connected to DB")
//         await InsertPoi(dbClient, {
//             _poiName: "masada",
//             _latitude: "50",
//             _longitude: "50",
//             _shortDesc: "test",
//             _language: "test",
//             _audio: "test",
//             _source: "test",
//             _Contributor: "test",
//             _CreatedDate: "test",
//             _ApprovedBy: "test",
//             _UpdatedBy: "test",
//             _LastUpdatedDate: "test"
//         });
//     } catch (e) {
//         console.error(e); 
//     } finally {
//        await dbClient.close();
//     }
// }

// async function findPoiInfoByName() {
//     try {
//         await dbClient.connect();
//         console.log("Connected to DB")
//         await findPoiByName(dbClient, "masada");

//     } catch (e) {
//         console.error(e); 
//     } finally {
//        await dbClient.close();
//     }
// }

// async function listDatabases(client) {
//     const dbList = await client.db().admin().listDatabases();
//     console.log("Databases: ");
//     dbList.databases.forEach(db => {
//         console.log(`-${db.name}`);
//     });
// }

// async function InsertPoi(client, newPoi) {
//     const res = await client.db("testDb").collection("testCollection").insertOne(newPoi);
//      console.log(`new poi created with the following id: ${res.insertedId}`);
//  }

//  async function findPoiByName(client, nameOfPoi) {
//     const res = await client.db("testDb").collection("testCollection").find({_poiName: nameOfPoi});
//     const results = await res.toArray();

//     if(res) {
//         console.log(`found a poi in the collection with the name '${nameOfPoi}'`);
//         console.log(results);
//     } else {
//         console.log(`No poi found with the name '${nameOfPoi}'`);
//     }
// }


// //getDB().catch(console.error);
// //createNewPoi().catch(console.error);
// //findPoiInfoByName().catch(console.error);

// function create() {
//     Swal.fire({
//         title: "Are you sure?",
//         text: "You won't be able to revert this!",
//         icon: "warning",
//         showCancelButton: true,
//         confirmButtonColor: "#3085d6",
//         cancelButtonColor: "#d33",
//         confirmButtonText: "Yes, create it!",
//     }).then((result) => {
//         if (result.value) {
//             createNewPoi().catch(console.error);
//             Swal.fire("Created!", "Your new poi has been created.", "success");
//         } else {
//             Swal.fire("Cancelled", "Your imaginary file is safe :)", "error");
//         }
//     });
// }

// function test() {
//     console.log("test")
// }

