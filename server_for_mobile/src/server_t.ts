import * as db from './db';
import * as generalServices from '../../services/generalServices';
import {getPoisFromOpenTrip} from './openTripFinder'
import * as serverCommunication from "../../services/serverCommunication";
import * as tokenGetter from "../../services/serverTokenGetter";
import * as geohash from 'ngeohash';
import { getPois } from "./getPois";
import { Poi } from "./types/poi";
import { Request, Response } from 'express';
import { getDistance } from 'geolib';
import { Coordinate, GeoBounds } from "./types/coordinate";
import { logger } from './utils/loggerService';
import * as dotenv from 'dotenv' // see https://github.com/motdotla/dotenv#how-do-i-use-dotenv-with-import
import { MongoClient } from 'mongodb';
import express from 'express';
import bodyParser from 'body-parser';
import cors from 'cors';
import AsyncLock from 'async-lock';
import { log } from 'console';
import { sendPoisToServer } from './utils/sendPois';
const app = express()
app.use(bodyParser.urlencoded({limit: '50mb', extended: true}));
app.use(bodyParser.json({limit: '50mb'}));
app.use(cors())
const port = 5600
app.use(bodyParser.json() );       // to support JSON-encoded bodies
app.use(bodyParser.urlencoded({     // to support URL-encoded bodies
extended: false}));
const MAX_POIS_FOR_USER = 100
const MAX_DAYS_USE_AREA_CACHE = 100
const uri = "mongodb+srv://root:root@autotripguide.swdtr.mongodb.net/myFirstDatabase?retryWrites=true&w=majority";
const lock = new AsyncLock();

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
        logger.info("Connected to search DB")
        
    } catch (e) {
        logger.info('Failed to connect to mongo DB')
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
    logger.info(`Search pois for user: lat: ${userData.lat}, lng: ${userData.lng}`)
    const geoHashStrings = getGeoHashBoundsStrings(userData, geoHashPrecitionLevel);
    const boundsArr:GeoBounds[] = [];
    let geoHashArr:any[] = []
    // add all the bounds
    geoHashStrings.forEach((geoHashStr)=>{
        boundsArr.push(getGeoHashBoundsByGeoStr(geoHashStr as string))
        geoHashArr.push(geoHashStr)
    });
    var pois:Poi[] = []
    for (let i = 0; i < boundsArr.length; i++ ) {
        const tempPoisArr = await db.findPois(dbClientSearcher, searchParams, boundsArr[i], MAX_POIS_FOR_USER, false,geoHashArr[i]);
        pois = pois.concat(tempPoisArr as any[]);
    }
    const filterdPois = pois.filter(poi => poi?._shortDesc.split(' ').length > 10)

    res.status(200);
    res.json(filterdPois);
    res.end();
    
    // update the db with new pois if needed
    geoHashStrings.forEach(async (geoHashStr)=>{
        // Acquire lock for this geohash
        lock.acquire(geoHashStr, async function() {
            const areaData = await db.getCachedAreaInfo(dbClientSearcher, {geoHashStr: geoHashStr})
             //if the online searcher didn't search on this location
            if (areaData && generalServices.getNumOfDaysBetweenDates(generalServices.getTodayDate(), areaData.lastUpdated) < MAX_DAYS_USE_AREA_CACHE) {
                // do nothing - everything is updated
            } else {
                logger.info(`Update db with geoHash pois: '${geoHashStr}'`)
                const params = {geoHashStr: geoHashStr, lastUpdated: generalServices.getTodayDate()}
                db.addCachedAreaInfo(dbClientSearcher, params)
                const bounds = getGeoHashBoundsByGeoStr(geoHashStr as string)
                updateDbWithOnlinePois(bounds, 'en',geoHashStr as string);
                updateDbWithGoogleApiPois(bounds,geoHashStr as string)
            }
        });
    })
 })

 async function updateDbWithOnlinePois(bounds: any, language: string,geoHash:string) {
    // async call for faster rsults
    await getPoisFromOpenTrip(bounds, language,geoHash,(poi: Poi)=>{
        logger.info(`Found new poi from openTripMAP: '${poi._poiName}' to geoHash: '${geoHash}'`)
        sendPoisToServer(dbClientSearcher,[poi])
    }); 
 }

 async function updateDbWithGoogleApiPois(bounds:any,geoHash:string) {
    try{
        const southWest :Coordinate = bounds['southWest'];
        const northEast :Coordinate = bounds['northEast'];
        const lat = (southWest.lat + northEast.lat) /2;
        const lng = (southWest.lng + northEast.lng) /2;
        const distance = getDistance({ latitude: lat, longitude: lng },    { latitude: northEast.lat, longitude: northEast.lng })
        const pois = await getPois(lat, lng, distance,geoHash)
        sendPoisToServer(dbClientSearcher,pois)
    } catch (e) {
        logger.error(`Error in google api for geoHash ${geoHash}: ${e}`);
    }
 }
 
 function addUserDataTosearchParams(searchParams:any, userData:any){
     if (userData.language) {
         searchParams['_language'] = userData.language
     }
 }

// return same as getGeoHashBoundsString but if there is a close geohash returns it too
function getGeoHashBoundsStrings(user_data:any, geoHashPrecition = 5):string[]{ 
    const mainSpecificGeoHash = getGeoHashBoundsString(user_data, geoHashPrecition + 1)
    const neighborsOfSpecific = geohash.neighbors(mainSpecificGeoHash)
    const geoHashSet = new Set<string>();
    for (let i = 0; i < neighborsOfSpecific.length; i ++) {
        const geoHashGeneral = neighborsOfSpecific[i].slice(0, geoHashPrecition);
        geoHashSet.add(geoHashGeneral);
    }
    return Array.from(geoHashSet);
}

// geoHashPrecition = 5 is the default (4.89km × 4.89km)
function getGeoHashBoundsString(user_data:any, geoHashPrecition = 5){ 
    const bounds= geohash.encode(user_data.lat, user_data.lng, geoHashPrecition)
    return bounds;
}

function getGeoHashBoundsByGeoStr(geohashStr:string) {
    const geoBounds = geohash.decode_bbox(geohashStr);
    const bounds: GeoBounds = {
        southWest: { lat: geoBounds[0], lng: geoBounds[1] },
        northEast: { lat: geoBounds[2], lng: geoBounds[3] }
      };
    return bounds;
}


// add new user
app.get("/addNewUser", async function (req:Request, res:Response) { //next requrie (the function will not stop the program)
    logger.info(`Add new user email: ${req.query.emailAddr}`);
    const userData = {'name': req.query.name, 'emailAddr': req.query.emailAddr, 'gender': req.query.gender, 'languages': req.query.languages, 'age': req.query.age, 'categories': req.query.categories}
    const result = await db.addUser(dbClientSearcher, userData)
    res.status(200);
    res.json(result);
    res.end();
 })

 // get categories
app.get("/getCategories", async function (req:Request, res:Response) { //next requrie (the function will not stop the program)
    logger.info(`Get categories for language: ${req.query.language}`)
    const language = {'language': req.query.language};
    const result = await db.getCategories(dbClientSearcher, language)
    res.status(200);
    res.json(result);
    res.end();
 })

 // get favorite categories for specific user
app.get("/getFavorCategories", async function (req:Request, res:Response) { //next requrie (the function will not stop the program)
    logger.info(`Get favorite categories for email: ${req.query.email}`)
    const emailAddr = {'emailAddr': req.query.email};
    const result = await db.getFavorCategories(dbClientSearcher, emailAddr)
    res.status(200);
    res.json(result);
    res.end();
 })

// update favorite categories for specific user
app.get("/updateFavorCategories", async function (req:Request, res:Response) { //next requrie (the function will not stop the program)
    logger.info(`Update favorite categories for email: ${req.query.email}`)
    const userInfo = {'emailAddr': req.query.email, 'favorCategories': req.query.categories};
    const result = await db.updateFavorCategories(dbClientSearcher, userInfo)
    res.status(200);
    res.json(result);
    res.end();
 })

// get user info
app.get("/getUserInfo", async function (req:Request, res:Response) { //next requrie (the function will not stop the program)
    logger.info(`Get user info for email: ${req.query.email}`)
    const userInfo = {'emailAddr': req.query.email};
    const result = await db.getUserInfo(dbClientSearcher, userInfo)
    res.status(200);
    res.json(result);
    res.end();
 })

 // update favorite categories for specific user
app.get("/updateUserInfo", async function (req:Request, res:Response) { //next requrie (the function will not stop the program)
    logger.info(`Update user info email: ${req.query.emailAddr}`)
    const userInfo = {'emailAddr': req.query.email, 'name': req.query.name, 'gender': req.query.gender, 'languages': req.query.languages, 'age': req.query.age};
    const result = await db.updateUserInfo(dbClientSearcher, userInfo)
    res.status(200);
    res.json(result);
    res.end();
 })

 // insert Poi To the history pois of specific user
app.get("/insertPoiToHistory", async function (req:Request, res:Response) { //next requrie (the function will not stop the program)
    logger.info(`Add poi to history '${req.query.poiName?.toString().toLowerCase()}', email: ${req.query.emailAddr}`)
    const poiInfo = {'id': req.query.id, 'poiName': req.query.poiName, 'emailAddr': req.query.emailAddr, 'time': req.query.time, 'pic': req.query.pic};
    const result = await db.insertPoiToHistory(dbClientSearcher, poiInfo)
    res.status(200);
    res.json(result);
    res.end();
 })

 // get the history pois of specific user
app.get("/getPoisHistory", async function (req:Request, res:Response) { //next requrie (the function will not stop the program)
    logger.info(`Get history pois for email: ${req.query.email}`)    
    const result = await db.getPoisHistory(dbClientSearcher, req.query.email)
    res.status(200);
    res.json(result);
    res.end();
 })

 app.get("/getPoiById", async function (req:Request, res:Response) {
    logger.info(`Get poi by id: ${req.query.poiId}`)
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
    logger.info(`Server is runing on port ${port}`)
})


//__________________________________________________________________________//
//debug


// if localtunnel doing problems
// http://localhost.run/ 

// write this in terminal:  ssh -R 80:localhost:5600 localhost.run
// OR
// install ngrok globaly : "npm install ngrok -g" 
// and then : "ngrok http 5600"
//ngrok authtoken 27ZMPFvj1rAMBK80Sxm7pjJuQGd_7TSnsVtTyy5NELsRvJ856


