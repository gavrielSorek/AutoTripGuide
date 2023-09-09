import 'dart:async';
import 'dart:ffi';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart' as bg;

class BackgroundLocationService {
  // Instance
  static BackgroundLocationService _locationService = BackgroundLocationService();
  bg.Coords? coords;

  // StreamController for location changes
  final StreamController<bg.Coords> _locationController = StreamController.broadcast();

  // Stream to expose for other classes to listen to
  Stream<bg.Coords> get onLocationChanged => _locationController.stream;

  static BackgroundLocationService get locationService {
    return _locationService;
  }

  BackgroundLocationService() {
  }

  // Method to configure the background geolocation
  Future<void> init() async {
    await bg.BackgroundGeolocation.ready(bg.Config(
      desiredAccuracy: bg.Config.DESIRED_ACCURACY_HIGH,  // High accuracy
      distanceFilter: 1.0,  // Distance in meters to trigger location updates
      stopOnTerminate: true,  // Stop tracking after app terminates
      startOnBoot: false,  // Start tracking as soon as the device restarts
      debug: false,  // Debugging information will be shown
      speedJumpFilter: 99999999,  // Adjust based on your requirements
    )).then((bg.State state) async {
      // Always call this method to start tracking after configuration
      await bg.BackgroundGeolocation.start();
      // Set isMoving to true immediately after starting
      await bg.BackgroundGeolocation.changePace(true);
    });
  }

  // Method to listen to location changes
  void listenToLocationChanges() {
    // Subscribe to location changes
    bg.BackgroundGeolocation.onLocation((bg.Location location) {
      coords = location.coords;
      // Add location data to the stream
      _locationController.sink.add(location.coords);
    }, (error) {
      print('[location] ERROR - $error');
    });

    // Optional: Subscribe to motion change events
    bg.BackgroundGeolocation.onMotionChange((bg.Location location) {
      print('[motionchange] - $location');
    });

    // You can also subscribe to other events like HTTP, heartbeat, activitychange, etc.
  }

  // Method to stop listening to location changes
  void stopListening() {
    bg.BackgroundGeolocation.stop();
  }

  Future<bg.Coords> getCurrentLocation() async {
    bg.Location location = await bg.BackgroundGeolocation.getCurrentPosition(
        timeout: 30,          // 30 second timeout to fetch location
        maximumAge: 5000,     // Accept the last-known-location if not older than 5000 ms.
        desiredAccuracy: 10,  // Try to fetch a location with an accuracy of `10` meters.
        samples: 3            // Fetch 3 samples and return the best one.
    );
    return location.coords;
  }
  // Close the stream when you dispose of this service.
  void dispose() {
    _locationController.close();
  }
}
