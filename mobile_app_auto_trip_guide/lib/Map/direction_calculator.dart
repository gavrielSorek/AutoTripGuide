import 'dart:math' as Math;

class DirectionCalculator {
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

  static double radians(n) {
    return n * (Math.pi / 180);
  }
  static double degrees(n) {
    return n * (180 / Math.pi);
  }
  static double getBearing(startLat,startLong,endLat,endLong){
    startLat = radians(startLat);
    startLong = radians(startLong);
    endLat = radians(endLat);
    endLong = radians(endLong);
    var dLong = endLong - startLong;

    var dPhi = Math.log(Math.tan(endLat/2.0+Math.pi/4.0)/Math.tan(startLat/2.0+Math.pi/4.0));
    if (dLong.abs() > Math.pi){
      if (dLong > 0.0) {
        dLong = -(2.0 * Math.pi - dLong);
      } else {
        dLong = (2.0 * Math.pi + dLong);
      }
    }
    return (degrees(Math.atan2(dLong, dPhi)) + 360.0) % 360.0;
  }

  static String getDirection(double? lat1, double? lng1, double? lat2, double? lng2) {
    if (lat1 == null || lng1 == null || lat2 == null || lng2 == null) {
      return 'Undefined';
    }
    double bearing = getBearing(lat1, lng1, lat2, lng2);
    int halfQuarter = 45;
    int directionNum = bearing~/halfQuarter;
    print("direction Num "  + directionNum.toString());
    return Directions[directionNum] ?? 'Undefined';
  }
}
