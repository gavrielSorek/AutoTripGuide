import mongoose from 'mongoose';
import { MongoClient } from 'mongodb';
import mongodb from 'mongodb';
import { logger } from './utils/loggerService';
import { GeoBounds } from './types/coordinate';



async function findDataByParams(client:MongoClient, queryObject:any, relevantBounds:GeoBounds, MaxCount:number, searchOutsideTheBoundery:boolean,geoHash:any) {
    const latBT = relevantBounds.southWest.lat; //latitude bigger than
    const latST = relevantBounds.northEast.lat; //latitude smaller than
    const lngBT = relevantBounds.southWest.lng; //longtitude bigger than
    const lngST = relevantBounds.northEast.lng; //longtitude smaller than
    queryObject['_latitude'] = {$gt: latBT, $lt: latST};
    queryObject['_longitude'] = {$gt: lngBT, $lt: lngST};
    let res = await client.db("auto_trip_guide_db").collection("poisCollection").find(queryObject).limit(MaxCount);
    let results = await res.toArray();
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
export async function findPois(client:MongoClient, poiParams:any , relevantBounds:GeoBounds, MaxCount:number, searchOutsideTheBoundery:boolean,geoHash:string) {
    return findDataByParams(client, poiParams, relevantBounds, MaxCount, searchOutsideTheBoundery,geoHash)
}

// The function returns audio promise
async function getAudio(dbClient:MongoClient, audioId:string) {
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
async function getAudioStream(dbClient:MongoClient, audioId:string) {
    const db = await dbClient.db("auto_trip_guide_db");
    const bucket = new mongodb.GridFSBucket(db, { bucketName: 'myAudioBucket' });
    var downloadStream = bucket.openDownloadStreamByName(audioId);
    return downloadStream
}

// this function return audio length
async function getAudioLength(dbClient:MongoClient, audioId:string) {
    const res = await dbClient.db("auto_trip_guide_db").collection("myAudioBucket.files").findOne({filename: audioId})
    if (res == null) {
       // print('error no audio')
        return undefined;
    }
    return res.length;
}


// The function checks if the email address exist in the db - the user sign in before
async function checkInfo(client:MongoClient, userInfo:any) {
    const emailAddrVal = userInfo.emailAddr;
    const resEmailAddr = await client.db("auto_trip_guide_db").collection("mobileUsers").find({emailAddr: emailAddrVal});
    const resEmailAddrArr = await resEmailAddr.toArray();
    const resEmailAddrLen = resEmailAddrArr.length;

     if(!resEmailAddrLen) {    //user with the given name or email is not exist
        logger.info(`not found a user with the details: '${emailAddrVal}'`);
         return 0;
     } else {    //user with the given email is xist
        logger.info(`Found a user with the email: '${emailAddrVal}'`);
        return 1;
     }
}

// The function inserts a new user to the db
export async function addUser(client:MongoClient, newUserInfo:any) {
    const checkCode = await checkInfo(client, newUserInfo);
    if(checkCode == 0) {    //the user's info not exist in the db
        const res = await client.db("auto_trip_guide_db").collection("mobileUsers").insertOne(newUserInfo);
        logger.info(`new user created with the following id: ${res.insertedId}`);
    }
    return checkCode;
}

// The function inserts a return the categories from the db
export async function getCategories(client:MongoClient, lang:any) {
    const categoryLang = lang.language;
    const res = await client.db("auto_trip_guide_db").collection("Categories").find({language: categoryLang});
    const resArr = await res.toArray();
    if (resArr.length > 0) {
        logger.info(`Found categories for the reuired language: '${categoryLang}'`);
        return resArr[0].categories;
    } else {
        return {};
    }
}

export async function getPoi(client:MongoClient, poiId:any) {
     const res = await client.db("auto_trip_guide_db").collection("poisCollection").findOne({ _id: poiId });
    if (res) {
        return res;
    } else {
        return null;
    }
}


// The function return the favorite categories of specific user from the db
export async function getFavorCategories(client:MongoClient, email:any) {
    const emailAddress = email.emailAddr;
    const res = await client.db("auto_trip_guide_db").collection("mobileUsers").find({emailAddr: emailAddress});
    const resArr = await res.toArray();
    if (resArr.length > 0) {
        logger.info(`Found favorite categories for the reuired user: '${emailAddress}'`);
        return resArr[0].categories;
    } else {
        return [];
    }
}

// The function update the favorite categories of specific user
export async function updateFavorCategories(client:MongoClient, userInfo:any) {
    const emailAddress = userInfo.emailAddr;
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
export async function getUserInfo(client:MongoClient, userInfo:any) {
    const emailAddress = userInfo.emailAddr;
    const res = await client.db("auto_trip_guide_db").collection("mobileUsers").find({emailAddr: emailAddress});
    const resArr = await res.toArray();
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
export async function updateUserInfo(client:MongoClient, userInfo:any) {
    const emailAddress = userInfo.emailAddr;
    const res = await client.db("auto_trip_guide_db").collection("mobileUsers").updateOne({emailAddr: emailAddress}, { $set: {
        name: userInfo.name, gender: userInfo.gender, languages: userInfo.languages, age: userInfo.age
    }});
    logger.info(`Update user info for user: '${emailAddress}'`);
    return 1;
}

// The function update the favorite categories of specific user
export async function insertPoiToHistory(client:MongoClient, poiInfo:any) {
    let userPoisHistory = await getPoisHistory(client, poiInfo.emailAddr);
    if (userPoisHistory) {
        const index = await userPoisHistory.findIndex((poi:any) => poi.poiId == poiInfo.id);
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
export async function getPoisHistory(client:MongoClient, email:any) {
    const res = await client.db("auto_trip_guide_db").collection("mobileUsers").find({emailAddr: email});
    const resArr = await res.toArray();
    return resArr.length > 0 ? resArr[0].poisHistory : [];
}

// The function returns data about cached area
export async function getCachedAreaInfo(client:MongoClient, parameters:any) {
    const res = await client.db("auto_trip_guide_db").collection("cachedAreas").find({geoHashStr: parameters.geoHashStr});
    const resArr = await res.toArray();
    if (resArr.length > 0) {
        logger.info(`Found cached area for the reuired geoHashStr: '${parameters.geoHashStr}'`);
        return resArr[0];
    } else {
        logger.info(`No cached area found for the reuired geoHashStr: '${parameters.geoHashStr}'`);
        return null;
    }
}

// The function returns data about cached area
export async function addCachedAreaInfo(client:MongoClient, parameters:any) {
    const cachedArea = await getCachedAreaInfo(client, parameters)
    var res
    if (cachedArea) {
        res = await client.db("auto_trip_guide_db").collection("cachedAreas").updateOne({geoHashStr: parameters.geoHashStr}, { $set: { 
            lastUpdated: parameters.lastUpdated
        }});
    } else {
        const data = {geoHashStr: parameters.geoHashStr, lastUpdated: parameters.lastUpdated} 
        res = await client.db("auto_trip_guide_db").collection("cachedAreas").insertOne(data);
        logger.info(`new cached area created for geoHash ${parameters.geoHashStr} with the following id: ${res.insertedId}`);
    }
    return res
}

// check if object is empty
// function isEmpty(obj) {
//     return Object.keys(obj).length === 0;
// }

// The function inserts a new user to the db
export async function getPoiPreference(client:MongoClient, email:any, poiId:any) { //preference 1= like, -1 = dislike, 0 = nothing
    const query = {"poiId": poiId, "email": email}
    const res = await client.db("auto_trip_guide_db").collection("poisPreference").findOne(query);
    if (res) {
        // User has a preference for the POI, return it
        return res.preference;
      } else {
        return '0'; // nothing
      }
}

export async function insertPoiPreference(client:MongoClient, email:any, poiId:any, preference:any) { //preference 1= like, -1 = dislike, 0 = nothing
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
  





