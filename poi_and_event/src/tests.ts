
import { wikiPlaceInfo, wikiNearestPlaces, wikiPageImage, placeLikelihood , searchWikipedia,searchWikipedia2,searchWikipedia3, wikiAllPageInfo, wikiPlaceResponse } from "./apis/wiki-api";
import { getInterestValue } from "./apis/interest-api";
let info: string = "";

// wikiPlaceInfo("new york").then((placeInfo) => {  
// });

// searchWikipedia("The Muse New York", "resorts").then((placeInfo) => {
//     wikiPlaceInfo(placeInfo).then((placeInfo) => {
//         console.log(placeInfo);
//     });
// });


// searchWikipedia("Chalav U'Devash Pizza", "Restaurants").then((placeInfo) => {
//     console.log(placeInfo);
// });

// wikiNearestPlaces(40.757926, -73.985564, 3000.0).then((placeInfo) => {
//     if (placeInfo !== undefined)
//         console.log(placeInfo[0]);
// });

// gptPlaceInfo("barcelona", 64).then((placeInfo) => {
//   //console.log((placeInfo));
// });

// formatToLength(info, 32,).then((placeInfo) => {
//   console.log((placeInfo));
// });


// wikiPageImage("Pizza_Hut_Israel").then((placeInfo) => {
//     console.log(placeInfo);
// });


// wikiAllPageInfo("Royalton_Hotel").then((placeInfo : wikiPlaceResponse) => {
//     console.log(placeInfo);
// });


//let list = ["Bet Shemesh", "Tel Beit Shemesh", "Stalactite Cave Nature Reserve", "Ne'eman Bakery", "Big Sport", "Auto Test Ltd. Beit Shemesh", "Ace - Bet Shemesh", "Nissan Junction Garage, Center for Automotive Services 1979 Ltd", "Vertica CRM", "Tsor'a"]
let list = ["Tel Beit Shemesh"]

list.forEach((place) => {
    searchWikipedia3(place, "resorts").then((placeInfo : any) => {
        console.log(place, "::::::",placeInfo);
    });
});