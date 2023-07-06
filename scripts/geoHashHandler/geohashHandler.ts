import { MongoClient, Db, Collection } from 'mongodb';
import * as geohash from 'ngeohash';
// Define interfaces for coordinates and bounds
interface Coordinates {
    lat: number;
    lng: number;
}

interface GeoBounds {
    southWest: Coordinates;
    northEast: Coordinates;
}

// Function to get geohash bounds by geohash string
function getGeoHashBoundsByGeoStr(geohashStr: string): GeoBounds {
    const geoBounds = geohash.decode_bbox(geohashStr);
    const bounds: GeoBounds = {
        southWest: { lat: geoBounds[0], lng: geoBounds[1] },
        northEast: { lat: geoBounds[2], lng: geoBounds[3] }
    };
    return bounds;
}

class AutoTripGuideDB {
    client: MongoClient;
    dbName: string;
    collectionName: string;
    collection: Collection | null = null;
    db: Db | null = null;

    constructor(url: string, dbName: string, collectionName: string) {
        this.client = new MongoClient(url);
        this.dbName = dbName;
        this.collectionName = collectionName;
    }

    async connect() {
        await this.client.connect();
        this.db = this.client.db(this.dbName);
        this.collection = this.db.collection(this.collectionName);
    }

    async disconnect() {
        await this.client.close();
    }

    async findGeoHash(geoHashStr: string) {
        if (!this.collection) {
            throw new Error('Database not connected');
        }

        const record = await this.collection.findOne({ geoHashStr: geoHashStr });

        if (!record) {
            console.log('No record found');
            return null;
        }

        console.log('Record found:', record);
        return record;
    }

    async deleteGeoHash(geoHashStr: string) {
        if (!this.collection) {
            throw new Error('Database not connected');
        }

        const deleteResult = await this.collection.deleteOne({ geoHashStr: geoHashStr });

        if (deleteResult.deletedCount === 0) {
            console.log('No record found to delete');
            return false;
        }

        console.log('Successfully deleted record');
        return true;
    }

    async getAllGeohash(): Promise<string[]> {
        if (!this.collection) {
            throw new Error('Database not connected');
        }

        const records = await this.collection.find({}, { projection: { _id: 0, geoHashStr: 1 } }).toArray();
        return records.map(record => record.geoHashStr);
    }
    
}

async function main() {
    const db = new AutoTripGuideDB("mongodb+srv://root:root@autotripguide.swdtr.mongodb.net/myFirstDatabase?retryWrites=true&w=majority",
     'auto_trip_guide_db', 'cachedAreas');
    await db.connect();
    console.log(await db.findGeoHash('sv8y9'));
    const allGeohashes = await db.getAllGeohash();

    console.log(allGeohashes);

    // await db.deleteGeoHash('sv8y9');

    await db.disconnect();
}

main();
