import 'dart:async';
import 'dart:math' show atan2, cos, pi, sin;
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';

class DrivingDirection {
  Location location = new Location();
  LocationData? lastLocation;
  StreamController<double> _controller = StreamController<double>();
  final double threshold; // minimum distance in meters

  DrivingDirection({this.threshold = 1}) {
    location.onLocationChanged.listen((LocationData currentLocation) {
      if (lastLocation != null) {
        // calculate the distance between the last two locations
        double lat1 = lastLocation!.latitude!;
        double lon1 = lastLocation!.longitude!;
        double lat2 = currentLocation.latitude!;
        double lon2 = currentLocation.longitude!;

        double distance = Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
        if (distance >= threshold) {
          // calculate the bearing between the last two locations
          double y = sin(lon2 - lon1) * cos(lat2);
          double x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(lon2 - lon1);
          double bearing = atan2(y, x) * (180 / pi);
          // add the calculated bearing to the stream
          _controller.add(bearing);
          lastLocation = currentLocation;
        }
      } else {
        lastLocation = currentLocation;
      }
    });
  }

  Stream<double> get onBearingChanged => _controller.stream;
}