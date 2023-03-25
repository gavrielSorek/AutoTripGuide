import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import '../Map/globals.dart';

extension HexColor on Color {
  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}

class Generals {
  static String getTime() {
    DateTime now = new DateTime.now();
    DateTime date =
        DateTime(now.year, now.month, now.day, now.hour, now.minute);
    String dateToday = date.toString().substring(0, 16);
    return dateToday;
  }

  static getDaysBetweenDates(String date1, String date2) {
    DateFormat format = DateFormat("yyyy-MM-dd HH:mm");
    DateTime startDate = format.parse(date1);
    DateTime endDate = format.parse(date2);
    int differenceInMilliseconds = endDate.difference(startDate).inMilliseconds;
    return (differenceInMilliseconds / (1000 * 60 * 60 * 24)).floor();
  }

  static Future<Uint8List?> poiIconSvgStringToUint8List(Color color) async {
    final svgString = Globals.svgMarkerString!;
        await rootBundle.loadString('assets/images/mapMarker.svg');
    const String originalMarkerColor = '#B0B0B0';
    // replace the fill color
    String markerIconString =
        (svgString.replaceAll(originalMarkerColor, color.toHex())).replaceAll(
            'opacity="1"/>',
            'opacity=' + '\"' + color.opacity!.toString() + '\"/>');
    final DrawableRoot svgRoot = await svg.fromSvgString(markerIconString, '');
    final PictureRecorder recorder = PictureRecorder();
    final Canvas canvas = Canvas(recorder);
    final Rect svgViewBox = Rect.fromLTWH(
        0, 0, svgRoot.viewport.viewBox.width, svgRoot.viewport.viewBox.height);
    svgRoot.draw(canvas, svgViewBox);
    final img = await recorder.endRecording().toImage(
        svgRoot.viewport.viewBox.width.toInt(),
        svgRoot.viewport.viewBox.height.toInt());
    final pngBytes = (await img.toByteData(format: ImageByteFormat.png))
        ?.buffer
        .asUint8List();
    return pngBytes;
  }
}

class PoisIconsBytesHolder {
  late Uint8List _greyIcon, _blueIcon, _greyTransIcon;

  Uint8List get greyIcon => _greyIcon;

  Uint8List get blueIcon => _blueIcon;

  Uint8List get greyTransIcon => _greyTransIcon;

  set greyIcon(Uint8List value) {
    _greyIcon = value;
  }

  set blueIcon(Uint8List value) {
    _blueIcon = value;
  }

  set greyTransIcon(Uint8List value) {
    _greyTransIcon = value;
  }
}
