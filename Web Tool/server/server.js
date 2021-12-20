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
const dbClient = new MongoClient(uri);


//init
async function init() {
    try {
        await dbClient.connect();
        console.log("Connected to search DB")
    } catch (e) {
        console.error(e); 
    }
}

async function closeServer(){
    await dbClient.close();
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
            await db.insertAudio(audioDbClient, audio, poiName, "null at this point")
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
    return db.findPois(dbClient, poiParam, paramVal, relevantBounds, MAX_ELEMENT_ON_MAP, searchOutsideTheBounds);
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

// Route that handles create new user logic
async function createNewUser(userInfo) {
    await db.createNewUser(dbClient, userInfo);
}

//create new user logic
app.post('/createNewUser', async function(req, res) {
    console.log("create new user request in the server")
    const data = req.body;
    createNewUser(data);
    var json_res = {
        x: "1",
        y: "2",
        z: "3"
     }
    res.status(200);
    res.json(json_res);
    res.end(); 
})

// Route that handles create new user logic
async function login(userInfo) {
    return await db.login(dbClient, userInfo);
}

//create new user logic
app.post('/login', async function(req, res) {
    console.log("login request in the server")
    const data = req.body;
    ret = login(data).then(function(response) {
        console.log("----------------------------")
        res.status(200);
        res.json(response);
        res.end();
    })  
})

// Start your server on a specified port
app.listen(port, async ()=>{
    await init()
    console.log(`Server is runing on port ${port}`)
})

