import axios from 'axios';
import * as dotenv from 'dotenv'
import { Event } from '../core/event';
import { gptEventInfo } from '../apis/gpt-api';

dotenv.config()

let API_KEY = process.env.TICKETMASTER_API_KEY;
const LATITUDE = 40.758; //NY
const LONGITUDE = -73.985; //NY
// const LATITUDE = 51.54; //LONDON
// const LONGITUDE = 0; //LONDON
// const LATITUDE = 49; //PARIS
// const LONGITUDE = 2.3; //PARIS
const RADIUS = 10; // km


export async function getEventsTM(lat: number, lon: number, radius: number, start_date: Date, end_date: Date): Promise<Event[]> {
  const today_ISO = start_date.toISOString()
  const start = today_ISO.slice(0, 19) + 'Z';
  const next_week_ISO = end_date.toISOString()
  const end = next_week_ISO.slice(0, 19) + 'Z';
  const url = 'https://app.ticketmaster.com/discovery/v2/events.json';
  // const url = 'https://app.ticketmaster.com/international-discovery/v2/events.json';
  const response = await axios.get(url, {
    params: {
      apikey: API_KEY,
      geoPoint: `${lat},${lon}`,
      radius,
      startDateTime: start,
      endDateTime: end,
      size: 10, // number of events
      includeImages: "yes",
      includeTest: "yes", // include event description in response
      sort_by: 'popularity',
      //locale: 'en-us'
    }
  });

  const events: Event[] = await Promise.all(response.data._embedded.events.map(async (event: any) => {
    const classification = event.classifications.find((c: any) => c.primary === true);
    const event_type = classification ? classification.segment.name : 'Unknown';
    if (event.description === undefined) {
      let place_info = await gptEventInfo(event.name, 30);
      console.log(place_info)
      if (place_info !== undefined) {
        event.description = place_info;
      }
    }
    return new Event(
      event.id,
      event._embedded.venues[0].location.latitude,
      event._embedded.venues[0].location.longitude,
      event.name,
      event_type,
      event.url,
      event.dates.start.dateTime,
      event.dates.end?.dateTime,
      event.dates.status.code,
      event._embedded.venues[0].name,
      event._embedded.venues[0].locale,
      `${event._embedded.venues[0].city.name}, ${event._embedded.venues[0].country.countryCode}`,
      event._embedded.venues[0].address.line1,
      event.images[0].url,
      event.description,
      "ticketmaster"
    );
  }));
  return events;
}

async function writeEventsToJsonFile(events: Event[]): Promise<void> {
  let fs = require('fs')
  fs.writeFile("src/outputs/events_ticketmaster.json", JSON.stringify(events, null, 2), (err: any) => {
    if (err) throw err;
  });
}


async function main() {
  try {
    // format: "2023-04-25T23:59:00Z"
    var today = new Date();
    var next_week = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000);
    const events = await getEventsTM(LATITUDE, LONGITUDE, RADIUS, today, next_week);
    await writeEventsToJsonFile(events);
    console.log('Events saved to json');
  } catch (error: any) {
    console.error(error.message);
  }
}


main();