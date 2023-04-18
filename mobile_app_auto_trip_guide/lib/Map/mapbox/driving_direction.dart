import 'dart:async';
import 'dart:math' show atan2, cos, pi, sin;
import 'package:location/location.dart';

class DrivingDirection {
  Location location = new Location();
  List<LocationData> locations = [];
  StreamController<double> _controller = StreamController<double>();

  DrivingDirection() {
    location.onLocationChanged.listen((LocationData currentLocation) {
      locations.add(currentLocation);

      if (locations.length > 1) {
        // calculate the bearing between the last two locations
        double lat1 = locations[locations.length - 2].latitude! * (pi / 180);
        double lon1 = locations[locations.length - 2].longitude! * (pi / 180);
        double lat2 = currentLocation.latitude! * (pi / 180);
        double lon2 = currentLocation.longitude! * (pi / 180);

        double y = sin(lon2 - lon1) * cos(lat2);
        double x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(lon2 - lon1);
        double bearing = atan2(y, x) * (180 / pi);

        // add the calculated bearing to the stream
        _controller.add(bearing);
      }
    });
  }

  Stream<double> get onBearingChanged => _controller.stream;
}