import axios from 'axios';
import * as dotenv from 'dotenv'
import { Event } from '../core/event';

dotenv.config()

const API_KEY = process.env.BANDSINTOWN_API_KEY;
const LATITUDE = 40.758;
const LONGITUDE = -73.985;
const RADIUS = 10; // miles

var today = new Date();
const START_DATE = today.toISOString().slice(0, 10);

var next_month = new Date((today.setDate(today.getDate() + 30)));
const END_DATE = next_month.toISOString().slice(0, 10);
// format: "2023-04-25"

const ARTIST_NAME = 'Red Hot Chili Peppers';

async function getEvents(artist: string, start_date: string, end_date: string): Promise<Event[]> {
    const date = `${start_date},${end_date}`;
    const url = `https://rest.bandsintown.com/artists/${artist}/events`;
    const response = await axios.get(url, {
        params: {
            app_id: API_KEY,
            // lat: LATITUDE,
            // lon: LONGITUDE,
            // radius: RADIUS,
            date: date,
            //per_page: 10
        }
    });

    const events: Event[] = response.data.map((event: any) => {
        return new Event(
            event.id,
            event.venue.latitude,
            event.venue.longitude,
            event.title,
            event.offers[0].type,
            event.url,
            event.on_sale_datetime,
            event.datetime,
            event.offers[0].status,
            event.venue.name,
            undefined,
            `${event.venue.city} ,${event.venue.country}`,
            event.venue.address,
        );
    });
    return events;
}

async function writeEventsToJsonFile(events: Event[]): Promise<void> {
    let fs = require('fs')
    fs.writeFile(`src/outputs/events_bandsintown.json`, JSON.stringify(events, null, 2), (err: any) => {
        if (err) throw err;
    });
}


async function main() {
    try {
        const events = await getEvents(ARTIST_NAME, START_DATE, END_DATE);
        await writeEventsToJsonFile(events);
        console.log('Events saved to json');
    } catch (error: any) {
        console.error(error.message);
    }
}

main();
