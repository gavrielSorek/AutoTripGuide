import 'dart:async';
import 'package:background_location/background_location.dart';

class BackgroundLocationService {
  // Instance
  static final BackgroundLocationService _locationService = BackgroundLocationService();
  Location? location;

  // StreamController for location changes
  final StreamController<Location> _locationController = StreamController.broadcast();

  // Stream to expose for other classes to listen to
  Stream<Location> get onLocationChanged => _locationController.stream;

  static BackgroundLocationService get locationService => _locationService;

  BackgroundLocationService();

  // Method to configure the background geolocation
  Future<void> init() async {
    await BackgroundLocation.setAndroidNotification(
      title: "Location is on",
      message: "Background location is running",
      icon: "@mipmap/ic_launcher", // You can provide your app icon here for the notification
    );

    await BackgroundLocation.setAndroidConfiguration(1000);
    await BackgroundLocation.startLocationService();
  }

  // Method to listen to location changes
  void listenToLocationChanges() {
    BackgroundLocation.getLocationUpdates((location) {
      this.location = location;
      _locationController.sink.add(location);
    });
  }

  // Method to stop listening to location changes
  void stopListening() {
    BackgroundLocation.stopLocationService();
  }

  Future<Location> getCurrentLocation() async {
    location = await BackgroundLocation().getCurrentLocation();
    return location!;
  }

  // Close the stream when you dispose of this service.
  void dispose() {
    _locationController.close();
  }
}
