module.exports = {insertPoiPreference, getPoiPreference, getPoi, getAudio, findPois, addUser, getCategories, getAudioStream, getAudioLength, addCachedAreaInfo, getCachedAreaInfo ,getFavorCategories, updateFavorCategories, getUserInfo, updateUserInfo, insertPoiToHistory, getPoisHistory};
var mongoose = require('mongoose');
const { MongoClient } = require('mongodb');
const mongodb = require('mongodb');
const { logger } = require('./utils/loggerService');



async function findDataByParams(client, queryObject, relevantBounds, MaxCount, searchOutsideTheBoundery,geoHash) {
    var latBT = relevantBounds.southWest.lat; //latitude bigger than
    var latST = relevantBounds.northEast.lat; //latitude smaller than
    var lngBT = relevantBounds.southWest.lng; //longtitude bigger than
    var lngST = relevantBounds.northEast.lng; //longtitude smaller than
    queryObject['_latitude'] = {$gt: latBT, $lt: latST};
    queryObject['_longitude'] = {$gt: lngBT, $lt: lngST};
    var res = await client.db("auto_trip_guide_db").collection("poisCollection").find(queryObject).limit(MaxCount);
    var results = await res.toArray();
    if (results.length == 0 && searchOutsideTheBoundery) { //if can search outside the bounderies and didm't find pois in the boundery
        delete queryObject._latitude;
        delete queryObject._longitude;
        res = await client.db("auto_trip_guide_db").collection("poisCollection").find(queryObject).limit(MaxCount);
        results = await res.toArray();
    }
    if (results.length != 0) {
        logger.info(`Found ${results.length} pois in the db for the geoHash '${geoHash}'`);
        return results
    } else {
        logger.info(`No pois found in the db for the geoHash '${geoHash}'`);
    }
}

// The function find a pois 
async function findPois(client, poiParams , relevantBounds, MaxCount, searchOutsideTheBoundery,geoHash) {
    var queryObject = poiParams
    return findDataByParams(client, queryObject, relevantBounds, MaxCount, searchOutsideTheBoundery,geoHash)
}

// The function returns audio promise
async function getAudio(dbClient, audioId) {
    const db = await dbClient.db("auto_trip_guide_db");
    const bucket = new mongodb.GridFSBucket(db, { bucketName: 'myAudioBucket' });
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
    const db = await dbClient.db("auto_trip_guide_db");
    const bucket = new mongodb.GridFSBucket(db, { bucketName: 'myAudioBucket' });
    var downloadStream = bucket.openDownloadStreamByName(audioId);
    return downloadStream
}

// this function return audio length
async function getAudioLength(dbClient, audioId) {
    var res = await dbClient.db("auto_trip_guide_db").collection("myAudioBucket.files").findOne({filename: audioId})
    if (res == null) {
        print('error no audio')
        return undefined;
    }
    return res.length;
}


// The function checks if the email address exist in the db - the user sign in before
async function checkInfo(client, userInfo) {
    var emailAddrVal = userInfo.emailAddr;
    var resEmailAddr = await client.db("auto_trip_guide_db").collection("mobileUsers").find({emailAddr: emailAddrVal});
    var resEmailAddrArr = await resEmailAddr.toArray();
    var resEmailAddrLen = resEmailAddrArr.length;

     if(!resEmailAddrLen) {    //user with the given name or email is not exist
        logger.info(`not found a user with the details: '${emailAddrVal}'`);
         return 0;
     } else {    //user with the given email is xist
        logger.info(`Found a user with the email: '${emailAddrVal}'`);
        return 1;
     }
}

// The function inserts a new user to the db
async function addUser(client, newUserInfo) {
    const checkCode = await checkInfo(client, newUserInfo);
    if(checkCode == 0) {    //the user's info not exist in the db
        const res = await client.db("auto_trip_guide_db").collection("mobileUsers").insertOne(newUserInfo);
        logger.info(`new user created with the following id: ${res.insertedId}`);
    }
    return checkCode;
}

// The function inserts a return the categories from the db
async function getCategories(client, lang) {
    var categoryLang = lang.language;
    var res = await client.db("auto_trip_guide_db").collection("Categories").find({language: categoryLang});
    var resArr = await res.toArray();
    if (resArr.length > 0) {
        logger.info(`Found categories for the reuired language: '${categoryLang}'`);
        return resArr[0].categories;
    } else {
        return {};
    }
}

async function getPoi(client, poiId) {
     const res = await client.db("auto_trip_guide_db").collection("poisCollection").findOne({ _id: poiId });
    if (res) {
        return res;
    } else {
        return null;
    }
}


// The function return the favorite categories of specific user from the db
async function getFavorCategories(client, email) {
    var emailAddress = email.emailAddr;
    var res = await client.db("auto_trip_guide_db").collection("mobileUsers").find({emailAddr: emailAddress});
    var resArr = await res.toArray();
    if (resArr.length > 0) {
        logger.info(`Found favorite categories for the reuired user: '${emailAddress}'`);
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
    const res = await client.db("auto_trip_guide_db").collection("mobileUsers").updateOne({emailAddr: emailAddress}, { $set: {
        categories: favorCategories
    }});
    return 1;
}

// The function return the user info from the db
async function getUserInfo(client, userInfo) {
    var emailAddress = userInfo.emailAddr;
    var res = await client.db("auto_trip_guide_db").collection("mobileUsers").find({emailAddr: emailAddress});
    var resArr = await res.toArray();
    const userInfoMap = new Map();
    if (resArr.length > 0) {
        logger.info(`found user info for the reuired email: '${emailAddress}'`);
        userInfoMap.set('name', resArr[0].name);
        userInfoMap.set('gender', resArr[0].gender);
        userInfoMap.set('languages', resArr[0].languages);
        userInfoMap.set('age', resArr[0].age);
    }
    const userInfoMapJson = Object.fromEntries(userInfoMap);
    logger.info(`userInfoMapJson: '${userInfoMapJson}'`);
    return userInfoMapJson;
}

// The function update the favorite categories of specific user
async function updateUserInfo(client, userInfo) {
    var emailAddress = userInfo.emailAddr;
    const res = await client.db("auto_trip_guide_db").collection("mobileUsers").updateOne({emailAddr: emailAddress}, { $set: {
        name: userInfo.name, gender: userInfo.gender, languages: userInfo.languages, age: userInfo.age
    }});
    logger.info(`Update user info for user: '${emailAddress}'`);
    return 1;
}

// The function update the favorite categories of specific user
async function insertPoiToHistory(client, poiInfo) {
    let userPoisHistory = await getPoisHistory(client, poiInfo.emailAddr);
    if (userPoisHistory) {
        const index = await userPoisHistory.findIndex(poi => poi.poiId == poiInfo.id);
        if(index != -1) {
            userPoisHistory[index].time = poiInfo.time;
            const res = await client.db("auto_trip_guide_db").collection("mobileUsers").updateOne({emailAddr: poiInfo.emailAddr}, { $set: {
                poisHistory: userPoisHistory
            }});
            return res;
        }
    }

    const res = await client.db("auto_trip_guide_db").collection("mobileUsers").updateOne({emailAddr: poiInfo.emailAddr}, { $push: { poisHistory: 
        {poiId: poiInfo.id, poiName: poiInfo.poiName, time: poiInfo.time, pic: poiInfo.pic}}});
        logger.info(`Update user info for user: '${poiInfo.emailAddr}'`);
    return res;
}

// The function return the favorite categories of specific user from the db
async function getPoisHistory(client, email) {
    var res = await client.db("auto_trip_guide_db").collection("mobileUsers").find({emailAddr: email});
    var resArr = await res.toArray();
    if (resArr.length > 0) {
        return resArr[0].poisHistory;
    } else {
        return [];
    }
}

// The function returns data about cached area
async function getCachedAreaInfo(client, parameters) {
    var res = await client.db("auto_trip_guide_db").collection("cachedAreas").find({geoHashStr: parameters.geoHashStr});
    var resArr = await res.toArray();
    if (resArr.length > 0) {
        logger.info(`Found cached area for the reuired geoHashStr: '${parameters.geoHashStr}'`);
        return resArr[0];
    } else {
        logger.info(`No cached area found for the reuired geoHashStr: '${parameters.geoHashStr}'`);
        return null;
    }
}

// The function returns data about cached area
async function addCachedAreaInfo(client, parameters) {
    let cachedArea = await getCachedAreaInfo(client, parameters)
    var res
    if (cachedArea) {
        res = await client.db("auto_trip_guide_db").collection("cachedAreas").updateOne({geoHashStr: parameters.geoHashStr}, { $set: { 
            lastUpdated: parameters.lastUpdated
        }});
    } else {
        let data = {geoHashStr: parameters.geoHashStr, lastUpdated: parameters.lastUpdated} 
        res = await client.db("auto_trip_guide_db").collection("cachedAreas").insertOne(data);
    }
    return res
}

// check if object is empty
function isEmpty(obj) {
    return Object.keys(obj).length === 0;
}

// The function inserts a new user to the db
async function getPoiPreference(client, email, poiId) { //preference 1= like, -1 = dislike, 0 = nothing
    const query = {"poiId": poiId, "email": email}
    const res = await client.db("auto_trip_guide_db").collection("poisPreference").findOne(query);
    if (res) {
        // User has a preference for the POI, return it
        return res.preference;
      } else {
        return '0'; // nothing
      }
}

async function insertPoiPreference(client, email, poiId, preference) { //preference 1= like, -1 = dislike, 0 = nothing
    const filter = {
      poiId: poiId,
      email: email,
    };
    const update = {
      $set: {
        preference: preference,
      },
    };
    const options = {
      upsert: true,
    };
    const result = await client
      .db("auto_trip_guide_db")
      .collection("poisPreference")
      .updateOne(filter, update, options);
    console.log(`Document inserted/updated: ${result}`);
}
  





