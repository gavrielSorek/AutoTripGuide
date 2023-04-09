import * as dotenv from 'dotenv'
import axios from 'axios';
import { Poi } from './types/poi';
import { getPoiCategory } from './utils/switch_categories';
// dotenv.config()
// additioal place types from: https://developers.google.com/maps/documentation/javascript/supported_types

function isEnglish(result: any): boolean {
    // Use a regular expression to check if the name is in English
    const englishRegex = /^[a-zA-Z\s]+$/;
    return englishRegex.test(result.name);
}


export async function getNearbyPois(latitude: number, longitude: number, radius: number, type: string = ""): Promise<Poi[]> {
    const API_KEY =process.env.GM_API_KEY; //  'AIzaSyD4sN0b5ki-gefxB_7tNIpNR5b8YQoz-sk' // process.env.GM_API_KEY;
    const response = await axios.get('https://maps.googleapis.com/maps/api/place/nearbysearch/json', {
        params: {
            location: `${latitude},${longitude}`,
            radius: radius,
            key: API_KEY,
            type: type,
            language: "en"
        }
    });
    const places = response.data.results.filter(isEnglish)
    var pois_list: Poi[] = [];
    for (const place of places) {
        const poi = new Poi(place.name, place.geometry.location.lat, place.geometry.location.lng)
        // poi._pic = place.photos
        poi._Categories = []
        let categories_set = new Set<string>();
        // var not_interesting = 0
        for (let c of place.types) {
            let category = getPoiCategory(c)
            // if (category == "-1") {not_interesting = 1}
            // else if (category != "1" && category != "-1") { categories_set.add(category) }
            if (category != "1") { categories_set.add(category) }
        }
        // if the poi doen't interesting, it won't be added
        // if (not_interesting == 1) {continue;}
        poi._Categories = [...categories_set]
        poi._country = place.vicinity
        pois_list.push(poi)
        // logger.write(place.place_id + " " + place.name + " " + place.geometry.location.lng + " " +
        //     place.geometry.location.lat + " " + place.types + " " + place.photos + " " + place.vicinity + "\n")
        // logger.write("* CATEGORIES: " + poi._Categories + "\n\n")
    }
    return pois_list;
}


// export function writePoisToJsonFile(pois_list: Poi[], json_name: string = "") {
//     const JsonPoisList = JSON.stringify(pois_list);
//     // write the pois list to a json file
//     let fs = require('fs')
//     fs.writeFile(`./src/outputs/${json_name}gm_pois.json`, JsonPoisList, function (err: any) {
//         if (err) {
//             console.log("err")
//         }
//     });
// }


//32.007139, 34.782673 h
//40.757926, -73.985564 times square
// radius in meters (3 km)

// getNearbyPois(32.1002165, 34.8833727, 3000.0).then((pois_list) => {
//     writePoisToJsonFile(pois_list);
//     console.log("ok");
// });