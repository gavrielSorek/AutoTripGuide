import 'dart:async';
import 'package:final_project/General%20Wigets/menu.dart';
import 'package:final_project/Map/globals.dart';
import 'package:final_project/Map/map_configuration.dart';
import 'package:final_project/Map/pois_attributes_calculator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:final_project/Map/types.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:mapbox_gl/mapbox_gl.dart' as mapbox;
import '../General Wigets/UniversalPanGestureRecognizer.dart';
import 'guide.dart';
import 'package:flutter/foundation.dart';
import 'dart:math' as math;

enum MarkersLayer { semiTransparent, grey, blue }

enum PoiAction { add, remove }

class MapPoiAction {
  PoiIconColor color;
  PoiAction action;
  MapPoi mapPoi;

  MapPoiAction(
      {required this.color, required this.action, required this.mapPoi});
}

class UserMap extends StatefulWidget {
  bool showLoadingPoisAnimation = false;

  // inits
  static late Position USER_LOCATION;

  // the last known location of the user in the old area - for new pois purposes
  static late Position LAST_AREA_USER_LOCATION;
  static double DISTANCE_BETWEEN_AREAS = 1000; //1000 meters
  static List userChangeLocationFuncs = [];
  StreamController<MapPoiAction> mapPoiActionStreamController =
      StreamController<MapPoiAction>.broadcast();
  StreamController<MapPoi> highlightedPoiStreamController =
      StreamController<MapPoi>.broadcast();

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
    highlightedPoiStreamController.add(mapPoi);
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

  void setMapPoiOnLayer(MapPoiAction mapPoiAction) {
    mapPoiActionStreamController.add(mapPoiAction);
  }
}

class _UserMapState extends State<UserMap> {
  late StreamSubscription mapPoiActionSubscription;
  GuideData guideData = GuideData();
  late Guide guideTool;
  WidgetVisibility navButtonState = WidgetVisibility.hide;
  WidgetVisibility loadingPois = WidgetVisibility.view;
  MapPoi? highlightedPoi;
  double mapHeading = 0;
  bool isNewPoisNeededFlag = true;
  int _numOfPoisRequests = 0;

  // at new area the we snooze to the server in order to seek new pois
  static int NEW_AREA_SNOOZE = 7;

  // at new area the we snooze to the server in order to seek new pois
  static int SECONDS_BETWEEN_SNOOZES = 15;

  // mapbox variables
  late mapbox.MapboxMap map;
  late mapbox.CameraPosition _cameraPosition;
  bool _isMoving = false;
  bool _compassEnabled = true;
  mapbox.CameraTargetBounds _cameraTargetBounds =
      mapbox.CameraTargetBounds.unbounded;
  mapbox.MinMaxZoomPreference _minMaxZoomPreference =
      mapbox.MinMaxZoomPreference.unbounded;
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

  mapbox.MyLocationTrackingMode _myLocationTrackingMode =
      mapbox.MyLocationTrackingMode.Tracking;
  List<Object>? _featureQueryFilter;
  mapbox.Fill? _selectedFill;

  _UserMapState() : super() {
    UserMap.userChangeLocationFuncs.add(onLocationChanged);
    double initialZoom = 15;
    _cameraPosition = mapbox.CameraPosition(
        target: _getRelativeCenterLatLng(initialZoom),
        bearing: mapHeading,
        zoom: initialZoom);
  }

  void updateState() {
    setState(() {});
  }

  Future<void> setMapPoiAction(MapPoiAction mapPoiAction) async {
    if (mapPoiAction.action == PoiAction.add) {
      mapbox.Symbol symbolToAdd =
          mapPoiAction.mapPoi.getSymbolFromPoi(mapPoiAction.color);
      _symbolManager.add(symbolToAdd);
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

  // given distance in pixels and distance in meters, return the zoom such that distInPixels = distInMeters
  double _getZoomLevel(
      double distInPixels, double distInMeters, double latitude) {
    // Calculate the pixel density (i.e. how many meters each pixel represents)
    double metersPerPixel = distInMeters / distInPixels;
    // zoom calculation
    double zoom = (math.log(156543.03392 *
            math.cos(latitude * math.pi / 180) /
            metersPerPixel) /
        math.log(2));
    return zoom.floor().toDouble();
  }

  Future<double> _getZoomPointInDistFromUser(
      double maxDistInPixels, mapbox.LatLng point) async {
    double distanceInMeters = await Geolocator.distanceBetween(
      UserMap.USER_LOCATION.latitude, // latitude of first location
      UserMap.USER_LOCATION.longitude, // longitude of first location
      point.latitude, // latitude of second location
      point.longitude, // longitude of second location
    );

    return _getZoomLevel(
        maxDistInPixels, distanceInMeters, UserMap.USER_LOCATION.latitude);
  }

  @override
  void initState() {
    mapPoiActionSubscription =
        widget.mapPoiActionStreamController.stream.listen((event) {
      setMapPoiAction(event);
      updateState();
    });
    print("init _UserMapState");
    guideTool = Guide(context, guideData);

    widget.highlightedPoiStreamController.stream.listen((event) async {
      if (highlightedPoi != null) {
        widget.mapPoiActionStreamController.add(MapPoiAction(
            color: PoiIconColor.grey,
            action: PoiAction.add,
            mapPoi: highlightedPoi!));
      }
      highlightedPoi = event;
      widget.mapPoiActionStreamController.add(MapPoiAction(
          color: PoiIconColor.blue,
          action: PoiAction.add,
          mapPoi: highlightedPoi!));

      _cameraPosition = mapbox.CameraPosition(
          target: _cameraPosition.target,
          // TODO calculate maxDistInPixels
          zoom: await _getZoomPointInDistFromUser(
              (MediaQuery.of(context).size.height -
                      Globals.globalWidgetsSizes.dialogBoxTotalHeight) /
                  4.75,
              mapbox.LatLng(highlightedPoi!.poi.latitude,
                  highlightedPoi!.poi.longitude)));
      _mapController.animateCamera(
        mapbox.CameraUpdate.newCameraPosition(
          mapbox.CameraPosition(
              target: _getRelativeCenterLatLng(_cameraPosition.zoom),
              bearing: mapHeading,
              zoom: _cameraPosition.zoom),
        ),
      );
    });
    super.initState();
  }

  @override
  void dispose() {
    print("____________________dispose statful map");
    mapPoiActionSubscription.cancel();
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
    return PoisAttributesCalculator.getPointAtAngle(
        UserMap.USER_LOCATION.latitude,
        UserMap.USER_LOCATION.longitude,
        latPerPx * (Globals.globalWidgetsSizes.dialogBoxTotalHeight / 4.5),
        (270 - mapHeading));
  }

  Future<void> _onMapCreated(mapbox.MapboxMapController controller) async {
    _mapController = controller;
    _mapController.addListener(_onMapChanged);
    _extractMapInfo();
    _mapController!.getTelemetryEnabled().then((isEnabled) => setState(() {
          _telemetryEnabled = isEnabled;
        }));

    LocationMarkerDataStreamFactory()
        .fromCompassHeadingStream()
        .listen((event) async {
      if (_myLocationTrackingMode == mapbox.MyLocationTrackingMode.None) {
        return;
      }
      final double epsilon = 2;
      double newHeading = event!.heading / pi * 180;
      if ((newHeading - mapHeading).abs() < epsilon) return;
      mapHeading = newHeading;

      _mapController.animateCamera(
        mapbox.CameraUpdate.newCameraPosition(
          mapbox.CameraPosition(
              target: _getRelativeCenterLatLng(_cameraPosition.zoom),
              bearing: mapHeading,
              zoom: _cameraPosition.zoom),
        ),
      );
    });
  }

  _onStyleLoadedCallback() async {
    _symbolManager = mapbox.SymbolManager(_mapController,
        iconAllowOverlap: true, onTap: (mapbox.Symbol symbol) {
      Globals.globalClickedPoiStream.add(symbol.id);
    });
    await _mapController.addImage(
        'greyPoi', Globals.svgPoiMarkerBytes.greyIcon);
    await _mapController.addImage(
        'bluePoi', Globals.svgPoiMarkerBytes.blueIcon);
    await _mapController.addImage(
        'greyTransPoi', Globals.svgPoiMarkerBytes.greyTransIcon);
    await _symbolManager.addAll(_symbolsOnMap);
    _mapController.setSymbolIconAllowOverlap(true);
    _mapController.setSymbolIconIgnorePlacement(true);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Style loaded :)"),
      backgroundColor: Theme.of(context).primaryColor,
      duration: Duration(seconds: 1),
    ));
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
  }

  @override
  Widget build(BuildContext context) {
    UniversalPanGestureRecognizer _panGestureRecognizer =
        UniversalPanGestureRecognizer(
      onUpdate: (details) {
        _onMapDrag(details);
      },
    );
    print("hello from build map");
    map = mapbox.MapboxMap(
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
      myLocationEnabled: _myLocationEnabled,
      myLocationTrackingMode: mapbox.MyLocationTrackingMode.None,
      myLocationRenderMode: mapbox.MyLocationRenderMode.COMPASS,
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
      onUserLocationUpdated: (location) {
        print(
            "new location: ${location.position}, alt.: ${location.altitude}, bearing: ${location.bearing}, speed: ${location.speed}, horiz. accuracy: ${location.horizontalAccuracy}, vert. accuracy: ${location.verticalAccuracy}");
      },
      onStyleLoadedCallback: _onStyleLoadedCallback,
    );

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                margin: EdgeInsets.only(
                    top: MediaQuery.of(context).size.width / 20,
                    left: MediaQuery.of(context).size.width / 40),
                width: MediaQuery.of(context).size.width / 10,
                child: FloatingActionButton(
                  heroTag: null,
                  onPressed: () {
                    if (_myLocationTrackingMode !=
                        mapbox.MyLocationTrackingMode.Tracking) {
                      _myLocationTrackingMode =
                          mapbox.MyLocationTrackingMode.Tracking;
                    }
                  },
                  child: const Icon(
                    Icons.my_location,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(
                    top: MediaQuery.of(context).size.width / 20,
                    right: MediaQuery.of(context).size.width / 40),
                width: MediaQuery.of(context).size.width / 10,
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
