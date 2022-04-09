import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:final_project/Map/location_types.dart';
import 'package:final_project/Map/server_communication.dart';
import 'package:final_project/Map/Audio_player_controller.dart';

import 'guide.dart';

class UserMap extends StatefulWidget {
  // inits
  static Location? USER_LOCATION;
  static LocationData? USER_LOCATION_DATA;
  static UserMap? USER_MAP;
  static ServerCommunication? MAP_SERVER_COMMUNICATOR;
  static List userChangeLocationFuncs = [];
  static Map poisMap = Map<String, MapPoi>(); // the string is poi name
  static bool continueGuide = false;

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

  static void preUnmountMap() {
    UserMap.poisMap.clear();
    userChangeLocationFuncs.clear();
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
  GuideData guideData = GuideData();
  AudioApp audioPlayer = AudioApp();
  late Guide guideTool;
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

  void guideUser() async {
    sleep(Duration(seconds: 5));
    guideTool.handleMapPoiVoice(UserMap.poisMap['my house']);
  }

  @override
  void initState() {
    super.initState();
    print("init _UserMapState");
    _centerOnLocationUpdate = CenterOnLocationUpdate.always;
    _centerCurrentLocationStreamController = StreamController<double?>();
    guideTool = Guide(context, guideData, audioPlayer);
    // FlutterCompass.events?.listen((event) {
    //   //TODO check
    //   // setState(() {
    //   //   mapHeading = 360 + event.heading!;
    //   //   print(event.heading!);
    //   //   _mapController.rotate(mapHeading);
    //   // });
    // });
  }

  @override
  void dispose() {
    print("____________________dispose statful map");
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
              UserMap.USER_LOCATION_DATA!.latitude!,
              UserMap.USER_LOCATION_DATA!.longitude!,
              UserMap.USER_LOCATION_DATA!.heading!,
              UserMap.USER_LOCATION_DATA!.speed!));

      setState(() {
        // add all the new poi
        print("add pois to map");
        for (Poi poi in pois) {
          if (!UserMap.poisMap.containsKey(poi.poiName)) {
            MapPoi mapPoi = MapPoi(poi);
            UserMap.poisMap[poi.poiName] = mapPoi;
            markersList.add(mapPoi.marker!);
          }
        }
      });
      // guideTool.handleMapPoiVoice(UserMap.poisMap["my house"]);
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
        // menu row.
        Align(
          alignment: Alignment.topLeft,
            child: AnimatedOpacity(
              opacity: guideData.status == GuideStatus.voice ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 500),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 152,
                  color: Colors.green,
                  child: audioPlayer,
                )
            )
        ),

        Align(
            alignment: Alignment.topRight,
            child: Container(
                alignment: Alignment.bottomRight,
                margin: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height / 6,
                    right: MediaQuery.of(context).size.width / 15),
                color: Colors.yellow,
                height: MediaQuery.of(context).size.width / 10,
                width: MediaQuery.of(context).size.width / 10,
                child: FloatingActionButton(
                  heroTag: null,
                  onPressed: () {
                    setState(() {
                      guideData.changeGuideType();
                    });
                    print("change to audio or to text");
                  },
                  child: guideData.guideIcon,
                ))),
        Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              margin: EdgeInsets.only(
                  bottom: MediaQuery.of(context).size.height / 11,
                  left: MediaQuery.of(context).size.width / 15),
              height: MediaQuery.of(context).size.width / 11,
              width: MediaQuery.of(context).size.width / 11,
              child: FloatingActionButton(
                heroTag: null,
                onPressed: () {
                  // Automatically center the location marker on the map when location updated until user interact with the map.
                  setState(
                    () =>
                        _centerOnLocationUpdate = CenterOnLocationUpdate.always,
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
      ],
      layers: [MarkerLayerOptions(markers: markersList)],
    );
  }
}
