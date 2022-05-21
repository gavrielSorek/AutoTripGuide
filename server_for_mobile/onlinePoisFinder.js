const axios = require('axios');
var geo = require("../services/countryByPosition");
var wikiTool = require("../services/wikiTool");
var textAnalysisTool = require("../services/textAnalysisTool");
var internetServices = require("../services/generalInternetServices");


// http://api.opentripmap.com/0.1/en/places/bbox?lon_min=38.364285&lat_min=59.855685&lon_max=38.372809&lat_max=59.859052&kinds=churches&format=geojson&apikey=5ae2e3f221c38a28845f05b6f5cf0b17ddcf46b0d9cfb7d66fc2628e
// http://api.opentripmap.com/0.1/en/places/xid/Q372040?apikey=5ae2e3f221c38a28845f05b6f5cf0b17ddcf46b0d9cfb7d66fc2628e
// http://api.opentripmap.com/0.1/en/places/xid/N2772835990?apikey=5ae2e3f221c38a28845f05b6f5cf0b17ddcf46b0d9cfb7d66fc2628e

const apiKey = '5ae2e3f221c38a28845f05b6f5cf0b17ddcf46b0d9cfb7d66fc2628e'

async function getPoisList(bounds, language) {
    var lightPois = (await getlightPois(bounds, language)).data;

    var pois = []
    for (var i = 0; i < 20; i++) { // TODO CHANGE TO LENGTH WHEN NOT DEBUGING
        var lightPoi = lightPois.features[i];
        var poiName = lightPoi.properties.name;
        var poiData = (await wikiTool.getPoiDescByName(poiName)); //TODO check if there is data
        if (!poiData.description) { // if didn't find in wikipedia
            continue;
        }
        //console.log(fullPoi); // debug
        //(lat = 32.0295, lng = 34.7518)
        poi = {
            _poiName : poiName , 
            _latitude : lightPoi.geometry.coordinates[1], 
            _longitude : lightPoi.geometry.coordinates[0], 
            _shortDesc : poiData.description,
            _language : language,
            _audio : 'no audio',
            _source : await wikiTool.getPoiUrlByMediaWikiId(poiData.wikiId),
            _Contributor : "online pois finder",
            _CreatedDate : getTodayDate(),
            _ApprovedBy: "ApprovedBy ??",
            _UpdatedBy : "online pois finder",
            _LastUpdatedDate : getTodayDate(),
            _country : geo.getCountry(lightPoi.geometry.coordinates[1], lightPoi.geometry.coordinates[0]),
            _Categories : await textAnalysisTool.convertArrayToServerCategories(await wikiTool.getPoiWikiCategoriesByName(poiName)),
            _pic : await internetServices.nameToPicUrl(poiName)
        }
        pois.push(poi);
    }
    return pois;
}

async function getlightPois(bounds, language) {
    const apiUrl = `http://api.opentripmap.com/0.1/${language}/places/bbox`
    var reqUrl = apiUrl + `?lon_min=${bounds['southWest'].lng}&lat_min=${bounds['southWest'].lat}&lon_max=${bounds['northEast'].lng}&lat_max=${bounds['northEast'].lat}&languege=${language}&kinds=${'interesting_places,sport,adult,amusements'}&format=geojson&apikey=${apiKey}`
    return axios.get(reqUrl)    
}

// function getPoiInfo(poiId, language) {
//     const apiUrl = `http://api.opentripmap.com/0.1/${language}/places/xid/${poiId}`;
//     var reqUrl = apiUrl + `?apikey=${apiKey}`;
//     return axios.get(reqUrl);
// }

// The function returns the date of today
function getTodayDate(){
    var today = new Date();
    var dd = String(today.getDate()).padStart(2, '0');
    var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
    var yyyy = today.getFullYear();

    today = dd + '/' + mm + '/' + yyyy;
    return today
}



// _________________________________________________________________________________________________//
// debug

function getBounds(){
    user_data = {lat : 32.1245, lng : 34.7954} 
    var epsilon = 0.02
    var relevantBounds = {}
    relevantBounds['southWest'] = {lat : user_data.lat - epsilon, lng : user_data.lng - epsilon}
    relevantBounds['northEast'] = {lat : user_data.lat + epsilon, lng : user_data.lng + epsilon}
    return relevantBounds;
}


async function tryModule() {
    var data = await getPoisList(getBounds(), 'en');
    console.log(data);
    
}
tryModule();