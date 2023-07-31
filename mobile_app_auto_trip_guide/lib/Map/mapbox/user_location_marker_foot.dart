import 'dart:async';
import 'package:journ_ai/Map/mapbox/user_location_marker.dart';
import 'package:flutter/animation.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

class UserLocationMarkerFoot extends UserLocationMarker {
  StreamSubscription<CompassEvent>? _compassSubscription;
  double startAnimationThreshold = 10.0; // in degrees
  double deviationThreshold = 12.0; // in degrees

  UserLocationMarkerFoot(
      MapboxMapController mapController,
      TickerProvider vsync,
      dynamic onMarkerUpdated) // Add threshold to constructor
      : super(
      mapController,
      Symbol('userLocation',
          SymbolOptions(
            geometry: LatLng(0, 0),
            iconImage: "userLocation",
            iconSize: 1,
            zIndex: 1000,
          )),
      onMarkerUpdated,
      AnimationController(
        vsync: vsync,
        duration: const Duration(milliseconds: 1200),
      ),
      AnimationController(
        vsync: vsync,
        duration: const Duration(milliseconds: 700),
      )) {}

  @override
  Future<void> start() async {
    super.start();
    _compassSubscription?.cancel();
    _compassSubscription = FlutterCompass.events?.listen((CompassEvent event) {
      if (event.heading != null) {
        double difference = (event.heading! - locationMarkerInfo.heading).abs();

        // Handle the case when the difference is across 360/0 boundary
        if (difference > 180) {
          difference = 360 - difference;
        }

        // Check if the new heading is significantly different or has noticeable deviation from the current animation
        bool isSignificantlyDifferent = difference > startAnimationThreshold;
        bool isNoticeableDeviation = difference > deviationThreshold && headingAnimationController.isAnimating;

        // If the new heading is significantly different or the current animation has noticeable deviation, reset and start the animation
        if (isSignificantlyDifferent || isNoticeableDeviation) {
          super.headingTween.begin = locationMarkerInfo.heading;
          headingTween.end = event.heading;
          //print("begin: " + super.headingTween.begin.toString() + " " + "end: " + headingTween.end.toString() + "\n");

          // Reset and start the animation
          headingAnimationController.reset();
          headingAnimationController.forward();
        }
      }
    });
  }


  @override
  Future<void> stop() async {
    super.stop();
    _compassSubscription?.cancel();
  }

  dispose() {
    super.dispose();
    _compassSubscription?.cancel();
  }
}