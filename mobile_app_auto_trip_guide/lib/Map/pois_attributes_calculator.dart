import 'dart:math';

import 'package:flutter_background_geolocation/flutter_background_geolocation.dart' as bg;
import 'package:journ_ai/Map/globals.dart';
import 'package:journ_ai/Map/map_configuration.dart';
import 'package:journ_ai/Map/types.dart';
import 'package:geolocator/geolocator.dart';

import '../General/generals.dart';
import 'package:mapbox_gl/mapbox_gl.dart' as mapbox;
import 'dart:math' as Math;

import '../Utils/background_location_service.dart';

class PoisAttributesCalculator {
  static double _MAX_DIST = 2000; //2000 meter
  static void setMaxDist(double value) {
    _MAX_DIST = value;
  }

  static double getMaxDist() {
    return _MAX_DIST;
  }

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
        Globals.globalUserMap.userLocation.latitude,
        Globals.globalUserMap.userLocation.longitude,
        Globals.globalUserMap.userHeading,
        poi.latitude,
        poi.longitude);
    int halfQuarter = 45;
    int directionNum = bearing ~/ halfQuarter;
    print("direction Num " + directionNum.toString());
    return USER_RELATIVE_DIRECTIONS[directionNum] ?? '';
  }

  static List<Poi> filterPois(List<Poi> pois, bg.Coords position) {
    // can add more filters
    pois = filterPoisByDistance(pois, position);
    pois = filterHistoricalPois(pois);
    return pois;
  }

  static List<Poi> filterPoisByDistance(List<Poi> pois, bg.Coords position) {
    pois.removeWhere((poi) =>
        getDistBetweenPoints(poi.latitude, poi.longitude, position.latitude,
            position.longitude) >
            _MAX_DIST);
    return pois;
  }

  Future<bool> isPoiNearUser(Poi poi) async {
    bg.Coords userLocation = await BackgroundLocationService.locationService.getCurrentLocation();;
    return getDistBetweenPoints(poi.latitude, poi.longitude, userLocation.latitude,
        userLocation.longitude) < _MAX_DIST;
  }

  static List<MapPoi> filterMapPoisByDistance(List<MapPoi> mapPois, bg.Coords position) {
    mapPois.removeWhere((mapPoi) =>
    getDistBetweenPoints(mapPoi.poi.latitude, mapPoi.poi.longitude, position.latitude,
        position.longitude) >
        _MAX_DIST);
    return mapPois;
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

  static String getPoiIntro(Poi poi) {
    int distInMeters = Geolocator.distanceBetween(Globals.globalUserMap.userLocation.latitude,
        Globals.globalUserMap.userLocation.longitude, poi.latitude, poi.longitude).toInt();
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

  static const earthRadius = 6371000.0; // Earth's radius in meters

  // calculate the new position that it's distanceInMeters from the original & angle is bearingInDegrees
  static mapbox.LatLng calculateNewPosition(mapbox.LatLng original,
      double distanceInMeters, double bearingInDegrees) {
    double distanceInRadians = distanceInMeters / earthRadius;
    double bearingInRadians = bearingInDegrees * (Math.pi / 180);
    double originalLatInRadians = original.latitude * (Math.pi / 180);
    double originalLngInRadians = original.longitude * (Math.pi / 180);

    double newLatInRadians = Math.asin(Math.sin(originalLatInRadians) * Math.cos(distanceInRadians) +
        Math.cos(originalLatInRadians) * Math.sin(distanceInRadians) * Math.cos(bearingInRadians));

    double newLngInRadians = originalLngInRadians + Math.atan2(
        Math.sin(bearingInRadians) * Math.sin(distanceInRadians) * Math.cos(originalLatInRadians),
        Math.cos(distanceInRadians) - Math.sin(originalLatInRadians) * Math.sin(newLatInRadians));

    double newLat = newLatInRadians * (180 / Math.pi);
    double newLng = newLngInRadians * (180 / Math.pi);

    return mapbox.LatLng(newLat, newLng);
  }
}
