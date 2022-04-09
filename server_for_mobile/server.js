const fs = require('fs')
const db = require("./db");

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
const MAX_POIS_FOR_USER = 20
const uri = "mongodb+srv://root:root@autotripguide.swdtr.mongodb.net/myFirstDatabase?retryWrites=true&w=majority";

const dbClientSearcher = new MongoClient(uri);
const dbClientAudio = new MongoClient(uri);

//init
async function init() {
    try {
        await dbClientSearcher.connect();
        await dbClientAudio.connect();
        console.log("Connected to search DB")
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
    pois = await db.findPois(dbClientSearcher, searchParams, getBounds(userData), MAX_POIS_FOR_USER, false)
    res.status(200);
    res.json(pois);
    res.end();
 })
 
 function addUserDataTosearchParams(searchParams, userData){
     if (userData.language) {
         searchParams['_language'] = userData.language
     }
 }

 function getBounds(user_data){
    var epsilon = 0.07
    var relevantBounds = {}
    relevantBounds['southWest'] = {lat : user_data.lat - epsilon, lng : user_data.lng - epsilon}
    relevantBounds['northEast'] = {lat : user_data.lat + epsilon, lng : user_data.lng + epsilon}
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

 app.listen(port, async ()=>{
    await init()
    console.log(`Server is runing on port ${port}`)
})

// if localtunnel doing problems
// http://localhost.run/ 

// write this in terminal:  ssh -R 80:localhost:5600 localhost.run
// OR
// install ngrok globaly : "npm install ngrok -g" 
// and then : "ngrok http 5600"
//ngrok authtoken 27ZMPFvj1rAMBK80Sxm7pjJuQGd_7TSnsVtTyy5NELsRvJ856
