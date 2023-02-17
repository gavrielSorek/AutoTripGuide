import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../Map/globals.dart';

class AppLoadingPage extends StatelessWidget {
  BuildContext? context;

  AppLoadingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    this.context = context;
    return Scaffold(
      body: Container(
        color: Colors.blue,
        child: SpinKitRotatingCircle(
          color: Colors.white,
          size: 50.0,
        ),
      ),
    );
  }

  void nextPage() {
    String initialRoute;
    if (Globals.globalController.isUserSignIn) {
      initialRoute = '/HomePage';
    } else {
      final bool? isIntroDone = Globals.globalPrefs?.getBool('introDone');
      initialRoute = isIntroDone != null ? '/login-screen' : '/onboard-screen';
    }
    Navigator.pop(context!);
    Navigator.pushNamed(context!, initialRoute);
  }
}
