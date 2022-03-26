import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:final_project/Map/location_types.dart';
import 'package:final_project/Map/events.dart';
import 'package:final_project/Map/server_communication.dart';

class UserMap extends StatefulWidget {
  // inits
  static Location? USER_LOCATION;
  static LocationData? USER_LOCATION_DATA;
  static UserMap? USER_MAP;
  static ServerCommunication? MAP_SERVER_COMMUNICATOR;

  static Future<void> mapInit() async {
    // initialization order is very important
    USER_LOCATION = await getLocation();
    USER_LOCATION_DATA = await USER_LOCATION!.getLocation();
    USER_LOCATION!.onLocationChanged.listen(locationChangedEvent);
    MAP_SERVER_COMMUNICATOR = ServerCommunication('auto_trip_guide_mobile.lt');
    USER_MAP = UserMap();
  }

  static Future<Location?> getLocation() async {
    Location location = Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return null;
      }
    }
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return null;
      }
    }
    return location;
  }

  static bool isNewPoisNeeded() {
    //TODO add logic
    return true;
  }
  static void locationChangedEvent(LocationData currentLocation) async {
    USER_LOCATION_DATA = currentLocation;
    USER_MAP!._userMapState.updateUserLocation();
    if (isNewPoisNeeded()) {
      List<Poi> pois = await MAP_SERVER_COMMUNICATOR!.getPoisByLocation(
          LocationInfo(
              USER_LOCATION_DATA!.latitude ?? -1,
              USER_LOCATION_DATA!.longitude ?? -1,
              USER_LOCATION_DATA!.heading ?? -1,
              USER_LOCATION_DATA!.speed ?? -1));
    }
  }

  late _UserMapState _userMapState;

  UserMap({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    _userMapState = _UserMapState();
    return _userMapState;
  }
}

class _UserMapState extends State<UserMap> {
  List<Marker> markersList = [
    Marker(
        width: 45.0,
        height: 45.0,
        point: LatLng(UserMap.USER_LOCATION_DATA!.latitude ?? 0.0,
            UserMap.USER_LOCATION_DATA!.longitude ?? 0.0),
        builder: (context) => Container(
            child: IconButton(
                icon: Icon(Icons.directions_car_sharp),
                onPressed: () {
                  print('Marker tapped!');
                }))),
    Marker(
      width: 45.0,
      height: 45.0,
      point: LatLng(32.8, 35.113394),
      builder: (context) => Container(
        child: IconButton(
          icon: Icon(Icons.location_on),
          color: Colors.purpleAccent,
          iconSize: 45.0,
          onPressed: () {
            print('Marker tapped');
          },
        ),
      ),
    ),
    Marker(
      width: 45.0,
      height: 45.0,
      point: LatLng(22.308324, 73.159934),
      builder: (context) => IconButton(
        icon: const Icon(Icons.location_on),
        color: Colors.purpleAccent,
        iconSize: 45.0,
        onPressed: () {
          print('Marker tapped');
        },
      ),
    ),
  ];

  void updateUserLocation() {
    setState(() {
      markersList[0] = getUserMarker();
    });
  }

  Marker getUserMarker() {
    return Marker(
        width: 45.0,
        height: 45.0,
        point: LatLng(32.81, UserMap.USER_LOCATION_DATA!.longitude ?? 0.0),
        builder: (context) => Container(
            child: IconButton(
                icon: Icon(Icons.directions_car_sharp),
                onPressed: () {
                  print('Marker tapped!');
                })));
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
        options: MapOptions(
            center: LatLng(UserMap.USER_LOCATION_DATA!.latitude ?? 0.0,
                UserMap.USER_LOCATION_DATA!.longitude ?? 0.0),
            minZoom: 5.0),
        layers: [
          TileLayerOptions(
              urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
              subdomains: ['a', 'b', 'c']),
          MarkerLayerOptions(markers: markersList)
        ]);
  }
}

