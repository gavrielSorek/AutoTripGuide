import 'dart:core';

import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart' as mapbox;

extension HexColor on Color {
  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}

extension StringExtension on String {
  String capitalizeTotalString() {
    String capitalizedString = "";
    List<String> stringArray = this.split(" ");
    for (int i = 0; i < stringArray.length; i++) {
      String capitalizedPartName = stringArray[i].capitalize();
      capitalizedString += capitalizedPartName + " ";
    }
    return capitalizedString;
  }

  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1).toLowerCase()}";
  }
}

class UserInfo {
  String? name;
  String? emailAddr;
  String gender;
  String languages;
  String? age;
  List<String>? categories;

  UserInfo(this.name, this.emailAddr, this.gender, this.languages, this.age,
      this.categories);
}

class VisitedPoi {
  String id;
  String? poiName;
  String time;
  String? pic;

  VisitedPoi({required this.id, this.poiName, required this.time, this.pic});

  factory VisitedPoi.fromJson(Map<String, dynamic> json) {
    return VisitedPoi(
        id: json['poiId'] as String,
        poiName: json['poiName'] as String,
        time: json['time'] as String,
        pic: json['pic'] as String);
  }
}

class LocationInfo {
  double lat;
  double lng;
  double heading;
  double speed;

  LocationInfo(this.lat, this.lng, this.heading, this.speed);
}

class Poi {
  String id;
  String? poiName;
  double latitude;
  double longitude;
  String? shortDesc;
  String? language;
  VendorInfo? vendorInfo;
  dynamic audio;
  String? source;
  String? Contributor;
  String? CreatedDate;
  String? ApprovedBy;
  String? UpdatedBy;
  String? LastUpdatedDate;
  String? country;
  String? pic;

  List<String> Categories;

  Poi(
      {required this.id,
      this.poiName,
      required this.latitude,
      required this.longitude,
      this.shortDesc,
      this.language,
      this.vendorInfo,
      this.audio,
      this.source,
      this.Contributor,
      this.CreatedDate,
      this.ApprovedBy,
      this.UpdatedBy,
      this.LastUpdatedDate,
      this.country,
      required this.Categories,
      this.pic});

  factory Poi.fromJson(Map<String, dynamic> json) {
    try {
      String picUrl = (json['_pic'] ?? '?') as String;
      if (picUrl == 'no pic') {
        picUrl = "";
      }
      String poiName = json['_poiName'] as String;
      String capitalizedPoiName = poiName.capitalizeTotalString();

      return Poi(
          id: json['_id'] as String,
          poiName: capitalizedPoiName,
          latitude: json['_latitude'] as double,
          longitude: json['_longitude'] as double,
          shortDesc: (json['_shortDesc'] ?? "?") as String,
          language: (json['_language'] ?? "?") as String,
          audio: (json['_audio'] ?? "?"),
          vendorInfo: VendorInfo(json['_vendorInfo']),
          source: (json['_source'] ?? "?") as String,
          Contributor: (json['_Contributor'] ?? "?") as String,
          CreatedDate: (json['_CreatedDate'] ?? "?") as String,
          ApprovedBy: (json['_ApprovedBy'] ?? "?") as String,
          UpdatedBy: (json['_UpdatedBy'] ?? "?") as String,
          LastUpdatedDate: (json['_LastUpdatedDate'] ?? "?") as String,
          country: (json['_country'] ?? "?") as String,
          pic: picUrl,
          Categories:
              ((json['_Categories'] ?? []) as List<dynamic>).cast<String>());
    } catch (e) {
      print("Error processing poi: $e");
      return Poi(
          id: 'Dummy',
          latitude: 1000,
          longitude: 1000,
          Categories: []); // not existed poi
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Poi &&
        other.id == id;
  }
}

class Audio {
  var audio;

  Audio(this.audio);

  factory Audio.fromJson(Map<String, dynamic> json) {
    return Audio(json['data']);
  }
}

class MapPoi {

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MapPoi &&
        other.poi == poi;
  }


  mapbox.Symbol getSymbolFromPoi(PoiIconColor color) {
    List<String> colors = ['greyPoi', 'bluePoi', 'greyTransPoi'];
    String iconImage = colors[color.index];
    return mapbox.Symbol(
        poi.id,
        mapbox.SymbolOptions(
            geometry: mapbox.LatLng(poi.latitude, poi.longitude),
            iconImage: iconImage,
            // this is the icon you want to use
            iconSize: 0.12,
            textField: poi.poiName,
            textSize: 10,
            textOpacity: 0.4));
  }

  Poi poi;

  MapPoi(this.poi) {}
}

enum GuideStatus { voice, text }

enum GuideState { working, waiting, stopped }

enum WidgetVisibility { hide, view }

enum PoiIconColor { grey, blue, greyTrans }

// contain data about the guid type
class GuideData {
  static List<Icon> guideIcons = [
    const Icon(Icons.settings_voice_outlined, color: Colors.white),
    const Icon(Icons.text_snippet_rounded, color: Colors.white),
  ];
  static var statusValues = GuideStatus.values;

  GuideStatus status = GuideStatus.voice; //default
  Icon guideIcon = guideIcons[GuideStatus.voice.index];

  // CHANGE THE STATUS AND THE ICON
  void changeGuideType() {
    int oppositeStatusIdx = 1 - status.index;
    status = statusValues[oppositeStatusIdx];
    guideIcon = guideIcons[oppositeStatusIdx];
  }
}

class VendorInfo {
  Map<String, dynamic> data = {};

  VendorInfo(Map<String, dynamic>? data) {
    if(data != null)
      this.data = data;
  }

  dynamic getProperty(String key) {
    return data[key];
  }
}