
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
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
  static List userChangeLocationFuncs = [];


  static Future<void> mapInit() async {
    // initialization order is very important
    USER_LOCATION = await getLocation();
    USER_LOCATION_DATA = await USER_LOCATION!.getLocation();
    USER_LOCATION!.onLocationChanged.listen(locationChangedEvent);
    MAP_SERVER_COMMUNICATOR = ServerCommunication();
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
    for (int i = 0; i < UserMap.userChangeLocationFuncs.length; i++ ) {
      userChangeLocationFuncs[i](currentLocation);
    }

    // List<Poi> pois;
    // if (isNewPoisNeeded()) {
    //   pois = await MAP_SERVER_COMMUNICATOR!.getPoisByLocation(
    //       LocationInfo(
    //           USER_LOCATION_DATA!.latitude ?? -1,
    //           USER_LOCATION_DATA!.longitude ?? -1,
    //           USER_LOCATION_DATA!.heading ?? -1,
    //           USER_LOCATION_DATA!.speed ?? -1));
    // }
  }

  // late _UserMapState _userMapState;

  UserMap({Key? key}) : super(key: key) {
    print("hello from ctor");
  }

  @override
  State<StatefulWidget> createState() {
    // _userMapState = _UserMapState();
    return _UserMapState();
  }

}

class _UserMapState extends State<UserMap> {
  late CenterOnLocationUpdate _centerOnLocationUpdate;
  late StreamController<double?> _centerCurrentLocationStreamController;
  MapController mapController = MapController();
  List<Marker> markers = [];

  _UserMapState() : super() {
    UserMap.userChangeLocationFuncs.add(onLocationChanged);
    print("hello from ctor2");
  }

  @override
  void initState() {
    super.initState();
    _centerOnLocationUpdate = CenterOnLocationUpdate.always;
    _centerCurrentLocationStreamController = StreamController<double?>();
  }

  @override
  void dispose() {
    _centerCurrentLocationStreamController.close();
    super.dispose();
  }

  List<Marker> markersList = [];

  void onLocationChanged(LocationData currentLocation) async {
    print("hello from location changed");
    List<Poi> pois;
    if (true) {
      pois = await UserMap.MAP_SERVER_COMMUNICATOR!.getPoisByLocation(
          LocationInfo(
              UserMap.USER_LOCATION_DATA!.latitude ?? -1,
              UserMap.USER_LOCATION_DATA!.longitude ?? -1,
              UserMap.USER_LOCATION_DATA!.heading ?? -1,
              UserMap.USER_LOCATION_DATA!.speed ?? -1));
    }
    setState(() {
      for (Poi poi in pois) {
        Marker marker = getMarkerFromPoi(poi);
        markersList.add(marker);
      }

      // markersList[0] = getUserMarker();
      // mapController.move(LatLng(currentLocation.latitude!,currentLocation.longitude!), mapController.zoom);
    });
  }

  Marker getMarkerFromPoi(Poi poi) {
    return Marker(
        width: 45.0,
        height: 45.0,
        point: LatLng(poi.latitude!, poi.longitude!),
        builder: (context) => Container(
            child: IconButton(
                icon: Icon(Icons.location_on),
                onPressed: () {
                  print('Marker tapped!');
                })));
  }

  @override
  Widget build(BuildContext context) {

    print("hello from build");
    return FlutterMap(
      mapController: mapController,
        options: MapOptions(
            onPositionChanged: (MapPosition position, bool hasGesture) {
              if (hasGesture) {
                setState(
                      () => _centerOnLocationUpdate = CenterOnLocationUpdate.never,
                );
              }
            },
          plugins: [LocationMarkerPlugin(),],
            center: LatLng(UserMap.USER_LOCATION_DATA!.latitude ?? 0.0,
                UserMap.USER_LOCATION_DATA!.longitude ?? 0.0),
            minZoom: 5.0),
      // ignore: sort_child_properties_last
      children: [
        TileLayerWidget(
          options: TileLayerOptions(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: ['a', 'b', 'c'],
            maxZoom: 19,
          ),
        ),
        LocationMarkerLayerWidget(
          plugin: LocationMarkerPlugin(
            centerCurrentLocationStream:
            _centerCurrentLocationStreamController.stream,
            centerOnLocationUpdate: _centerOnLocationUpdate,
          ),
        ),
      ],

      nonRotatedChildren: [
        Positioned(
          left: 20,
          bottom: 20,
          child: FloatingActionButton(
            onPressed: () {
              // Automatically center the location marker on the map when location updated until user interact with the map.
              setState(
                    () => _centerOnLocationUpdate = CenterOnLocationUpdate.always,
              );
              // Center the location marker on the map and zoom the map to level 18.
              _centerCurrentLocationStreamController.add(18);
            },
            child: const Icon(
              Icons.my_location,
              color: Colors.white,
            ),
          ),
        )
      ],
        layers: [MarkerLayerOptions(markers: markersList)],
        // layers: [
        //   TileLayerOptions(
        //       urlTemplate: "https://a.tile.openstreetmap.de/{z}/{x}/{y}.png",
        //       subdomains: ['a', 'b', 'c']),
        //   // MarkerLayerOptions(markers: markersList),
        //   LocationMarkerLayerOptions()
        //
        // ]
    );
  }
}

