import 'dart:math';
import 'package:journ_ai/Map/globals.dart';
import 'package:journ_ai/Map/pois_attributes_calculator.dart';
import 'package:journ_ai/Map/types.dart';
import 'package:location/location.dart';

class PersonalizeRecommendation {
  static double _DISTANCE_WEIGHT = 0.6;

  static double getDistWeight() {
   return  _DISTANCE_WEIGHT;
  }

  static void setDistWeight(double val) {
    _DISTANCE_WEIGHT = val;
  }

  // calculate the distance between two locations from LatLng
  static double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  // get distance of poi from user
  static double getDistanceInKm(Poi poi) {
    LocationData userLocation = Globals.globalUserMap.userLocation;
    double dist = calculateDistance(userLocation.latitude,
        userLocation.longitude, poi.latitude, poi.longitude);
    return dist;
  }

  static double getDistanceInMeters(Poi poi) {
    return getDistanceInKm(poi) * 1000;
  }

  // get score of poi according to user's preferences
  static int getPreferenceScore(Poi poi) {
    List<String> categories = poi.Categories;
    int intersections =
        Globals.favoriteCategoriesSet.intersection(categories.toSet()).length;
    int favoriteCategoriesLength = Globals.favoriteCategoriesSet.length;
    return favoriteCategoriesLength - intersections;
  }

  // sort pois by weighted score of preferences and distance
  static int sortMapPoisByWeightedScore(MapPoi mapPoi1, MapPoi mapPoi2) {
    double distanceA = getDistanceInKm(mapPoi1.poi);
    double distanceB = getDistanceInKm(mapPoi2.poi);
    int preferencesScoreA = getPreferenceScore(mapPoi1.poi);
    int preferencesScoreB = getPreferenceScore(mapPoi2.poi);
    int weightedScoreA =
        ((0.7 * distanceA + 0.3 * preferencesScoreA) * 1000).round();
    int weightedScoreB =
        ((0.7 * distanceB + 0.3 * preferencesScoreB) * 1000).round();
    return weightedScoreA - weightedScoreB;
  }

  // sort pois by weighted score of preferences and distance
  static int sortMapPoisByDist(MapPoi mapPoi1, MapPoi mapPoi2) {
    double distanceA = getDistanceInMeters(mapPoi1.poi);
    double distanceB = getDistanceInMeters(mapPoi2.poi);
    return distanceA.round()- distanceB.round();
  }

  static double normalizeDistance(double distanceInMeters) {
    double maxDistance =
        PoisAttributesCalculator.getMaxDist(); // maximum distance considered (change as needed)
    return 1 - min(distanceInMeters, maxDistance) / maxDistance;
  }

  static int sortMapPoisByCombinedScore(MapPoi mapPoi1, MapPoi mapPoi2) {

    double vendorScorePoi1 = getVendorScore(mapPoi1.poi);
    double distInMetersPoi1 = getDistanceInMeters(mapPoi1.poi);
    double vendorScorePoi2 = getVendorScore(mapPoi2.poi);
    double distInMetersPoi2 = getDistanceInMeters(mapPoi2.poi);

    // normalize distances
    double normalizedDistancePoi1 = normalizeDistance(distInMetersPoi1);
    double normalizedDistancePoi2 = normalizeDistance(distInMetersPoi2);

    // calculate combined scores
    double combinedScorePoi1 =
        _DISTANCE_WEIGHT * normalizedDistancePoi1 + (1 - _DISTANCE_WEIGHT) * vendorScorePoi1;
    double combinedScorePoi2 =
        _DISTANCE_WEIGHT * normalizedDistancePoi2 + (1 - _DISTANCE_WEIGHT) * vendorScorePoi2;

    return (combinedScorePoi2 * 1000).round() -
        (combinedScorePoi1 * 1000).round(); // for descending sort
  }

  static const maxGoogleReviewers = 1000;
  static const double maxAvgRating = 5;
  static const double epsilon = 1e-10;

  static double getGoogleVendorScore(VendorInfo vendorInfo) {
    dynamic avgRating = 0;
    int numOfReviewers = 0;
    if (vendorInfo.getProperty('_avgRating') != null) {
      avgRating = vendorInfo.getProperty('_avgRating');
    }
    if (vendorInfo.getProperty('_numReviews') != null) {
      numOfReviewers = vendorInfo.getProperty('_numReviews');
    }
    return ((avgRating / maxAvgRating) +
        (numOfReviewers / min(maxGoogleReviewers, numOfReviewers + epsilon)) / 2);
  }

  static const Map<String, double> ratingStrToScoreOpenTripMap = {
    "3h": 3,
    "3": 3,
    "2h": 2,
    "2": 2,
    "1h": 1,
    "1": 1
  };
  static const maxOpenTripMapRating = 3;
  static double getOpenTripMapVendorScore(VendorInfo vendorInfo) {
    String? ratingStr = vendorInfo.getProperty('_rating');
    if (ratingStrToScoreOpenTripMap[ratingStr] != null) {
      return ratingStrToScoreOpenTripMap[ratingStr]! / maxOpenTripMapRating;
    }
    return 0;
  }

  static double getVendorScore(Poi poi) {
    if (poi.vendorInfo == null) return 0;
    VendorInfo vendorInfo = poi.vendorInfo!;
    switch (vendorInfo.getProperty('_source')) {
      case 'google':
        return getGoogleVendorScore(vendorInfo);
      case 'openTripMap':
        return getOpenTripMapVendorScore(vendorInfo);
      default:
        return 0;
    }
  }
}
