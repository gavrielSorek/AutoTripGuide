import 'dart:async';
import 'package:background_location/background_location.dart';

class BackgroundLocationService {
  // Private constructor for singleton pattern
  BackgroundLocationService._();

  // Singleton instance
  static final BackgroundLocationService _instance = BackgroundLocationService._();
  static BackgroundLocationService get instance => _instance;

  Location? location;

  // StreamController for location changes
  final StreamController<Location> _locationController = StreamController<Location>.broadcast();

  // Stream to expose for other classes to listen to
  Stream<Location> get onLocationChanged => _locationController.stream;

  // Method to configure the background geolocation
  Future<void> init() async {
    try {
      await BackgroundLocation.setAndroidNotification(
        title: "Location is on",
        message: "Background location is running",
        icon: "@mipmap/ic_launcher", // Provide your app icon here for the notification
      );
      await BackgroundLocation.setAndroidConfiguration(1000);
      print("Location service initialized");
      await BackgroundLocation.startLocationService(distanceFilter: 1);
    } catch (e) {
      print("Error initializing location service: $e");
    }
  }

  // Method to listen to location changes
  void listenToLocationChanges() {
    BackgroundLocation.getLocationUpdates((location) {
      print("Location updated: ${location.toMap()}");
      this.location = location;
      _locationController.sink.add(location);
    });
  }

  // Method to stop listening to location changes
  void stopListening() {
    BackgroundLocation.stopLocationService();
  }

  Future<Location> getCurrentLocation() async {
    try {
      location = await BackgroundLocation().getCurrentLocation();
      return location!;
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
