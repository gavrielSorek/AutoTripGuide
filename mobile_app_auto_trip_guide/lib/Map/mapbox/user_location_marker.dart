import 'dart:async';

import 'package:flutter/animation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

import 'animations.dart';

class LocationMarkerInfo {
  LatLng latLng;
  double heading;

  LocationMarkerInfo({required this.latLng, required this.heading});
}

abstract class UserLocationMarker {
  final MapboxMapController mapController;
  SymbolManager? _userSymbolManager;
  Symbol _symbol;
  late final AnimationController _moveAnimationController;
  late final AnimationController _headingAnimationController;
  LocationMarkerInfo _locationMarkerInfo =
      LocationMarkerInfo(latLng: LatLng(0, 0), heading: 0);
  dynamic onMarkerUpdated;
  late HeadingTween _headingTween;
  late LatLngTween _locationTween;
  StreamSubscription<Position>? _positionSubscription;
  bool isActive = false;

  UserLocationMarker(this.mapController, this._symbol, this.onMarkerUpdated,
      this._moveAnimationController, this._headingAnimationController) {
    _headingTween = HeadingTween(
      begin: locationMarkerInfo.heading,
      end: locationMarkerInfo.heading,
    );
    // Create a Tween to animate the marker's movement
    _locationTween = LatLngTween(
      begin: locationMarkerInfo.latLng,
      end: locationMarkerInfo.latLng,
    );
    // Create an animation from the Tween
    Animation<double> headingAnimation =
        _headingTween.animate(_headingAnimationController);
    headingAnimation.addListener(() {
      _locationMarkerInfo.heading = headingAnimation.value;
      _updateSymbol();
    });
    // Create an animation from the Tween
    Animation<LatLng> animation =
        _locationTween.animate(_moveAnimationController);
    // Add a listener to the animation to update the marker's location
    animation.addListener(() {
      _locationMarkerInfo.latLng = animation.value;
      _updateSymbol();
    });
  }

  get locationMarkerInfo => _locationMarkerInfo;

  get headingTween => _headingTween;

  get headingAnimationController => _headingAnimationController;

  Future<void> _updateSymbol() async {
    if (!isActive)
      return;
    _symbol = Symbol(
        _symbol.id,
        _symbol.options.copyWith(
          SymbolOptions(
              geometry: _locationMarkerInfo.latLng,
              iconRotate: (_locationMarkerInfo.heading -
                  (mapController.cameraPosition?.bearing ?? 0))),
        ));
    await _userSymbolManager!.set(_symbol);
    onMarkerUpdated(_locationMarkerInfo);
  }

  Future<void> start() async {
    isActive = true;
    _userSymbolManager = SymbolManager(mapController,
        iconAllowOverlap: true, textAllowOverlap: true);
    // Get the user's current location
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    // Create a LatLng object from the user's location
    LatLng userLocation = LatLng(position.latitude, position.longitude);
    _locationMarkerInfo.latLng = userLocation;
    await _userSymbolManager!.add(_symbol);
    locationMarkerInfo.heading = mapController.cameraPosition?.bearing ?? 0;
    _updateSymbol();
    _positionSubscription?.cancel();
    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.best,
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
    isActive = false;
    // Remove the marker from the map
    await _userSymbolManager?.remove(_symbol);
    _userSymbolManager?.dispose();
    _moveAnimationController.stop();
    _headingAnimationController.stop();
    _positionSubscription?.cancel();
  }

  dispose() {
    _userSymbolManager?.dispose();
    _moveAnimationController.dispose();
    _headingAnimationController.dispose();
    _positionSubscription?.cancel();
  }
}
