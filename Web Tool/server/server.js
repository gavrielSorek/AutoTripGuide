const db = require("../db/db");
const wiki_service = require("../server/WikiServices/positionByNameWiki");

const { MongoClient } = require('mongodb');
const mongodb = require('mongodb');
var fs = require('fs');

const express = require('express')
bodyParser = require('body-parser');
const app = express()
app.use(bodyParser.urlencoded({limit: '50mb', extended: true}));
app.use(bodyParser.json({limit: '50mb'}));
let cors = require('cors')
app.use(cors())
const port = 5500
app.use(bodyParser.json() );       // to support JSON-encoded bodies
app.use(bodyParser.urlencoded({     // to support URL-encoded bodies
extended: false})); 
const MAX_ELEMENT_ON_MAP = 50

// Route that handles create New Poi logic

//init GLOBAL
uri = "mongodb+srv://root:root@autotripguide.swdtr.mongodb.net/myFirstDatabase?retryWrites=true&w=majority";
const dbPoiSearcherClient = new MongoClient(uri);

//init
async function init() {
    try {
        await dbPoiSearcherClient.connect();
        console.log("Connected to search DB")
    } catch (e) {
        console.error(e); 
    }
}

async function closeServer(){
    await dbPoiSearcherClient.close();
}


async function createNewPoi(poiName, longitude, latitude, shortDesc, language,
    audio, source, Contributor, CreatedDate, ApprovedBy, UpdatedBy, LastUpdatedDate) {
    const uri = "mongodb+srv://root:root@autotripguide.swdtr.mongodb.net/myFirstDatabase?retryWrites=true&w=majority";
    const dbClient = new MongoClient(uri);
    var audioDbClient = undefined
    var audioStatus = "no audio"
    if (audio) {
        audioDbClient = new MongoClient(uri);
        audioStatus = "audio exist"
    }
    try {
        await dbClient.connect();
        console.log("Connected to DB")
        await db.InsertPoi(dbClient, {
            _poiName: poiName,
            _latitude: latitude,
            _longitude: longitude,
            _shortDesc: shortDesc,
            _language: language,
            _audio: audioStatus,
            _source: source,
            _Contributor: Contributor,
            _CreatedDate: CreatedDate,
            _ApprovedBy: ApprovedBy,
            _UpdatedBy: UpdatedBy,
            _LastUpdatedDate: LastUpdatedDate
        });
        if (audioDbClient) {
            await audioDbClient.connect();
            await db.insertAudio(audioDbClient, Object.values(audio), poiName, "null at this point")
        }
    } catch (e) {
        console.error(e); 
    } finally {
        await dbClient.close();
    }
}

// Route that handles create New Pois logic
async function createNewPois(pois) {
    const uri = "mongodb+srv://root:root@autotripguide.swdtr.mongodb.net/myFirstDatabase?retryWrites=true&w=majority";
    const dbClient = new MongoClient(uri);
    try {
        await dbClient.connect();
        console.log("Connected to DB")
        await db.InsertPois(dbClient, pois);
    } catch (e) {
        console.error(e); 
    } finally {
       await dbClient.close();
    }
}

async function findPoisInfo(poiParam, paramVal,relevantBounds, searchOutsideTheBounds) {
    return db.findPois(dbPoiSearcherClient, poiParam, paramVal, relevantBounds, MAX_ELEMENT_ON_MAP, searchOutsideTheBounds);
}
//Route that create new poi logic
app.post('/createPoi', (req, res, next) =>{
    console.log("Poi info is recieved")
    const data = req.body; 
    console.log(data._poiName)
    var json_res = {
        x: "1",
        y: "2",
        z: "3"
     }
    createNewPoi(data._poiName, data._longitude, data._latitude, data._shortDesc, data._language,
        data._audio, data._source, data._Contributor, data._CreatedDate, data._ApprovedBy, data._UpdatedBy, data._LastUpdatedDate)
    res.status(200);
    res.json(json_res);
    res.end();
    next();
})

//Route that create new pois logic
app.post('/createPois', (req, res, next) =>{
    console.log("Pois info is recieved")
    const data = req.body; 
    var json_res = {
        x: "1",
        y: "2",
        z: "3"
     }
    createNewPois(data)
    res.status(200);
    res.json(json_res);
    res.end();
    next();
})

//search poi logic
app.post('/searchPois', async function(req, res) {
    console.log("Pois search general")
    const data = req.body;
    const queryParam = data.poiParameter;
    poisInfo = findPoisInfo(queryParam, data.poiInfo.poiParameter ,data.relevantBounds, data.searchOutsideTheBounds).then(function(pois) {
        console.log("----------------------------")
        res.status(200);
        res.json(pois);
        res.end();
    })
    
})






//Route that search poi logic
app.post('/findPoiPosition', async function(req, res) {
    console.log("find poi location request is recieved")
    const data = req.body;
    poiName = data._poiName
    language = data._language
    poiPosition = wiki_service.getPositionByName(poiName, language)
    poiPosition.then((position)=>{sendPosition(position, res)}).catch(()=>{console.log("error cant find this position")});
})

//return audio by name
async function retAudioByName(audioName, res) {
    console.log("the audio name: " + audioName)
    console.log("the server try to send the audio")
    const uri = "mongodb+srv://root:root@autotripguide.swdtr.mongodb.net/myFirstDatabase?retryWrites=true&w=majority";
    const dbClient = new MongoClient(uri);
    try {
        await dbClient.connect();
        console.log("Connected to DB")
        audioPromise = db.getAudio(dbClient, audioName)
        audioPromise.then(value => {
            res.json(value);
            console.log("success to send audio")
            res.status(200);
            dbClient.close()}).catch(err=>{console.log("cant retrive audio file")
            res.status(400)
            res.end();
            dbClient.close();})
    } catch (e) {
        console.error(e);
        res.status(400);
        res.end();
    }
}

//Route that search audio logic
app.post('/searchPoiAudioByName', async function(req, res) {
    console.log("audio search by name is recieved")
    const data = req.body;
    console.log(data)
    console.log(data._poiName)
    retAudioByName(data._poiName, res)
})

function sendPosition(position, res) {
    console.log("lat: " + position.lat + " lng: " + position.lon)
    var json_res = {
        latitude: position.lat,
        longitude: position.lon,
    }
    res.status(200);
    res.json(json_res);
    res.end();
}

// Start your server on a specified port
app.listen(port, async ()=>{
    await init()
    console.log(`Server is runing on port ${port}`)
})





// var http = require('http'); // 1 - Import Node.js core module

// var server = http.createServer(function (req, res) {   // 2 - creating server

//     //handle incomming requests here..

// });

// server.listen(5000); //3 - listen for any incoming requests

// console.log('Node.js web server at port 5000 is running..')


// const { MongoClient } = require('mongodb');

// async function main() {
//     const uri = "mongodb+srv://root:root@autotripguide.swdtr.mongodb.net/myFirstDatabase?retryWrites=true&w=majority";
//     const client = new MongoClient(uri);
//     try {
//         await client.connect();
//         await listDatabases(client)
//         // await createPoi(client, {
//         //     _poiName: "masada",
//         //     _latitude: "50",
//         //     _longitude: "50",
//         //     _shortDesc: "test",
//         //     _language: "test",
//         //     _audio: "test",
//         //     _source: "test",
//         //     _Contributor: "test",
//         //     _CreatedDate: "test",
//         //     _ApprovedBy: "test",
//         //     _UpdatedBy: "test",
//         //     _LastUpdatedDate: "test"
//         // });
//         await findPoiInfoByName(client, "masada");

//     } catch (e) {
//        console.error(e); 
//     } finally {
//        await client.close();
//     }
// }
// main().catch(console.error);

// async function findPoiInfoByName(client, nameOfPoi) {
//     const res = await client.db("testDb").collection("testCollection").find({_poiName: nameOfPoi});
    
//     const results = await res.toArray();

//     if(res) {
//         console.log(`found a poi in the collection with the name '${nameOfPoi}'`);
//         console.log(results);
//     } else {
//         console.log(`No poi found with the name '${nameOfPoi}'`);
//     }
// }


// async function createPoi(client, newPoi) {
//    const res = await client.db("testDb").collection("testCollection").insertOne(newPoi);
//     console.log(`new poi created with the following id: ${res.insertedId}`);
// }


// async function listDatabases(client) {
//     const dbList = await client.db().admin().listDatabases();
//     console.log("Databases: ");
//     dbList.databases.forEach(db => {
//         console.log(`-${db.name}`);
        
//     });
// }


