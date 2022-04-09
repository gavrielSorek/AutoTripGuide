import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class UserInfo {
  String? name;
  String? emailAddr;

  // String? gender;
  // List<String>? languages;
  // int? age;
  // List<String>? Categories;
  UserInfo(this.name, this.emailAddr);
}

class LocationInfo {
  double lat;
  double lng;
  double heading;
  double speed;

  LocationInfo(this.lat, this.lng, this.heading, this.speed);
}

class Poi {
  String? id;
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
    this.id,
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
      id: json['_id'] as String,
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

class MapPoi {
  // return marker from poi
  static Marker getMarkerFromPoi(Poi poi, MutableMapIconButton iconButton) {
    return Marker(
      width: 45.0,
      height: 45.0,
      point: LatLng(poi.latitude!, poi.longitude!),
      builder: (context) => Container(child: iconButton),
    );
  }

  Poi poi;
  Marker? marker;
  // IconButton? iconButton;
  MutableMapIconButton? iconButton;


  MapPoi(this.poi) {
    iconButton = MutableMapIconButton();
        // IconButton(
        // icon: Icon(Icons.location_on),
        // color: Colors.purpleAccent,
        // iconSize: 45.0,
        // onPressed: () {
        //   iconButton!.c = 100;
        //   print('Marker tapped');
        // });
    marker = getMarkerFromPoi(poi, iconButton!);
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


class MutableMapIconButton extends StatefulWidget {
  MutableMapIconButton({Key? key}) : super(key: key);
  _MutableMapIconButton? iconState;

  @override
  State<StatefulWidget> createState() {
    iconState = _MutableMapIconButton();
    return iconState!;
  }
}
class _MutableMapIconButton extends State<StatefulWidget> {
  Color _iconColor = Colors.purple;
  double _iconSize = 45.0;

  void setColor(Color color) {
    setState(() {
      _iconColor = color;
    });
  }
  void setSize(double size) {
    setState(() {
      _iconSize = size;
    });
  }

  @override
  Widget build(BuildContext) {
    return IconButton(
      icon: Icon(Icons.location_on),
      iconSize: _iconSize,
      color: _iconColor,
      onPressed: () {
        setColor(Colors.black);
      },
    );
  }
}
