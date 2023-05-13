import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../Map/globals.dart';

class AppInitializationPage extends StatefulWidget {
  const AppInitializationPage({Key? key}) : super(key: key);

  @override
  _AppInitializationPageState createState() => _AppInitializationPageState();
}

class _AppInitializationPageState extends State<AppInitializationPage> {
  @override
  void initState() {
    super.initState();
    initApp();
  }

  Future<void> initApp() async {
    await Globals.init(context);
    nextPage();
  }

  void nextPage() {
    String initialRoute;
    if (Globals.globalController.isUserSignIn) {
      initialRoute = '/HomePage';
    } else {
      final bool? isIntroDone = Globals.globalPrefs?.getBool('introDone');
      isIntroDone != null ? '' : Globals.appEvents.introStarted();
      initialRoute = isIntroDone != null ? '/login-screen' : '/onboard-screen';
    }
    Navigator.pop(context);
    Navigator.pushNamed(context, initialRoute);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.blue,
        child: Center(
          child: SpinKitRotatingCircle(
            color: Colors.white,
            size: 50.0,
          ),
        ),
      ),
    );
  }
}
