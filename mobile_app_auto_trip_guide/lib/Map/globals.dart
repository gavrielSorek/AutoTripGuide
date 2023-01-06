import 'dart:async';
import 'dart:collection';
import 'dart:ffi';
import 'package:final_project/Map/types.dart';
import 'package:final_project/Map/server_communication.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../Pages/login_controller.dart';
import 'apps_launcher.dart';
import 'audio_player_controller.dart';
import 'map.dart';

class Globals {
  static UserMap globalUserMap = UserMap();
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

  // static List<Widget> globalPagesList = [HomePage(), AccountPage(), HistoryPage()];
  static var globalColor = Color.fromRGBO(51, 153, 255, 0.8);
  static StreamController<VisitedPoi> globalVisitedPoiStream =
      StreamController<VisitedPoi>.broadcast();
  static final globalAudioApp = AudioApp();
  static StreamController<MapPoi> globalClickedPoiStream =
      StreamController<MapPoi>.broadcast();
  static String? svgMarkerString;

  static void setGlobalVisitedPoisList(List<VisitedPoi> visitedPoisList) {
    globalVisitedPoi = visitedPoisList;
  }

  static void addGlobalVisitedPoi(VisitedPoi visitedPoi) {
    globalVisitedPoi.add(visitedPoi);
    globalVisitedPoiStream.add(visitedPoi);
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

  static init() async {
    // initialization order is very important
    await UserMap.mapInit();
    globalAllPois.clear();
    globalUnhandledKeys.clear();
    mainMapPoi = null;
    globalUserInfoObj = null;
    svgMarkerString =
        await rootBundle.loadString('assets/images/mapMarker.svg');
  }

  static clearAll() async {
    // TODO add members to close
    globalAllPois.clear();
    globalUnhandledKeys.clear();
    mainMapPoi = null;
    globalUserInfoObj = null;
  }
}
