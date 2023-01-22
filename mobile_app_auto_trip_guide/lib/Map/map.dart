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

enum MarkersLayer { semiTransparent, grey, blue }

enum Action { add, remove }

class MapPoiAction {
  MarkersLayer layer;
  Action action;
  MapPoi mapPoi;

  MapPoiAction(
      {required this.layer, required this.action, required this.mapPoi});
}

class MapPoisLayer {
  final MarkersLayer layer;
  final List<MapPoi> mapPois;

  MapPoisLayer({required this.layer, required this.mapPois});
}

class UserMap extends StatefulWidget {
  bool showLoadingPoisAnimation = false;

  // inits
  static late Position USER_LOCATION;

  // the last known location of the user in the old area - for new pois purposes
  static late Position LAST_AREA_USER_LOCATION;
  static double DISTANCE_BETWEEN_AREAS = 1000; //1000 meters
  static List userChangeLocationFuncs = [];
  StreamController<MapPoisLayer> mapPoisLayerStreamController =
      StreamController<MapPoisLayer>.broadcast();
  StreamController<MapPoiAction> mapPoiActionStreamController =
      StreamController<MapPoiAction>.broadcast();
  StreamController<LatLng> highlightedPoiStreamController =
      StreamController<LatLng>.broadcast();

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
        desiredAccuracy: LocationAccuracy.medium);
    // initialization order is very important

    Geolocator.getPositionStream(
            locationSettings: LocationSettings(accuracy: LocationAccuracy.high))
        .listen(locationChangedEvent);
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
    mapPoisLayerStreamController
        .add(MapPoisLayer(layer: MarkersLayer.blue, mapPois: [mapPoi]));
    highlightedPoiStreamController
        .add(LatLng(mapPoi.poi.latitude, mapPoi.poi.longitude));
  }

  void setLoadingAnimationState(bool isActive) {
    showLoadingPoisAnimation = isActive;
    userMapState?.updateState();
  }

  UserMap({Key? key}) : super(key: key) {
    Future.delayed(Duration(seconds: 1),
        (() => {userMapState?.onLocationChanged(LAST_AREA_USER_LOCATION)}));
    print("hello from ctor");
  }

  _UserMapState? userMapState;

  @override
  State<StatefulWidget> createState() {
    userMapState = _UserMapState();
    return userMapState!;
  }

  void setMapPoisLayer(MapPoisLayer mapPoisLayer) {
    mapPoisLayerStreamController.add(mapPoisLayer);
  }

  void setMapPoiOnLayer(MapPoiAction mapPoiAction) {
    mapPoiActionStreamController.add(mapPoiAction);
  }
}

class _UserMapState extends State<UserMap> {
  late StreamSubscription mapPoisLayerSubscription;
  late StreamSubscription mapPoiActionSubscription;
  List<List<Marker>> listOfMarkersLayers = [];
  StreamController<LocationMarkerPosition> _currentLocationStreamController =
      StreamController<LocationMarkerPosition>();
  GuideData guideData = GuideData();
  late Guide guideTool;
  WidgetVisibility navButtonState = WidgetVisibility.hide;
  WidgetVisibility nextButtonState = WidgetVisibility.hide;
  WidgetVisibility loadingPois = WidgetVisibility.view;
  MapPoi? highlightedPoi;
  List<Color> layersColor = [
    Color(0xffB0B0B0).withAlpha(130),
    Color(0xffB0B0B0),
    Color(0xff0A84FF)
  ];

  late CenterOnLocationUpdate _centerOnLocationUpdate;
  late StreamController<double?> _centerCurrentLocationStreamController;
  final MapController _mapController = MapController();
  double mapHeading = 0;

  bool isNewPoisNeededFlag = true;
  int _numOfPoisRequests = 0;

  // at new area the we snooze to the server in order to seek new pois
  static int NEW_AREA_SNOOZE = 7;

  // at new area the we snooze to the server in order to seek new pois
  static int SECONDS_BETWEEN_SNOOZES = 15;

  _UserMapState() : super() {
    UserMap.userChangeLocationFuncs.add(onLocationChanged);
    UserMap.userChangeLocationFuncs.add(updateMapRelativePosition);
    UserMap.userChangeLocationFuncs.add((Position currentLocation) {
      _currentLocationStreamController.add(LocationMarkerPosition(
          latitude: currentLocation.latitude,
          longitude: currentLocation.longitude,
          accuracy: currentLocation.accuracy));
    });

    // add a layer for every value in the MarkersLayer enum
    MarkersLayer.values.forEach((element) {
      listOfMarkersLayers.add([]);
    });
  }

  CustomPoint? getRelativeScreenCenterToUserPosition() {
    CustomPoint? userPoint = _mapController.latLngToScreenPoint(LatLng(
        UserMap.USER_LOCATION.latitude, UserMap.USER_LOCATION.longitude));
    return CustomPoint(userPoint!.x,
        userPoint!.y + Globals.globalWidgetsSizes.dialogBoxTotalHeight / 2);
  }

  LatLng getRelativeCenterToUserPosition() {
    return _mapController.pointToLatLng(
        getRelativeScreenCenterToUserPosition() ?? CustomPoint(0, 0))!;
  }

  void updateMapRelativePosition(Position currentLocation) async {
    double epsilon = 0.0001;
    if (_centerOnLocationUpdate == CenterOnLocationUpdate.always) {
      LatLng oldCenter = _mapController.center;
      LatLng newCenter = getRelativeCenterToUserPosition();
      if ((newCenter.longitude - oldCenter.longitude).abs() < epsilon &&
          (newCenter.latitude - oldCenter.latitude).abs() < epsilon) {
        return; // the location didn't changed really
      }
      _mapController.move(newCenter, _mapController.zoom);
    }
  }

  void updateState() {
    setState(() {});
  }

  void setMapPoisLayer(MapPoisLayer mapPoisLayer) {
    List<Marker> newMarkerLayer = <Marker>[];
    mapPoisLayer.mapPois.forEach((element) {
      Marker marker =
          element.createMarkerFromPoi(layersColor[mapPoisLayer.layer.index]);
      newMarkerLayer.add(marker);
    });
    listOfMarkersLayers[mapPoisLayer.layer.index] = newMarkerLayer;
  }

  void setMapPoiAction(MapPoiAction mapPoiAction) {
    // first remove the element
    listOfMarkersLayers[mapPoiAction.layer.index].removeWhere((marker) =>
        marker.point.latitude == mapPoiAction.mapPoi.poi.latitude &&
        marker.point.longitude == mapPoiAction.mapPoi.poi.longitude);
    if (mapPoiAction.action == Action.add) {
      listOfMarkersLayers[mapPoiAction.layer.index].add(mapPoiAction.mapPoi
          .createMarkerFromPoi(layersColor[mapPoiAction.layer.index]));
    }
  }

  bool isValidScreenPoint(CustomPoint? screenPoint) {
    double margin = 20;
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    double dialogHeight = Globals.globalWidgetsSizes.dialogBoxTotalHeight;

    if (screenPoint == null) return false;
    if (screenPoint.x > screenWidth ||
        screenPoint.x < 0 ||
        screenPoint.y > screenHeight ||
        screenHeight - screenPoint.y - margin < dialogHeight ||
        screenPoint.y < 0) return false;
    return true;
  }

  @override
  void initState() {
    mapPoisLayerSubscription =
        widget.mapPoisLayerStreamController.stream.listen((event) {
      setMapPoisLayer(event);
      updateState();
    });
    mapPoiActionSubscription =
        widget.mapPoiActionStreamController.stream.listen((event) {
      setMapPoiAction(event);
      updateState();
    });
    print("init _UserMapState");
    _centerOnLocationUpdate = CenterOnLocationUpdate.always;
    _centerCurrentLocationStreamController = StreamController<double?>();
    guideTool = Guide(context, guideData);

    widget.highlightedPoiStreamController.stream.listen((event) {
      double xMarginFromCenter =
          (UserMap.USER_LOCATION.longitude - event.longitude).abs();
      double yMarginFromCenter =
          (UserMap.USER_LOCATION.latitude - event.latitude).abs();

      _mapController.fitBounds(
        LatLngBounds(
          LatLng(UserMap.USER_LOCATION.latitude + yMarginFromCenter,
              UserMap.USER_LOCATION.longitude + xMarginFromCenter),
          LatLng(UserMap.USER_LOCATION.latitude - yMarginFromCenter,
              UserMap.USER_LOCATION.longitude - xMarginFromCenter),
        ),
        options: FitBoundsOptions(
            padding: EdgeInsets.only(
                bottom: Globals.globalWidgetsSizes.dialogBoxTotalHeight + 80,
                top: 80,
                right: 50,
                left: 50),
            forceIntegerZoomLevel: false),
      );
      // need to move because bounds can change the center a little bit
      updateMapRelativePosition(UserMap.USER_LOCATION);
    });

    LocationMarkerDataStreamFactory().compassHeadingStream().listen((event) {
      if (_centerOnLocationUpdate != CenterOnLocationUpdate.always) return;
      _mapController.rotate(-event.heading / pi * 180);
      updateMapRelativePosition(UserMap.USER_LOCATION);
    });
    super.initState();
  }

  @override
  void dispose() {
    print("____________________dispose statful map");
    mapPoisLayerSubscription.cancel();
    mapPoiActionSubscription.cancel();
    _centerCurrentLocationStreamController.close();
    _currentLocationStreamController.close();
    super.dispose();
  }

  // add new pois if location changed
  void onLocationChanged(Position currentLocation) async {
    if (!mounted) return;
    print("hello from location changed");
    // TODO add a condition that won't crazy the server
    if (isNewPoisNeeded()) {
      loadNewPois(location: currentLocation);
    }
  }

  Future<void> loadNewPois({Position? location = null}) async {
    Position selectedLocation = location ?? UserMap.USER_LOCATION;
    List<Poi> pois;
    pois = await Globals.globalServerCommunication.getPoisByLocation(
        LocationInfo(selectedLocation.latitude, selectedLocation.longitude,
            selectedLocation.heading, selectedLocation.speed));

    pois = PoisAttributesCalculator.filterPois(pois, selectedLocation);
// pois = [new Poi(latitude: 32.100084,longitude: 34.881173,country: 'Israel',poiName: 'Roy1',Categories: [],id:'a',audio: null,shortDesc:'Adullam-France Park (Hebrew: פארק עדולם-צרפת), also known as Parc de France-Adoulam, is a sprawling park of 50,000 dunams (50 km2; 19 sq mi)(ca. 12,350 acres) in the Central District of Israel, located south of Beit Shemesh. The park, established in 2008 for public recreation, features two major hiking and biking trails, and four major archaeological sites from the Second Temple period. It stretches between Naḥal Ha-Elah (Highway 375), its northernmost boundary, to Naḥal Guvrin (Highway 35), its southernmost boundary. To its west lies the Beit Guvrin-Beit Shemesh highway, and to its east the "green line" – now territories under joint Israeli-Palestinian Arab control – which marks its limit.'),new Poi(latitude: 32.100080,longitude: 34.881170,poiName: 'Roy2',country: 'Israel',Categories: [],id:'b',audio: null,shortDesc: 'bbbb')];
    setState(() {
      // add all the new poi
      print("add pois to map");
      for (Poi poi in pois) {
        if (!Globals.globalAllPois.containsKey(poi.id)) {
          MapPoi mapPoi = MapPoi(poi);
          Globals.globalAllPois[poi.id] = mapPoi;
          Globals.addUnhandledPoiKey(poi.id);
          widget.mapPoiActionStreamController.add(MapPoiAction(
              layer: MarkersLayer.semiTransparent,
              action: Action.add,
              mapPoi: MapPoi(poi)));
        }
      }
    });

    // if there is new pois and guideTool waiting
    if (pois.isNotEmpty) {
      guideTool.setPoisInQueue(pois);
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
          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
          subdomains: ['a', 'b', 'c'],
          maxZoom: 19,
        ),
        CurrentLocationLayer(
          positionStream: _currentLocationStreamController.stream,
          // centerCurrentLocationStream:
          //     _centerCurrentLocationStreamController.stream,
          // centerOnLocationUpdate: _centerOnLocationUpdate),
        ),
        MarkerLayer(
            markers: listOfMarkersLayers[MarkersLayer.semiTransparent.index]),
        MarkerLayer(markers: listOfMarkersLayers[MarkersLayer.grey.index]),
        MarkerLayer(markers: listOfMarkersLayers[MarkersLayer.blue.index]),
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
                    child:
                        NavigationDrawer.buildNavigationDrawerButton(context),
                  ),
                  widget.showLoadingPoisAnimation
                      ? Container(
                          color: Colors.transparent,
                          alignment: Alignment.bottomRight,
                          margin: EdgeInsets.only(
                              right: MediaQuery.of(context).size.width / 60),
                          height: MediaQuery.of(context).size.width / 10,
                          width: MediaQuery.of(context).size.width / 10,
                          child: LoadingAnimationWidget.threeArchedCircle(
                            size: 30,
                            color: Colors.blue,
                          ))
                      : Container(),
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
                      _centerOnLocationUpdate = CenterOnLocationUpdate.always;
                      _mapController.move(getRelativeCenterToUserPosition(),
                          _mapController.zoom); // need to be called twice!

                      // Center the location marker on the map and zoom the map to level 14.
                      // _centerCurrentLocationStreamController.add(13);
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

  void triggerGuide() {
    // guideTool.handlePois();
  }

  void guideAboutMapPoi(MapPoi mapPoi) {
    //TODO ADD LOGIC
    // guideTool.stop();
    // guideTool.askPoi(mapPoi);
  }
}
