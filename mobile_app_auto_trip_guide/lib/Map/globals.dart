import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'package:final_project/Map/types.dart';
import 'package:final_project/Map/server_communication.dart';
import 'package:final_project/Utils/appEvents.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../General Wigets/generals.dart';
import 'background_audio_player.dart';
import '../Pages/login_controller.dart';
import 'apps_launcher.dart';
import 'map.dart';

class Globals {
  static double globalScreenHeight = 0;
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
  static StreamController<VisitedPoi> globalVisitedPoiStream =
      StreamController<VisitedPoi>.broadcast();
  static StreamController<String> globalClickedPoiStream =
      StreamController<String>.broadcast();
  static String? svgMarkerString;
  static IconsBytesHolder svgPoiMarkerBytes = IconsBytesHolder();
  static SharedPreferences? globalPrefs;
  static late AppEvents appEvents;
  static late Mixpanel mixpanel;


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

  static init(BuildContext context) async {
    // initialization order is very important
    mixpanel = await Mixpanel.init("cb8330c185f7677aac8efe418058e344", trackAutomaticEvents: true);
    appEvents = new AppEvents(email:'unknownUser@gmail.com');
    await appEvents.init();
    await globalUserMap.mapInit(context);
    globalPrefs = await SharedPreferences.getInstance();
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
    await globalController.init();
    if (globalController.isUserSignIn) {
      await globalController.login();
      Globals.appEvents.signInCompleted('success');
      await loadUserDetails();
      if(globalUserInfoObj != null && globalUserInfoObj!.emailAddr != null){
       appEvents.email = globalUserInfoObj!.emailAddr!;
      }
    }
  }

  static clearAll() async {
    // TODO add members to close
    globalAllPois.clear();
    globalUnhandledKeys.clear();
    mainMapPoi = null;
    globalUserInfoObj = null;
  }

  static stopAll() async {
    await globalUserMap.stopAll();
    globalGuideAudioPlayerHandler.stop();
  }

  static loadUserDetails() async {
    Globals.globalEmail =
        Globals.globalController.googleAccount.value?.email ?? ' ';
    Globals.globalServerCommunication.addNewUser(UserInfo(
        Globals.globalController.googleAccount.value?.displayName ?? ' ',
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
        Globals.globalController.googleAccount.value?.email ?? ' '));
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
