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


export async function getNearbyPois(latitude: number, longitude: number, radius: number, type: string): Promise<Poi[]> {
    console.log('searching POIS in google for type '  + type , latitude, longitude, radius);
    const API_KEY = process.env.GM_API_KEY; //  'AIzaSyD4sN0b5ki-gefxB_7tNIpNR5b8YQoz-sk' // process.env.GM_API_KEY;
    const response = await axios.get('https://maps.googleapis.com/maps/api/place/nearbysearch/json', {
        params: {
            location: `${latitude},${longitude}`,
            radius: radius,
            key: 'AIzaSyAO11FomILrsrAlP4XJloA0huZUtXWNvvc',
            type: type,
            language: "en"
        }
    });
    const places = response.data.results.filter(isEnglish)
    var pois_list: Poi[] = [];
    for (const place of places) {
        const poi = new Poi(place.name, place.geometry.location.lat, place.geometry.location.lng)
        poi._pic = place.photos?.length ? place.photos[0].photo_reference : ''
        poi._googleInfo = { _avgRating: place.rating, _numReviews: place.user_ratings_total, _placeId: place.place_id}
        poi._Categories = []
        const categories_set = new Set<string>();
        for (let c of place.types) {
            let category = getPoiCategory(c)
            if (category != "1") { categories_set.add(category) }
        }
        poi._Categories = [...categories_set]
        poi._country = place.vicinity
        pois_list.push(poi)
    }
    console.log('find total:' + pois_list.length)
    return pois_list;
}

export async function fetchGoogleMapsPhotoUrl(photoReference: string,poiName:string, apiKey = process.env.GM_API_KEY,maxwidth = 150): Promise<string> {
    return axios.get(`https://maps.googleapis.com/maps/api/place/photo`, {
      params: {
        photo_reference: photoReference,
        key: apiKey,
        maxwidth: maxwidth
      },
    }).then(response => {
        //console.log(response)
        if(response.status === 200) {
            return response?.request?.res?.responseUrl
        } else{
            return ''
        }
    }
      
    ).catch(error => {
        console.log('status 400 error for fetching photo for: ', poiName)
        return ''
    });
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