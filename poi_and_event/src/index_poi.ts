
import { Poi } from "./core/poi";
import { getNearbyPois } from "./core/nearby_pois_objects";
import { processPois, translateDescriptions } from "./process_poi";




export async function getPois(lat: number, lon: number, rad: number, language : string = ""): Promise<Poi[]> {
    let pois : Poi[] = await getNearbyPois(lat, lon, rad);
    let proccesed : Poi[] = await processPois(pois);
    if (language != "")
        proccesed = await translateDescriptions(proccesed, language);
    return proccesed;
}

