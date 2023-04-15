import 'dart:async';
import 'dart:ui';
import 'package:flutter/animation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
class LocationMarkerInfo{
  LatLng latLng;
  double heading;
  LocationMarkerInfo({required this.latLng, required this.heading});
}
class UserLocationMarker {
  final MapboxMapController mapController;
  late final AnimationController animationController;
  late Symbol _symbol;
  LocationMarkerInfo _locationMarkerInfo = LocationMarkerInfo(latLng: LatLng(0, 0), heading: 0);
  dynamic onMarkerLocationUpdated;

  UserLocationMarker({
    required this.mapController,
    required TickerProvider vsync,
    this.onMarkerLocationUpdated
  }) {
    animationController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 1000),
    );
  }

  LocationMarkerInfo  get locationMarkerInfo => _locationMarkerInfo;
  Future<void> start() async {
    // Get the user's current location
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    // Create a LatLng object from the user's location
    LatLng userLocation = LatLng(position.latitude, position.longitude);
    locationMarkerInfo.latLng = userLocation;

    // Add a marker to the map at the user's location
    _symbol = await mapController.addSymbol(
      SymbolOptions(
        geometry: userLocation,
        iconImage: "airport-15",
        zIndex: 1000,
      ),
    );

    // Create a Tween to animate the marker's movement
    LatLngTween tween = LatLngTween(
      begin: userLocation,
      end: userLocation,
    );

    // Create an animation from the Tween
    Animation<LatLng> animation = tween.animate(animationController);

    // Add a listener to the animation to update the marker's location
    animation.addListener(() {
      locationMarkerInfo.latLng = animation.value;
      // Update the marker's location on the map
      mapController.updateSymbol(
        _symbol,
        SymbolOptions(
          geometry: locationMarkerInfo.latLng,
        ),
      );
      onMarkerLocationUpdated(locationMarkerInfo);
    });

    // Create a timer that updates the marker's location every second
    Timer.periodic(Duration(milliseconds: 800), (timer) async {
      // Get the user's current location
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      // Create a LatLng object from the user's location
      LatLng userLocation = LatLng(position.latitude, position.longitude);

      // Update the Tween's begin and end values to animate the marker's movement
      tween.begin = _symbol.options.geometry;
      tween.end = userLocation;

      // Reset and start the animation
      animationController.reset();
      animationController.forward();
    });
  }

  Future<void> stop() async {
    // Remove the marker from the map
    await mapController.removeSymbol(_symbol);
  }
}

class LatLngTween extends Tween<LatLng> {
  LatLngTween({required LatLng begin, required LatLng end})
      : super(begin: begin, end: end);

  @override
  LatLng lerp(double t) {
    return LatLng(
      lerpDouble(begin?.latitude, end?.latitude, t)!,
      lerpDouble(begin?.longitude, end?.longitude, t)!,
    );
  }
}