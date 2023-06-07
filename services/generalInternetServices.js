
module.exports = { nameToPicUrl};
var gis = require('g-i-s');

async function nameToPicUrl(description) {
    var pics  = await new Promise((resolve, reject) => {
        gis(description, logResults);
        function logResults(error, results) {
            if (error) {
                reject(error)
            } else {
                resolve(results);
            }
        }
    })
    if (pics.length >= 1) {
        return pics[0].url
    }
    return undefined; // if no pics
}

//______________________________________________________________________/
//debug

// async function main() {
//     console.log(await nameToPicUrl('asdasdasda'));
// }
// main();