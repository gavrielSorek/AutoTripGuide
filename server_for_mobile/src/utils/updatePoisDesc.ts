
const { MongoClient } = require('mongodb');
import * as dotenv from 'dotenv' // see https://github.com/motdotla/dotenv#how-do-i-use-dotenv-with-import

const uri = "mongodb+srv://root:root@autotripguide.swdtr.mongodb.net/myFirstDatabase?retryWrites=true&w=majority";
const dbClientSearcher = new MongoClient(uri);

//init
async function init() {
    try {
        dotenv.config()
        await dbClientSearcher.connect();
        console.log("Connected to search DB")
        // tryModule()
        
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
        const pois = await collection.find({ _shortDesc: { $regex: /chatGPT/, $options: 'i' },_ApprovedBy: approvedByValue }).toArray();
        console.log(pois.length)
        console.log(pois[0])
        // for (const poi of pois) {
        //     const newShortDesc = calculateNewShortDesc(poi);
        //     await collection.updateOne({ _id: poi._id }, { $set: { _shortDesc: newShortDesc } });
        // }
    } finally {
        await dbClientSearcher.close();
    }
}

run().catch(console.dir);