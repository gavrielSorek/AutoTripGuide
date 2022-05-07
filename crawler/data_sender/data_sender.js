var XMLHttpRequest = require('xhr2');
var xhr = new XMLHttpRequest();
var geo = require("./services/countryByPosition");
var tokenGetter = require("./services/serverTokenGetter");
const serverUrl = 'https://autotripguide.loca.lt';
var globalCategories = []
var serverCategories = []

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
async function sendPoisToServer(pois) {
    const Http = new XMLHttpRequest();
    const url = serverUrl + '/createPois';
    Http.open("POST", url);
    Http.withCredentials = false;
    Http.setRequestHeader("Content-Type", "application/json");
    var objectToSend = {}
    var tokenAndPermission = await tokenGetter.getToken('crawler@gmail.com', '1234', serverUrl)
    objectToSend["poisArray"] = pois
    objectToSend["permissionStatus"] = tokenAndPermission.permissionStatus
    objectToSend["PermissionToken"] = tokenAndPermission.PermissionToken

    var poisInfoJson = JSON.stringify(objectToSend);
    Http.send(poisInfoJson);
    Http.onreadystatechange = (e) => {  
        var response = Http.responseText;
        if (Http.readyState == XMLHttpRequest.DONE && Http.status == 200) {
            // successful
            console.log("all the data was sent")
        }
    }


}
//convert dms coordinated to dd
function ConvertDMSToDD(degrees, minutes, seconds, direction) {
    var dd = Number(degrees) + Number(minutes) / 60 + Number(seconds) / (60 * 60);

    if (direction == "S" || direction == "W") {
        dd = dd * -1;
    } // Don't do anything for N or E
    return dd;
}

//convert from dms coordinates to dd
function ParseDMS(input) {
    var lat = NaN
    var lng = NaN
    var parts = input.split(/[^\d\w\\.]+/);
    if (parts[1] == 'N' || parts[1] == 'S' || parts[1] == 'E' || parts[1] == 'W') { //if from the shape 31°N 35°E
        lat = ConvertDMSToDD(parts[0], '0', '0', parts[1]);
        lng = ConvertDMSToDD(parts[2], '0', '0', parts[3]);
    } else if (parts[2] == 'N' || parts[2] == 'S' || parts[2] == 'E' || parts[2] == 'W') { //if from the shape "32°48′N 35°06′E"
        lat = ConvertDMSToDD(parts[0], parts[1], '0', parts[2]);
        lng = ConvertDMSToDD(parts[3], parts[4], '0', parts[5]);
    } else {
        lat = ConvertDMSToDD(parts[0], parts[1], parts[2], parts[3]);
        lng = ConvertDMSToDD(parts[4], parts[5], parts[6], parts[7]);
    }
    return { lat: lat, lng: lng }
}
//convert crawler poi to poi that the server can understand
function convertFromCrawlerToServerPoi(crawlerPois) {
    //for every poi
    serverPois = []
    for (var i = 0; i < crawlerPois.length; i++) {
        var crawlePoi = crawlerPois[i];
        var position = ParseDMS(crawlePoi['position']['latitude'] + " " + crawlePoi['position']['longitude'])
        //convert object to array
        var categoriesObject = convertToServerCategories(crawlePoi['categories'].join());
        var categoriesArray = [];
        categoriesObject.forEach(element => {
            categoriesArray.push(element);
        });

        serverPoi = {
            _poiName: crawlePoi['title'],
            _latitude: position['lat'],
            _longitude: position['lng'],
            _shortDesc: crawlePoi['summary'],
            _language: crawlePoi['language'],
            _audio: "no audio",
            _source: crawlePoi['URL'],
            _Contributor: "crawler",
            _CreatedDate: getTodayDate(),
            _ApprovedBy: "ApprovedBy ??",
            _UpdatedBy: "UpdatedBy crawler",
            _LastUpdatedDate: getTodayDate(),
            _country: geo.getCountry(position['lat'], position['lng']),
            _Categories: categoriesArray
            // _Categories: convertToServerCategories(crawlePoi['categories'].join())
        }
        serverPois.push(serverPoi)
    }
    return serverPois
}

async function getServerCategories(){
    var lang = {
        language : "eng", //TODO::ADAPT LANGUAGE TO CATEGORIES LANGUAGE
    }
    var langJson= JSON.stringify(lang);
    const Http = new XMLHttpRequest();
    const url=serverUrl + '/getCategories';
    Http.open("POST", url);
    Http.withCredentials = false;
    Http.setRequestHeader("Content-Type", "application/json");
    Http.send(langJson);
    const categoriesPromise = new Promise((resolve, reject) => {
        Http.onreadystatechange = (e) => {  
            if (Http.readyState == 4) { //if the operation is completed. 
                var response = Http.responseText
                if(response.length > 0) {
                    console.log("response from the server is recieved")
                    var jsonResponse = JSON.parse(Http.responseText);
                    resolve(Object.keys(jsonResponse));
                } else {
                    reject("get categories from server failed");
                }
            }
        }
    });
    return categoriesPromise;
}

function convertToServerCategories(crawlerCategories) {
    crawlerCategories = crawlerCategories.toLowerCase();
    var filterServerCategories = []
    serverCategories.forEach(element => {
        category = element.toLowerCase();
        if(crawlerCategories.includes(category)) {
            filterServerCategories.push(element);
        }
    });
    return filterServerCategories;
}

async function main() {
    serverCategories = await getServerCategories();
    var args = process.argv.slice(2);
    const jsonData = require(args[0]);
    var serverPois = convertFromCrawlerToServerPoi(jsonData)
    sendPoisToServer(serverPois)
}
main()