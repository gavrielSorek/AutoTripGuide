module.exports = {getPositionByName};
const wiki = require('wikijs').default;
//the function return postion in dd coordinate by name, this function teturn promise
async function getPositionByName(title, language) {

  return wiki({ apiUrl: "https://"+ language +".wikipedia.org/w/api.php"})
    .page(title)
    .then(page => page.coordinates())
}

// //example function how to use getPositionByName
// function example() {
//   var ex = getPositionByName('masada', 'en')
//   console.log(ex)
//   ex.then((position)=>{console.log("lat: " + position.lat + " lng: " + position.lon)}).catch(()=>{console.log("error cant find this position")});
// }
// example()