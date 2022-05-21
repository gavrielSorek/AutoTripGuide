// tool that communicate with wikipedia api
module.exports = { getPoiWikiCategoriesByName};

const axios = require('axios');
// https://en.wikipedia.org/w/api.php?action=query&format=json&prop=categories&titles=masada - example
const wikiApiUrl = 'https://en.wikipedia.org/w/api.php'

async function getPoiWikiCategoriesByName(poiName) {
    var reqUrl = wikiApiUrl + `?action=query&format=json&prop=categories&titles=${poiName}`;
    var response = undefined;
    try {
        var response = await axios.get(reqUrl)

    } catch {
        console.log('error in getPoiWikiCategoriesByName');
    }


    var temp = response.data.query.pages;
    var categories = temp[Object.keys(temp)[0]].categories;
    var retCategories = [];
    if (categories) {
        for (var i = 0; i <categories.length;  i++ ) {
            retCategories.push(categories[i].title)
        }
    }
    return retCategories;
}

//https://en.wikipedia.org/w/api.php?format=json&action=query&prop=extracts|categories&exintro&explaintext&redirects=1&titles=masada

async function getPoiDescByName(poiName) {
    var reqUrl = wikiApiUrl + `?format=json&action=query&prop=extracts|categories&exintro&explaintext&redirects=1&titles=${poiName}`;
    console.log(reqUrl);

    var response = undefined;
    try {
        var response = await axios.get(reqUrl)

    } catch {
        console.log('error in getPoiDescByName');
    }

    var temp = response.data.query.pages;
    var shortDesc = temp[Object.keys(temp)[0]].extract;
    return shortDesc;
}


//______________________________________________________________________________________________________//
// debug

//  async function main() {
//     console.log( await getPoiWikiCategoriesByName('Masada'));
//     console.log( await getPoiDescByName('Masada'));
//  }
//  main();
