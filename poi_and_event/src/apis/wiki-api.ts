import axios from 'axios'
import { getDistance } from '../utils/distance'
import { Poi } from '../core/poi'
import { wordSimilarity } from '../utils/same_place';
import { match } from 'assert';
import * as dotenv from 'dotenv'

dotenv.config()

export interface wikiPlaceResponse {
    photo?: string;
    description?: string;
    lat?: number;
    lon?: number;
}

export async function wikiPlaceInfo(placeName: string, checkDist: number = 1, lat?: number, lon?: number): Promise<string | undefined> {
    let url: string = "https://en.wikipedia.org/w/api.php?format=json";

    let params: { [key: string]: string } = {
        action: "query",
        prop: "extracts|coordinates|categories",
        exintro: "",
        explaintext: "",
        redirects: "1",
        titles: placeName
    };
    url = buildUrl(url, params);
    try {
        const response = await axios.get(url);
        let pageId: string = Object.keys(response.data.query.pages)[0];
        const placeInfo = response.data.query.pages[pageId];
        if (placeInfo.coordinates && checkDist) {
            let lat1: number = placeInfo.coordinates[0].lat;
            let lon1: number = placeInfo.coordinates[0].lon;
            if (lat && lon && getDistance(lat, lon, lat1, lon1) < 0.1)
                return undefined;
        }
        //if(placeInfo.extract.includes("most commonly refers to:")) 
        //    return handleRefersTo(placeInfo.extract, lat, lon);
        return await placeInfo.extract;
    }
    catch (error) {
        return undefined;
    }
}

export async function wikiNearestPlaces(lat: number, lon: number, radius: number): Promise<Poi[] | undefined> {

    const url = `https://en.wikipedia.org/w/api.php?action=query&list=geosearch&gscoord=${lat}|${lon}&gsradius=${radius}&format=json`;
    const response = await axios.get(url);
    const places = response.data.query.geosearch;
    if (places === undefined)
        return undefined;
    let pois: Poi[] = [];
    for (let place of places) {
        let poi = new Poi("", place.title, place.title, place.lat, place.log, "");
        let placeInfo = await wikiPlaceInfo(poi._poiName);
        if (placeInfo !== undefined) {
            poi._shortDesc = placeInfo;
            pois.push(poi);
        }
    }
    return pois;
}


async function handleRefersTo(text: string, lat?: number, lon?: number): Promise<string | undefined> {
    let lines = text.split("\n")
    if (lat && lon)
        return wikiPlaceInfo(lines[3].split(",")[0], 1, lat, lon);
    return wikiPlaceInfo(lines[3].split(",")[0]);
}

function buildUrl(url: string, params: { [key: string]: string }): string {
    Object.keys(params).forEach(function (key) {
        url += "&" + key;
        if (params[key] !== "")
            url = url + "=" + params[key];
    });
    return url;
}

export async function searchWikipedia(place: string, category: string): Promise<string> {
    const googleSearchUrl = `https://www.google.com/search?q=${encodeURIComponent(`${place} ${category} wikipedia`)}`;
    const { data } = await axios.get(googleSearchUrl);
    const match = data.match(/https?:\/\/(?:[a-z]+\.)?wikipedia\.org\/wiki\/([^"&]+)/);
    return match ? match[1] : null;
}

export async function searchWikipedia2(place: string, category: string): Promise<string> {
    const googleSearchUrl = `https://www.google.com/search?q=${encodeURIComponent(`${place} ${category} wikipedia`)}`;
    const { data } = await axios.get(googleSearchUrl);
    const matches = data.match(/https?:\/\/(?:[a-z]+\.)?wikipedia\.org\/wiki\/([^"&]+)/g);
    console.log(matches.length)
    if (matches && matches.length >= 2) {
        const firstPageName = matches[0].split('/').pop();
        const secondPageName = matches[1].split('/').pop();
        console.log(firstPageName, " ", secondPageName)
        if (wordSimilarity(firstPageName.replaceAll("_", " "), place) > wordSimilarity(secondPageName.replaceAll("_", " "), place)) {
            return firstPageName;
        } else {
            return secondPageName;
        }
    }
    else {
        return matches[0] ? matches[0].split('/').pop() : null;
    }
}

export async function searchWikipedia3(name: string, category: string): Promise<string> {
    const apiKey = process.env.GM_API_KEY;
    const cx = process.env.GOOGLE_CX;
    const query = `${name}}`;
    const endpoint = `https://www.googleapis.com/customsearch/v1?key=${apiKey}&cx=${cx}&q=${query}`;

    try {
        const response = await axios.get(endpoint);
        let firstPageName = response.data.items[0].link.split('/').pop();
        let secondPageName = response.data.items[1].link.split('/').pop();
        if (wordSimilarity(firstPageName.replaceAll("_", " "), name) > wordSimilarity(secondPageName.replaceAll("_", " "), name)) {
            return firstPageName;
        } else {
            return secondPageName;
        }
    } catch (error) {
        console.error(error);
        return "";
    }
}


export async function wikiPageImage(placeName: string, type?: string): Promise<string | undefined> {
    let url: string = "https://en.wikipedia.org/w/api.php?format=json";
    let params: { [key: string]: string } = {
        formatversion: "2",
        action: "query",
        prop: "pageimages",
        piprop: "original",
        titles: placeName
    };
    url = buildUrl(url, params);
    try {
        const response = await axios.get(url);
        let pageId: string = Object.keys(response.data.query.pages)[0];
        const placeInfo = response.data.query.pages[pageId];
        if (placeInfo.original.source) {
            return placeInfo.original.source;
        }
        return undefined;
    }
    catch (error) {
        return undefined;
    }
};


export async function wikiAllPageInfo(placeName: string): Promise<wikiPlaceResponse> {
    const url = "https://en.wikipedia.org/w/api.php";
    const params = {
        format: "json",
        formatversion: "2",
        action: "query",
        prop: "pageimages|extracts|coordinates|categories",
        piprop: "original",
        titles: placeName,
    };
    try {
        const response = await axios.get(url, { params });
        const page = response.data.query.pages[0];
        const wikiResponse: wikiPlaceResponse = {
            photo: page.original?.source,
            description: "page.extract",
            lat: page.coordinates?.[0]?.lat,
            lon: page.coordinates?.[0]?.lon,
        };
        return wikiResponse;
    } catch (error) {
        return {};
    }
}

export function placeLikelihood(place: wikiPlaceResponse): number {
    let likelihood = 0;
    if (place.lat || place.lon) {
        likelihood += 5;
    }
    if (place.photo) {
        likelihood += 5;
    }
    return likelihood;
}
