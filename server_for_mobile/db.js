module.exports = { getAudio, findPois, addUser};
// var ObjectID = require('bson').ObjectID;
var mongoose = require('mongoose');
const { MongoClient } = require('mongodb');
const mongodb = require('mongodb');


async function findDataByParams(client, queryObject, relevantBounds, MaxCount, searchOutsideTheBoundery) {
    var latBT = relevantBounds.southWest.lat; //latitude bigger than
    var latST = relevantBounds.northEast.lat; //latitude smaller than
    var lngBT = relevantBounds.southWest.lng; //longtitude bigger than
    var lngST = relevantBounds.northEast.lng; //longtitude smaller than
    queryObject['_latitude'] = {$gt: latBT, $lt: latST};
    queryObject['_longitude'] = {$gt: lngBT, $lt: lngST};
    var res = await client.db("testDb").collection("testCollection").find(queryObject).limit(MaxCount);
    var results = await res.toArray();
    if (results.length == 0 && searchOutsideTheBoundery) { //if can search outside the bounderies and didm't find pois in the boundery
        delete queryObject._latitude;
        delete queryObject._longitude;
        res = await client.db("testDb").collection("testCollection").find(queryObject).limit(MaxCount);
        results = await res.toArray();
    }
    if (results.length != 0) {
        console.log(`found a poi in the collection with the param '${queryObject}'`);
        console.log(results);
        return results
    } else {
        console.log(`No poi found with the param '${queryObject}'`);
    }
}

// The function find a pois 
async function findPois(client, poiParams , relevantBounds, MaxCount, searchOutsideTheBoundery) {
    var queryObject = poiParams
    return findDataByParams(client, queryObject, relevantBounds, MaxCount, searchOutsideTheBoundery)
}

// The function returns audio promise
async function getAudio(dbClient, audioId) {
    const db = await dbClient.db("testDb");
    const bucket = new mongodb.GridFSBucket(db, { bucketName: 'myCustomBucket' });
    var downloadStream = bucket.openDownloadStreamByName(audioId);
    const audioPromise = new Promise((resolve, reject)=> {
    downloadStream.on('data', (chunk) =>{
        resolve(chunk);
    })
    downloadStream.on('error', ()=> {reject('error to download audio')})
    });
    return audioPromise
}

// The function checks if the email address exist in the db - the user sign in before
async function checkInfo(client, userInfo) {
    var emailAddrVal = userInfo.emailAddr;
    var resEmailAddr = await client.db("testDb").collection("mobileUsers").find({emailAddr: emailAddrVal});
    var resEmailAddrArr = await resEmailAddr.toArray();
    var resEmailAddrLen = resEmailAddrArr.length;

     if(!resEmailAddrLen) {    //user with the given name or email is not exist
         console.log(`not found a user with the details: '${emailAddrVal}'`);
         return 0;
     } else {    //user with the given email is xist
        console.log(`Found a user with the email: '${emailAddrVal}'`);
        return 1;
     }
}

// The function inserts a new user to the db
async function addUser(client, newUserInfo) {
    checkCode = await checkInfo(client, newUserInfo);
    if(checkCode == 0) {    //the user's info not exist in the db
        const res = await client.db("testDb").collection("mobileUsers").insertOne(newUserInfo);
        console.log(`new user created with the following id: ${res.insertedId}`);
    }
    return checkCode;
}

// check if object is empty
function isEmpty(obj) {
    return Object.keys(obj).length === 0;
}



