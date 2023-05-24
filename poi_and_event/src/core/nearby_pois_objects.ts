import * as dotenv from 'dotenv'
import { Poi } from './poi';
import axios from 'axios';
import { getPoiCategory } from '../utils/switch_categories';
import { translate } from '../apis/translate-api'
import { MIN_REVIEWS } from '../utils/constants';
dotenv.config()
// additioal place types from: https://developers.google.com/maps/documentation/javascript/supported_types

async function getCountryFromLatLon(lat: number, lon: number): Promise<string> {
    const url = `https://nominatim.openstreetmap.org/reverse?lat=${lat}&lon=${lon}&format=jsonv2`;
    const response = await axios.get(url);
    const address = response.data.address;
    const country = address?.country;
    if (country == undefined) {
        return ""
    }
    const translated = await translate(country)
    if (translated == undefined) {
        return country
    }
    return translated
}

export async function getNearbyPois(latitude: number, longitude: number, radius: number, type: string = "", fs_name: string = "untyped"): Promise<Poi[]> {
    let API_KEY = process.env.GM_API_KEY;
    let fs = require('fs')
    var logger = fs.createWriteStream(`src/outputs/${fs_name}_results.txt`, {
        flags: 'a' // 'a' means appending (old data will be preserved)
    })
    const response = await axios.get('https://maps.googleapis.com/maps/api/place/nearbysearch/json', {
        params: {
            location: `${latitude},${longitude}`,
            radius: radius,
            key: API_KEY,
            type: type,
            language: "en"
        }
    });
    const places = response.data.results
    var pois_list: Poi[] = [];
    for (const place of places) {
        if (place.user_ratings_total < MIN_REVIEWS) { continue; }
        let translated_name = await translate(place.name)
        if (translated_name === undefined) { translated_name = place.name }
        const poi = new Poi(place.place_id, place.name, translated_name, place.geometry.location.lat, place.geometry.location.lng)
        poi._pic = place.photos
        poi._Categories = []
        let categories_set = new Set<string>();
        for (let c of place.types) {
            let category = getPoiCategory(c)
            if (category != "1") { categories_set.add(category) }
        }
        poi._Categories = [...categories_set]
        poi._country = await getCountryFromLatLon(place.geometry.location.lat, place.geometry.location.lng)
        pois_list.push(poi)
        logger.write(place.place_id + " " + place.name + " " + place.geometry.location.lng + " " +
            place.geometry.location.lat + " " + place.types + " " + place.photos + " " + place.vicinity + "\n")
        logger.write("* CATEGORIES: " + poi._Categories + "\n\n")
    }
    return pois_list;
}


export function writePoisToJsonFile(pois_list: Poi[], json_name: string = "") {
    const JsonPoisList = JSON.stringify(pois_list);
    // write the pois list to a json file
    let fs = require('fs')
    fs.writeFile(`src/outputs/${json_name}gm_pois.json`, JsonPoisList, function (err: any) {
        if (err) {
            console.log(err)
        }
    });
}


//32.007139, 34.782673 h
//40.757926, -73.985564 times square
// radius in meters (3 km)

let time_square_lat = 40.757926;
let time_square_lng = -73.985564;

let rabin_square_lat = 31.747730;
let rabin_square_lng = 34.994789;

// getNearbyPois(rabin_square_lat, rabin_square_lng, 3000.0).then((pois_list) => {
//     console.log(pois_list.length);
//     writePoisToJsonFile(pois_list);
//     console.log("ok");
// });