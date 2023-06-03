import { getNearbyPois } from "../nearby_pois_objects";
const serverCommunication = require("../../../services/serverCommunication");
import * as dotenv from 'dotenv' // see https://github.com/motdotla/dotenv#how-do-i-use-dotenv-with-import
var tokenGetter = require("../../../services/serverTokenGetter");
const { MongoClient } = require('mongodb');




const uri = "mongodb+srv://root:root@autotripguide.swdtr.mongodb.net/myFirstDatabase?retryWrites=true&w=majority";

const dbClientSearcher = new MongoClient(uri);
const dbClientAudio = new MongoClient(uri);
var globaltokenAndPermission:any = undefined;
const geoHashPrecitionLevel = 5;

//init
async function init() {
    try {
        dotenv.config()
        await dbClientSearcher.connect();
        await dbClientAudio.connect();
        globaltokenAndPermission = await tokenGetter.getToken('crawler@gmail.com', '1234', serverCommunication.getServerUrl()) //get tokens and permissions for web server
        console.log("Connected to search DB")
        // tryModule()
        
    } catch (e) {
        console.log('Failed to connect to mongo DB')
        console.error(e); 
    }
}

async function run() {


    const poi_types = ['airport', 'art_gallery', 'church', 'synagogue', 'casino', 'park', 'stadium', 'city_hall', 'zoo', 'museum', 'tourist_attraction', 'movie_theater']
    const t = await getNearbyPois(32.174384, 34.840811,30,'')
    serverCommunication.sendPoisToServer([t[0] ], globaltokenAndPermission)
    console.log(t[0])
}

run().catch(console.dir);