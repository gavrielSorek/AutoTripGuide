import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'package:journ_ai/Map/types.dart';
import 'package:journ_ai/Map/server_communication.dart';
import 'package:journ_ai/Utils/appEvents.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../General/generals.dart';
import '../Utils/BufferedStream.dart';
import 'background_audio_player.dart';
import '../Pages/login_controller.dart';
import 'apps_launcher.dart';
import 'map.dart';
enum LoginMethod {
  GOOGLE,
  APPLE,
}
class Globals {
  static Sizes globalWidgetsSizes = Sizes();
  static final GlobalKey<UserMapState> globalUserMapKey = GlobalKey();
  static UserMap globalUserMap = UserMap(key: globalUserMapKey,);
  static ServerCommunication globalServerCommunication = ServerCommunication();
  static Map<String, MapPoi> globalAllPois = HashMap<String, MapPoi>();
  static List<String> globalUnhandledKeys = [];
  static String globalDefaultLanguage = "eng";
  static String globalEmail = "";
  static Map<String, List<String>>? globalCategories;
  static List<String> globalFavoriteCategories = [];
  static Set<String> favoriteCategoriesSet = <String>{};
  static UserInfo? globalUserInfoObj;
  static List<VisitedPoi> globalVisitedPoi = [];
  static AppLauncher globalAppLauncher = AppLauncher();
  static MapPoi? mainMapPoi; // spoken poi
  static final globalController = Get.put(LoginController());
  static late BackgroundAudioHandler globalGuideAudioPlayerHandler; // the initialization is in the main
  static var globalColor = Color.fromRGBO(51, 153, 255, 0.8);
  static BufferedStream<String> globalsIdsFromDeepLinksBuffer = BufferedStream<String>(); // saves pois id deep links
  static StreamController<VisitedPoi> globalVisitedPoiStream =
      StreamController<VisitedPoi>.broadcast();
  static StreamController<String> globalClickedPoiStream =
      StreamController<String>.broadcast();
  static String? svgMarkerString;
  static IconsBytesHolder svgPoiMarkerBytes = IconsBytesHolder();
  static late AppEvents appEvents;
  static late Mixpanel mixpanel;
  static bool isUserSignIn = false;

  static void setGlobalVisitedPoisList(List<VisitedPoi> visitedPoisList) {
    globalVisitedPoi = visitedPoisList;
  }

  static void addGlobalVisitedPoi(VisitedPoi visitedPoi) {
    globalVisitedPoi.removeWhere((visitedPoiInList) => visitedPoi.id == visitedPoiInList.id);
    globalVisitedPoi.add(visitedPoi);
    globalVisitedPoiStream.add(visitedPoi);
    globalServerCommunication.insertPoiToHistory(visitedPoi);
  }
  

  static void addUnhandledPoiKey(String key) {
    if (globalUnhandledKeys.isEmpty) {
      globalUserMap.userMapState?.loadingPois = WidgetVisibility.hide;
    }
    globalUnhandledKeys.add(key);
  }

  static void removeUnhandledPoiKey(int index) {
    globalUnhandledKeys.removeAt(index);
    if (globalUnhandledKeys.isEmpty) {
      globalUserMap.userMapState?.loadingPois = WidgetVisibility.view;
    }
  }

  static setFavoriteCategories(List<String> newFavoriteCategories) {
    globalFavoriteCategories = newFavoriteCategories;
    favoriteCategoriesSet = newFavoriteCategories.toSet();
  }

  static setMainMapPoi(var mapPoi) {
    if (Globals.globalUserMap.userMapState != null && mapPoi != null) {
      Globals.globalUserMap.userMapState!.showNavButton();
    }
    mainMapPoi = mapPoi;
  }

  static deleteMainMapPoi() {
    if (Globals.globalUserMap.userMapState != null) {
      Globals.globalUserMap.userMapState!.hideNavButton();
    }
    mainMapPoi = null;
  }

  // should executed first - soon as possible
  static preInit() async {
    mixpanel = await Mixpanel.init("cb8330c185f7677aac8efe418058e344", trackAutomaticEvents: true);
    appEvents = new AppEvents(email:'unknownUser@gmail.com');
  }

  static init(BuildContext context) async {
    // initialization order is very important
    await appEvents.init();
    await globalUserMap.mapInit(context);
    globalAllPois.clear();
    globalUnhandledKeys.clear();
    mainMapPoi = null;
    globalUserInfoObj = null;
    svgMarkerString =
        await rootBundle.loadString('assets/images/mapMarker.svg');
    svgPoiMarkerBytes.userIcon = await Generals.loadSvgStringAsUint8List(await rootBundle.loadString('assets/images/location_marker.svg'));
    svgPoiMarkerBytes.carLocationIcon = await Generals.loadSvgStringAsUint8List(await rootBundle.loadString('assets/images/car_location_marker.svg'));
    svgPoiMarkerBytes.greyIcon = (await Generals.poiIconSvgStringToUint8List(Colors.grey))!;
    svgPoiMarkerBytes.blueIcon = (await Generals.poiIconSvgStringToUint8List(Colors.blue))!;
    svgPoiMarkerBytes.greyTransIcon = (await Generals.poiIconSvgStringToUint8List(Colors.grey.withOpacity(0.40)))!;


    await globalGuideAudioPlayerHandler.initAudioPlayer();
    // check if user is signed in or not
    var lastLoginMethod = (await SharedPreferences.getInstance()).getString('lastLoginMethod');
    switch(lastLoginMethod){
      case 'GOOGLE':
          Globals.appEvents.signIn('google');
          await globalController.login();
          await loadUserDetails();
          isUserSignIn = true;
          Globals.appEvents.email = globalUserInfoObj!.emailAddr!;
          appEvents.email = globalUserInfoObj!.emailAddr!;
          Globals.appEvents.signInCompleted('success');
          break;
      case 'APPLE':
          Globals.appEvents.signIn('apple');
          var userIdentifier = (await SharedPreferences.getInstance()).getString('userIdentifier');
          var credential = await SignInWithApple.getCredentialState(userIdentifier ?? '');
          if(credential == CredentialState.authorized){
            var email = (await SharedPreferences.getInstance()).getString('userEmail');
            var userName = (await SharedPreferences.getInstance()).getString('userName');
            await loadUserDetails(loginMethod: LoginMethod.APPLE,userEmail: email,userName: userName);
            Globals.appEvents.email = email!;
            appEvents.email = email!;
            Globals.appEvents.signInCompleted('success');
            isUserSignIn = true;
            
          } else{
           (await SharedPreferences.getInstance()).remove('userIdentifier');
           (await SharedPreferences.getInstance()).remove('lastLoginMethod');
          }
          break;
    }

  }

  static clearAll() async {
    // TODO add members to close
    globalAllPois.clear();
    globalUnhandledKeys.clear();
    mainMapPoi = null;
    globalUserInfoObj = null;
    globalsIdsFromDeepLinksBuffer.clear();
  }

  static stopAll() async {
    await globalUserMap.stopAll();
    globalGuideAudioPlayerHandler.stop();
  }

  static loadUserDetails({loginMethod = LoginMethod.GOOGLE,userEmail='',userName=''}) async {
    var email = '';
    var displayName = '';
    if(loginMethod == LoginMethod.GOOGLE){
      email = globalController.googleAccount.value?.email ?? ' ';
      displayName = globalController.googleAccount.value?.displayName ?? ' ';
    } else if(loginMethod == LoginMethod.APPLE){
      email = userEmail;
      displayName = userName;
    }
    Globals.globalEmail = email;
    Globals.globalServerCommunication.addNewUser(UserInfo(
        displayName,
        Globals.globalEmail,
        ' ',
        ' ',
        ' ',
        Globals.globalFavoriteCategories));

    if (Globals.globalUserInfoObj == null) {
      Map<String, String> userInfo = await Globals.globalServerCommunication
          .getUserInfo(Globals.globalEmail);
      Globals.globalUserInfoObj = UserInfo(
          userInfo["name"],
          Globals.globalEmail,
          userInfo["gender"] ?? " ",
          userInfo["languages"] ?? " ",
          userInfo["age"],
          Globals.globalFavoriteCategories);
    }
    Globals.globalCategories ??= await Globals.globalServerCommunication
        .getCategories(Globals.globalDefaultLanguage);
    Globals.setFavoriteCategories(await Globals.globalServerCommunication
        .getFavorCategories(
        email ?? ' '));
    Globals.setGlobalVisitedPoisList(await Globals.globalServerCommunication
        .getPoisHistory(Globals.globalEmail));
  }
  static exitApp() async{
    await Globals.globalGuideAudioPlayerHandler.stop();
    exit(0);
  }
}

// sizes of widgets
class Sizes {
  double _dialogBoxTotalHeight = 0;

  double get poiGuideBoxTotalHeight {
    return this._dialogBoxTotalHeight;
  }

  void set poiGuideBoxTotalHeight(double dialogBoxHeight) {
    _dialogBoxTotalHeight = dialogBoxHeight;
  }
}
