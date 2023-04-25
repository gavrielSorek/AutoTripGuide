
import 'dart:async';
import 'package:final_project/Map/mapbox/user_location_marker.dart';
import 'package:flutter/animation.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

class UserLocationMarkerFoot extends UserLocationMarker {
  StreamSubscription<CompassEvent>? _compassSubscription;

  UserLocationMarkerFoot(MapboxMapController mapController, TickerProvider vsync,
      dynamic onMarkerUpdated)
      : super(
      mapController,
      Symbol(
          'userLocation',
          SymbolOptions(
            geometry: LatLng(0, 0),
            iconImage: "userLocation",
            iconSize: 1,
            zIndex: 1000,
          )),
      onMarkerUpdated,
      AnimationController(
        vsync: vsync,
        duration: const Duration(milliseconds: 600),
      ),
      AnimationController(
        vsync: vsync,
        duration: const Duration(milliseconds: 700),
      )) {}

  @override
  Future<void> start() async {
    super.start();
    _compassSubscription?.cancel();
            _compassSubscription =
            FlutterCompass.events?.listen((CompassEvent event) {
              super.headingTween.begin = locationMarkerInfo.heading;
              headingTween.end = event.heading;
              // Reset and start the animation
              headingAnimationController.reset();
              headingAnimationController.forward();
        });
  }

  @override
  Future<void> stop() async {
    super.stop();
    _compassSubscription?.cancel();
  }
}
