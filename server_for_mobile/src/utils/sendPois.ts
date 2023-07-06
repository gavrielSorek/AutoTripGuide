import { MongoClient } from "mongodb";
import { findPois, insertPois } from "../db";
import { Poi } from "../types/poi";
import { logger } from "./loggerService";
import { v1 as uuidv1 } from 'uuid';
import { getCountry } from "./countryByPosition";

export async function sendPoisToServer(dbClientSearcher:MongoClient,pois:Poi[]) {
    try{
        let isAllPoisAdded = true;
        const filteredPois = []
    
        for(const poi of pois) {
            if (!poi._poiName) {
                logger.error('[Poi-db], poi missing name didnt create poi');
                continue;
            }
            var poiSearchParams = {_poiName: poi._poiName.toLowerCase()};
            var poisInfo = await findPois(dbClientSearcher, poiSearchParams,  null, 1, true,'internal search');
            if (poisInfo) { // if poi already exist, error
                logger.warn(`[Poi-db], poi already exist , ${poi._poiName} ,from source ${poi._Contributor}`);
                isAllPoisAdded = false;
                continue;
            }
            if(poi._id){
                poi._id = undefined
            }
            const newPoi = await poiHandler(poi);
            filteredPois.push(newPoi)
        }
        if(filteredPois.length != 0) {
            await insertPois(dbClientSearcher, filteredPois);
        }
        return isAllPoisAdded;
    } catch(e){
        logger.error(`Error in sendPoisToServer: ${e}`);
    } 
}

function poiHandler(poi:Poi) {
    const language = poi._language
    if(!poi._poiName) {
        poi._poiName = 'unknown'
    }
    if(language == "en") {
        poi._poiName = poi._poiName.toLowerCase();
    }
    if(!poi._country) {
        poi._country = getCountry(poi._latitude, poi._longitude);
    }
    if(!poi._id) {
        poi._id = uuidv1()
    }
    if(!poi._pic) {
        poi._pic = "no pic"
    }
    if(!poi._vendorInfo) {
        poi._vendorInfo = null;
    }
    return poi;
}


//     try {
//         for (var i = 0; i < Object.keys(pois).length; i++) {
//             // if (!pois[i]._poiName) {
//             //     console.log('error in createNewPois, poi missing name didnt create poi');
//             //     isAllPoisAdded = false;
//             //     continue;
//             // }
//             var poiSearchParams = {_poiName: pois[i]._poiName.toLowerCase()};
//             var poisInfo = await db.findPois(dbClientSearcher, poiSearchParams, relevantBounds = undefined, MaxCount = 1, searchOutsideTheBounds = undefined);
//             if (poisInfo) { // if poi already exist, error
//                 console.log('error in createNewPois, poi already exist');
//                 isAllPoisAdded = false;
//                 continue;
//             }
//             if(pois[i]._id){
//                 pois[i]._id = undefined
//             }
//             // if everthing is ok
//             pois[i] = await poiHandler(pois[i]);
//             filteredPois.push(pois[i])
//         }
//         await db.InsertPois(dbClientInsertor, filteredPois);
//     } catch (e) {
//         console.error(e); 
//         var isAllPoisAdded = false;
//     } 
//     return isAllPoisAdded;
// }