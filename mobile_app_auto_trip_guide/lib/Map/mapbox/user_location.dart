import 'dart:async';
import 'dart:ui';
import 'package:flutter/animation.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
class LocationMarkerInfo{
  LatLng latLng;
  double heading;
  LocationMarkerInfo({required this.latLng, required this.heading});
}
class UserLocationMarker {
  final MapboxMapController mapController;
  late final AnimationController _moveAnimationController;
  late final AnimationController headingAnimationController;
  late Symbol _symbol;
  LocationMarkerInfo _locationMarkerInfo = LocationMarkerInfo(latLng: LatLng(0, 0), heading: 0);
  dynamic onMarkerUpdated;
  StreamSubscription<CompassEvent>? _compassSubscription;
  StreamSubscription<Position>? _positionSubscription;
  UserLocationMarker({
    required this.mapController,
    required TickerProvider vsync,
    this.onMarkerUpdated
  }) {
    headingAnimationController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 500),
    );
    _moveAnimationController = AnimationController(
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
        geometry: locationMarkerInfo.latLng,
        iconImage: "userLocation",
        iconSize: 1,
        zIndex: 1000,
      ),
    );


    // Create a Tween to animate the marker's heading
    HeadingTween headingTween = HeadingTween(
      begin: locationMarkerInfo.heading ,
      end: locationMarkerInfo.heading ,
    );
    // Create an animation from the Tween
    Animation<double> headingAnimation = headingTween.animate(headingAnimationController);
    headingAnimation.addListener(() {
      locationMarkerInfo.heading = headingAnimation.value;
      _updateSymbol();
    });

    if ( _compassSubscription== null || _compassSubscription!.isPaused) {
      _compassSubscription = FlutterCompass.events?.listen((CompassEvent event) {
        headingTween.begin = _locationMarkerInfo.heading;
        headingTween.end = event.heading ??  _locationMarkerInfo.heading;
        // Reset and start the animation
        headingAnimationController.reset();
        headingAnimationController.forward();
      });
    }

    // Create a Tween to animate the marker's movement
    LatLngTween tween = LatLngTween(
      begin: locationMarkerInfo.latLng ,
      end: locationMarkerInfo.latLng ,
    );

    // Create an animation from the Tween
    Animation<LatLng> animation = tween.animate(_moveAnimationController);

    // Add a listener to the animation to update the marker's location
    animation.addListener(() {
      locationMarkerInfo.latLng = animation.value;
      _updateSymbol();
    });

    if (_positionSubscription == null || _positionSubscription!.isPaused) {
      _positionSubscription = Geolocator.getPositionStream(
        locationSettings:  LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
          distanceFilter: 0,
        ),
      ).listen((Position position) {
        tween.begin = _symbol.options.geometry;
        tween.end = LatLng(position.latitude, position.longitude);
        // Reset and start the animation
        _moveAnimationController.reset();
        _moveAnimationController.forward();
      }); 
    }
  }

  Future<void> stop() async {
    // Remove the marker from the map
    await mapController.removeSymbol(_symbol);
    _compassSubscription?.cancel();
    _positionSubscription?.cancel();
  }

  void _updateSymbol() {
    // Update the marker's location on the map
    mapController.updateSymbol(
      _symbol,
      SymbolOptions(
          geometry: locationMarkerInfo.latLng,
        iconRotate: (locationMarkerInfo.heading - (mapController.cameraPosition?.bearing ?? 0)),
      ),
    );
    onMarkerUpdated(locationMarkerInfo);
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

class HeadingTween extends Tween<double> {
  HeadingTween({required double begin, required double end})
      : super(begin: begin, end: end);

  @override
  double lerp(double t) {
    double adjustedEnd = end!;
    if ((end! - begin!).abs() > 180) {
      if (end! < begin!) {
        adjustedEnd += 360;
      } else {
        adjustedEnd -= 360;
      }
    }
    return lerpDouble(begin, adjustedEnd, t)!;
  }
}