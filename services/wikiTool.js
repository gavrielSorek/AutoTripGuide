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


    var response = await axios.get(reqUrl)
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



//______________________________________________________________________________________________________//
// debug
// getPoiWikiCategoriesByName('Masada')