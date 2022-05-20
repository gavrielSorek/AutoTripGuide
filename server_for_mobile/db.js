module.exports = { getAudio, findPois, addUser, getCategories, getAudioStream, getAudioLength ,getFavorCategories, updateFavorCategories, getUserInfo, updateUserInfo};
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

// this function return audio stream
async function getAudioStream(dbClient, audioId) {
    const db = await dbClient.db("testDb");
    const bucket = new mongodb.GridFSBucket(db, { bucketName: 'myCustomBucket' });
    var downloadStream = bucket.openDownloadStreamByName(audioId);
    return downloadStream
}

// this function return audio length
async function getAudioLength(dbClient, audioId) {
    var res = await dbClient.db("testDb").collection("myCustomBucket.files").findOne({filename: audioId})
    if (res == null) {
        print('error no audio')
        return undefined;
    }
    return res.length;
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

// The function inserts a return the categories from the db
async function getCategories(client, lang) {
    var categoryLang = lang.language;
    var res = await client.db("testDb").collection("Categories").find({language: categoryLang});
    var resArr = await res.toArray();
    if (resArr.length > 0) {
        //console.log(resArr[0].categories);
        console.log("found categories for the reuired language")
        return resArr[0].categories;
    } else {
        return {};
    }
}

// The function return the favorite categories of specific user from the db
async function getFavorCategories(client, email) {
    var emailAddress = email.emailAddr;
    var res = await client.db("testDb").collection("mobileUsers").find({emailAddr: emailAddress});
    var resArr = await res.toArray();
    if (resArr.length > 0) {
        //console.log(resArr[0].categories);
        console.log("found favorite categories for the reuired user")
        return resArr[0].categories;
    } else {
        return [];
    }
}

// The function update the favorite categories of specific user
async function updateFavorCategories(client, userInfo) {
    var emailAddress = userInfo.emailAddr;
    var favorCategories = userInfo.favorCategories;
    if (typeof favorCategories !== 'object' || favorCategories == null) {
        favorCategories = userInfo.favorCategories.split(', ');
    }
    const res = await client.db("testDb").collection("mobileUsers").updateOne({emailAddr: emailAddress}, { $set: {
        categories: favorCategories
    }});
    return 1;
}

// The function return the user info from the db
async function getUserInfo(client, userInfo) {
    var emailAddress = userInfo.emailAddr;
    var res = await client.db("testDb").collection("mobileUsers").find({emailAddr: emailAddress});
    var resArr = await res.toArray();
    const userInfoMap = new Map();
    if (resArr.length > 0) {
        console.log("found user info for the reuired email")
        userInfoMap.set('name', resArr[0].name);
        userInfoMap.set('gender', resArr[0].gender);
        userInfoMap.set('languages', resArr[0].languages);
        userInfoMap.set('age', resArr[0].age);
    }
    const userInfoMapJson = Object.fromEntries(userInfoMap);
    console.log(userInfoMapJson);
    return userInfoMapJson;
}

// The function update the favorite categories of specific user
async function updateUserInfo(client, userInfo) {
    var emailAddress = userInfo.emailAddr;
    const res = await client.db("testDb").collection("mobileUsers").updateOne({emailAddr: emailAddress}, { $set: {
        name: userInfo.name, gender: userInfo.gender, languages: userInfo.languages, age: userInfo.age
    }});
    console.log("after updateUserInfo in the server side");
    return 1;
}

// check if object is empty
function isEmpty(obj) {
    return Object.keys(obj).length === 0;
}



