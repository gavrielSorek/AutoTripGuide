//https://www.npmjs.com/package/country-reverse-geocoding
var crg = require('country-reverse-geocoding').country_reverse_geocoding();
// import * as crg from 'country-reverse-geocoding';
export function getCountry(lat:any, lng:any) {
    var country = crg.get_country(lat, lng);
    if (country) {
        return country.name
    }
    return undefined;
}