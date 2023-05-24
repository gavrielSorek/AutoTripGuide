import axios from 'axios';
import * as dotenv from 'dotenv'

dotenv.config()

let API_KEY = process.env.EVENTBRITE_API_KEY;

const EVENTBRITE_API_URL = 'https://www.eventbriteapi.com/v3/events/search/';
const EVENTBRITE_API_TOKEN = 'YOUR_EVENTBRITE_API_TOKEN';

const categories = [
  'music', 'film', 'food', 'sports', 'business', 'arts', 'performances', 'community', 'science',
  'technology', 'travel', 'charity', 'fashion', 'health', 'holiday', 'home_lifestyle', 'auto_boat_air',
  'hobbies', 'school_activities', 'other'
];

const getEvents = async () => {
  const events = [];
  for (let i = 0; i < categories.length; i++) {
    const response = await axios.get(EVENTBRITE_API_URL, {
      headers: {
        Authorization: `Bearer ${EVENTBRITE_API_TOKEN}`
      },
      params: {
        location: 'london',
        categories: categories[i],
        start_date_range: 'this_week'
      }
    });
    events.push(...response.data.events);
  }
  return events;
}

getEvents().then((events) => {
  console.log(events);
}).catch((error) => {
  console.error(error);
});







// const searchEvents = async () => {
//   const response = await axios.get(URL, {
//     headers: {
//       Authorization: `Bearer ${API_KEY}`,
//     },
//     params: {
//       q: 'London',
//       'location.address': 'London',
//       'start_date.range_start': '2023-04-17T00:00:00Z',
//       'start_date.range_end': '2023-04-23T23:59:59Z',
//     },
//   });
  
//   console.log(response.data.events);
// };

