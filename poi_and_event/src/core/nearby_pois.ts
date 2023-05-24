import * as dotenv from 'dotenv'
import request from 'request'
// import request

// const dotenv = require('dotenv');
dotenv.config()
// additioal place types from: https://developers.google.com/maps/documentation/javascript/supported_types
const poi_types = ['airport', 'aquarium', 'art_gallery', 'bar', 'bicycle_store', 'book_store',
    'bowling_alley', 'cafe', 'campground', 'car_rental', 'casino', 'cemetery', 'church', 'city_hall', 'hindu_temple',
    'home_goods_store', 'library', 'lodging', 'meal_takeaway', 'movie_rental', 'movie_theater',
    'museum', 'night_club', 'painter', 'park', 'restaurant', 'shopping_mall', 'spa', 'stadium', 'synagogue',
    'tourist_attraction', 'travel_agency', 'university', 'zoo']


function getCategorizedNearbyPois(latitude: number, longitude: number, radius: number) {
    const location = `${latitude},${longitude}`;
    // const request = require('request');
    const API_KEY = process.env.GM_API_KEY;
    // define the result txt file
    var fs = require('fs')
    var logger = fs.createWriteStream('./src/outputs/results.txt', {
        flags: 'a' // 'a' means appending (old data will be preserved)
    })

    // for each place category
    for (let poi_type of poi_types) {
        const url = `https://maps.googleapis.com/maps/api/place/nearbysearch/json?key=${API_KEY}&location=${location}&radius=${radius}&type=${poi_type}`;

        request(url, function (error: any, response: any, body: any): any {
            if (!error && response.statusCode == 200) {
                const data = JSON.parse(body);

                // print only the categories that have places in the checked area
                if (data.results.length) {
                    logger.write("***CATEGORY:  " + poi_type + "\n")
                    // results: An array of place results. Each element of place contains name, address, types and so on.
                    // print all the nearby pois of the current category
                    for (const place of data.results) {
                        logger.write(place.name + " - " + place.types + "\n")
                    }
                    logger.write("\n")
                }
            }
        });
    }
}


//32.007139, 34.782673 h
//40.757926, -73.985564 times square
// radius in meters (3 km)
getCategorizedNearbyPois(40.757926, -73.985564, 3000);
