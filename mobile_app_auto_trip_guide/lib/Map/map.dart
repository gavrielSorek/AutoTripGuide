import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:final_project/Map/location_types.dart';
import 'package:final_project/Map/server_communication.dart';

class UserMap extends StatefulWidget {
  // inits
  static Location? USER_LOCATION;
  static LocationData? USER_LOCATION_DATA;
  static UserMap? USER_MAP;
  static ServerCommunication? MAP_SERVER_COMMUNICATOR;
  static List userChangeLocationFuncs = [];
  static Map poisMap = Map<String, Poi>(); // the string is poi name

  static Future<void> mapInit() async {
    // initialization order is very important
    USER_LOCATION = await getLocation();
    USER_LOCATION_DATA = await USER_LOCATION!.getLocation();
    MAP_SERVER_COMMUNICATOR = ServerCommunication();
    USER_MAP = UserMap();
    USER_LOCATION!.onLocationChanged.listen(locationChangedEvent);
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

  static void locationChangedEvent(LocationData currentLocation) async {
    USER_LOCATION_DATA = currentLocation;
    for (int i = 0; i < UserMap.userChangeLocationFuncs.length; i++) {
      userChangeLocationFuncs[i](currentLocation);
    }
  }

  UserMap({Key? key}) : super(key: key) {
    print("hello from ctor");
  }

  @override
  State<StatefulWidget> createState() {
    return _UserMapState();
  }
}

class _UserMapState extends State<UserMap> {
  late CenterOnLocationUpdate _centerOnLocationUpdate;
  late StreamController<double?> _centerCurrentLocationStreamController;
  final MapController _mapController = MapController();
  double mapHeading = 0;
  List<Marker> markersList = [];
  bool isNewPoisNeededFlag = true;

  _UserMapState() : super() {
    UserMap.userChangeLocationFuncs.add(onLocationChanged);
    print("hello from ctor2");
  }

  @override
  void initState() {
    super.initState();
    _centerOnLocationUpdate = CenterOnLocationUpdate.always;
    _centerCurrentLocationStreamController = StreamController<double?>();
    FlutterCompass.events?.listen((event) {
      //TODO check
      setState(() {
        mapHeading = 360 + event.heading!;
        print(event.heading!);
        // _mapController.rotate(mapHeading);
      });
    });
  }

  @override
  void dispose() {
    _centerCurrentLocationStreamController.close();
    super.dispose();
  }

  // add new pois if location changed
  void onLocationChanged(LocationData currentLocation) async {
    print("hello from location changed");
    List<Poi> pois;
    // TODO add a condition that won't crazy the server
    if (isNewPoisNeeded()) {
      pois = await UserMap.MAP_SERVER_COMMUNICATOR!.getPoisByLocation(
          LocationInfo(
              UserMap.USER_LOCATION_DATA!.latitude ?? -1,
              UserMap.USER_LOCATION_DATA!.longitude ?? -1,
              UserMap.USER_LOCATION_DATA!.heading ?? -1,
              UserMap.USER_LOCATION_DATA!.speed ?? -1));

      setState(() {
        // add all the new poi
        print("add pois to map");
        for (Poi poi in pois) {
          if (!UserMap.poisMap.containsKey(poi.poiName)) {
            UserMap.poisMap[poi.poiName] = poi;
            Marker marker = getMarkerFromPoi(poi);
            markersList.add(marker);
          }
        }
      });
    }
  }

  // change pois needed flag
  Future<void> poisNeededFlagChange(int timeToWait, bool val) async {
    await Future.delayed(Duration(seconds: timeToWait));
    isNewPoisNeededFlag = val;
  }

  bool isNewPoisNeeded() {
    if (isNewPoisNeededFlag) {
      isNewPoisNeededFlag = false;
      poisNeededFlagChange(5, true);
      print("hello from isNewPoisNeeded");
      return true;
    }
    return false;
  }

  // return marker from poi
  Marker getMarkerFromPoi(Poi poi) {
    return Marker(
      width: 45.0,
      height: 45.0,
      point: LatLng(poi.latitude!, poi.longitude!),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    print("hello from build map");
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
          rotation: mapHeading,
          onPositionChanged: (MapPosition position, bool hasGesture) {
            if (hasGesture) {
              setState(
                () => _centerOnLocationUpdate = CenterOnLocationUpdate.never,
              );
            }
          },
          plugins: [
            LocationMarkerPlugin(),
          ],
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
        Column(
            // menu row
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                      alignment: Alignment.bottomRight,
                      margin: EdgeInsets.all(20),
                      color: Colors.yellow,
                      height: MediaQuery.of(context).size.width / 11,
                      width: MediaQuery.of(context).size.width / 11,
                      child: FloatingActionButton(
                        onPressed: () {
                          print("change to audio or to text");
                        },
                        child: const Icon(
                          Icons.settings_voice_outlined,
                          color: Colors.white,
                        ),
                      ))),
              Align(
                  alignment: Alignment.bottomLeft,
                  widthFactor: 10,
                  heightFactor: 10,
                  child: Container(
                    height: MediaQuery.of(context).size.width / 11,
                    width: MediaQuery.of(context).size.width / 11,
                    child: FloatingActionButton(
                      onPressed: () {
                        // Automatically center the location marker on the map when location updated until user interact with the map.
                        setState(
                          () => _centerOnLocationUpdate =
                              CenterOnLocationUpdate.always,
                        );
                        // Center the location marker on the map and zoom the map to level 15.
                        _centerCurrentLocationStreamController.add(14);
                      },
                      child: const Icon(
                        Icons.my_location,
                        color: Colors.white,
                      ),
                    ),
                  ))
            ])
      ],
      layers: [MarkerLayerOptions(markers: markersList)],
    );
  }
}
