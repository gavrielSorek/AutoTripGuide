
import { Event } from '../core/event'
import { encode, neighbors, decode, decode_bbox } from 'ngeohash';
import Geohash from 'ngeohash';
import { isSamePlace } from '../utils/same_place';
import { getDistance } from '../utils/distance';
import { DISTANCE_THRESHOLD_NEW_EVENT } from '../utils/constants';
var proximityhash = require('proximityhash');
import * as geolib from 'geolib';


export interface BoundingBox {
    minLat: number;
    maxLat: number;
    minLong: number;
    maxLong: number;
}

export interface Circle {
    lat: number;
    lon: number;
    rad: number;
}


interface EventWithId {
    event: Event;
    id: number
}
export function removeDuplicates(array: Event[], precision: number): Event[] {
    const eventsWithId: EventWithId[] = array.map((event, index) => ({ event: event, id: index }));
    let map: Map<string, EventWithId[]> = groupByGeohash(eventsWithId, precision);
    let result: Event[] = [];
    let inserted: Set<number> = new Set<number>();
    for (const evi of eventsWithId) {
        const hash = encode(evi.event.lat, evi.event.lon, precision);
        const neighbors_hash: string[] = neighbors(hash).concat(hash);

        for (const n of neighbors_hash) {
            const geo_events = map.get(n) || [];
            for (const e of geo_events) {
                if (isSamePlace(e.event.name, evi.event.name)) {
                    // Give same id to same event
                    let min = Math.min(e.id, evi.id);
                    e.id = evi.id = min;
                    // Check if event is already inserted 
                    if (!inserted.has(evi.id)) {
                        result.push(evi.event);
                        inserted.add(evi.id);
                    }
                }
                else if (!inserted.has(evi.id)) {
                    result.push(evi.event);
                    inserted.add(evi.id);
                }
            }
        }
    }
    return result;
}

function groupByGeohash(array: EventWithId[], precision: number): Map<string, EventWithId[]> {
    let map = new Map<string, EventWithId[]>();
    for (const evi of array) {
        let e: Event = evi.event;
        const hash = encode(e.lat, e.lon, precision);
        if (map.has(hash))
            map.get(hash)?.push(evi);
        else
            map.set(hash, [evi]);
    }
    return map;
}


export function removeDuplicates2(array: Event[]) {
    return array.filter(function (item, pos) {
        return pos === array.findIndex(function (e) {
            return isSamePlace(e.name, item.name) && getDistance(e.lat, e.lon, item.lat, item.lon) * 1000 < DISTANCE_THRESHOLD_NEW_EVENT;
        });
    }
    );
}


// radius in meters
export function geohashCover(lat: number, lon: number, radius: number, precision: number): string[] {
    var options = {
        latitude: lat, //required
        longitude: lon,//required
        radius: radius,// in mts, required
        precision: precision,// geohash precision level , required
        georaptorFlag: false,  //set true to compress hashes using georaptor
        minlevel: precision, // minimum geohash level, default value: 1
        maxlevel: precision, // maximum geohash level, default value: 12
        approxHashCount: false // set to true to round off if the hashes count is greater than 27
    }
    let geohashes: string[] = proximityhash.createGeohashes(options);
    let uniq: string[] = [...new Set(geohashes)];
    return uniq;
}


// radius in meters
export function isGeohashInsideCircle(lat: number, lon: number, radius: number, geohash: string): boolean {
    const decoded = decode(geohash);
    const [minLat, minLon, maxLat, maxLon] = decode_bbox(geohash);
    const northDistance = getDistance(lat, lon, minLat, minLon) * 1000;
    const southDistance = getDistance(lat, lon, minLat, maxLon) * 1000;
    const eastDistance = getDistance(lat, lon, maxLat, minLon) * 1000;
    const westDistance = getDistance(lat, lon, maxLat, maxLon) * 1000;
    if (northDistance > radius || southDistance > radius || eastDistance > radius || westDistance > radius) {
        return false;
    }
    return true;
}

function getMaximalCircle(bbox: BoundingBox): Circle {
    const center = geolib.getCenter([
        { latitude: bbox.minLat, longitude: bbox.minLong },
        { latitude: bbox.maxLat, longitude: bbox.maxLong }
    ]) as { latitude: number; longitude: number };
    const radius = geolib.getDistance(
        { latitude: center.latitude, longitude: center.longitude },
        { latitude: bbox.minLat, longitude: bbox.minLong }
    );
    return { lat: center.latitude, lon: center.longitude, rad: radius };
}


// radius in meters
function circleMinimumBoundingBox(lat: number, lon: number, rad: number): BoundingBox {
    const radiusInDegrees = rad / 111000; // Convert radius from meters to degrees
    const latInRadians = lat * Math.PI / 180; // Convert center latitude to radians
    const minLat = lat - radiusInDegrees;
    const maxLat = lat + radiusInDegrees;
    const minLong = lon - (radiusInDegrees / Math.cos(latInRadians));
    const maxLong = lon + (radiusInDegrees / Math.cos(latInRadians));
    return { minLat, maxLat, minLong, maxLong };
}

function hashMinimumBoundingBox(geohashes: string[]): BoundingBox {
    let minLat = 90;
    let maxLat = -90;
    let minLon = 180;
    let maxLon = -180;

    for (const geohash of geohashes) {
        const [minLat_hash, minLon_hash, maxLat_hash, maxLon_hash] = decode_bbox(geohash);
        minLat = Math.min(minLat, minLat_hash);
        maxLat = Math.max(maxLat, maxLat_hash);
        minLon = Math.min(minLon, minLon_hash);
        maxLon = Math.max(maxLon, maxLon_hash);
    }
    return { minLat: minLat, maxLat: maxLat, minLong: minLon, maxLong: maxLon };
}

function geohashCover2(lat: number, lon: number, queryRadius: number, precision: number): string[] {
    const boundingBox = circleMinimumBoundingBox(lat, lon, queryRadius);
    let north_west = encode(boundingBox.maxLat, boundingBox.minLong, precision);
    let south_west = encode(boundingBox.minLat, boundingBox.minLong, precision);
    let south_east = encode(boundingBox.minLat, boundingBox.maxLong, precision);
    let north_east = encode(boundingBox.maxLat, boundingBox.maxLong, precision);
    const geohashes = [north_west, south_west, south_east, north_east];
    return []
}



export function biggerCircle(circle: Circle, precision: number) {
    const geohashes: string[] = geohashCover(circle.lat, circle.lon, circle.rad, precision);
    const bbox: BoundingBox = hashMinimumBoundingBox(geohashes);
    const biggerCircle: Circle = getMaximalCircle(bbox);
    return biggerCircle;
}


let c = geohashCover(32.14477481963984, 34.79331500737771, 500,5)
//console.log(c)

let b : BoundingBox = hashMinimumBoundingBox(c)
//console.log(b)

let circle : Circle = getMaximalCircle(b)
//console.log(circle)


// let d1 = getDistance(32.14477481963984, 34.79331500737771, 32.146003686082736, 34.804676909383254)
// let d2 = geolib.getDistance(
//     { latitude: 32.14477481963984, longitude: 34.79331500737771 },
//     { latitude: 32.146003686082736, longitude: 34.804676909383254 }
// );

// console.log(d1)
// console.log(d2)

// let gethashes = getGeoHashCover(32.14477481963984, 34.79331500737771, 50, 5);

// gethashes.forEach((hash) => {
//     console.log(hash);
// })

// gethashes.forEach((hash) => {
//     console.log(isGeohashInsideCircle(51.5074, 0.1278, 10000, hash));
// })


// let latitude1 = 51.5074;
// let longitude2 = 0.1278;


// let events: Event[] = [];

// let ev1 = new Event();
// ev1.name = "1";
// ev1.lat = 51.5074;
// ev1.lon = 0.1278;

// let ev2 = new Event();
// ev2.name = "2";
// ev2.lat = 51.5074;
// ev2.lon = 0.1278;

// let ev3 = new Event();
// ev3.name = "event1";
// ev3.lat = 51.5074;
// ev3.lon = 0.1278;

// let ev4 = new Event();
// ev4.name = "event2";
// ev4.lat = 51.5074;
// ev4.lon = 0.1278;

// events.push(ev1);
// events.push(ev2);
// events.push(ev3);
// events.push(ev4);

// let result = removeDuplicates(events, 6);
// for (const e of result) {
//     console.log(e.name);
// }

