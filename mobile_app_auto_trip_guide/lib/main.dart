import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:final_project/Pages/home_page.dart';
import 'package:location/location.dart';
import 'Map/globals.dart';
import 'Map/map.dart';
import 'Pages/login_page.dart';

// inits

Future<void> init() async {
  // initialization order is very important
  await Globals.init();
}

// start logic
void main() async {
  HttpOverrides.global = MyHttpOverrides();
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
        primarySwatch: Colors.green,
      ),
      home: LoginPage(),   //const HomePage()
    );
  }
}



// for the problem 	CERTIFICATE_VERIFY_FAILED: certificate has expired(handshake.cc:393)
class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext? context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}