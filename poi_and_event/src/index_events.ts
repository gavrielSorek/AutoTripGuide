import { Event } from './core/event';
import { geohashCover, biggerCircle, removeDuplicates } from './utils/geo_hash';
import { checkGeohashesExist, getEventsByGeohashes, upsertEvents, upsertGeohashes } from './data/db_events';
import { DAYS_EXPIRED_EVENT, GEO_SIZE } from './utils/constants';
import { getDistance } from './utils/distance';
import { getEventsTM } from './eventApis/events_ticketmaster';
import { Circle } from './utils/geo_hash';


export async function getEvents(lat: number, lon: number, rad: number, endDate: Date): Promise<Event[]> {
    rad = rad * 1000;
    let geo_hashes = geohashCover(lat, lon, rad, GEO_SIZE);
    let events: boolean = await checkGeohashesExist(geo_hashes, DAYS_EXPIRED_EVENT);

    events = false;

    // if events exist in db no need to fetch from ticketmaster and others.
    if (events) {
        console.log("fetching from db");
        let events = await getEventsByGeohashes(geo_hashes);

        // filter events by distance 
        let result = events.filter((event: Event) => {
            return getDistance(lat, lon, event.lat, event.lon) <= rad;
            
        });
        return result;
    }


    // if events don't exist in db, fetch from ticketmaster and then insert to db.
    else {
        console.log("fetching from ticketmaster");
        let circle: Circle = biggerCircle({ lat: lat, lon: lon, rad: rad }, GEO_SIZE);
        let events = await getEventsTM(circle.lat, circle.lon, circle.rad, new Date(), endDate);


        //events = removeDuplicates(events, GEO_SIZE);


        // insert events to db
        let relevantGeohashes = geohashCover(lat, lon, rad, GEO_SIZE);


        // filter events by relevant geohashes
        let eventsToInsert = events.filter((event: Event) => {
            return relevantGeohashes.includes(event.geoHash);
        });



        let upsert_event_res: boolean = await upsertEvents(events);
        let upsert_geo_res: boolean = await upsertGeohashes(relevantGeohashes);

        // filtering the events and returning to the user.
        let result = events.filter((event: Event) => {
            return getDistance(lat, lon, event.lat, event.lon) <= rad;
        });

        if (await upsert_event_res == false)
            console.log("upsert event failed");
        if (await upsert_geo_res == false)
            console.log("upsert geohash failed");
        return result;
    }
}

// times square
const LATITUDE1 = 40.758;
const LONGITUDE1 = -73.985;


// london
const LATITUDE2 = 51.5074;
const LONGITUDE2 = 0.1278;

// madrid
const LATITUDE3 = 40.4168;
const LONGITUDE3 = -3.7038;




const RADIUS = 10; // km
// Date in 7 days
const END_DATE = new Date(new Date().getTime() + 7 * 24 * 60 * 60 * 1000);


let a = performance.now();

getEvents(LATITUDE2, LONGITUDE2, RADIUS, END_DATE).then((events) => {
    console.log("number of events: " + events.length);
    let b = performance.now();
    console.log("time: " + (b - a) / 1000 + " seconds");
})