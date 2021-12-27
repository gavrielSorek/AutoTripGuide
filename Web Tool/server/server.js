const db = require("../db/db");
var geo = require("./services/countryByPosition");
const wiki_service = require("../server/WikiServices/positionByNameWiki");
var CryptoJS = require("crypto-js");
var nodemailer = require('nodemailer');
dotenv = require('dotenv').config();
var key = "123"

const { MongoClient } = require('mongodb');
const mongodb = require('mongodb');
var fs = require('fs');

const express = require('express')
bodyParser = require('body-parser');
const app = express()
app.use(bodyParser.urlencoded({limit: '50mb', extended: true}));
app.use(bodyParser.json({limit: '50mb'}));
let cors = require('cors');
const { data } = require("jquery");
app.use(cors())
const port = 5500
app.use(bodyParser.json() );       // to support JSON-encoded bodies
app.use(bodyParser.urlencoded({     // to support URL-encoded bodies
extended: false})); 
const MAX_ELEMENT_ON_MAP = 50

// Route that handles create New Poi logic

//init GLOBAL
uri = "mongodb+srv://root:root@autotripguide.swdtr.mongodb.net/myFirstDatabase?retryWrites=true&w=majority";
const dbClientSearcher = new MongoClient(uri);
const dbClientInsertor = new MongoClient(uri);
const dbClientAudio = new MongoClient(uri);

//init
async function init() {
    try {
        await dbClientSearcher.connect();
        await dbClientInsertor.connect();
        await dbClientAudio.connect();
        console.log("Connected to search DB")
    } catch (e) {
        console.error(e); 
    }
}

async function closeServer(){
    await dbClientSearcher.close();
    await dbClientInsertor.close();
    await dbClientAudio.close()
}


// Route that handles create New Pois logic
async function createNewPois(pois) {
    try {
        pois.every(poiHandler)
        await db.InsertPois(dbClientInsertor, pois);
    } catch (e) {
        console.error(e); 
    } 
}

async function findPoisInfo(poiParam, paramVal,relevantBounds, searchOutsideTheBounds) {
    return db.findPois(dbClientSearcher, poiParam, paramVal, relevantBounds, MAX_ELEMENT_ON_MAP, searchOutsideTheBounds);
}
async function poiHandler(poi) {
    if(poi._audio != "no audio") {
        db.insertAudio(dbClientAudio, Object.values(poi._audio), poi._poiName, "null at this point");
    } 
    if(!poi._country) {
        poi._country = geo.getCountry(parseFloat(poi._latitude), parseFloat(poi._longitude));
    }
}

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
    try {
        audioPromise = db.getAudio(dbClientAudio, audioName)
        audioPromise.then(value => {
            res.json(value);
            console.log("success to send audio")
            res.status(200);
            }).catch(err=>{console.log("cant retrive audio file: " + err)
            res.status(400)
            res.end();})
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


/************************  login + signup functions ************************/

var transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
        type: 'OAuth2',
        user: process.env.MAIL_USERNAME,
        pass: process.env.MAIL_PASSWORD,
        clientId: process.env.OAUTH_CLIENTID,
        clientSecret: process.env.OAUTH_CLIENT_SECRET,
        refreshToken: process.env.OAUTH_REFRESH_TOKEN
    }
  });
  
// The function send signup email to new user that sign up
function sendSignUpMail(emailAddr){
    var mailOptions = {
        from: 'autotripguide@gmail.com',
        to: emailAddr,
        subject: 'Welcome to Auto trip guide',
        text: 'Hi! \n Thanks for signing up to Auto trip guide!'
    };
    
    transporter.sendMail(mailOptions, function(error, info){
        if (error) {
          console.log(error);
        } else {
          console.log('Email signUp sent: ' + info.response);
        }
      });
}
  
function encrypt(password) {
    // Encrypt
    var cipherPassword = CryptoJS.AES.encrypt(password, key).toString();
    return cipherPassword
}

function decrypt(cipherPassword) {
    // Decrypt
    var bytes  = CryptoJS.AES.decrypt(cipherPassword, key);
    var originalPassword = bytes.toString(CryptoJS.enc.Utf8);
    return originalPassword
}

// The function compare between passwords - when one of them encrypted
function comparePass(pass, encryptPass) {
    originalPass = decrypt(encryptPass);
    if(pass.localeCompare(originalPass) == 0) {
        console.log("the password identical")
        return true;
    } else {
        console.log("the password are not identical!!!!")
        return false;
    }
}

// Route that handles create new user logic
async function createNewUser(userInfo) {
    return await db.createNewUser(dbClientInsertor, userInfo);
}

//create new user logic
app.post('/createNewUser', async function(req, res) {
    console.log("create new user request in the server")
    var data = req.body;
    pass = data.password;
    data.password = encrypt(pass)
    ret = createNewUser(data).then(function(response) {
        console.log("----------------------------")
        if(response == 0) {   // new user created
            sendSignUpMail(data.emailAddr);
        }
        res.status(200);
        res.json(response);
        res.end();
    }); 
});

// Route that handles login logic
async function login(userInfo) {
    return await db.login(dbClientInsertor, userInfo);
}

// login logic
app.post('/login', async function(req, res) {
    console.log("login request in the server")
    const data = req.body;
    var pass = data.password
    ret = login(data).then(function(response) {
        if(response.length == 0) {
            newResponse = 0     // The user's name or email not exist - so the user not exist
        } else {                // The user's name or email exist
            var encryptPass = response[0].password
            if(comparePass(pass, encryptPass)) {    //check of the password
                newResponse = 2    // The user's name or email + password are correct
            } else {
                newResponse = 1    // The password are not correct
            }
        }
        console.log("----------------------------")
        res.status(200);
        res.json(newResponse);
        res.end();
    });  
});

// Start your server on a specified port
app.listen(port, async ()=>{
    await init()
    console.log(`Server is runing on port ${port}`)
})



