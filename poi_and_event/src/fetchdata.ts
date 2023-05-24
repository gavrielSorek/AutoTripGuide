import { Poi } from "./core/poi";
//import { fetchPlace } from "./nearpoi";
import { wikiPlaceInfo } from "./apis/wiki-api";
import { gptPlaceInfo, formatToLength } from "./apis/gpt-api";



export async function fetchData(lat: number, lon: number, radius: number): Promise<Poi> {
    // place.place_id, place.name, place.geometry.location.lng, place.geometry.location.lat,
    // place.description, place.types, place.photos, place.vicinity

    const _Categories = ["Buildings", "Parks", "Museums"]

    // create a new poi object with the field: _Categories, _id, _description.
    let p = new Poi("3hshj4509kfj9", "masada", "masada", lat, lon, "description", "english", "audio", "viki");
    return p;
};


