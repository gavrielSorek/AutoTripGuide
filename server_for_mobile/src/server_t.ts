const db = require("./db");
const generalServices = require('../../services/generalServices')
const onlinePoisFinder = require("./onlinePoisFinder");
const serverCommunication = require("../../services/serverCommunication");
var tokenGetter = require("../../services/serverTokenGetter");
var geohash = require('ngeohash');
import { getPois } from "./getPois";
import { Poi } from "./types/poi";
import { Request, Response } from 'express';
import { getDistance } from 'geolib';
import { Coordinate } from "./types/coordinate";
import * as dotenv from 'dotenv' // see https://github.com/motdotla/dotenv#how-do-i-use-dotenv-with-import
import { gptPlaceInfo } from "./chat-gpt/gpt-api";


const { MongoClient } = require('mongodb');

const express = require('express')
const bodyParser = require('body-parser');
const app = express()
app.use(bodyParser.urlencoded({limit: '50mb', extended: true}));
app.use(bodyParser.json({limit: '50mb'}));
const cors = require('cors');
app.use(cors())
const port = 5600
app.use(bodyParser.json() );       // to support JSON-encoded bodies
app.use(bodyParser.urlencoded({     // to support URL-encoded bodies
extended: false}));
const MAX_POIS_FOR_USER = 100
const MAX_DAYS_USE_AREA_CACHE = 30

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
// get searchPage page
app.get("/", async function (req:Request, res:Response) { //next requrie (the function will not stop the program)
    res.write("hello");
    res.end();
 })
 // get searchPage page
 app.get("/searchNearbyPois", async function (req:any, res:Response) { //next requrie (the function will not stop the program)
    const userData = {'lat': parseFloat(req.query.lat), 'lng': parseFloat(req.query.lng), 'speed': parseFloat(req.query.speed), 'heading': parseFloat(req.query.heading), 'language': req.query.language}
    const searchParams = {}
    addUserDataTosearchParams(searchParams, userData)

    var geoHashStrings = getGeoHashBoundsStrings(userData, geoHashPrecitionLevel);
    var boundsArr:any = [];
    // add all the bounds
    geoHashStrings.forEach((geoHashStr)=>{
        boundsArr.push(getGeoHashBoundsByGeoStr(geoHashStr))
    });
    var pois:Poi[] = []
    for (let i = 0; i < boundsArr.length; i++ ) {
        let tempPoisArr = await db.findPois(dbClientSearcher, searchParams, boundsArr[i], MAX_POIS_FOR_USER, false);
        pois = pois.concat(tempPoisArr);
    }
    const filterdPois = pois.filter(poi => poi._shortDesc.length > 10)

    res.status(200);
    res.json(filterdPois);
    res.end();
    
    // update the db with new pois if needed
    geoHashStrings.forEach(async (geoHashStr)=>{
        let areaData = await db.getCachedAreaInfo(dbClientSearcher, {geoHashStr: geoHashStr})
        //if the online searcher didn't search on this location
        if (areaData && generalServices.getNumOfDaysBetweenDates(generalServices.getTodayDate(), areaData.lastUpdated) < MAX_DAYS_USE_AREA_CACHE) {
            // do nothing - everything is updated
        } else {
            const bounds = getGeoHashBoundsByGeoStr(geoHashStr)
            updateDbWithOnlinePois(bounds, 'en');
            updateDbWithGoogleApiPois(bounds)
            const params = {geoHashStr: geoHashStr, lastUpdated: generalServices.getTodayDate()}
            db.addCachedAreaInfo(dbClientSearcher, params)
        }
    })
 })

 async function updateDbWithOnlinePois(bounds: any, language: string) {
    // async call for faster rsults
    await onlinePoisFinder.getPoisList(bounds, language,(poi: Poi)=>{
        serverCommunication.sendPoisToServer([poi], globaltokenAndPermission)
    }); 
 }

 async function updateDbWithGoogleApiPois(bounds:any){
    const southWest :Coordinate = bounds['southWest'];
    const northEast :Coordinate = bounds['northEast'];
    const lat = (southWest.lat + northEast.lat) /2;
    const lng = (southWest.lng + northEast.lng) /2;
    const distance = getDistance({ latitude: lat, longitude: lng },    { latitude: northEast.lat, longitude: northEast.lng })
    const pois = await getPois(lat, lng, distance)
    console.log(pois)
    serverCommunication.sendPoisToServer(pois, globaltokenAndPermission)
 }
 
 function addUserDataTosearchParams(searchParams:any, userData:any){
     if (userData.language) {
         searchParams['_language'] = userData.language
     }
 }

// return same as getGeoHashBoundsString but if there is a close geohash returns it too
function getGeoHashBoundsStrings(user_data:any, geoHashPrecition = 5){ 
    var mainSpecificGeoHash = getGeoHashBoundsString(user_data, geoHashPrecition + 1)
    var neighborsOfSpecific = geohash.neighbors(mainSpecificGeoHash)
    let geoHashSet = new Set();
    for (let i = 0; i < neighborsOfSpecific.length; i ++) {
        let geoHashGeneral = neighborsOfSpecific[i].slice(0, geoHashPrecition);
        geoHashSet.add(geoHashGeneral);
    }
    return geoHashSet;
}

// geoHashPrecition = 5 is the default (4.89km × 4.89km)
function getGeoHashBoundsString(user_data:any, geoHashPrecition = 5){ 
    var bounds= geohash.encode(user_data.lat, user_data.lng, geoHashPrecition)
    return bounds;
}

function getGeoHashBoundsByGeoStr(geohashStr:any) {
    var geoBounds = geohash.decode_bbox(geohashStr);
    let relevantBounds:any = {}
    relevantBounds['southWest'] = {lat : geoBounds[0], lng : geoBounds[1]}
    relevantBounds['northEast'] = {lat : geoBounds[2], lng : geoBounds[3]}
    return relevantBounds;
}


// add new user
app.get("/addNewUser", async function (req:Request, res:Response) { //next requrie (the function will not stop the program)
    console.log("inside get of addNewUser - server side")
    const userData = {'name': req.query.name, 'emailAddr': req.query.emailAddr, 'gender': req.query.gender, 'languages': req.query.languages, 'age': req.query.age, 'categories': req.query.categories}
    const result = await db.addUser(dbClientSearcher, userData)
    res.status(200);
    res.json(result);
    res.end();
 })

 // get categories
app.get("/getCategories", async function (req:Request, res:Response) { //next requrie (the function will not stop the program)
    console.log("inside get of Categories - server side")
    const language = {'language': req.query.language};
    const result = await db.getCategories(dbClientSearcher, language)
    res.status(200);
    res.json(result);
    res.end();
 })

 // get favorite categories for specific user
app.get("/getFavorCategories", async function (req:Request, res:Response) { //next requrie (the function will not stop the program)
    console.log("inside get of favorite Categories - server side")
    const emailAddr = {'emailAddr': req.query.email};
    const result = await db.getFavorCategories(dbClientSearcher, emailAddr)
    res.status(200);
    res.json(result);
    res.end();
 })

// update favorite categories for specific user
app.get("/updateFavorCategories", async function (req:Request, res:Response) { //next requrie (the function will not stop the program)
    console.log("inside update of favorite Categories - server side")
    const userInfo = {'emailAddr': req.query.email, 'favorCategories': req.query.categories};
    const result = await db.updateFavorCategories(dbClientSearcher, userInfo)
    res.status(200);
    res.json(result);
    res.end();
 })

// get user info
app.get("/getUserInfo", async function (req:Request, res:Response) { //next requrie (the function will not stop the program)
    console.log("inside get of User Info - server side")
    const userInfo = {'emailAddr': req.query.email};
    const result = await db.getUserInfo(dbClientSearcher, userInfo)
    res.status(200);
    res.json(result);
    res.end();
 })

 // update favorite categories for specific user
app.get("/updateUserInfo", async function (req:Request, res:Response) { //next requrie (the function will not stop the program)
    console.log("inside update of user info - server side")
    const userInfo = {'emailAddr': req.query.email, 'name': req.query.name, 'gender': req.query.gender, 'languages': req.query.languages, 'age': req.query.age};
    const result = await db.updateUserInfo(dbClientSearcher, userInfo)
    res.status(200);
    res.json(result);
    res.end();
 })

 // insert Poi To the history pois of specific user
app.get("/insertPoiToHistory", async function (req:Request, res:Response) { //next requrie (the function will not stop the program)
    console.log("inside insert poi to history - server side")
    const poiInfo = {'id': req.query.id, 'poiName': req.query.poiName, 'emailAddr': req.query.emailAddr, 'time': req.query.time, 'pic': req.query.pic};
    const result = await db.insertPoiToHistory(dbClientSearcher, poiInfo)
    res.status(200);
    res.json(result);
    res.end();
 })

 // get the history pois of specific user
app.get("/getPoisHistory", async function (req:Request, res:Response) { //next requrie (the function will not stop the program)
    console.log("inside get pois history - server side")
    const emailAddr = {'emailAddr': req.query.email};
    const result = await db.getPoisHistory(dbClientSearcher, emailAddr)
    res.status(200);
    res.json(result);
    res.end();
 })

 app.get("/getPoiById", async function (req:Request, res:Response) {
    console.log("inside get poi - server side")
    const poiId = req.query.poiId;
    const poiInfo = await db.getPoi(dbClientSearcher, poiId);
    if (poiInfo) {
        res.status(200);
        res.json(poiInfo);
        res.end();
    } else {
        res.status(404);
        res.end();
    }
});

//TODO ,add permissions.authContributor
app.post("/insertUserPoiPreference", async function (req:Request, res:Response) {
    try {
      await db.insertPoiPreference(dbClientSearcher, req.query.emailAddr, req.query.poiId, req.query.preference);
      res.status(200).end();
    } catch (err) {
      console.error(err);
      res.status(500).send("Internal Server Error");
    }
});

app.get("/getUserPoiPreference",async function (req:Request, res:Response) { //next require (the function will not stop the program)
    req.query.id
    const preference = await db.getPoiPreference(dbClientSearcher, req.query.emailAddr, req.query.poiId);
    res.status(200);
    res.json({ 'preference': preference });
    res.end();
})

 app.listen(port, async ()=>{
    await init()
    console.log(`Server is runing on port ${port}`)

    // const lat = 32.1000895;
    // const long = 34.8833617;
    // const distance = 1200;
    // const t= await getPois(lat, long, distance)
   // const t =await gptPlaceInfo('Yekhezkel Bekhor Synagogue',200)
    //console.log(t);
})


//__________________________________________________________________________//
//debug



// async function tryModule() {
//     var user_data = {lat : 32.1245, lng : 34.7954} 
//     await updateDbWithOnlinePois(bounds, 'en');
    
// }

// if localtunnel doing problems
// http://localhost.run/ 

// write this in terminal:  ssh -R 80:localhost:5600 localhost.run
// OR
// install ngrok globaly : "npm install ngrok -g" 
// and then : "ngrok http 5600"
//ngrok authtoken 27ZMPFvj1rAMBK80Sxm7pjJuQGd_7TSnsVtTyy5NELsRvJ856


