import 'dart:async';
import 'dart:math';
import 'package:final_project/General%20Wigets/menu.dart';
import 'package:final_project/Map/globals.dart';
import 'package:final_project/Map/map_configuration.dart';
import 'package:final_project/Map/mapbox/user_location_marker.dart';
import 'package:final_project/Map/mapbox/user_location_marker_car.dart';
import 'package:final_project/Map/pois_attributes_calculator.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:final_project/Map/types.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:mapbox_gl/mapbox_gl.dart' as mapbox;
import '../General Wigets/UniversalPanGestureRecognizer.dart';
import '../Pages/location_permission_page.dart';
import 'guide.dart';
import 'package:flutter/foundation.dart';
import 'dart:math' as math;
import 'package:wakelock/wakelock.dart';
import 'mapbox/user_location_marker_foot.dart';

double log2(num x) => log(x) / ln2;

double toRadians(double degrees) {
  return degrees * (math.pi / 180.0);
}

const double EARTH_RADIUS = 6378137;

enum MarkersLayer { semiTransparent, grey, blue }

enum UserStatus { driving, walking }

enum CameraOption { move, animate }

enum PoiAction {
  add,
  remove,
  highlight
} // highlight cause that the poi wont delete from the map if no space

class MapPoiAction {
  PoiIconColor color;
  PoiAction action;
  MapPoi mapPoi;

  MapPoiAction(
      {required this.color, required this.action, required this.mapPoi});
}

class UserMap extends StatefulWidget {
  bool isScanning = false;
  Timer? _scanningTimer;

  // inits
  late Position userLocation; // the heading here isn't updated
  double userHeading = 0; // the correct heading
  MapPoi? currentHighlightedPoi = null;
  bool isFirstScanning = true;
  // the last known location of the user in the old area - for new pois purposes
  late Position lastAreaUserLocation;
  static double DISTANCE_BETWEEN_AREAS = 1000; //1000 meters
  List userChangeLocationFuncs = [];
  StreamController<MapPoiAction> mapPoiActionStreamController =
      StreamController<MapPoiAction>.broadcast();
  StreamController<MapPoi> highlightedPoiStreamController =
      StreamController<MapPoi>.broadcast();
  StreamController<List<Poi>> poisToAddQueue =
    StreamController<List<Poi>>.broadcast();


  Future<void> mapInit(context) async {
    await LocationUtils.checkAndRequestLocationPermission(context);
    userLocation = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
    Geolocator.getPositionStream(
            locationSettings: LocationSettings(accuracy: LocationAccuracy.high))
        .listen(locationChangedEvent);
    lastAreaUserLocation = userLocation;
  }

  bool isUserInNewArea() {
    double dist = PoisAttributesCalculator.getDistBetweenPoints(
        lastAreaUserLocation.latitude,
        lastAreaUserLocation.longitude,
        userLocation.latitude,
        userLocation.longitude);

    if (dist > DISTANCE_BETWEEN_AREAS) {
      lastAreaUserLocation = userLocation;
      print("The user is in a new area");
      return true;
    }
    return false;
  }

  void locationChangedEvent(Position currentLocation) async {
    userLocation = currentLocation;
    for (int i = 0; i < userChangeLocationFuncs.length; i++) {
      userChangeLocationFuncs[i](currentLocation);
    }
  }

  void preUnmountMap() {
    userChangeLocationFuncs.clear();
  }

  void highlightPoi(MapPoi mapPoi) {
    currentHighlightedPoi = mapPoi;
    highlightedPoiStreamController.add(mapPoi);
  }

  void setPoisScanningStatus(bool isActive) {
    isScanning = isActive;
    if (isActive) {
      loadNewPois(location: userLocation);
      _scanningTimer = Timer.periodic(Duration(seconds: 5), (timer) {
        loadNewPois(location: userLocation);
      });
    } else {
      _scanningTimer?.cancel();
      _scanningTimer = null;
    }
    userMapState?.updateState();
  }

  UserMap({Key? key}) : super(key: key) {
    Future.delayed(Duration(seconds: 1),
        (() => {userMapState?.onLocationChanged(lastAreaUserLocation)}));
    print("hello from ctor");
  }

  _UserMapState? userMapState;

  @override
  State<StatefulWidget> createState() {
    userMapState = _UserMapState();
    return userMapState!;
  }

  void setMapPoiOnLayer(MapPoiAction mapPoiAction) {
    mapPoiActionStreamController.add(mapPoiAction);
  }

  Future<void> loadNewPois({Position? location = null}) async {
    Position selectedLocation = location ?? userLocation;
    List<Poi> pois;
    pois = await Globals.globalServerCommunication.getPoisByLocation(
        LocationInfo(selectedLocation.latitude, selectedLocation.longitude,
            selectedLocation.heading, selectedLocation.speed));

    pois = PoisAttributesCalculator.filterPois(pois, selectedLocation);
    // add all the new poi
    print("add pois to map");
    for (Poi poi in pois) {
      if (!Globals.globalAllPois.containsKey(poi.id)) {
        MapPoi mapPoi = MapPoi(poi);
        Globals.globalAllPois[poi.id] = mapPoi;
        Globals.addUnhandledPoiKey(poi.id);
        mapPoiActionStreamController.add(MapPoiAction(
            color: PoiIconColor.greyTrans,
            action: PoiAction.add,
            mapPoi: MapPoi(poi)));
      }
    }

    if (pois.isNotEmpty) {
      poisToAddQueue.add(pois);
    }
  }

}

class _UserMapState extends State<UserMap> with TickerProviderStateMixin, WidgetsBindingObserver {
  late StreamSubscription mapPoiActionSubscription;
  late StreamSubscription highlightedPoiSubscription;
  late StreamSubscription poisToAddSubscription;
  UserStatus _userStatus = UserStatus.walking; // this effects on the rotation
  GuideData guideData = GuideData();
  late Guide guideTool;
  WidgetVisibility navButtonState = WidgetVisibility.hide;
  WidgetVisibility loadingPois = WidgetVisibility.view;
  MapPoi? highlightedPoi;
  double userIconHeading = 0;
  bool isNewPoisNeededFlag = true;
  int _numOfPoisRequests = 0;

  // at new area the we snooze to the server in order to seek new pois
  static int NEW_AREA_SNOOZE = 7;

  // at new area the we snooze to the server in order to seek new pois
  static int SECONDS_BETWEEN_SNOOZES = 15;
  // for rendering purposes
  AppLifecycleState _lastLifecycleState = AppLifecycleState.resumed;
  // mapbox variables
  late mapbox.MapboxMap map;
  Key _mapboxUniqueKey = UniqueKey(); // for recreating the widget purposes
  late mapbox.CameraPosition _cameraPosition;
  bool _isMoving = false;
  bool _compassEnabled = true;
  mapbox.CameraTargetBounds _cameraTargetBounds =
      mapbox.CameraTargetBounds.unbounded;
  mapbox.MinMaxZoomPreference _minMaxZoomPreference =
      mapbox.MinMaxZoomPreference(1, 16);
  List<String> _styleStrings = [
    mapbox.MapboxStyles.MAPBOX_STREETS,
    mapbox.MapboxStyles.OUTDOORS,
    mapbox.MapboxStyles.LIGHT,
    mapbox.MapboxStyles.DARK,
    mapbox.MapboxStyles.SATELLITE,
    mapbox.MapboxStyles.SATELLITE_STREETS,
    mapbox.MapboxStyles.TRAFFIC_DAY,
    mapbox.MapboxStyles.TRAFFIC_NIGHT,
    "assets/style.json"
  ];
  int _styleStringIndex = 0;
  bool _rotateGesturesEnabled = true;
  bool _scrollGesturesEnabled = true;
  bool? _doubleClickToZoomEnabled;
  bool _tiltGesturesEnabled = true;
  bool _zoomGesturesEnabled = true;
  bool _myLocationEnabled = true;
  bool _telemetryEnabled = true;
  Set<mapbox.Symbol> _symbolsOnMap = Set();
  late mapbox.SymbolManager _symbolManager;
  late mapbox.SymbolManager _highlightSymbolManager;
  List<UserLocationMarker> _userLocationMarkers = <UserLocationMarker>[];

  mapbox.MyLocationTrackingMode _myLocationTrackingMode =
      mapbox.MyLocationTrackingMode.Tracking;
  List<Object>? _featureQueryFilter;
  mapbox.Fill? _selectedFill;

  mapbox.MapboxMap createMapboxMap(Key mapboxWidgetUniqueKey) {
    UniversalPanGestureRecognizer _panGestureRecognizer =
    UniversalPanGestureRecognizer(
      onUpdate: (details) {
        _onMapDrag(details);
      },
    );

    return mapbox.MapboxMap(
      key: mapboxWidgetUniqueKey,
      gestureRecognizers: Set()
        ..add(Factory<UniversalPanGestureRecognizer>(
                () => _panGestureRecognizer)),
      accessToken: MapConfiguration.mapboxAccessToken,
      onMapCreated: _onMapCreated,
      initialCameraPosition: _cameraPosition,
      compassEnabled: _compassEnabled,
      cameraTargetBounds: _cameraTargetBounds,
      minMaxZoomPreference: _minMaxZoomPreference,
      styleString: _styleStrings[_styleStringIndex],
      rotateGesturesEnabled: _rotateGesturesEnabled,
      scrollGesturesEnabled: _scrollGesturesEnabled,
      tiltGesturesEnabled: _tiltGesturesEnabled,
      zoomGesturesEnabled: _zoomGesturesEnabled,
      doubleClickZoomEnabled: _doubleClickToZoomEnabled,
      trackCameraPosition: true,
      onMapClick: (point, latLng) async {
        print(
            "Map click: ${point.x},${point.y}   ${latLng.latitude}/${latLng.longitude}");
        print("Filter $_featureQueryFilter");
        List features = await _mapController!
            .queryRenderedFeatures(point, ["landuse"], _featureQueryFilter);
        print('# features: ${features.length}');
        _clearFill();
        if (features.isEmpty && _featureQueryFilter != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('QueryRenderedFeatures: No features found!')));
        } else if (features.isNotEmpty) {
          _drawFill(features);
        }
      },
      onMapLongClick: (point, latLng) async {
        print(
            "Map long press: ${point.x},${point.y}   ${latLng.latitude}/${latLng.longitude}");
        math.Point convertedPoint =
        await _mapController.toScreenLocation(latLng);
        mapbox.LatLng convertedLatLng = await _mapController.toLatLng(point);
        print(
            "Map long press converted: ${convertedPoint.x},${convertedPoint.y}   ${convertedLatLng.latitude}/${convertedLatLng.longitude}");
        double metersPerPixel =
        await _mapController.getMetersPerPixelAtLatitude(latLng.latitude);

        print(
            "Map long press The distance measured in meters at latitude ${latLng.latitude} is $metersPerPixel m");

        List features =
        await _mapController.queryRenderedFeatures(point, [], null);
        if (features.length > 0) {
          print(features[0]);
        }
      },
      onUserLocationUpdated: (location) {},
      onStyleLoadedCallback: _onStyleLoadedCallback,
    );
  }

  _UserMapState() : super() {
  }

  void updateCameraByRelativePosition(
      {CameraOption option = CameraOption.animate}) {
    mapbox.CameraUpdate newCameraPosition =
        mapbox.CameraUpdate.newCameraPosition(
      mapbox.CameraPosition(
          target: _getRelativeCenterLatLng(_cameraPosition.zoom),
          bearing: userIconHeading,
          zoom: _cameraPosition.zoom),
    );

    switch (option) {
      case CameraOption.move:
        _mapController.moveCamera(newCameraPosition);
        break;
      case CameraOption.animate:
        _mapController.animateCamera(newCameraPosition);
        break;
      default:
        _mapController.animateCamera(newCameraPosition);
        break;
    }
  }

  void updateState() {
    setState(() {});
  }

  Future<void> setMapPoiAction(MapPoiAction mapPoiAction) async {
    if (mapPoiAction.action == PoiAction.add ||
        mapPoiAction.action == PoiAction.highlight) {
      mapbox.Symbol symbolToAdd =
          mapPoiAction.mapPoi.getSymbolFromPoi(mapPoiAction.color);
      if (mapPoiAction.action == PoiAction.add) {
        _symbolManager.add(symbolToAdd);
      } else {
        _highlightSymbolManager.removeAll(_highlightSymbolManager.annotations);
        _highlightSymbolManager.add(symbolToAdd);
      }
      _symbolsOnMap.add(symbolToAdd);
    } else if (mapPoiAction.action == PoiAction.remove) {
      mapbox.Symbol? oldSymbol =
          _symbolManager.byId(mapPoiAction.mapPoi.poi.id);
      if (oldSymbol != null) {
        _symbolManager.remove(oldSymbol);
        _symbolsOnMap.remove(oldSymbol);
      }
    }
  }

  // double getMetersPerPixelAtLatitude(double latitude, double zoom) {
  //   const double EARTH_RADIUS = 6378137;
  //   const int TILE_SIZE = 256;
  //   const double MIN_ZOOM = 0;
  //   const double MAX_ZOOM = 22;
  //   const double MIN_LATITUDE = -85.05112878;
  //   const double MAX_LATITUDE = 85.05112878;
  //   double constrainedZoom = math.max(math.min(zoom, MAX_ZOOM), MIN_ZOOM);
  //   double constrainedLatitude =
  //   math.max(math.min(latitude, MAX_LATITUDE), MIN_LATITUDE);
  //   double metersPerPixel = ((2 *
  //       math.pi *
  //       EARTH_RADIUS *
  //       math.cos(toRadians(constrainedLatitude))) /
  //       (TILE_SIZE * math.pow(2, constrainedZoom))) / 2;
  //   return metersPerPixel;
  // }

  // given distance in pixels and distance in meters, return the zoom such that distInPixels = distInMeters
  Future<double> _getZoomLevel(metersPerPixel,
      double latitude) async {
    double zoom = log2((2 * math.pi * EARTH_RADIUS *
        math.cos(toRadians(latitude))) / (512 * metersPerPixel));
    return zoom;
  }

  Future<double> _getZoomPointInDistFromUser(double distInPixels,
      mapbox.LatLng point) async {
    double distanceInMeters = await Geolocator.distanceBetween(
      widget.userLocation.latitude, // latitude of first location
      widget.userLocation.longitude, // longitude of first location
      point.latitude, // latitude of second location
      point.longitude, // longitude of second location
    );

    return _getZoomLevel(
        distanceInMeters / distInPixels, widget.userLocation.latitude);
  }

  @override
  void initState() {
    widget.userChangeLocationFuncs.add(onLocationChanged);
    double initialZoom = 15;
    _cameraPosition = mapbox.CameraPosition(
        target: _getRelativeCenterLatLng(initialZoom),
        bearing: userIconHeading,
        zoom: initialZoom);
    mapPoiActionSubscription =
        widget.mapPoiActionStreamController.stream.listen((event) {
      setMapPoiAction(event);
      updateState();
    });
    print("init _UserMapState");
    guideTool = Guide(context, guideData);

    poisToAddSubscription = widget.poisToAddQueue.stream.listen((pois) {
      guideTool.setPoisInQueue(pois);

    });

    highlightedPoiSubscription = widget.highlightedPoiStreamController.stream.listen((event) async {
      if (highlightedPoi != null) {
        widget.mapPoiActionStreamController.add(MapPoiAction(
            color: PoiIconColor.grey,
            action: PoiAction.add,
            mapPoi: highlightedPoi!));
      }
      highlightedPoi = event;
      widget.mapPoiActionStreamController.add(MapPoiAction(
          color: PoiIconColor.blue,
          action: PoiAction.highlight,
          mapPoi: highlightedPoi!));
      final padding = 80;
      final userPixelDistFromHighlightedPoi = min((MediaQuery.of(context).size
          .height - Globals.globalWidgetsSizes.dialogBoxTotalHeight) / 2,
          MediaQuery.of(context).size.width / 2) - padding;
      _cameraPosition = mapbox.CameraPosition(
          target: _cameraPosition.target,
          zoom: await _getZoomPointInDistFromUser(
              userPixelDistFromHighlightedPoi,
              mapbox.LatLng(highlightedPoi!.poi.latitude,
                  highlightedPoi!.poi.longitude)));
      updateCameraByRelativePosition();
    });
    super.initState();
    Wakelock.enable();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  Future<void> dispose() async {
    print("____________________dispose statful map");
    mapPoiActionSubscription.cancel();
    highlightedPoiSubscription.cancel();
    poisToAddSubscription.cancel();
    _mapController.dispose();
    disposeLocationMarkers();
    Wakelock.disable();
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  void disposeLocationMarkers() async {
    for (final element in _userLocationMarkers) {
      await element.dispose();
    }
    _userLocationMarkers.clear();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.detached) { // if detached close the app
      Globals.exitApp();
    }
    // if ([AppLifecycleState.detached].contains(state)) {
    //   Wakelock.disable();
    // }
    //  if (state == AppLifecycleState.resumed) {
    //    Wakelock.enable();
    //    Navigator.push(
    //      context,
    //      MaterialPageRoute(builder: (context) => LocationPermissionPage()),
    //    );
    //    if (_lastLifecycleState == AppLifecycleState.detached) {
    //      disposeLocationMarkers();
    //      _recreateWidget();
    //    }
    //  }
    // _lastLifecycleState = state;
  }

  void _recreateWidget() {
    setState(() {
      _mapboxUniqueKey = UniqueKey();
    });
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
    Position selectedLocation = location ?? widget.userLocation;
    List<Poi> pois;
    Globals.appEvents.scanningStarted(widget.isFirstScanning, true, selectedLocation.latitude, selectedLocation.longitude,);
    pois = await Globals.globalServerCommunication.getPoisByLocation(
        LocationInfo(selectedLocation.latitude, selectedLocation.longitude,
            selectedLocation.heading, selectedLocation.speed));
   Globals.appEvents.scanningFinished(true,pois.length);
    widget.isFirstScanning = false;
    pois = PoisAttributesCalculator.filterPois(pois, selectedLocation);
    setState(() {
      // add all the new poi
      print("add pois to map");
      for (Poi poi in pois) {
        if (!Globals.globalAllPois.containsKey(poi.id)) {
          MapPoi mapPoi = MapPoi(poi);
          Globals.globalAllPois[poi.id] = mapPoi;
          Globals.addUnhandledPoiKey(poi.id);
          widget.mapPoiActionStreamController.add(MapPoiAction(
              color: PoiIconColor.greyTrans,
              action: PoiAction.add,
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
    if (widget.isUserInNewArea()) {
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

  late mapbox.MapboxMapController _mapController;
  var isLight = true;

  void _extractMapInfo() {
    final position = _mapController!.cameraPosition;
    if (position != null) _cameraPosition = position;
    _isMoving = _mapController!.isCameraMoving;
  }

  void _onMapChanged() {
    setState(() {
      _extractMapInfo();
    });
  }

  mapbox.LatLng _getRelativeCenterLatLng(double zoom) {
    double latPerPx = 360 / math.pow(2, zoom) / 256;
    if (!_userLocationMarkers.isEmpty) {
      return PoisAttributesCalculator.getPointAtAngle(
          _userLocationMarkers[_userStatus.index]
              .locationMarkerInfo
              .latLng
              .latitude,
          _userLocationMarkers[_userStatus.index]
              .locationMarkerInfo
              .latLng
              .longitude,
          latPerPx * (Globals.globalWidgetsSizes.dialogBoxTotalHeight / 4.5),
          (270 - userIconHeading));
    } else {
      return PoisAttributesCalculator.getPointAtAngle(
          widget.userLocation.latitude,
          widget.userLocation.longitude,
          latPerPx * (Globals.globalWidgetsSizes.dialogBoxTotalHeight / 4.5),
          (270 - userIconHeading));
    }
  }

  Future<void> _onMapCreated(mapbox.MapboxMapController controller) async {
    _mapController = controller;

    _userLocationMarkers.add(UserLocationMarkerCar(controller, this,
        (LocationMarkerInfo locationMarkerInfo) {
      userIconHeading = locationMarkerInfo.heading; // heading if user centered
      widget.userHeading = userIconHeading;
      if (_myLocationTrackingMode != mapbox.MyLocationTrackingMode.None) {
        updateCameraByRelativePosition(option: CameraOption.move);
      }
    }));
    _userLocationMarkers.add(UserLocationMarkerFoot(controller, this,
        (LocationMarkerInfo locationMarkerInfo) {
      userIconHeading = locationMarkerInfo.heading; // heading if user centered
      widget.userHeading = userIconHeading;
      if (_myLocationTrackingMode != mapbox.MyLocationTrackingMode.None) {
        updateCameraByRelativePosition(option: CameraOption.move);
      }
    }));

    _mapController.addListener(_onMapChanged);
    _extractMapInfo();
   await _mapController!.getTelemetryEnabled().then((isEnabled) => setState(() {
          _telemetryEnabled = isEnabled;
        }));
  }

  _onStyleLoadedCallback() async {
    _symbolManager =
        mapbox.SymbolManager(_mapController, onTap: (mapbox.Symbol symbol) {
      Globals.globalClickedPoiStream.add(symbol.id);
    });
    _highlightSymbolManager = mapbox.SymbolManager(_mapController,
        iconAllowOverlap: true,
        textAllowOverlap: true, onTap: (mapbox.Symbol symbol) {
      Globals.globalClickedPoiStream.add(symbol.id);
    });
    await _userLocationMarkers[_userStatus.index].start();
    await _mapController.addImage(
        'userLocation', Globals.svgPoiMarkerBytes.userIcon);
    await _mapController.addImage(
        'carLocation', Globals.svgPoiMarkerBytes.carLocationIcon);
    await _mapController.addImage(
        'greyPoi', Globals.svgPoiMarkerBytes.greyIcon);
    await _mapController.addImage(
        'bluePoi', Globals.svgPoiMarkerBytes.blueIcon);
    await _mapController.addImage(
        'greyTransPoi', Globals.svgPoiMarkerBytes.greyTransIcon);
    await _symbolManager.addAll(_symbolsOnMap);
    if (highlightedPoi != null) {
      await _highlightSymbolManager.add(highlightedPoi!.getSymbolFromPoi(PoiIconColor.blue));
    }
  }

  _clearFill() {
    if (_selectedFill != null) {
      _mapController!.removeFill(_selectedFill!);
      setState(() {
        _selectedFill = null;
      });
    }
  }

  _drawFill(List<dynamic> features) async {
    Map<String, dynamic>? feature =
        features.firstWhereOrNull((f) => f['geometry']['type'] == 'Polygon');

    if (feature != null) {
      List<List<mapbox.LatLng>> geometry = feature['geometry']['coordinates']
          .map(
              (ll) => ll.map((l) => LatLng(l[1], l[0])).toList().cast<LatLng>())
          .toList()
          .cast<List<LatLng>>();
      mapbox.Fill fill = await _mapController!.addFill(mapbox.FillOptions(
        geometry: geometry,
        fillColor: "#FF0000",
        fillOutlineColor: "#FF0000",
        fillOpacity: 0.6,
      ));
      setState(() {
        _selectedFill = fill;
      });
    }
  }

  void _onMapDrag(DragUpdateDetails details) {
    _myLocationTrackingMode = mapbox.MyLocationTrackingMode.None;
    updateState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    map = createMapboxMap(_mapboxUniqueKey);
    return Stack(children: [
      map,
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
                widget.isScanning
                    ? Container(
                        color: Colors.transparent,
                        alignment: Alignment.bottomRight,
                        margin: EdgeInsets.only(
                            right: width / 60),
                        height: width / 10,
                        width: width / 10,
                        child: LoadingAnimationWidget.threeArchedCircle(
                          size: 30,
                          color: Colors.blue,
                        ))
                    : Container(),
                Container(
                  margin: EdgeInsets.only(
                      top: width / 20,
                      right: width / 40),
                  width: width / 10,
                  child: FloatingActionButton(
                    heroTag: null,
                    onPressed: () {
                      _symbolManager.dispose();
                      _styleStringIndex =
                          (_styleStringIndex + 1) % _styleStrings.length;
                      updateState();
                    },
                    child: const Icon(
                      Icons.map_outlined,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                margin: EdgeInsets.only(
                    top: height / 90,
                    left: width / 40),
                width: width / 10,
                child: _myLocationTrackingMode ==
                        mapbox.MyLocationTrackingMode.None
                    ? FloatingActionButton(
                        heroTag: null,
                        onPressed: () {
                          _myLocationTrackingMode =
                              mapbox.MyLocationTrackingMode.Tracking;
                          updateCameraByRelativePosition();
                        },
                        child: const Icon(
                          Icons.my_location,
                          color: Colors.white,
                        ),
                      )
                    : null,
              ),
              Container(
                margin: EdgeInsets.only(
                    top: height / 90,
                    right: width / 40),
                width: width / 10,
                child: FloatingActionButton(
                  heroTag: null,
                  onPressed: () async {
                      await _userLocationMarkers[_userStatus.index].stop();
                      _userStatus =
                          UserStatus.values[(_userStatus.index + 1) % 2];
                      await _userLocationMarkers[_userStatus.index].start();
                      updateState();
                  },
                  child: Icon(
                    _userStatus == UserStatus.walking
                        ? Icons.directions_walk
                        : Icons.drive_eta_sharp,
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
    ]);
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
}
