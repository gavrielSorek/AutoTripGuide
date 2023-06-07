import { gptPlaceInfo } from "./chat-gpt/gpt-api";
import { fetchGoogleMapsPhotoUrl, getNearbyPois } from "./nearby_pois_objects";
import { Poi } from "./types/poi";
import { Sources } from "./types/sources";
import { logger } from "./utils/loggerService";


const poi_types = ['airport', 'art_gallery', 'church', 'synagogue', 'casino', 'park', 'stadium', 'city_hall', 'zoo', 'museum', 'tourist_attraction', 'movie_theater']


const lat = 32.1000895;
const long = 34.8833617;
const distance = 1200;



export async function getPois(lat:number, long:number, distance:number){
    logger.info('searching POIS in google', lat, long, distance);
    const pois_set = new Set<Poi>();
    // for each place category
    for (const poi_type of poi_types) {
      await getNearbyPois(lat, long, distance, poi_type).then((pois_list) => {
        for (const poi of pois_list) {
          // if this poi is already in the set, it won't be added
          const found_poi = Array.from(pois_set).find(place => place._poiName === poi._poiName);
          if (found_poi) {
            continue;
          }
          pois_set.add(poi);
        }
      });
    }
    const new_pois_list: Poi[] = [...pois_set]
    // in this step we will fetch from chat/wiki
    const promises = new_pois_list.map((poi : Poi) =>  gptPlaceInfo(poi._poiName,poi._country, 128).then(desc =>{
      if(desc !== undefined){
        poi._shortDesc = `[chatGPT-v4] ${desc}`;
        poi._source = Sources.CHAT_GPT
      }
    }));

   const p2 = new_pois_list.map(poi => fetchGoogleMapsPhotoUrl(poi._pic,poi._poiName).then(pic_url => {
    if(pic_url !== undefined){
      poi._pic = pic_url;
    } }));
    await Promise.all([...promises,...p2])
    logger.info('total after gpt add description: ' +new_pois_list.length)
     return new_pois_list;
} 

// async function process_one_poi(poi : Poi) : Promise<Poi> {
//      const placeInfo = await gptPlaceInfo(poi._poiName, 128);
//       if (placeInfo !== undefined) {
//           poi._shortDesc = placeInfo;
//           poi._source = Sources.CHAT_GPT
//       }
//       // interestResponse = await getInterestValue(poi._poiName, poi._shortDesc);
//       // num = interestResponse.rate || 0;
//  // }
//   return poi;
// }
// getPois(lat,long,distance);