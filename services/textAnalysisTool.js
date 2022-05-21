var XMLHttpRequest = require('xhr2');

module.exports = { convertArrayToServerCategories, convertToServerCategories};
const serverUrl = 'https://autotripguide.loca.lt';

var globalServerCategories = undefined;

async function getServerCategories(){
    var lang = {
        language : "eng", //TODO::ADAPT LANGUAGE TO CATEGORIES LANGUAGE
    }
    var langJson= JSON.stringify(lang);
    const Http = new XMLHttpRequest();
    const url=serverUrl + '/getCategories';
    Http.open("POST", url);
    Http.withCredentials = false;
    Http.setRequestHeader("Content-Type", "application/json");
    Http.send(langJson);
    const categoriesPromise = new Promise((resolve, reject) => {
        Http.onreadystatechange = (e) => {  
            if (Http.readyState == 4) { //if the operation is completed. 
                var response = Http.responseText
                if(response.length > 0) {
                    console.log("response from the server is recieved in getServerCategories")
                    var jsonResponse = JSON.parse(Http.responseText);
                    resolve(Object.keys(jsonResponse));
                } else {
                    reject("get categories from server failed");
                }
            }
        }
    });
    return categoriesPromise;
}


// async function convertArrayToServerCategories(categoriesToConvert) {
//     if (!globalServerCategories) {
//         globalServerCategories = await getServerCategories();
//     }
//     categoriesLower = []
//     categoriesToConvert.forEach(element => {
//         categoriesLower.push(element.toLowerCase());
//       });
//     var filterServerCategories = []
//     globalServerCategories.forEach(element => {
//         category = element.toLowerCase();
//         if(categoriesLower.includes(category)) {
//             filterServerCategories.push(element);
//         }
//     });
//     return filterServerCategories;
// }

async function convertArrayToServerCategories(categoriesToConvert) {
    categoriesStr = '';
    for (var i =0; i < categoriesToConvert.length; i++) {
        categoriesStr += ', '
        categoriesStr += categoriesToConvert[i];
    }
    return await convertToServerCategories(categoriesStr)

}
async function convertToServerCategories(categoriesToConvert) {
    if (!globalServerCategories) {
            globalServerCategories = await getServerCategories();
        }
    categoriesToConvert = categoriesToConvert.toLowerCase();
    var filterServerCategories = []
    globalServerCategories.forEach(element => {
        category = element.toLowerCase();
        if(categoriesToConvert.includes(category)) {
            filterServerCategories.push(element);
        }
    });
    return filterServerCategories;
}


//______________________________________________________________________________________________________________________________//
// debug

// async function main() {
//     var debugCategories = ['buildings', 'museums in Israel'];
//     var categories = await convertArrayToServerCategories(debugCategories);
//     console.log(categories);
// }

// main()