module.exports = { InsertPoi, findPoiByName, findPoiByContributor};

// The function insert a new poi to the db
async function InsertPoi(client, newPoi) {
    const res = await client.db("testDb").collection("testCollection").insertOne(newPoi);
    console.log(`new poi created with the following id: ${res.insertedId}`);
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
        console.log(`found a poi in the collection with the name '${nameOfContributor}'`);
        console.log(results);
        return results
    } else {
        console.log(`No poi found with the name '${nameOfContributor}'`);
    }
}