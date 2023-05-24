import * as dotenv from 'dotenv'
import { getDistance } from '../utils/distance'
import { Poi } from '../core/poi'
import { isSamePlace } from '../utils/same_place'
import { DB_NAME, DB_COLLECTION_NAME, DISTANCE_THRESHOLD_NEW_POI } from '../utils/constants'
dotenv.config()


const { MongoClient, ServerApiVersion } = require('mongodb');
const username = process.env.DB_USERNAME
const password = process.env.DB_PASSWORD
const uri = `mongodb+srv://${username}:${password}@cluster0.aafyqdr.mongodb.net/?retryWrites=true&w=majority`;
const client = new MongoClient(uri, { useNewUrlParser: true, useUnifiedTopology: true, serverApi: ServerApiVersion.v1 });


async function collectionsName() {
  try {
    await client.connect();
    const db = client.db(DB_NAME);
    const collections = await db.collections();
    collections.forEach((e: any) => { console.log(e.collectionName) })

    const Categories = client.db(DB_NAME).collection("Categories");
    // print all categories
    let cursor = await Categories.find({})
    let result = await cursor.toArray()
    result.forEach((e: any) => { console.log(e) })
    

  } catch (err) {
    console.error(err);
  } finally {
    await client.close();
  }
}

async function findPois(latitude: number, longitude: number, radius: number): Promise<Poi[]> {
  const earthRadius = 6371000; // meters
  const lat_dist = (radius / earthRadius) * (180 / Math.PI);
  const lon_dist = (radius / earthRadius) * (180 / Math.PI) / Math.cos(latitude * Math.PI / 180);
  let filter = {
    _latitude: { $gt: latitude - lat_dist, $lt: latitude + lat_dist },
    _longitude: { $gt: longitude - lon_dist, $lt: longitude + lon_dist }
  }
  //console.log(getDistance(latitude, longitude, latitude + lat_dist, longitude+ lon_dist));
  try {
    await client.connect();
    const pois = client.db(DB_NAME).collection(DB_COLLECTION_NAME);
    let cursor = await pois.find(filter)
    let found_poi = await cursor.toArray()
    //found_poi.forEach((e: any) => {
    //  console.log(getDistance(latitude, longitude, e._latitude, e._longitude))
    //})
    return found_poi;
    //console.log(result.length)
  } catch (err) {
    console.error(err);
    return [];
  } finally {
    await client.close();
  }
}


async function addPois(poi: Poi, radius: number): Promise<Boolean> {
  try {
    await client.connect();
    const pois = client.db(DB_NAME).collection(DB_COLLECTION_NAME);
    const overlappingPois = await findPois(poi._latitude, poi._longitude, radius);
    console.log(overlappingPois.length)
    for (let i = 0; i < overlappingPois.length; i++) {
      if (isSamePlace(poi._poiName, overlappingPois[i]._poiName)) {
        console.log("There is already a POI at this location.");
        return false;
      }
    }
    console.log("Adding POI to DB");
    //const result = await pois.insertOne(poi);
    return true;
  } catch (err) {
    console.error(err);
    return false;
  } finally {
    await client.close();
  }
}




//findPois(32.09583333333334, 35.46138888888889, 5)

//collectionsName()

// create poi instance with the name "alexandrium"
let poi : Poi = new Poi();
poi._poiName = "alexandrium hotel in haifa";
poi._latitude = 32.09583333333334;
poi._longitude = 35.46138888888889;


// add the poi to the db
addPois(poi, DISTANCE_THRESHOLD_NEW_POI);


//connectDB();

