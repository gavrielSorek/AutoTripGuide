import 'dart:io';

import 'package:flutter/material.dart';
import 'package:final_project/Pages/home_page.dart';
import 'package:location/location.dart';

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
  // UserMap.locationChangedEvent(UserMap.USER_LOCATION_DATA!);
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
