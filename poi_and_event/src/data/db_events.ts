import * as dotenv from 'dotenv'
import { getDistance } from '../utils/distance'
import { Event } from '../core/event'
import { Geo } from '../core/geo'
import { isSamePlace } from '../utils/same_place'
import { DB_NAME, DB_COLLECTION_NAME, DISTANCE_THRESHOLD_NEW_POI, EVENT_COLLECTION_NAME, GEO_COLLECTION_NAME } from '../utils/constants'
dotenv.config()

const DAY_IN_MILLISECONDS = 86400000;


const { MongoClient, ServerApiVersion, BulkWriteResult } = require('mongodb');
const username = process.env.DB_USERNAME
const password = process.env.DB_PASSWORD
const uri = `mongodb+srv://${username}:${password}@cluster0.aafyqdr.mongodb.net/?retryWrites=true&w=majority`;
const client = new MongoClient(uri, { useNewUrlParser: true, useUnifiedTopology: true, serverApi: ServerApiVersion.v1 });



export async function addEventToDB(event: Event, radius: number): Promise<Boolean> {
  try {
    await client.connect();
    const EventTest = client.db(DB_NAME).collection(EVENT_COLLECTION_NAME);
    await EventTest.createIndex({ expireAt: 1 }, { expireAfterSeconds: 0 });
    const result = await EventTest.insertOne(event);
    return true;
  } catch (err) {
    console.error(err);
    return false;
  } finally {
    await client.close();
  }
}

export async function upsertEvents(events: Event[]): Promise<boolean> {
  try {
    await client.connect();
    const eventsCollection = client.db(DB_NAME).collection(EVENT_COLLECTION_NAME);
    const bulkOps = events.map(event => ({
      updateOne: {
        filter: { id: event.id },
        update: { $set: event },
        upsert: true
      }
    }));
    const bulkWriteResult = await eventsCollection.bulkWrite(bulkOps);
    return true;
  } catch (err) {
    console.error(err);
    return false;
  } finally {
    await client.close();
  }
}

export async function getEventsByGeohashes(geohashes: string[]): Promise<Event[]> {
  try {
    await client.connect();
    const events = client.db(DB_NAME).collection(EVENT_COLLECTION_NAME);
    const result = await events.find({ geoHash: { $in: geohashes } }).toArray();
    return result;
  } catch (err) {
    console.error(err);
    return [];
  } finally {
    await client.close();
  }
}


export async function checkGeohashesExist(geohashes: string[], maxAgeInDays: number): Promise<boolean> {
  try {
    await client.connect();
    const geosCollection = client.db(DB_NAME).collection(GEO_COLLECTION_NAME);
    const foundGeohashes = await geosCollection.find({
      getHash: { $in: geohashes },
      lastUpdated: { $gte: new Date(Date.now() - maxAgeInDays * DAY_IN_MILLISECONDS) }
    }).toArray();
    return foundGeohashes.length === geohashes.length;
  } catch (err) {
    console.error(err);
    return false;
  } finally {
    await client.close();
  }
}

export async function upsertGeohashes(geohashes: string[]): Promise<boolean> {
  try {
    await client.connect();
    const geosCollection = client.db(DB_NAME).collection(GEO_COLLECTION_NAME);
    const bulkOps = geohashes.map((geohash) => ({
      updateOne: {
        filter: { getHash: geohash },
        update: { $set: { lastUpdated: new Date() } },
        upsert: true
      }
    }));
    const result = await geosCollection.bulkWrite(bulkOps);
    return result;
  } catch (err) {
    console.error(err);
    return false;
  } finally {
    await client.close();
  }
}
