const fs = require('fs')
const db = require("./db");
const generalServices = require('../services/generalServices')
const onlinePoisFinder = require("./onlinePoisFinder");
const serverCommunication = require("../services/serverCommunication");
var tokenGetter = require("../services/serverTokenGetter");
var geohash = require('ngeohash');


const { MongoClient } = require('mongodb');
const mongodb = require('mongodb');

const express = require('express')
bodyParser = require('body-parser');
const app = express()
app.use(bodyParser.urlencoded({limit: '50mb', extended: true}));
app.use(bodyParser.json({limit: '50mb'}));
let cors = require('cors');
const { data } = require("jquery");
app.use(cors())
const port = 5600
app.use(bodyParser.json() );       // to support JSON-encoded bodies
app.use(bodyParser.urlencoded({     // to support URL-encoded bodies
extended: false}));
const MAX_POIS_FOR_USER = 300
const MAX_DAYS_USE_AREA_CACHE = 30

const uri = "mongodb+srv://root:root@autotripguide.swdtr.mongodb.net/myFirstDatabase?retryWrites=true&w=majority";

const dbClientSearcher = new MongoClient(uri);
const dbClientAudio = new MongoClient(uri);
var globaltokenAndPermission = undefined;
const geoHashHandledByOnlineSercher  = new Set(); // TODO limit the size (like cache)
const geoHashPrecitionLevel = 5;

//init
async function init() {
    try {
        await dbClientSearcher.connect();
        await dbClientAudio.connect();
        globaltokenAndPermission = await tokenGetter.getToken('crawler@gmail.com', '1234', serverCommunication.getServerUrl()) //get tokens and permissions for web server
        console.log("Connected to search DB")
        // tryModule()
        
    } catch (e) {
        console.error(e); 
    }
}
// get searchPage page
app.get("/", async function (req, res) { //next requrie (the function will not stop the program)
    res.status(200);
    res.write("hello");
    res.end();
 })
 // get searchPage page
 app.get("/searchNearbyPois", async function (req, res) { //next requrie (the function will not stop the program)
    userData = {'lat': parseFloat(req.query.lat), 'lng': parseFloat(req.query.lng), 'speed': parseFloat(req.query.speed), 'heading': parseFloat(req.query.heading), 'language': req.query.language}
    searchParams = {}
    addUserDataTosearchParams(searchParams, userData)

    var geoHashStrings = getGeoHashBoundsStrings(userData, geoHashPrecitionLevel);
    var boundsArr = [];
    // add all the bounds
    geoHashStrings.forEach((geoHashStr)=>{
        boundsArr.push(getGeoHashBoundsByGeoStr(geoHashStr))
    });
    var pois = []
    for (let i = 0; i < boundsArr.length; i++ ) {
        let tempPoisArr = await db.findPois(dbClientSearcher, searchParams, boundsArr[i], MAX_POIS_FOR_USER, false);
        pois = pois.concat(tempPoisArr);
    }

    res.status(200);
    res.json(pois);
    res.end();
    // update the db with new pois if needed
    geoHashStrings.forEach(async (geoHashStr)=>{
        let areaData = await db.getCachedAreaInfo(dbClientSearcher, {geoHashStr: geoHashStr})
        //if the online searcher didn't search on this location
        if (areaData && generalServices.getNumOfDaysBetweenDates(generalServices.getTodayDate(), areaData.lastUpdated) < MAX_DAYS_USE_AREA_CACHE) {
            // do nothing - everything is updated
        } else {
            updateDbWithOnlinePois(getGeoHashBoundsByGeoStr(geoHashStr), 'en');
            params = {geoHashStr: geoHashStr, lastUpdated: generalServices.getTodayDate()}
            db.addCachedAreaInfo(dbClientSearcher, params)
        }
    })
 })

 async function updateDbWithOnlinePois(bounds, language) {
    // async call for faster rsults
    await onlinePoisFinder.getPoisList(bounds, language,(poi)=>{
        serverCommunication.sendPoisToServer([poi], globaltokenAndPermission)
    }); 
 }
 
 function addUserDataTosearchParams(searchParams, userData){
     if (userData.language) {
         searchParams['_language'] = userData.language
     }
 }

// return same as getGeoHashBoundsString but if there is a close geohash returns it too
function getGeoHashBoundsStrings(user_data, geoHashPrecition = 5){ 
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
function getGeoHashBoundsString(user_data, geoHashPrecition = 5){ 
    var bounds= geohash.encode(user_data.lat, user_data.lng, geoHashPrecition)
    return bounds;
}

function getGeoHashBoundsByGeoStr(geohashStr) {
    var geoBounds = geohash.decode_bbox(geohashStr);
    relevantBounds = {}
    relevantBounds['southWest'] = {lat : geoBounds[0], lng : geoBounds[1]}
    relevantBounds['northEast'] = {lat : geoBounds[2], lng : geoBounds[3]}
    return relevantBounds;
}


// add new user
app.get("/addNewUser", async function (req, res) { //next requrie (the function will not stop the program)
    console.log("inside get of addNewUser - server side")
    userData = {'name': req.query.name, 'emailAddr': req.query.emailAddr, 'gender': req.query.gender, 'languages': req.query.languages, 'age': req.query.age, 'categories': req.query.categories}
    result = await db.addUser(dbClientSearcher, userData)
    res.status(200);
    res.json(result);
    res.end();
 })

 // get categories
app.get("/getCategories", async function (req, res) { //next requrie (the function will not stop the program)
    console.log("inside get of Categories - server side")
    language = {'language': req.query.language};
    result = await db.getCategories(dbClientSearcher, language)
    res.status(200);
    res.json(result);
    res.end();
 })

 // get favorite categories for specific user
app.get("/getFavorCategories", async function (req, res) { //next requrie (the function will not stop the program)
    console.log("inside get of favorite Categories - server side")
    emailAddr = {'emailAddr': req.query.email};
    result = await db.getFavorCategories(dbClientSearcher, emailAddr)
    res.status(200);
    res.json(result);
    res.end();
 })

// update favorite categories for specific user
app.get("/updateFavorCategories", async function (req, res) { //next requrie (the function will not stop the program)
    console.log("inside update of favorite Categories - server side")
    userInfo = {'emailAddr': req.query.email, 'favorCategories': req.query.categories};
    result = await db.updateFavorCategories(dbClientSearcher, userInfo)
    res.status(200);
    res.json(result);
    res.end();
 })

// get user info
app.get("/getUserInfo", async function (req, res) { //next requrie (the function will not stop the program)
    console.log("inside get of User Info - server side")
    userInfo = {'emailAddr': req.query.email};
    result = await db.getUserInfo(dbClientSearcher, userInfo)
    res.status(200);
    res.json(result);
    res.end();
 })

 // update favorite categories for specific user
app.get("/updateUserInfo", async function (req, res) { //next requrie (the function will not stop the program)
    console.log("inside update of user info - server side")
    userInfo = {'emailAddr': req.query.email, 'name': req.query.name, 'gender': req.query.gender, 'languages': req.query.languages, 'age': req.query.age};
    result = await db.updateUserInfo(dbClientSearcher, userInfo)
    res.status(200);
    res.json(result);
    res.end();
 })

 // insert Poi To the history pois of specific user
app.get("/insertPoiToHistory", async function (req, res) { //next requrie (the function will not stop the program)
    console.log("inside insert poi to history - server side")
    poiInfo = {'id': req.query.id, 'poiName': req.query.poiName, 'emailAddr': req.query.emailAddr, 'time': req.query.time, 'pic': req.query.pic};
    result = await db.insertPoiToHistory(dbClientSearcher, poiInfo)
    res.status(200);
    res.json(result);
    res.end();
 })

 // get the history pois of specific user
app.get("/getPoisHistory", async function (req, res) { //next requrie (the function will not stop the program)
    console.log("inside get pois history - server side")
    emailAddr = {'emailAddr': req.query.email};
    result = await db.getPoisHistory(dbClientSearcher, emailAddr)
    res.status(200);
    res.json(result);
    res.end();
 })

 app.listen(port, async ()=>{
    await init()
    console.log(`Server is runing on port ${port}`)
})


//__________________________________________________________________________//
//debug



async function tryModule() {
    var user_data = {lat : 32.1245, lng : 34.7954} 
    await updateDbWithOnlinePois(bounds, 'en');
    
}

// if localtunnel doing problems
// http://localhost.run/ 

// write this in terminal:  ssh -R 80:localhost:5600 localhost.run
// OR
// install ngrok globaly : "npm install ngrok -g" 
// and then : "ngrok http 5600"
//ngrok authtoken 27ZMPFvj1rAMBK80Sxm7pjJuQGd_7TSnsVtTyy5NELsRvJ856


