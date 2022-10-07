import 'package:final_project/Map/map.dart';
import 'package:geolocator/geolocator.dart';

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

  static double getBearingBetweenPoints(startLat,startLong,endLat,endLong){
    double bearing = Geolocator.bearingBetween(startLat, startLong, endLat, endLong);
    if (bearing < 0) {
      return 360 + bearing;
    }
    return bearing;
  }

  static double getDistBetweenPoints(double lat1, double lng1, double lat2, double lng2) {
    double distanceInMeters = Geolocator.distanceBetween(lat1, lng1, lat2, lng2);
    return distanceInMeters;
  }

  static double getBearingBetweenPointsWithHeading(double lat1, double lng1, double lat2, double lng2, double heading) {
    double trueBearing = getBearingBetweenPoints(lat1, lng1, lat2, lng2);
    double relativeUserHeadingToPoint = trueBearing - heading;
    if (relativeUserHeadingToPoint >= 0) {
      return relativeUserHeadingToPoint;
    } else {
      return 360 + relativeUserHeadingToPoint;
    }
  }

  static String getDirection(double? lat1, double? lng1, double? lat2, double? lng2) {
    if (lat1 == null || lng1 == null || lat2 == null || lng2 == null) {
      return 'Undefined';
    }
    // double bearing = getBearingBetweenPoints(lat1, lng1, lat2, lng2);
    double bearing = getBearingBetweenPointsWithHeading(lat1, lng1, lat2, lng2, UserMap.USER_LOCATION.heading);
    int halfQuarter = 45;
    int directionNum = bearing~/halfQuarter;
    print("direction Num "  + directionNum.toString());
    return Directions[directionNum] ?? 'Undefined';
  }
}
