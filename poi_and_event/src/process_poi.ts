import { wikiPlaceInfo, searchWikipedia, wikiPageImage } from "./apis/wiki-api";
import { gptPlaceInfo } from "./apis/gpt-api";
import { Poi } from "./core/poi";
import data from './outputs/gm_pois.json';
import { getInterestValue } from "./apis/interest-api";
import { INTEREST_THRESHOLD, GPT_MAX_LENGTH } from "./utils/constants";
import { translate } from "./apis/translate-api";



export class PoiTest {
    name: string;
    description: string
    rate: number;
    source: string;
    pic: string[];
    constructor(name: string, description: string, rate: number, source: string, pic: string[]) {
        this.name = name;
        this.description = description;
        this.rate = rate;
        this.source = source;
        this.pic = pic;
    }
}

export async function processPois(data : Poi[]): Promise<Poi[]> {
    let promisses = data.map((poi: Poi) => process_one_poi(poi));
    return await Promise.all(promisses)
}

async function process_one_poi(poi: Poi): Promise<Poi> {
    // initialize a poi object
    let source = "";
    let alt_name = await searchWikipedia(poi._poiName, poi._Categories[0]);
    let placeInfo;
    let page_image;
    if (alt_name === undefined)
        alt_name = poi._poiName;
    page_image = wikiPageImage(alt_name);
    placeInfo = await wikiPlaceInfo(alt_name);
    if (placeInfo !== undefined) {
        poi._shortDesc = placeInfo;
        source = "wiki"
    }
    let interestResponse = await getInterestValue(poi._poiName, poi._shortDesc);
    let num = interestResponse.rate || 0;

    if (num < INTEREST_THRESHOLD) {
        placeInfo = await gptPlaceInfo(poi._poiName, GPT_MAX_LENGTH);
        if (placeInfo !== undefined) {
            poi._shortDesc = placeInfo;
            source = "GPT"
        }
        interestResponse = await getInterestValue(poi._poiName, poi._shortDesc);
        num = interestResponse.rate || 0;
    }
    let pic = await page_image;
    let pic_array = [];
    if (pic !== undefined)
        pic_array.push(pic);
    if (source !== "")
        poi._source = source;
    poi._pic = pic_array;
    return poi
}

function writePoisToJsonFile(pois_list: Poi[], json_name: string = "") {
    const JsonPoisList = JSON.stringify(pois_list);
    // write the pois list to a json file
    let fs = require('fs')
    fs.writeFile(`./src/outputs/gm_pois_${json_name}description.json`, JsonPoisList, function (err: any) {
        if (err) {
        }
    });
}


export async function translateDescriptions(pois_list: Poi[], language: string): Promise<Poi[]> {
    const translationPromises = pois_list.map(async (poi) => {
        let translated_description = await translate(poi._shortDesc, language);
        return translated_description === undefined ? poi._shortDesc : translated_description;
    });
    const translated_descriptions = await Promise.all(translationPromises);
    for (let i = 0; i < pois_list.length; i++) {
        pois_list[i]._shortDesc = translated_descriptions[i];
    }
    return pois_list;
}




let pois_list: Poi[] = data.map((poi : any) => poi)

processPois(pois_list).then((res) => {
    writePoisToJsonFile(res)
    translateDescriptions(res, 'hebrew').then((translated_pois) => {
        writePoisToJsonFile(translated_pois, "translated_")
        console.log("translated pois");
    })
})