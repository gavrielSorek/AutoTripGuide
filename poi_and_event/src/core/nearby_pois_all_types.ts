import { getNearbyPois } from './nearby_pois_objects';
import { writePoisToJsonFile } from './nearby_pois_objects';
import { Poi } from './poi';

// additioal place types from: https://developers.google.com/maps/documentation/javascript/supported_types
// const poi_types = ['airport', 'aquarium', 'art_gallery', 'bar', 'bicycle_store', 'book_store',
//   'bowling_alley', 'cafe', 'campground', 'car_rental', 'casino', 'cemetery', 'church', 'city_hall', 'hindu_temple',
//   'home_goods_store', 'library', 'lodging', 'meal_takeaway', 'movie_rental', 'movie_theater',
//   'museum', 'night_club', 'painter', 'park', 'restaurant', 'shopping_mall', 'spa', 'stadium', 'synagogue',
//   'tourist_attraction', 'travel_agency', 'university', 'zoo']

const poi_types = ['airport', 'art_gallery', 'church', 'synagogue', 'casino', 'park', 'stadium', 'city_hall', 'zoo', 'museum', 'tourist_attraction', 'movie_theater']


async function getAllTypesPois() {
  let pois_set = new Set<Poi>();
  // for each place category
  for (let poi_type of poi_types) {
    // 31.8334139475428, 34.97983217570125 latrun
    await getNearbyPois(31.8334, 34.97988, 3000.0, poi_type, "all_types").then((pois_list) => {
      if (pois_list != undefined) {
        for (let poi of pois_list) {
          // if this poi is already in the set, it won't be added
          let found_poi = Array.from(pois_set).find(place => place._poiName === poi._poiName);
          if (found_poi) {
            continue;
          }
          pois_set.add(poi);
        }
      }
    });
  }
  var new_pois_list: Poi[] = [];
  new_pois_list = [...pois_set]
  writePoisToJsonFile(new_pois_list, "all_types_");
}

getAllTypesPois()