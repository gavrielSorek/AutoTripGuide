module.exports = { InsertPoi, findPoiByName, findPoiByContributor, findPoiByApprover, InsertPois};

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
        num_of_object+=1
        //add mor logic
      }
      console.log(`${num_of_object} new pois was created`);
    } catch (e) {
        console.log(e)
    }

}

// The function find a poi by name from the db
async function findPoiByName(client, nameOfPoi) {
    const res = await client.db("testDb").collection("testCollection").find({_poiName: nameOfPoi});
    const results = await res.toArray();
    if(res) {
        console.log(`found a poi in the collection with the name '${nameOfPoi}'`);
        console.log(results);
        return results
    } else {
        console.log(`No poi found with the name '${nameOfPoi}'`);
    }
}

// The function find a poi by name of the contributor from the db
async function findPoiByContributor(client, nameOfContributor) {
    const res = await client.db("testDb").collection("testCollection").find({_Contributor: nameOfContributor});
    const results = await res.toArray();
    if(res) {
        console.log(`found a poi in the collection with the contributor '${nameOfContributor}'`);
        console.log(results);
        return results
    } else {
        console.log(`No poi found with the contributor '${nameOfContributor}'`);
    }
}

// The function find a poi by name of the Approver from the db
async function findPoiByApprover(client, nameOfApprover) {
    const res = await client.db("testDb").collection("testCollection").find({_ApprovedBy: nameOfApprover});
    const results = await res.toArray();
    if(res) {
        console.log(`found a poi in the collection with the Approver '${nameOfApprover}'`);
        console.log(results);
        return results
    } else {
        console.log(`No poi found with the Approver '${nameOfApprover}'`);
    }
}
