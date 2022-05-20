import 'dart:async';
import 'package:final_project/Map/globals.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:final_project/Map/types.dart';
import 'guide.dart';

class UserMap extends StatefulWidget {
  // inits
  static Location? USER_LOCATION;
  static LocationData? USER_LOCATION_DATA;
  static List userChangeLocationFuncs = [];

  static Future<void> mapInit() async {
    // initialization order is very important
    USER_LOCATION = await getLocation();
    USER_LOCATION_DATA = await USER_LOCATION!.getLocation();
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
    userChangeLocationFuncs.clear();
  }

  UserMap({Key? key}) : super(key: key) {
    print("hello from ctor");
  }

  _UserMapState? userMapState;

  @override
  State<StatefulWidget> createState() {
    userMapState = _UserMapState();
    return userMapState!;
  }
}

class _UserMapState extends State<UserMap> {
  GuideData guideData = GuideData();
  late Guide guideTool;
  WidgetVisibility navButtonState = WidgetVisibility.hide;
  WidgetVisibility nextButtonState = WidgetVisibility.hide;

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
    print("init _UserMapState");
    _centerOnLocationUpdate = CenterOnLocationUpdate.always;
    _centerCurrentLocationStreamController = StreamController<double?>();
    guideTool = Guide(context, guideData, Globals.globalAudioPlayer);
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      guideTool.handlePois();
    });

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
      pois = await Globals.globalServerCommunication.getPoisByLocation(
          LocationInfo(
              UserMap.USER_LOCATION_DATA!.latitude!,
              UserMap.USER_LOCATION_DATA!.longitude!,
              UserMap.USER_LOCATION_DATA!.heading!,
              UserMap.USER_LOCATION_DATA!.speed!));

      setState(() {
        // add all the new poi
        print("add pois to map");
        for (Poi poi in pois) {
          if (!Globals.globalAllPois.containsKey(poi.id)) {
            MapPoi mapPoi = MapPoi(poi);
            Globals.globalAllPois[poi.id] = mapPoi;
            Globals.globalUnhandledKeys.add(poi.id);
            Globals.globalPoisIdToMarkerIdx[poi.id] = markersList.length;
            markersList.add(mapPoi.marker!);
          }
        }
      });

      Globals.globalUnhandledKeys
          .sort(Globals.sortPoisByUserPreferences); //TODO improve complexity
      // if there is new pois and guideTool waiting
      if (pois.isNotEmpty && guideTool.state == GuideState.waiting) {
        guideTool.handlePois();
      }
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
            urlTemplate: 'https://a.tile.openstreetmap.de/{z}/{x}/{y}.png',
            subdomains: ['a', 'b', 'c'],
            maxZoom: 19,
          ),
        ),
        // MarkerLayerWidget(options: MarkerLayerOptions(markers: markersList)
        // ),
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
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // audio player
            AnimatedOpacity(
                opacity: guideData.status == GuideStatus.voice ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 500),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 48,
                  color: Colors.green,
                  child: Globals.globalAudioPlayer,
                )),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                    color: Colors.transparent,
                    margin: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height / 15,
                        left: MediaQuery.of(context).size.width / 15),
                    // height: MediaQuery.of(context).size.width / 2,
                    width: MediaQuery.of(context).size.width / 11,
                    child: AnimatedOpacity(
                        opacity:
                            WidgetVisibility.view == navButtonState ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 500),
                        child: FloatingActionButton(
                          heroTag: null,
                          onPressed: () {
                            print("navigate to poi pressed");

                            if (Globals.mainMapPoi != null) {
                              print("navigate to poi");
                              double lat = Globals.mainMapPoi!.poi.latitude;
                              double lng = Globals.mainMapPoi!.poi.longitude;
                              Globals.globalAppLauncher.launchWaze(lat, lng);
                            }
                            // Automatically center the location marker on the map when location updated until user interact with the map.
                            // Center the location marker on the map and zoom the map to level 15.
                          },
                          child: const Icon(
                            Icons.navigation_rounded,
                            color: Colors.white,
                          ),
                        ))),
                // guide state button
                Container(
                    color: Colors.transparent,
                    alignment: Alignment.bottomRight,
                    margin: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height / 15,
                        right: MediaQuery.of(context).size.width / 15),
                    height: MediaQuery.of(context).size.width / 10,
                    width: MediaQuery.of(context).size.width / 10,
                    child: FloatingActionButton(
                      heroTag: null,
                      onPressed: () {
                        setState(() {
                          guideData.changeGuideType();
                          if (guideData.status == GuideStatus.text) {
                            Globals.globalAudioPlayer.clearPlayer();
                          }
                          guideTool.guideStateChanged();
                        });
                        print("change to audio or to text");
                      },
                      child: guideData.guideIcon,
                    ))
                // )
                ,
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  margin: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height / 30,
                      left: MediaQuery.of(context).size.width / 15),
                  // height: MediaQuery.of(context).size.height / 0.8,
                  width: MediaQuery.of(context).size.width / 10,
                  child: FloatingActionButton(
                    heroTag: null,
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
                ),
                Container(
                    alignment: Alignment.bottomRight,
                    margin: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height / 30,
                        right: MediaQuery.of(context).size.width / 15),
                    color: Colors.transparent,
                    height: MediaQuery.of(context).size.width / 10,
                    width: MediaQuery.of(context).size.width / 10,
                    child: AnimatedOpacity(
                        opacity: nextButtonState == WidgetVisibility.view
                            ? 1.0
                            : 0.0,
                        duration: const Duration(milliseconds: 500),
                        child: FloatingActionButton(
                          heroTag: null,
                          onPressed: () {
                            guideTool.stop();
                            guideTool.handlePois();
                            print("next");
                          },
                          child: const Icon(Icons.navigate_next_sharp,
                              color: Colors.white),
                        ))),
              ],
            ),
            Spacer(),
            guideTool.guideDialogBox
          ],
        )
      ],
      layers: [
        MarkerLayerOptions(markers: markersList),
      ],
    );
  }

  void showNextButton() {
    setState(() {
      nextButtonState = WidgetVisibility.view;
    });
  }

  void hideNextButton() {
    setState(() {
      nextButtonState = WidgetVisibility.hide;
    });
  }

  void showNavButton() {
    if (!mounted) {
      return; // Just do nothing if the widget is disposed.
    }
    setState(() {
      navButtonState = WidgetVisibility.view;
    });
  }

  void hideNavButton() {
    if (!mounted) {
      return; // Just do nothing if the widget is disposed.
    }
    setState(() {
      navButtonState = WidgetVisibility.hide;
    });
  }

  void highlightMapPoi(MapPoi mapPoi) {
    setState(() {
      mapPoi.iconButton!.iconState?.setColor(Colors.black);
    });
  }

  void unHighlightMapPoi(MapPoi mapPoi) {
    setState(() {
      mapPoi.iconButton!.iconState?.setColor(Colors.purpleAccent);
    });
  }

  void triggerGuide() {
    guideTool.handlePois();
  }

  void guideAboutMapPoi(MapPoi mapPoi) {
    guideTool.stop();
    guideTool.askPoi(mapPoi);
  }
}
