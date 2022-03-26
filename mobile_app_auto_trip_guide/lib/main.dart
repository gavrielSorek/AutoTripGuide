import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:final_project/Map/location_types.dart';
import 'package:final_project/Map/events.dart';
import 'package:final_project/Map/server_communication.dart';
import 'Map/map.dart';


// inits

Future<void> init() async {
  // initialization order is very important
  await UserMap.mapInit();

}
// start logic
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await init();
  runApp(const AutoGuideApp());

  // check
  // sleep(const Duration(seconds:10));
  // print('sleep finished');
  // locationChangedEvent(USER_LOCATION_DATA!);
}

class AutoGuideApp extends StatelessWidget {
  const AutoGuideApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.green,
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
              child: UserMap.USER_MAP,
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
