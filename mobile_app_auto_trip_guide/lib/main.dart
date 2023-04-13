import 'dart:io';
import 'package:final_project/Map/background_audio_player.dart';
import 'package:final_project/Pages/history_page.dart';
import 'package:final_project/Pages/home_page.dart';
import 'package:final_project/Pages/app_loading_page.dart';
import 'package:final_project/Pages/personal_details_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'Map/globals.dart';
import 'Map/onboarding.dart';
import 'Pages/favorite_categories_page.dart';
import 'Pages/login_page.dart';
import 'dart:math';
import 'package:audio_service/audio_service.dart';

// start logic
Future<void> main() async {
  HttpOverrides.global = MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();
  // store this in a singleton
  Globals.globalGuideAudioPlayerHandler = await AudioService.init(
    builder: () => BackgroundAudioHandler(),
    config: AudioServiceConfig(
      androidNotificationChannelId: 'com.mycompany.myapp.channel.audio',
      androidNotificationChannelName: 'Audio playback',
      androidNotificationOngoing: true,
    ),
  );
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown])
      .then((_) {
    runApp(const AutoGuideApp());
  });
}

class AutoGuideApp extends StatelessWidget {
  const AutoGuideApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AppLoadingPage initializationPage = AppLoadingPage();
    if (!Globals.globalIsInitialized) {
      Globals.init().then((result) {
        initializationPage.nextPage();
      });
    }

    return MaterialApp(
      title: 'Auto Trip Guide',
      theme: ThemeData(
        primarySwatch: generateMaterialColor(Globals.globalColor),
        fontFamily: 'Roboto',
      ),
      initialRoute: '/init-screen',
      routes: {
        // When navigating to the "/" route, build the FirstScreen widget.
        '/login-screen': (context) => LoginPage(),
        '/HomePage': (context) => HomePage(),
        '/history-screen': (context) => HistoryPage(),
        '/favorite-categories-screen': (context) => FavoriteCategoriesPage(),
        '/personal-details-screen': (context) => PersonalDetailsPage(),
        '/onboard-screen': (context) => OnBoardingPage(),
        '/init-screen': (context) => initializationPage
      },
      // routes: {'/': (BuildContext ctx) => HomePage()}
    );
  }
}

// for the problem 	CERTIFICATE_VERIFY_FAILED: certificate has expired(handshake.cc:393)
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

MaterialColor generateMaterialColor(Color color) {
  return MaterialColor(color.value, {
    50: tintColor(color, 0.9),
    100: tintColor(color, 0.8),
    200: tintColor(color, 0.6),
    300: tintColor(color, 0.4),
    400: tintColor(color, 0.2),
    500: color,
    600: shadeColor(color, 0.1),
    700: shadeColor(color, 0.2),
    800: shadeColor(color, 0.3),
    900: shadeColor(color, 0.4),
  });
}

int tintValue(int value, double factor) =>
    max(0, min((value + ((255 - value) * factor)).round(), 255));

Color tintColor(Color color, double factor) => Color.fromRGBO(
    tintValue(color.red, factor),
    tintValue(color.green, factor),
    tintValue(color.blue, factor),
    1);

int shadeValue(int value, double factor) =>
    max(0, min(value - (value * factor).round(), 255));

Color shadeColor(Color color, double factor) => Color.fromRGBO(
    shadeValue(color.red, factor),
    shadeValue(color.green, factor),
    shadeValue(color.blue, factor),
    1);
