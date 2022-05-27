import 'dart:math' as Math;

class DirectionCalculator {
  static Map<int, String> Directions = {
    0: 'North',
    4: 'South',
    6: 'East',
    2: 'West',
    7: 'Northeast',
    1: 'Northwest',
    5: 'Southeast',
    3: 'Southwest',
   -1: 'Undefined'
  };

  static String getDirection(double? lat1, double? lng1, double? lat2, double? lng2) {
    if (lat1 == null || lng1 == null || lat2 == null || lng2 == null) {
      return 'Undefined';
    }
    double angle = Math.atan2(lat2 - lat1, lng2 - lng1);
    angle += Math.pi;
    angle /= Math.pi / 4;
    int halfQuarter = angle.toInt();
    halfQuarter %= 8;
    return Directions[halfQuarter] ?? 'Undefined';
  }
}
