var XMLHttpRequest = require('xhr2');
module.exports = { convertArrayToServerCategories, convertToServerCategories, splitMulti, translate, detectLanguage, translateIfNotInTargetLanguage};

const serverCommunication = require("./serverCommunication");
const serverUrl = serverCommunication.getServerUrl;

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
        } else if(category.indexOf(' ') >= 0) { //the category name include more than one word
            const categoryArray = category.split(" ");
            for(var i=0; i<categoryArray.length; i++) {
                if(categoriesToConvert.includes(categoryArray[i])) {
                    filterServerCategories.push(element);
                    return;
                }
            }
        }
    });
    return filterServerCategories;
}
// split a string with multiple separators
function splitMulti(str, tokens){
    var tempChar = tokens[0]; // We can use the first token as a temporary join character
    for(var i = 1; i < tokens.length; i++){
        str = str.split(tokens[i]).join(tempChar);
    }
    str = str.split(tempChar);
    return str;
}


//************************************************************************************************** */ translation tool
// const cld = require('cld');
const translatte = require('translatte');
const franc = require('franc');
const convert3To1 = require('iso-639-3-to-1')

async function translate(stringToTranslate, langToTranslate) {
    return (await translatte(stringToTranslate, {to: langToTranslate})).text;
}  

async function detectLanguage(text) {
    var result = franc(text);
    return convert3To1(result); // convert to iso-639-1 language code (from iso-639-3)
  }

async function isInLanguage(text, languageCode) {
    const result = await detectLanguage(text);
    if (result) {
        return result === languageCode;
    } else  {
        return false;
    }
}

async function translateIfNotInTargetLanguage(text, desiredLanguageCode){
    if (await isInLanguage(text, desiredLanguageCode)) {
        return text;
    } else {
        return await translate(text, desiredLanguageCode);
    }
}







//______________________________________________________________________________________________________________________________//
// debug

async function testTranslate() {
    // var temp = await translate('שלום לכולם', 'en');
    // console.log(temp);
    // var temp2 = await translate('this is a test', 'he');
    // console.log(temp2);
    // var temp3 = await translateIfNotInTargetLanguage('This is try number one', 'en');
    // console.log(temp3);
    var temp4 = await translateIfNotInTargetLanguage('This is try number one', 'he');
    console.log(temp4);


}

async function main() {
    var debugCategories = ['Geological', 'Bridges'];
    var categories = await convertArrayToServerCategories(debugCategories);
    console.log(categories);
    //var voice = await textToVoice('hello world');
}

// async function testTranslate() {
//     var result = await translatte('אתה מדבר אנגלית תקינה?', {to: 'en'});
//     console.log(result.text)
//     // translatte('תקינה אתה מדבר אנגלית?', {to: 'en'}).then(res => {
//     //     console.log(res.text);
//     // }).catch(err => {
//     //     console.error(err);
//     // });
// }  

// testCld();
//main()
//testTranslate()

