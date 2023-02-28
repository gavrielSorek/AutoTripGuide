import 'package:final_project/Map/globals.dart';
import 'package:final_project/Map/map.dart';
import 'package:final_project/Map/map_configuration.dart';
import 'package:final_project/Map/types.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../General Wigets/generals.dart';

class PoisAttributesCalculator {
  static Map<int, String> Directions = {
    0: 'North',
    4: 'South',
    6: 'West',
    2: 'East',
    7: 'Northwest',
    1: 'Northeast',
    5: 'Southwest',
    3: 'Southeast',
    -1: 'Undefined'
  };

  // static Map<int, String> USER_RELATIVE_DIRECTIONS = {
  //   0: 'ahead',
  //   4: 'behind',
  //   6: 'left',
  //   2: 'right',
  //   7: 'ahead left',
  //   1: 'ahead left',
  //   5: 'behind left',
  //   3: 'behind right',
  //   -1: 'Undefined'
  // };

  static double getBearingBetweenPoints(startLat, startLong, endLat, endLong) {
    double bearing =
        Geolocator.bearingBetween(startLat, startLong, endLat, endLong);
    if (bearing < 0) {
      return 360 + bearing;
    }
    return bearing;
  }

  static double getDistBetweenPoints(
      double lat1, double lng1, double lat2, double lng2) {
    double distanceInMeters =
        Geolocator.distanceBetween(lat1, lng1, lat2, lng2);
    return distanceInMeters;
  }

  static double getBearingBetweenPointsWithHeading(
      double lat1, double lng1, double lat2, double lng2, double heading) {
    double trueBearing = getBearingBetweenPoints(lat1, lng1, lat2, lng2);
    double relativeUserHeadingToPoint = trueBearing - heading;
    if (relativeUserHeadingToPoint >= 0) {
      return relativeUserHeadingToPoint;
    } else {
      return 360 + relativeUserHeadingToPoint;
    }
  }

  static String getDirection(
      double? lat1, double? lng1, double? lat2, double? lng2) {
    if (lat1 == null || lng1 == null || lat2 == null || lng2 == null) {
      return 'Undefined';
    }
    // double bearing = getBearingBetweenPoints(lat1, lng1, lat2, lng2);
    double bearing = getBearingBetweenPointsWithHeading(
        lat1, lng1, lat2, lng2, UserMap.USER_LOCATION.heading);
    int halfQuarter = 45;
    int directionNum = bearing ~/ halfQuarter;
    print("direction Num " + directionNum.toString());
    return Directions[directionNum] ?? 'Undefined';
  }

  static List<Poi> filterPois(List<Poi> pois, Position position) {
    // can add more filters
    pois = filterPoisByDistance(pois, position);
    pois = filterHistoricalPois(pois);
    return pois;
  }

  static List<Poi> filterPoisByDistance(List<Poi> pois, Position position) {
    const double maxDist = 2000; //2000 meters
    pois.removeWhere((poi) =>
        getDistBetweenPoints(poi.latitude, poi.longitude, position.latitude,
            position.longitude) >
        maxDist);
    return pois;
  }

  static List<Poi> filterHistoricalPois(List<Poi> pois) {
    String currentTime = Generals.getTime();
    List<Poi> poisCpy = pois.toList();
    poisCpy.removeWhere((poi) {
      try {
        var visitedPoi = Globals.globalVisitedPoi
            .firstWhere((element) => element.id == poi.id);
        return Generals.getDaysBetweenDates(visitedPoi.time, currentTime) <=
            MapConfiguration.numOfDayNotShowPoi;
      } catch (e) {
        return false;
      }
    });
    return poisCpy;
  }
}
