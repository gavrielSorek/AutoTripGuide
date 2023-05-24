import axios from 'axios';
import * as dotenv from 'dotenv';
import { Event } from '../core/event';
import { gptEventInfo } from '../apis/gpt-api';

dotenv.config();

const API_KEY = process.env.MEETUP_API_KEY;
const LATITUDE = 40.758; // NY
const LONGITUDE = -73.985; // NY
const RADIUS = 10; // km

//https://secure.meetup.com/oauth2/authorize?client_id={YOUR_CLIENT_KEY}&response_type=token&redirect_uri={YOUR_CLIENT_REDIRECT_URI}


export async function getEventsMeetup(lat: number, lon: number, radius: number, start_date: Date, end_date: Date): Promise<Event[]> {
  const start = Math.floor(start_date.getTime() / 1000); // Convert start date to UNIX timestamp
  const end = Math.floor(end_date.getTime() / 1000); // Convert end date to UNIX timestamp

  const url = 'https://api.meetup.com/find/upcoming_events';
  const response = await axios.get(url, {
    params: {
      key: API_KEY,
      lat,
      lon,
      radius,
      start_date_range: start,
      end_date_range: end,
      page: 30, // Number of events per page
      fields: 'featured_photo', // include featured photo in the response
      order: 'time', // order events by time
    },
  });

  const events: Event[] = await Promise.all(
    response.data.events.map(async (event: any) => {
      const event_type = event.group.category ? event.group.category.name : 'Unknown';
      if (!event.description) {
        let place_info = await gptEventInfo(event.name, 30);
        if (place_info !== undefined) {
          event.description = place_info;
        }
      }
      return new Event(
        event.id,
        event.group.lat,
        event.group.lon,
        event.name,
        event_type,
        event.link,
        new Date(event.time).toISOString(), // Convert to ISO string format
        new Date(new Date(event.time).getTime() + event.duration),
        //new Date(event.time + event.duration),
        'unknown', // You can map the event status from Meetup API response
        event.group.name,
        'unknown', // You can map the event locale from Meetup API response
        `${event.group.city}, ${event.group.country}`,
        event.group.localized_location,
        '', // You can add the event image URL if available in the Meetup API response
        event.description,
        'meetup'
      );
    })
  );
  return events;
}



// export async function getEventsMeetup(lat: number, lon: number, radius: number, start_date: Date, end_date: Date): Promise<Event[]> {
//   const url = 'https://api.meetup.com/gql';

//   const query = `
//     query($lat: Float!, $lon: Float!, $radius: Float!, $start: DateTime!, $end: DateTime!, $size: Int!) {
//         eventsSearch(filter: { status: UPCOMING }, input: { first: $size, lat: $lat, lon: $lon, radius: $radius, eventDateMin: $start, eventDateMax: $end }) {
//           edges {
//             node {
//               id
//               name
//               time
//               duration
//               link
//               status
//               group {
//                 name
//                 lat
//                 lon
//               }
//               venue {
//                 name
//                 city
//                 localized_country_name
//                 address_1
//               }
//               featured_photo {
//                 highres_link
//               }
//             }
//           }
//         }
//       }
//     }
//   `;

//   const variables = {
//     lat,
//     lon,
//     radius,
//     start: start_date.toISOString(),
//     end: end_date.toISOString(),
//     size: 30, // number of events
//   };

//   const response = await axios.post(url, { query, variables }, {
//     params: {
//       key: API_KEY,
//     },
//   });

//   const events: Event[] = await Promise.all(response.data.data.proNetworkByUrlname.eventsSearch.edges.map(async (edge: any) => {
//     const event = edge.node;
//     const event_type = event.group ? event.group.name : 'Unknown';

//     if (!event.description) {
//       let place_info = await gptEventInfo(event.name, 30);
//       if (place_info !== undefined) {
//         event.description = place_info;
//       }
//     }

//     const startDateTime = new Date(event.time).toISOString();
//     const endDateTime = new Date(event.time + event.duration).toISOString();

//     return new Event(
//       event.id,
//       event.group.lat,
//       event.group.lon,
//       event.name,
//       event_type,
//       event.link,
//       startDateTime,
//       new Date(new Date(event.time).getTime() + event.duration),
//       event.status,
//       event.venue?.name,
//       event.venue?.localized_country_name,
//       `${event.venue?.city}, ${event.venue?.localized_country_name}`,
//       event.venue?.address_1,
//       event.featured_photo?.highres_link,
//       event.description,
//       "meetup"
//     );
//   }));

//   return events;
// }




async function writeEventsToJsonFile(events: Event[]): Promise<void> {
  const fs = require('fs');
  fs.writeFile('src/outputs/events_meetup.json', JSON.stringify(events, null, 2), (err: any) => {
    if (err) throw err;
  });
}

async function main() {
  try {
    const today = new Date();
    const next_week = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000);
    const events = await getEventsMeetup(LATITUDE, LONGITUDE, RADIUS, today, next_week);
    await writeEventsToJsonFile(events);
    console.log('Events saved to json');
  } catch (error: any) {
    console.error(error.message);
  }
}

main();
