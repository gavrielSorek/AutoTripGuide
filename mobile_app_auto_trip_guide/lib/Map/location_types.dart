import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LocationInfo {
  double lat;
  double lng;
  double heading;
  double speed;

  LocationInfo(this.lat, this.lng, this.heading, this.speed);
}

class Poi {
  String? poiName;
  double? latitude;
  double? longitude;
  String? shortDesc;
  String? language;
  dynamic? audio;
  String? source;
  String? Contributor;
  String? CreatedDate;
  String? ApprovedBy;
  String? UpdatedBy;
  String? LastUpdatedDate;
  String? country;
  List<String>? Categories;

  Poi({
    this.poiName,
    this.latitude,
    this.longitude,
    this.shortDesc,
    this.language,
    this.audio,
    this.source,
    this.Contributor,
    this.CreatedDate,
    this.ApprovedBy,
    this.UpdatedBy,
    this.LastUpdatedDate,
    this.country,
    this.Categories,
  });

  factory Poi.fromJson(Map<String, dynamic> json) {
    return Poi(
      poiName: json['_poiName'] as String,
      latitude: json['_latitude'] as double,
      longitude: json['_longitude'] as double,
      shortDesc: (json['_shortDesc'] ?? "?") as String,
      language: (json['_language'] ?? "?") as String,
      audio: (json['_audio'] ?? "?") as String,
      source: (json['_source'] ?? "?") as String,
      Contributor: (json['_Contributor'] ?? "?") as String,
      CreatedDate: (json['_CreatedDate'] ?? "?") as String,
      ApprovedBy: (json['_ApprovedBy'] ?? "?") as String,
      UpdatedBy: (json['_UpdatedBy'] ?? "?") as String,
      LastUpdatedDate: (json['_LastUpdatedDate'] ?? "?") as String,
      country: (json['_country'] ?? "?") as String,
      Categories: (json['_Categories']?.split(',') ?? ['?']) as List<String>,
    );
  }
}

enum GuideStatus { voice, text }

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
