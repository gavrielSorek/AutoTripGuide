//https://www.npmjs.com/package/country-reverse-geocoding
module.exports = { getCountry };
var crg = require('country-reverse-geocoding').country_reverse_geocoding();

function getCountry(lat, lng) {
    var country = crg.get_country(lat, lng);
    if (country) {
        return country.name
    }
    return undefined;
}
// function example() {
//     console.log(getCountry(32.550555555555555, 35.356944444444444))
// }
// example()