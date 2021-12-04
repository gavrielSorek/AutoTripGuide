var XMLHttpRequest = require('xhr2');
var xhr = new XMLHttpRequest();


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
function sendPoisToServer(pois) {
    const Http = new XMLHttpRequest();
    const url = 'http://localhost:5500/createPois';
    Http.open("POST", url);
    Http.withCredentials = false;
    Http.setRequestHeader("Content-Type", "application/json");
    var poisInfoJson = JSON.stringify(pois);
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
    var parts = input.split(/[^\d\w\\.]+/);
    var lat = ConvertDMSToDD(parts[0], parts[1], parts[2], parts[3]);
    var lng = ConvertDMSToDD(parts[4], parts[5], parts[6], parts[7]);
    return { lat: lat, lng: lng }
}
//convert crawler poi to poi that the server can understand
function convertFromCrawlerToServerPoi(crawlerPois) {
    //for every poi
    serverPois = []
    for (var i = 0; i < crawlerPois.length; i++) {
        var crawlePoi = crawlerPois[i];
        var position = ParseDMS(crawlePoi['position']['latitude'] + " " + crawlePoi['position']['longitude'])
        serverPoi = {
            _poiName: crawlePoi['title'],
            _latitude: position['lat'],
            _longitude: position['lng'],
            _shortDesc: crawlePoi['summary'],
            _language: crawlePoi['language'],
            _audio: "null",
            _source: crawlePoi['URL'],
            _Contributor: "crawler",
            _CreatedDate: getTodayDate(),
            _ApprovedBy: "ApprovedBy ??",
            _UpdatedBy: "UpdatedBy crawler",
            _LastUpdatedDate: getTodayDate()
        }
        serverPois.push(serverPoi)
    }
    return serverPois
}
function main() {
    var args = process.argv.slice(2);
    const jsonData = require(args[0]);
    serverPois = convertFromCrawlerToServerPoi(jsonData)
    sendPoisToServer(serverPois)

}
main()