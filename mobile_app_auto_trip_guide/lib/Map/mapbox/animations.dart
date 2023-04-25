import 'dart:ui';

import 'package:flutter/animation.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

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