import 'dart:async';
import 'package:location/location.dart';

class BackgroundLocationService {
  // Private constructor for singleton pattern
  BackgroundLocationService._();

  // Singleton instance
  static final BackgroundLocationService _instance = BackgroundLocationService._();
  static BackgroundLocationService get instance => _instance;

  LocationData? locationData;
  final location = Location();

  // StreamController for location changes
  final StreamController<LocationData> _locationController = StreamController<LocationData>.broadcast();

  // Stream to expose for other classes to listen to
  Stream<LocationData> get onLocationChanged => _locationController.stream;

  // Method to configure the background geolocation
  Future<void> init() async {
    location.changeSettings(accuracy: LocationAccuracy.high, distanceFilter: 1);
    print("Location service initialized");
  }

  // Method to listen to location changes
  void listenToLocationChanges() {
    location.onLocationChanged.listen((LocationData currentLocation) {
      print("Location updated: ${currentLocation}");
      this.locationData = currentLocation;
      _locationController.sink.add(currentLocation);
    });
  }

  // Method to stop listening to location changes
  void stopListening() {
    // This will be handled automatically by disposing of the stream subscription from listenToLocationChanges()
  }

  Future<LocationData?> getCurrentLocation() async {
    try {
      locationData = await location.getLocation();
      return locationData;
    } catch (e) {
      print("Error getting current location: $e");
      rethrow;
    }
  }

  // Close the stream when you dispose of this service.
  void dispose() {
    if (!_locationController.isClosed) {
      _locationController.close();
    }
  }
}
