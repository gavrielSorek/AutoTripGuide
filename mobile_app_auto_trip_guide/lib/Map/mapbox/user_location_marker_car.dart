import 'dart:async';
import 'package:final_project/Map/mapbox/driving_direction.dart';
import 'package:final_project/Map/mapbox/user_location_marker.dart';
import 'package:flutter/animation.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

class UserLocationMarkerCar extends UserLocationMarker {
  StreamSubscription<double>? _drivingDirectionSubscription;

  UserLocationMarkerCar(MapboxMapController mapController, TickerProvider vsync,
      dynamic onMarkerUpdated)
      : super(
            mapController,
            Symbol(
                'carLocation',
                SymbolOptions(
                  geometry: LatLng(0, 0),
                  iconImage: "carLocation",
                  iconSize: 1,
                  zIndex: 1000,
                )),
            onMarkerUpdated,
            AnimationController(
              vsync: vsync,
              duration: const Duration(milliseconds: 1600),
            ),
            AnimationController(
              vsync: vsync,
              duration: const Duration(milliseconds: 700),
            )) {}

  @override
  Future<void> start() async {
    super.start();
    _drivingDirectionSubscription?.cancel();
    _drivingDirectionSubscription =
        DrivingDirection().onBearingChanged.listen((event) {
      super.headingTween.begin = locationMarkerInfo.heading;
      headingTween.end = event;
      // Reset and start the animation
      headingAnimationController.reset();
      headingAnimationController.forward();
    });
  }

  @override
  Future<void> stop() async {
    super.stop();
    _drivingDirectionSubscription?.cancel();
  }
  dispose() {
    super.dispose();
    _drivingDirectionSubscription?.cancel();
  }
}
