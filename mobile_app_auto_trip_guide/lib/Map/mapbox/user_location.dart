import 'dart:async';
import 'dart:ui';
import 'package:final_project/Map/mapbox/driving_direction.dart';
import 'package:flutter/animation.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

class LocationMarkerInfo {
  LatLng latLng;
  double heading;

  LocationMarkerInfo({required this.latLng, required this.heading});
}

enum RotationMode { drivingDirection, compass }

class UserLocationMarker {
  final MapboxMapController mapController;
  late SymbolManager _userSymbolManager;
  late Symbol _symbol;
  RotationMode _rotationMode = RotationMode.compass;
  late final AnimationController _moveAnimationController;
  late final AnimationController _headingAnimationController;
  LocationMarkerInfo _locationMarkerInfo =
      LocationMarkerInfo(latLng: LatLng(0, 0), heading: 0);
  dynamic onMarkerUpdated;
  late HeadingTween _headingTween;
  late LatLngTween _locationTween;
  StreamSubscription<Position>? _positionSubscription;
  StreamSubscription<CompassEvent>? _compassSubscription;
  StreamSubscription<double>? _drivingDirectionSubscription;

  UserLocationMarker(
      {required this.mapController,
      required TickerProvider vsync,
      this.onMarkerUpdated}) {
    _headingAnimationController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 600),
    );
    // Create a Tween to animate the marker's heading
    _headingTween = HeadingTween(
      begin: locationMarkerInfo.heading,
      end: locationMarkerInfo.heading,
    );
    // Create an animation from the Tween
    Animation<double> headingAnimation =
        _headingTween.animate(_headingAnimationController);
    headingAnimation.addListener(() {
      locationMarkerInfo.heading = headingAnimation.value;
      _updateSymbol();
    });

    _moveAnimationController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 1000),
    );
    // Create a Tween to animate the marker's movement
    _locationTween = LatLngTween(
      begin: locationMarkerInfo.latLng,
      end: locationMarkerInfo.latLng,
    );

    // Create an animation from the Tween
    Animation<LatLng> animation =
        _locationTween.animate(_moveAnimationController);
    // Add a listener to the animation to update the marker's location
    animation.addListener(() {
      locationMarkerInfo.latLng = animation.value;
      _updateSymbol();
    });
  }

  LocationMarkerInfo get locationMarkerInfo => _locationMarkerInfo;

  Future<void> start() async {
    _userSymbolManager = SymbolManager(mapController,
        iconAllowOverlap: true, textAllowOverlap: true);
    // Get the user's current location
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    // Create a LatLng object from the user's location
    LatLng userLocation = LatLng(position.latitude, position.longitude);
    locationMarkerInfo.latLng = userLocation;

    // Add a marker to the map at the user's location
    _symbol = Symbol(
      'userLocation',
      SymbolOptions(
        geometry: locationMarkerInfo.latLng,
        iconImage: "userLocation",
        iconSize: 1,
        zIndex: 1000,
      ),
    );
    _userSymbolManager.add(_symbol);
    updateRotationMode(_rotationMode);
    _positionSubscription?.cancel();
    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 0,
      ),
    ).listen((Position position) {
      _locationTween.begin = _symbol.options.geometry;
      _locationTween.end = LatLng(position.latitude, position.longitude);
      // Reset and start the animation
      _moveAnimationController.reset();
      _moveAnimationController.forward();
    });
  }

  Future<void> stop() async {
    // Remove the marker from the map
    _userSymbolManager.remove(_symbol);
    _compassSubscription?.cancel();
    _positionSubscription?.cancel();
    _drivingDirectionSubscription?.cancel();
  }

  void _updateSymbol() {
    _symbol = Symbol(
        _symbol.id,
        _symbol.options.copyWith(
          SymbolOptions(
              geometry: locationMarkerInfo.latLng,
              iconRotate: (locationMarkerInfo.heading -
                  (mapController.cameraPosition?.bearing ?? 0))),
        ));
    _userSymbolManager.set(_symbol);
    onMarkerUpdated(locationMarkerInfo);
  }

  void updateRotationMode(RotationMode rotationMode) {
    _rotationMode = rotationMode;
    switch (rotationMode) {
      case (RotationMode.compass):
        _drivingDirectionSubscription?.cancel();
        _compassSubscription?.cancel();
        _compassSubscription =
            FlutterCompass.events?.listen((CompassEvent event) {
          _headingTween.begin = _locationMarkerInfo.heading;
          _headingTween.end = event.heading ?? _locationMarkerInfo.heading;
          // Reset and start the animation
          _headingAnimationController.reset();
          _headingAnimationController.forward();
        });
        break;
      case (RotationMode.drivingDirection):
        _drivingDirectionSubscription?.cancel();
        _compassSubscription?.cancel();
        _drivingDirectionSubscription =
            DrivingDirection().onBearingChanged.listen((event) {
          _headingTween.begin = _locationMarkerInfo.heading;
          _headingTween.end = event;
          // Reset and start the animation
          _headingAnimationController.reset();
          _headingAnimationController.forward();
        });
        break;
    }
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
