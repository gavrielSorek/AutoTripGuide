import 'dart:math';
import 'package:final_project/Map/globals.dart';
import 'package:geolocator/geolocator.dart';
import 'map.dart';

class PersonalizeRecommendation {

  // calculate the distance between two locations from LatLng
  static double calculateDistance(lat1, lon1, lat2, lon2){
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 - c((lat2 - lat1) * p)/2 +
        c(lat1 * p) * c(lat2 * p) *
            (1 - c((lon2 - lon1) * p))/2;
    return 12742 * asin(sqrt(a));
  }

  // get distance of poi from user
  static double getDistanceInKm(String id) {
    Position userLocation = UserMap.USER_LOCATION;
    double latitude = Globals.globalAllPois[id]!.poi.latitude;
    double longitude = Globals.globalAllPois[id]!.poi.longitude;
    double dist = calculateDistance(userLocation?.latitude ?? latitude, userLocation?.longitude ?? longitude, latitude, longitude);
    return dist;
  }

  // get score of poi according to user's preferences
  static int getPreferenceScore(String id) {
    List<String> categories = Globals.globalAllPois[id]!.poi.Categories;
    int intersections = Globals.favoriteCategoriesSet.intersection(categories.toSet()).length;
    int favoriteCategoriesLength = Globals.favoriteCategoriesSet.length;
    return favoriteCategoriesLength - intersections;
  }

  // sort pois by weighted score of preferences and distance
  static int sortPoisByWeightedScore(String idA, String idB) {
    double distanceA = getDistanceInKm(idA);
    double distanceB = getDistanceInKm(idB);
    int preferencesScoreA = getPreferenceScore(idA);
    int preferencesScoreB = getPreferenceScore(idB);
    int weightedScoreA = ((0.7 * distanceA + 0.3 * preferencesScoreA) * 1000).round();
    int weightedScoreB = ((0.7 * distanceB + 0.3 * preferencesScoreB) * 1000).round();
    return weightedScoreA - weightedScoreB;
  }
}