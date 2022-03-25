import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:final_project/Map/locationTypes.dart';
import 'package:final_project/Map/events.dart';


// inits
Location? USER_LOCATION;
LocationData? USER_LOCATION_DATA;

Future<void> init() async {
  USER_LOCATION = await getLocation();
  USER_LOCATION_DATA = await USER_LOCATION!.getLocation();
  USER_LOCATION!.onLocationChanged.listen(locationChangedEvent);
}

// start logic
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await init();
  runApp(const AutoGuideApp());
}

class AutoGuideApp extends StatelessWidget {
  const AutoGuideApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Auto Trip Guide'), centerTitle: true),
        body: Column(
          children: [
            Expanded(
                child: Container(
              child: UserMap(),
            )),
            Row( // menu row
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  child: const ElevatedButton(onPressed: mapButtonClickedEvent, child: Icon(Icons.map),
                  ),
                  height: MediaQuery.of(context).size.height / 11,
                  width: MediaQuery.of(context).size.width / 4,
                  color: Colors.cyan,
                ),
                Container(
                  child: const ElevatedButton(onPressed: accountButtonClickedEvent, child: Icon(Icons.account_box_outlined),
                  ),
                  height: MediaQuery.of(context).size.height / 11,
                  width: MediaQuery.of(context).size.width / 4,
                  color: Colors.cyan,
                ),
                Container(
                  child: const ElevatedButton(onPressed: reviewsButtonClickedEvent, child: Icon(Icons.rate_review),
                  ),
                  height: MediaQuery.of(context).size.height / 11,
                  width: MediaQuery.of(context).size.width / 4,
                  color: Colors.cyan,
                ),
                Container(
                  child: const ElevatedButton(onPressed: settingButtonClickedEvent, child: Icon(Icons.settings),
                  ),
                  height: MediaQuery.of(context).size.height / 11,
                  width: MediaQuery.of(context).size.width / 4,
                  color: Colors.cyan,
                ),
              ],
            )
          ],
        )
        );
  }
}

class UserMap extends StatefulWidget {
  const UserMap({Key? key}) : super(key: key);

  @override
  _UserMapState createState() => _UserMapState();
}

class _UserMapState extends State<UserMap> {
  List<Marker> markersList = [
    Marker(
        width: 45.0,
        height: 45.0,
        point: LatLng(USER_LOCATION_DATA!.latitude ?? 0.0,
            USER_LOCATION_DATA!.longitude ?? 0.0),
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

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
        options: MapOptions(
            center: LatLng(USER_LOCATION_DATA!.latitude ?? 0.0,
                USER_LOCATION_DATA!.longitude ?? 0.0),
            minZoom: 5.0),
        layers: [
          TileLayerOptions(
              urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
              subdomains: ['a', 'b', 'c']),
          MarkerLayerOptions(markers: markersList)
        ]);
  }
}

Future<Location?> getLocation() async {
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

void locationChangedEvent(LocationData currentLocation) {
  USER_LOCATION_DATA = currentLocation;
  // TODO change user marker
}
