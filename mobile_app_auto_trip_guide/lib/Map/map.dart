import 'dart:async';
import 'package:final_project/General%20Wigets/menu.dart';
import 'package:final_project/Map/globals.dart';
import 'package:final_project/Map/personalize_recommendation.dart';
import 'package:final_project/Map/pois_attributes_calculator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:final_project/Map/types.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'guide.dart';
import 'package:flutter/foundation.dart';

class UserMap extends StatefulWidget {
  MapPoi? highlightedPoi;
  bool showLoadingPoisAnimation = false;

  // inits
  static late Position USER_LOCATION;

  // the last known location of the user in the old area - for new pois purposes
  static late Position LAST_AREA_USER_LOCATION;
  static double DISTANCE_BETWEEN_AREAS = 1000; //1000 meters
  static List userChangeLocationFuncs = [];

  static Future<void> mapInit() async {
    //permissions handling
    LocationPermission permission = await Geolocator.checkPermission();
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied');
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    USER_LOCATION = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    // initialization order is very important
    Geolocator.getPositionStream().listen(locationChangedEvent);
    LAST_AREA_USER_LOCATION = USER_LOCATION;
  }

  static bool isUserInNewArea() {
    double dist = PoisAttributesCalculator.getDistBetweenPoints(
        LAST_AREA_USER_LOCATION.latitude,
        LAST_AREA_USER_LOCATION.longitude,
        USER_LOCATION.latitude,
        USER_LOCATION.longitude);

    if (dist > DISTANCE_BETWEEN_AREAS) {
      LAST_AREA_USER_LOCATION = USER_LOCATION;
      print("The user is in a new area");
      return true;
    }
    return false;
  }

  static void locationChangedEvent(Position currentLocation) async {
    USER_LOCATION = currentLocation;
    for (int i = 0; i < UserMap.userChangeLocationFuncs.length; i++) {
      userChangeLocationFuncs[i](currentLocation);
    }
  }

  static void preUnmountMap() {
    userChangeLocationFuncs.clear();
  }

  void highlightPoi(MapPoi mapPoi) {
    //TODO USE BLOC
    if (this.highlightedPoi != null) {
      userMapState?.unHighlightMapPoi(highlightedPoi!);
    }
    this.highlightedPoi = mapPoi;
    userMapState?.highlightMapPoi(mapPoi);
  }

  void setLoadingAnimationState(bool isActive) {
    //TODO USE BLOC
    showLoadingPoisAnimation = isActive;
    userMapState?.updateState();
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
  WidgetVisibility loadingPois = WidgetVisibility.view;

  late CenterOnLocationUpdate _centerOnLocationUpdate;
  late StreamController<double?> _centerCurrentLocationStreamController;
  final MapController _mapController = MapController();
  double mapHeading = 0;
  List<Marker> markersList = [];
  bool isNewPoisNeededFlag = true;
  int _numOfPoisRequests = 0;

  // at new area the we snooze to the server in order to seek new pois
  static int NEW_AREA_SNOOZE = 7;

  // at new area the we snooze to the server in order to seek new pois
  static int SECONDS_BETWEEN_SNOOZES = 15;

  _UserMapState() : super() {
    UserMap.userChangeLocationFuncs.add(onLocationChanged);
    print("hello from ctor2");
  }

  void updateState() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    print("init _UserMapState");
    _centerOnLocationUpdate = CenterOnLocationUpdate.always;
    _centerCurrentLocationStreamController = StreamController<double?>();
    guideTool = Guide(context, guideData);
  }

  @override
  void dispose() {
    print("____________________dispose statful map");
    _centerCurrentLocationStreamController.close();
    super.dispose();
  }

  // add new pois if location changed
  void onLocationChanged(Position currentLocation) async {
    print("hello from location changed");
    List<Poi> pois;
    // TODO add a condition that won't crazy the server
    if (isNewPoisNeeded()) {
      pois = await Globals.globalServerCommunication.getPoisByLocation(
          LocationInfo(currentLocation.latitude, currentLocation.longitude,
              currentLocation.heading, currentLocation.speed));
      setState(() {
        // add all the new poi
        print("add pois to map");
        for (Poi poi in pois) {
          if (!Globals.globalAllPois.containsKey(poi.id)) {
            MapPoi mapPoi = MapPoi(poi);
            Globals.globalAllPois[poi.id] = mapPoi;
            Globals.addUnhandledPoiKey(poi.id);
            Globals.globalPoisIdToMarkerIdx[poi.id] = markersList.length;
            markersList.add(mapPoi.marker!);
          }
        }
      });

      Globals.globalUnhandledKeys
          .sort(PersonalizeRecommendation.sortPoisByWeightedScore);
      // if there is new pois and guideTool waiting
      if (pois.isNotEmpty) {
        guideTool.setPoisInQueue(pois);
      }
    }
  }

  // change pois needed flag
  Future<void> poisNeededFlagChange(int timeToWait, bool val) async {
    await Future.delayed(Duration(seconds: timeToWait));
    isNewPoisNeededFlag = val;
  }

  bool isNewPoisNeeded() {
    if (UserMap.isUserInNewArea()) {
      _numOfPoisRequests = 0; //restart the counting
      isNewPoisNeededFlag = true;
    }
    if (isNewPoisNeededFlag) {
      isNewPoisNeededFlag = false;
      poisNeededFlagChange(
          SECONDS_BETWEEN_SNOOZES, NEW_AREA_SNOOZE >= _numOfPoisRequests);
      _numOfPoisRequests++;
      print("New pois are needed!!!!");
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
          center: LatLng(
              UserMap.USER_LOCATION.latitude, UserMap.USER_LOCATION.longitude),
          minZoom: 5.0),
      // ignore: sort_child_properties_last
      children: [
        TileLayer(
          urlTemplate: 'https://a.tile.openstreetmap.de/{z}/{x}/{y}.png',
          subdomains: ['a', 'b', 'c'],
          maxZoom: 19,
        ),
        CurrentLocationLayer(
            centerCurrentLocationStream:
                _centerCurrentLocationStreamController.stream,
            centerOnLocationUpdate: _centerOnLocationUpdate),
        MarkerLayer(markers: markersList)
      ],
      nonRotatedChildren: [
        Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 60),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    child: NavigationDrawer.buildNavigationDrawerButton(context),
                  ),
                  if (widget.showLoadingPoisAnimation)
                    Container(
                        color: Colors.transparent,
                        alignment: Alignment.bottomRight,
                        margin: EdgeInsets.only(
                            right: MediaQuery.of(context).size.width / 60),
                        height: MediaQuery.of(context).size.width / 10,
                        width: MediaQuery.of(context).size.width / 10,
                        child: LoadingAnimationWidget.dotsTriangle(
                          size: 30,
                          color: Colors.blue,
                        )),
                ],
              ),
            ),
            Row(
              children: [
                Container(
                  margin: EdgeInsets.only(
                      top: MediaQuery.of(context).size.width / 20,
                      left: MediaQuery.of(context).size.width / 40),
                  width: MediaQuery.of(context).size.width / 10,
                  child: FloatingActionButton(
                    heroTag: null,
                    onPressed: () {
                      // Automatically center the location marker on the map when location updated until user interact with the map.
                      setState(
                            () => _centerOnLocationUpdate = CenterOnLocationUpdate.always,
                      );
                      // Center the location marker on the map and zoom the map to level 14.
                      _centerCurrentLocationStreamController.add(14);
                    },
                    child: const Icon(
                      Icons.my_location,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(child: guideTool.storiesDialogBox)
                    // guideTool.guideDialogBox,
                  ],
                ))
          ],
        ),
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
      mapPoi.iconButton!.iconState?.setColor(Color(0xff0A84FF));
    });
  }

  void unHighlightMapPoi(MapPoi mapPoi) {
    setState(() {
      mapPoi.iconButton!.iconState?.setColor(Color(0xffB0B0B0));
    });
  }

  void triggerGuide() {
    // guideTool.handlePois();
  }

  void guideAboutMapPoi(MapPoi mapPoi) {
    //TODO ADD LOGIC
    // guideTool.stop();
    // guideTool.askPoi(mapPoi);
  }
}
