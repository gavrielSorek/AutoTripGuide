import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'globals.dart';

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
  dynamic? audio;
  String? source;
  String? Contributor;
  String? CreatedDate;
  String? ApprovedBy;
  String? UpdatedBy;
  String? LastUpdatedDate;
  String? country;
  String? pic;

  List<String> Categories;

  Poi({
    required this.id,
    this.poiName,
    required this.latitude,
    required this.longitude,
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
    required this.Categories,
    this.pic
  });

  factory Poi.fromJson(Map<String, dynamic> json) {
    return Poi(
      id: json['_id'] as String,
      poiName: json['_poiName'] as String,
      latitude: json['_latitude'] as double,
      longitude: json['_longitude'] as double,
      shortDesc: (json['_shortDesc'] ?? "?") as String,
      language: (json['_language'] ?? "?") as String,
      audio: (json['_audio'] ?? "?"),
      source: (json['_source'] ?? "?") as String,
      Contributor: (json['_Contributor'] ?? "?") as String,
      CreatedDate: (json['_CreatedDate'] ?? "?") as String,
      ApprovedBy: (json['_ApprovedBy'] ?? "?") as String,
      UpdatedBy: (json['_UpdatedBy'] ?? "?") as String,
      LastUpdatedDate: (json['_LastUpdatedDate'] ?? "?") as String,
      country: (json['_country'] ?? "?") as String,
      pic: (json['_pic'] ?? "https://image.shutterstock.com/image-photo/no-photography-allowed-on-white-260nw-139998481.jpg") as String,
      Categories: ((json['_Categories'] ?? []) as List<dynamic>).cast<String>());
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
  // return marker from poi
  static Marker getMarkerFromPoi(Poi poi, MutableMapIconButton iconButton) {
    return Marker(
      width: 45.0,
      height: 45.0,
      point: LatLng(poi.latitude, poi.longitude),
      builder: (context) => Container(child: iconButton),
    );
  }

  Poi poi;
  Marker? marker;

  // IconButton? iconButton;
  MutableMapIconButton? iconButton;

  MapPoi(this.poi) {
    iconButton = MutableMapIconButton(()=>{Globals.globalUserMap.userMapState?.guideAboutMapPoi(this)});
    marker = getMarkerFromPoi(poi, iconButton!);
  }
}

enum GuideStatus { voice, text }
enum GuideState { working, waiting, stopped }
enum WidgetVisibility { hide, view }

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
  dynamic onPressedFunc;

  MutableMapIconButton(this.onPressedFunc, {Key? key}) : super(key: key);
  _MutableMapIconButton? iconState;
  @override
  State<StatefulWidget> createState() {
    iconState = _MutableMapIconButton(onPressedFunc);
    return iconState!;
  }
}

class _MutableMapIconButton extends State<StatefulWidget> {
  Color _iconColor = Colors.purple;
  double _iconSize = 45.0;
  dynamic onPressedFunc;
  _MutableMapIconButton(this.onPressedFunc);

  void setColor(Color color) {
    if (!mounted) {
      return; // Just do nothing if the widget is disposed.
    }
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
      onPressed: onPressedFunc,
    );
  }
}
