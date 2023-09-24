import 'dart:async';
import 'package:location/location.dart';

class LocationLimitedData {
  double latitude;
  double longitude;
  double heading;
  double speed;
  LocationLimitedData({required this.latitude, required this.longitude,required this.heading, this.speed = 0});
}

class BackgroundLocationService {
  // Private constructor for singleton pattern
  BackgroundLocationService._();

  // Singleton instance
  static final BackgroundLocationService _instance = BackgroundLocationService._();
  static BackgroundLocationService get instance => _instance;

  LocationLimitedData locationInfo = LocationLimitedData(latitude: 0, longitude: 0, heading: 0);
  final location = Location();

  // StreamController for location changes
  final StreamController<LocationLimitedData> _locationController = StreamController<LocationLimitedData>.broadcast();

  // Stream to expose for other classes to listen to
  Stream<LocationLimitedData> get onLocationChanged => _locationController.stream;

  // Method to configure the background geolocation
  Future<void> init() async {
    location.changeSettings(accuracy: LocationAccuracy.high, distanceFilter: 1);
    LocationLimitedData currentLocation = await getCurrentLocation();
    if (currentLocation != null) {
      locationInfo = currentLocation;
    }
    print("Location service initialized");
  }

  // Method to listen to location changes
  void listenToLocationChanges() {
    location.onLocationChanged.listen((LocationData currentLocation) {
      print("Location updated: ${currentLocation}");
      locationInfo.latitude = currentLocation.latitude ?? locationInfo.latitude;
      locationInfo.longitude = currentLocation.longitude ?? locationInfo.longitude;
      locationInfo.heading = currentLocation.heading ?? locationInfo.heading;
      locationInfo.speed = currentLocation.speed ?? locationInfo.speed;
      _locationController.sink.add(locationInfo);
    });
  }

  // Method to stop listening to location changes
  void stopListening() {
    // This will be handled automatically by disposing of the stream subscription from listenToLocationChanges()
  }

  // Method to get the last known location
  LocationLimitedData? getLastLocation() {
    return locationInfo;
  }

  // Method to get the current location
  Future<LocationLimitedData> getCurrentLocation() async {
    try {
      var currentLocationData = await location.getLocation();
      locationInfo.latitude = currentLocationData.latitude ?? locationInfo.latitude;
      locationInfo.longitude = currentLocationData.longitude ?? locationInfo.longitude;
      locationInfo.heading = currentLocationData.heading ?? locationInfo.heading;
      locationInfo.speed = currentLocationData.speed ?? locationInfo.speed;
      return locationInfo;
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
