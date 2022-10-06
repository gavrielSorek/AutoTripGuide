const axios = require('axios');
var geo = require("../services/countryByPosition");
var wikiTool = require("../services/wikiTool");
var textAnalysisTool = require("../services/textAnalysisTool");
var internetServices = require("../services/generalInternetServices");
module.exports = { getPoisList};
const maxPois = 20;

// http://api.opentripmap.com/0.1/en/places/bbox?lon_min=38.364285&lat_min=59.855685&lon_max=38.372809&lat_max=59.859052&kinds=churches&format=geojson&apikey=5ae2e3f221c38a28845f05b6f5cf0b17ddcf46b0d9cfb7d66fc2628e
// http://api.opentripmap.com/0.1/en/places/xid/Q372040?apikey=5ae2e3f221c38a28845f05b6f5cf0b17ddcf46b0d9cfb7d66fc2628e
// http://api.opentripmap.com/0.1/en/places/xid/N2772835990?apikey=5ae2e3f221c38a28845f05b6f5cf0b17ddcf46b0d9cfb7d66fc2628e

const apiKey = '5ae2e3f221c38a28845f05b6f5cf0b17ddcf46b0d9cfb7d66fc2628e'

async function getPoisList(bounds, languageCode, onSinglePoiFound = undefined) {
    var lightPois = (await getlightPois(bounds, languageCode)).data;

    var pois = []
    for (var i = 0; i < Math.min(maxPois, lightPois.features.length); i++) {
        var lightPoi = lightPois.features[i];
        if (lightPoi.properties.name === '') {continue;} // filter unknown pois
        var fullPoi = (await getPoiInfo(lightPoi.properties.xid, languageCode)).data;
        var description = fullPoi.name
        //description = await wikiTool.getPoiDescByName(fullPoi.name) //TODO DELETE
        if (fullPoi.wikipedia_extracts) { // if not contains wikipedia content
            description = fullPoi.wikipedia_extracts.text;
            description = await textAnalysisTool.translateIfNotInTargetLanguage(description, languageCode);
        }

        poi = {
            _poiName : fullPoi.name , 
            _latitude : fullPoi.point.lat, 
            _longitude : fullPoi.point.lon, 
            _shortDesc : description,
            _language : languageCode,
            _audio : 'no audio',
            _source : fullPoi.wikipedia,
            _Contributor : "online pois finder",
            _CreatedDate : getTodayDate(),
            _ApprovedBy: "ApprovedBy ??",
            _UpdatedBy : "online pois finder",
            _LastUpdatedDate : getTodayDate(),
            _country : geo.getCountry(fullPoi.point['lat'], fullPoi.point['lon']),
            _Categories : await textAnalysisTool.convertToServerCategories(fullPoi.kinds),
            _pic : await internetServices.nameToPicUrl(fullPoi.name)
        }
        pois.push(poi);
        if(onSinglePoiFound) {
            onSinglePoiFound(poi);
        }
    }
    console.log(`Found ${pois.length.toString()} new pois`)
    return pois;
}

async function getlightPois(bounds, language) {
    const apiUrl = `http://api.opentripmap.com/0.1/${language}/places/bbox`
    var reqUrl = apiUrl + `?lon_min=${bounds['southWest'].lng}&lat_min=${bounds['southWest'].lat}&lon_max=${bounds['northEast'].lng}&lat_max=${bounds['northEast'].lat}&languege=${language}&kinds=${'interesting_places,sport,adult,amusements'}&format=geojson&apikey=${apiKey}`
    return axios.get(reqUrl)    
}

function getPoiInfo(poiId, language) {
    const apiUrl = `http://api.opentripmap.com/0.1/${language}/places/xid/${poiId}`;
    var reqUrl = apiUrl + `?apikey=${apiKey}`;
    return axios.get(reqUrl);
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



// _________________________________________________________________________________________________//
// debug

function getBounds(){
    user_data = {lat : 32.80, lng : 35.114} 
    var epsilon = 0.02
    var relevantBounds = {}
    relevantBounds['southWest'] = {lat : user_data.lat - epsilon, lng : user_data.lng - epsilon}
    relevantBounds['northEast'] = {lat : user_data.lat + epsilon, lng : user_data.lng + epsilon}
    return relevantBounds;
}


async function tryModule() {
    var data = await getPoisList(getBounds(), 'en');
    for (var i=0; i<data.length; i++)
        console.log(i + ". " + JSON.stringify(data[i]));
}
//tryModule();
