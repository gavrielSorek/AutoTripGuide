module.exports = { InsertPoi, InsertPois, insertAudio, getAudio, findPois, createNewUser, login};
// const { MongoClient } = require('mongodb');
const mongodb = require('mongodb');
// var fs = require('fs');

// The function insert a new poi to the db
async function InsertPoi(client, newPoi) {
    const res = await client.db("testDb").collection("testCollection").insertOne(newPoi);
    console.log(`new poi created with the following id: ${res.insertedId}`);
}

// The function insert a new poiss to the db
async function InsertPois(client, newPois) {
    try {
        const res = await client.db("testDb").collection("testCollection").insertMany(newPois);
        num_of_object = 0
        for (const id in res.insertedIds) {
            num_of_object += 1
            //add mor logic
        }
        console.log(`${num_of_object} new pois was created`);
    } catch (e) {
        console.log(e)
    }
}
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
async function findPois(client, poiParam ,paramVal, relevantBounds, MaxCount, searchOutsideTheBoundery) {
    var queryObject = {}
    queryObject[poiParam] = paramVal
    return findDataByParams(client, queryObject, relevantBounds, MaxCount, searchOutsideTheBoundery)
}

// The function insert audio to the db
async function insertAudio(dbClient, audio, audioName, idOfPoi) {
    const db = await dbClient.db("testDb");
    const bucket = new mongodb.GridFSBucket(db, { bucketName: 'myCustomBucket' });

    var uploadStream = bucket.openUploadStream(audioName, { chunkSizeBytes: 1048576, metadata: { title: audioName, poi_id: idOfPoi } })
    uploadStream.write(audio);
    uploadStream.end()
}
// The function returns audio promise
async function getAudio(dbClient, audioName, idOfAudio = null) {
    const db = await dbClient.db("testDb");
    const bucket = new mongodb.GridFSBucket(db, { bucketName: 'myCustomBucket' });
    var downloadStream = bucket.openDownloadStreamByName(audioName);
    const audioPromise = new Promise((resolve, reject)=> {
    downloadStream.on('data', (chunk) =>{
        resolve(chunk);
    })
    downloadStream.on('error', ()=> {reject('error to download ' + audioName)})
    });
    return audioPromise
}

// The function check if the name or email exist in the db
async function checkInfo(client, userInfo) {
    var userNameVal = userInfo.userName;
    var emailAddrVal = userInfo.emailAddr;
    var resUserName = await client.db("testDb").collection("users").find({userName: userNameVal});
    var resEmailAddr = await client.db("testDb").collection("users").find({emailAddr: emailAddrVal});
    var resUserNameArr = await resUserName.toArray();
    var resEmailAddrArr = await resEmailAddr.toArray();
    var resUserNameLen = resUserNameArr.length;
    var resEmailAddrLen = resEmailAddrArr.length;

     if(!resUserNameLen && !resEmailAddrLen) {    //user with the given name or email is not exist
         console.log(`not found a user with the details: '${userNameVal}' , '${emailAddrVal}'`);
         return 0;
     } else if(resUserNameLen && resEmailAddrLen) {    //user with the given name and email is xist
         console.log(`Found a user with the user name and the email: '${userNameVal}' , '${emailAddrVal}'`);
         return 1;
     } else if(resUserNameLen) {    //user with the given name is exist
        console.log(`Found a user with the user name: '${userNameVal}'`);
        return 2;
     } else {    //user with the given email is xist
        console.log(`Found a user with the email: '${emailAddrVal}'`);
        return 3;
     }
}


// The function insert a new user to the db
async function createNewUser(client, newUserInfo) {
    checkCode = await checkInfo(client, newUserInfo);
    if(checkCode == 0) {    //the user's info not exist in the db
        const res = await client.db("testDb").collection("users").insertOne(newUserInfo);
        console.log(`new user created with the following id: ${res.insertedId}`);
    }
    return checkCode;
}

// The function login user to the system according his details in the db
async function login(client, userInfo) {
    var userNameVal = userInfo.userName
    var emailAddrVal = userInfo.emailAddr
    var passwordVal = userInfo.password
    var resultsLen = 0
    checkCode = await checkInfo(client, userInfo);
    if(checkCode == 0) {    //The user's name or email not exist - so the user not exist
        console.log("The user not exist")
        return 0;
    } else if(checkCode == 1 || checkCode == 2) {  //The user's name exist
        var resUserName = await client.db("testDb").collection("users").find({userName: userNameVal, password: passwordVal});
        results = await resUserName.toArray();
        resultsLen = results.length
    } else {    //The user's email address exist
        var resEmailAddr = await client.db("testDb").collection("users").find({emailAddr: emailAddrVal, password: passwordVal});
        results = await resEmailAddr.toArray();
        resultsLen = results.length
    }
    if(resultsLen == 0) {
        console.log("The password wrong");
        return 1;
    } else {
        console.log("The user exist")
        return 2;
    }
}


// async function example() {
//     const uri = "mongodb+srv://root:root@autotripguide.swdtr.mongodb.net/myFirstDatabase?retryWrites=true&w=majority";
//     const dbClient = new MongoClient(uri);
//     await dbClient.connect()
//     var relevantBounds = {}
//     relevantBounds['northEast'] = {'lat': 33.09572898, 'lng' : 36.47348}
//     relevantBounds['southWest'] = {'lat': 30.0, 'lng' : 35.9539974}
//     // findPoiByName(dbClient, 'Masada', relevantBounds, 10, false)
//     findPois(dbClient, '_Contributor','crawler', relevantBounds, 100, true)
//     // var p =getAudio(dbClient, 'audioName')
//     // p.then(value => {console.log(value)}).catch(err=>{console.log(err)})

// }
// example()
// async function c() {
//     const audioFile = fs.createReadStream("./au1.mp4");
//     audioFile.on('data', async (chunk) => {
//         const uri = "mongodb+srv://root:root@autotripguide.swdtr.mongodb.net/myFirstDatabase?retryWrites=true&w=majority";
//         const dbClient = new MongoClient(uri);
//         await dbClient.connect();
//         // await dbClient.connect();

//         // Send chunk to client
//         insertAudio(dbClient, chunk, 'my audio123', '1'); // May be?
//     });
// }
// c()
