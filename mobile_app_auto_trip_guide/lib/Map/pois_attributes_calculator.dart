import 'dart:math';

import 'package:final_project/Map/globals.dart';
import 'package:final_project/Map/map.dart';
import 'package:final_project/Map/map_configuration.dart';
import 'package:final_project/Map/types.dart';
import 'package:geolocator/geolocator.dart';

import '../General Wigets/generals.dart';
import 'package:mapbox_gl/mapbox_gl.dart' as mapbox;

class PoisAttributesCalculator {
  static Map<int, String> USER_RELATIVE_DIRECTIONS = {
    0: 'ahead of you',
    4: 'behind you',
    6: 'to your left',
    2: 'to your right',
    7: 'to your upper left',
    1: 'to your upper right',
    5: 'to your lower left',
    3: 'to your lower right',
    -1: 'Undefined'
  };

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
      double lat1, double lng1, double heading, double lat2, double lng2) {
    double trueBearing = getBearingBetweenPoints(lat1, lng1, lat2, lng2);
    double relativeUserHeadingToPoint = trueBearing - heading;
    if (relativeUserHeadingToPoint >= 0) {
      return relativeUserHeadingToPoint;
    } else {
      return 360 + relativeUserHeadingToPoint;
    }
  }

  static String getDirectionStr(Poi poi) {
    // double bearing = getBearingBetweenPoints(lat1, lng1, lat2, lng2);
    double bearing = getBearingBetweenPointsWithHeading(
        UserMap.USER_LOCATION.latitude,
        UserMap.USER_LOCATION.longitude,
        UserMap.USER_HEADING,
        poi.latitude,
        poi.longitude);
    int halfQuarter = 45;
    int directionNum = bearing ~/ halfQuarter;
    print("direction Num " + directionNum.toString());
    return USER_RELATIVE_DIRECTIONS[directionNum] ?? '';
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

  // Define a function that takes in the x and y coordinates of a point,
// a radius, and an angle in degrees, and returns the x and y coordinates
// of the point at that angle and distance.
  static mapbox.LatLng getPointAtAngle(
      double lat, double lng, double radius, double angleDegrees) {
    // Convert the angle from degrees to radians.
    double angleRadians = angleDegrees * pi / 180.0;

    double pointLng = lng + radius * cos(angleRadians);
    double pointLat = lat + radius * sin(angleRadians);
    // Return the coordinates as a list.
    return mapbox.LatLng(pointLat, pointLng);
  }

  static String getPoiIntro(Poi poi) {
    int distInMeters = Geolocator.distanceBetween(UserMap.USER_LOCATION.latitude,
        UserMap.USER_LOCATION.longitude, poi.latitude, poi.longitude).toInt();
    int distInTensOfMeters = (distInMeters / 10).round() * 10;
    String directionStr = getDirectionStr(poi);
    String poiName = poi.poiName ?? "";
    String intro = 'In ' +
        distInTensOfMeters.toString() +
        'meters,' +
        directionStr +
        ", is " +
        poiName +
        ".";
    return intro;
  }
}
