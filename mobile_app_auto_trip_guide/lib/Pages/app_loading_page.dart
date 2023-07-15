import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

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
    final bool? isIntroDone = Globals.globalPrefs?.getBool('introDone');
    String initialRoute;

    if(isIntroDone == null ) {
      Globals.appEvents.introStarted();
      initialRoute = '/onboard-screen';
    } else if(Globals.globalController.isUserSignIn){
      initialRoute = '/HomePage';
    } else {
      initialRoute = '/login-screen';
    }

    Navigator.pop(context);
    Navigator.pushNamed(context, initialRoute);
   }

  @override
  Widget build(BuildContext context) {
    return LoadingAppWidget();
  }
}

class LoadingAppWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          color: Color.fromRGBO(10, 132, 255, 1),
        ),
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Image.asset(
                'assets/images/logo_white.png',
                width: 280,
                height: 280,
              ),
              Shimmer.fromColors(
                baseColor: Colors.white.withOpacity(0.3),  // stronger base color
                highlightColor: Colors.black38,
                period: Duration(milliseconds: 2000),  // slower speed
                child: Image.asset(
                  'assets/images/logo_white.png',  // your png asset
                  width: 280,
                  height: 280,
                ),
              ),
              Positioned(
                bottom: 30.0,
                child: Text(
                  'Discover on the go!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color.fromRGBO(255, 255, 255, 1),
                    fontFamily: 'Inter',
                    fontSize: 19,
                    letterSpacing: 0.3499999940395355,
                    fontWeight: FontWeight.normal,
                    height: 1.4736842105263157,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
