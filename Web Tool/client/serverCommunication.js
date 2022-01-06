// module.exports = {getPoisInfo, getAudioById};
// The function get the poi info according name
// function getPoisInfo(poiParameter, valueOfParameter, searchOutsideTheBounds) {
//     const myPromise = new Promise((resolve, reject) => {
//     var poiInfo = {
//         poiParameter : valueOfParameter
//     }
//     var quaryParams = {}
//     quaryParams['poiParameter'] = poiParameter
//     quaryParams['relevantBounds'] = getRelevantBounds()
//     quaryParams['poiInfo'] = poiInfo
//     quaryParams['searchOutsideTheBounds'] = searchOutsideTheBounds
//     var quaryParamsJson= JSON.stringify(quaryParams);
//     const Http = new XMLHttpRequest();
//     const url = uriBeginning + 'searchPois';
//     Http.open("POST", url);
//     Http.withCredentials = false;
//     Http.setRequestHeader("Content-Type", "application/json");
//     console.log(quaryParamsJson)
//     Http.send(quaryParamsJson);
//     Http.onreadystatechange = (e) => {
//         if (Http.readyState == 4) { //if the operation is complete.
//             var response = Http.responseText
//             if (response.length > 0) {
//                 console.log("response from the server is recieved")
//                 var poisInfo = JSON.parse(Http.responseText);
//                 resolve(poiInfo);
//                 if(poisInfo.length == 0) {
//                     userShowNotFoundMessage()
//                     console.log("not found");
//                     return
//                 } else {
//                 console.log(poisInfo);
//                 showPoisOnMap(poisInfo);
//                 }
//             } else {
//                 userShowNotFoundMessage();
//                 console.log("not found");
//             }
//         }
//     }
// });
// }

// // The function get the poi info for pois that waiting for approval
// function getAudioById(id) {
//     var poiInfo = {
//         _id : id
//     }
//     var poiInfoJson= JSON.stringify(poiInfo);
//     const Http = new XMLHttpRequest();
//     const url= uriBeginning + 'searchPoiAudioById';
//     Http.open("POST", url);
//     Http.withCredentials = false;
//     Http.setRequestHeader("Content-Type", "application/json");
//     Http.send(poiInfoJson);
//     Http.onreadystatechange = (e) => {
//         if (Http.readyState == 4) { //if the operation is complete. 
//             var response = Http.responseText
//             if(response.length > 0) {
//                 console.log("response from the server is recieved")
//                 var poisInfo = JSON.parse(Http.responseText);
//                 console.log(poisInfo);
//                 if(poisInfo.length == 0) {
//                     console.log("not found");
//                 }
//                 loadAudio(poisInfo)
//             } else {
//                 console.log("not found");
//             }
//         }  
//     }
// }