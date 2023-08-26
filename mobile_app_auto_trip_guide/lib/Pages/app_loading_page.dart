import 'package:flutter/material.dart';
import 'package:journ_ai/Map/server_communication.dart';
import 'package:journ_ai/Pages/upgrade_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

import '../Map/globals.dart';
import '../Utils/app_info.dart';
import 'critical_error_page.dart';
import 'internet_connection_page.dart';

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
    await InternetUtils.checkAndRequestInternetConnection(context); //must verify internet connectivity before all
    try {
      UpdateStatus upgradeStatus = await AppInfo.getUpdateStatus();
      // if update exists
      if (upgradeStatus != UpdateStatus.notRequired) {
        // Show the upgrading screen
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => UpgradePage(upgradeStatus)),
        );
      }
      await Globals.preInit();
      bool? isIntroDone = (await SharedPreferences.getInstance()).getBool('introDone');
      if (isIntroDone == null)
        {
          Globals.appEvents.introStarted();
          await Navigator.pushNamed(context, '/onboard-screen');
        }
      nextPage();
    } catch (error) {
      debugPrint(error.toString());
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CriticalErrorPage()),
      );
    };
  }

  Future<void> nextPage() async {
    await Globals.init(context);

    String route;
   if( Globals.isUserSignIn ){
      route = '/HomePage';
    } else {
      route = '/login-screen';
    }
    Navigator.of(context).pushNamedAndRemoveUntil(
        route, (Route<dynamic> route) => false);
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
