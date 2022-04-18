module.exports = {InsertPois, insertAudio, getAudio, findPois, createNewUser, login, editPoi, deletePoi, changePermission};
// var ObjectID = require('bson').ObjectID;
var mongoose = require('mongoose');
const { MongoClient } = require('mongodb');
const mongodb = require('mongodb');

// The function insert a new pois to the db
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
async function findPois(client, poiParams , relevantBounds, MaxCount, searchOutsideTheBoundery) {
    return findDataByParams(client, poiParams, relevantBounds, MaxCount, searchOutsideTheBoundery)
}
// The function insert audio to the db
async function insertAudio(dbClient, audio, audioName, idOfPoi) {
    const db = await dbClient.db("testDb");
    const bucket = new mongodb.GridFSBucket(db, { bucketName: 'myCustomBucket' });

    var uploadStream = bucket.openUploadStream(idOfPoi, { chunkSizeBytes: 1048576, metadata: { _poiName: audioName} })
    uploadStream.write(audio);
    uploadStream.end()
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
    downloadStream.on('error', ()=> {reject('error to download ' + audioName)})
    });
    return audioPromise
}
//delete poi audio
async function deletePoi(client, updatedPoi, id) {
    deleteAudio(client, id);
    var queryObject = {_id: id}
    client.db("testDb").collection("testCollection").deleteOne(queryObject, function(err, res){
        if(err) {
            console.log("problem in update function-db")
        }
        else {
            console.log("poi updated")
        }
    })
}
//update audio in db
async function deleteAudio(client, id) {
    var audioFile = await client.db("testDb").collection("myCustomBucket.files").findOne({'filename': id});
    if (audioFile != null) { //if the poi has audio
        console.log(audioFile);
        // const obj_id = new mongoose.Types.ObjectId(audioFile);
        const db = await client.db("testDb");
        const bucket = new mongodb.GridFSBucket(db, { bucketName: 'myCustomBucket' });
        console.log(typeof audioFile._id)
        try  {
            bucket.delete(audioFile._id, ()=>{console.log("audio was deleted")})
        } catch {
            console.log("error to delete audio")
        }
    }
    console.log(audioFile);

}

//delete poi
async function editPoi(client, updatedPoi, id) {
    var queryObject = {_id: id}
    client.db("testDb").collection("testCollection").replaceOne(queryObject, updatedPoi, mongoHandler)
    await deleteAudio(client, id);
    if (updatedPoi._audio != 'no audio') {
        insertAudio(client, Object.values(updatedPoi._audio), updatedPoi._poiName, updatedPoi._id)
    }
}
// mongo ans handler
function mongoHandler(err, res) {
    if(err) {
        console.log("problem in update function-db")
    }
    else {
        console.log("poi updated")
    }
}

// The function checks if the name or email exist in the db
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


// The function inserts a new user to the db
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
    var resUserName = await client.db("testDb").collection("users").find({userName: userNameVal});
    var resEmailAddr = await client.db("testDb").collection("users").find({emailAddr: emailAddrVal});
    var resUserNameArr = await resUserName.toArray();
    var resEmailAddrArr = await resEmailAddr.toArray();
    var resUserNameLen = resUserNameArr.length;
    var resEmailAddrLen = resEmailAddrArr.length;

    if(resUserNameLen) {
        return resUserNameArr;
    } else if(resEmailAddrLen) {
        return resEmailAddrArr;
    } else {
        console.log("The user not exist")
        return [];
    }
}

// The function inserts a new user to the db
async function changePermission(client, userInfo) {
    var userEmailAddr = userInfo.emailAddr;
    var newPermission = userInfo.newPermission;
    checkCode = await checkInfo(client, userInfo);
    if(checkCode == 0) {    //the user's info not exist in the db
        return checkCode;
    } else {
        var user = await client.db("testDb").collection("users").findOne({emailAddr: userEmailAddr});
        var user_id = user._id 
        const res = await client.db("testDb").collection("users").updateOne({_id: user_id}, { $set: {
            permission: newPermission
        }});
        return 1;
    }
    
}








// //init
// async function init() {
//     try {
//         const dbClientAudio = new MongoClient('mongodb+srv://root:root@autotripguide.swdtr.mongodb.net/myFirstDatabase?retryWrites=true&w=majority');
//         await dbClientAudio.connect();
//         // ppp = await findDataByParams(dbClientAudio, {_poiName: 'Masada'}, getDefaultBounds(), 10, true)
//         mmm = await findPois(dbClientAudio, '_poiName' ,'Masada', getDefaultBounds(), 10, true)
//         console.log(mmm)
//     } catch (e) {
//         console.error(e); 
//     }
// }
// init()
// function getDefaultBounds(){
//     var relevantBounds = {}
//     relevantBounds['southWest'] = {lat : 31.31610138349565, lng : 35.35400390625001}
//     relevantBounds['northEast'] = {lat : 31.83303, lng : 36.35400390625001}
//     return relevantBounds;
// }