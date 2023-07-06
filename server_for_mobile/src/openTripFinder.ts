import axios from 'axios';
import * as geo from "../../services/countryByPosition";
import * as textAnalysisTool from "../../services/textAnalysisTool";
import * as internetServices from "../../services/generalInternetServices";
const maxPois = 200;
import { logger } from './utils/loggerService';
import { Poi } from './types/poi';
import { Sources } from './types/sources';
import { wikiGetImageUrl } from './utils/wiki';

// http://api.opentripmap.com/0.1/en/places/bbox?lon_min=38.364285&lat_min=59.855685&lon_max=38.372809&lat_max=59.859052&kinds=churches&format=geojson&apikey=5ae2e3f221c38a28845f05b6f5cf0b17ddcf46b0d9cfb7d66fc2628e
// http://api.opentripmap.com/0.1/en/places/xid/Q372040?apikey=5ae2e3f221c38a28845f05b6f5cf0b17ddcf46b0d9cfb7d66fc2628e
// http://api.opentripmap.com/0.1/en/places/xid/N2772835990?apikey=5ae2e3f221c38a28845f05b6f5cf0b17ddcf46b0d9cfb7d66fc2628e

const apiKey = '5ae2e3f221c38a28845f05b6f5cf0b17ddcf46b0d9cfb7d66fc2628e'
export const blacklistStrings: string[] = ['depopulated','palestinian'];


export async function getPoisFromOpenTrip(bounds:any, languageCode:string,geoHashStr: string, onSinglePoiFound:any = undefined) {
    logger.info('searching for pois in open trip map for geoHash ' + geoHashStr);
    try{

        const lightPois = (await getlightPois(bounds, languageCode)).data;
        const tempPois =  lightPois.features.filter((poi:any, index:number) => lightPois.features.findIndex((p:any) => p.properties.name === poi.properties.name) === index);
        const pois:Poi[] = []
        for(const poi of tempPois) {
            if (poi.properties.name === '') {continue;} // filter unknown pois
            const fullPoi = (await getPoiInfo(poi.properties.xid, languageCode)).data;
            if(!fullPoi.wikipedia_extracts) { // if not contains wikipedia content
                continue;
            }
            const description = await textAnalysisTool.translateIfNotInTargetLanguage(fullPoi.wikipedia_extracts.text, languageCode);
            const isBlacklisted = blacklistStrings.every((str) => description.toLowerCase().includes(str.toLowerCase()));
            if(isBlacklisted){
                continue;
            }
            const pic = fullPoi.preview ? fullPoi.preview.source : await wikiGetImageUrl(fullPoi.wikipedia);
            const newPoi:Poi = {
                _id: undefined,
                _poiName : fullPoi.name , 
                _latitude : fullPoi.point.lat, 
                _longitude : fullPoi.point.lon, 
                _shortDesc : description,
                _language : languageCode,
                _vendorInfo: {
                    _source: Sources.openTripMap,
                    _rating: fullPoi.rate,
                    _url: fullPoi.wikipedia,
                    _placeId: fullPoi.xid,
                    _wikiPlaceId: fullPoi.wikidata
                },
                _audio : 'no audio',
                _source : fullPoi.wikipedia,
                _Contributor : "openTripMap",
                _CreatedDate : getTodayDate(),
                _ApprovedBy: "ApprovedBy ??",
                _UpdatedBy : "online pois finder",
                _LastUpdatedDate : getTodayDate(),
                _country : geo.getCountry(fullPoi.point['lat'], fullPoi.point['lon']),
                _Categories : await textAnalysisTool.convertToServerCategories(fullPoi.kinds),
                _pic : pic
            }
            pois.push(newPoi);
            if(onSinglePoiFound) {
                onSinglePoiFound(newPoi);
            }
        }
    
    
        logger.info(`total found ${pois.length.toString()} from open trip map for geoHash ${geoHashStr}`)
        return pois;
    } catch (e) {
        logger.error(`Error in open trip map for geoHash ${geoHashStr}: ${e}`);
        return [];
    }
}

async function getlightPois(bounds:any, language:string,minRate = '2') {
    const apiUrl = `http://api.opentripmap.com/0.1/${language}/places/bbox`
    const reqUrl = apiUrl + `?lon_min=${bounds['southWest'].lng}&lat_min=${bounds['southWest'].lat}&lon_max=${bounds['northEast'].lng}&lat_max=${bounds['northEast'].lat}&languege=${language}&kinds=${'interesting_places,sport,adult,amusements'}&format=geojson&apikey=${apiKey}&rate=${minRate}`
    return axios.get(reqUrl)    
}

function getPoiInfo(poiId:string, language:string) {
    const apiUrl = `http://api.opentripmap.com/0.1/${language}/places/xid/${poiId}`;
    const reqUrl = apiUrl + `?apikey=${apiKey}`;
    return axios.get(reqUrl);
}

function getTodayDate() {
    return new Date().toLocaleDateString('en-GB');
}
