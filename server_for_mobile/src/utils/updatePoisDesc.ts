
const { MongoClient } = require('mongodb');
import * as dotenv from 'dotenv' // see https://github.com/motdotla/dotenv#how-do-i-use-dotenv-with-import
import { gptPlaceInfo } from '../chat-gpt/gpt-api';

const uri = "mongodb+srv://root:root@autotripguide.swdtr.mongodb.net/myFirstDatabase?retryWrites=true&w=majority";
const dbClientSearcher = new MongoClient(uri);

//init
async function init() {
    try {
        dotenv.config()
        await dbClientSearcher.connect();
        console.log("Connected to search DB")
        
    } catch (e) {
        console.log('Failed to connect to mongo DB')
        console.error(e); 
    }
}

async function run() {
    try {
        console.log('init')
        await init()
        console.log('client connected')
        const db = dbClientSearcher.db('auto_trip_guide_db');
        const collection = db.collection('poisCollection');

        const calculateNewShortDesc = (poi: any) => {
            const newShortDesc = '///'
            // Your code to calculate new _shortDesc value for each poi item
            return newShortDesc;
        }

        const approvedByValue = 'shirin&avi';
        const shortDescValue = '^\[chatGPT]\]';

        // const pois = await collection.find({ _ApprovedBy: approvedByValue, _shortDesc: { $regex: shortDescValue } }).toArray();
        const pois = await collection.find({ _poiName: "picolonia city",_shortDesc: { $regex: /chatGPT-v3/, $options: 'i' },_ApprovedBy: approvedByValue }).toArray();
        let total = 0
        console.log(pois.length)
        const batchSize = 30; // Adjust this value as needed
        for (let i = 0; i < pois.length; i += batchSize) {
            const batch = pois.slice(i, i + batchSize);
            const updatePromises = batch.map(async (poi:any) => {
              const newShortDesc = await gptPlaceInfo(poi._poiName, poi._country, 128);
              console.log(newShortDesc);
              await collection.updateOne(
                { _id: poi._id },
                { $set: { _shortDesc: `[chatGPT-v3] ${newShortDesc}` } }
              );
            });
            await Promise.all(updatePromises);
          }
         for (const poi of pois) {
          //  console.log(poi)
            // const newShortDesc = await gptPlaceInfo(poi._poiName,poi._country, 128)
            // console.log(newShortDesc)
            //  await collection.updateOne({ _id: poi._id }, { $set: { _shortDesc: `[chatGPT-v2] ${newShortDesc}` } });
            //  total = total + 1
            //  console.log('update total: '+  total)
        }
    } finally {
        await dbClientSearcher.close();
    }
}

run().catch(console.dir);