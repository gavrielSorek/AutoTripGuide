import 'dart:collection';
import 'package:final_project/Map/audio_player_controller.dart';
import 'package:final_project/Map/types.dart';
import 'package:final_project/Map/server_communication.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import '../Pages/login_controller.dart';
import 'apps_launcher.dart';
import 'map.dart';

class Globals {
  static UserMap globalUserMap = UserMap();
  static ServerCommunication globalServerCommunication = ServerCommunication();
  static AudioApp globalAudioPlayer = AudioApp();
  static Map globalAllPois = HashMap<String, MapPoi>();
  static List<String> globalUnhandledKeys = [];
  static Map globalPoisIdToMarkerIdx = HashMap<String, int>();
  static String globalDefaultLanguage = "eng";
  static String globalEmail = "";
  static Map<String, List<String>>? globalCategories;
  static List<String> globalFavoriteCategories = [];
  static Set<String> favoriteCategoriesSet = <String>{};
  static UserInfo? globalUserInfoObj;
  static List<VisitedPoi> globalVisitedPoi = [];
  static Map globalInterestingPois = HashMap<String, MapPoi>(); // TODO use
  static AppLauncher globalAppLauncher = AppLauncher();
  static MapPoi? mainMapPoi; // spoken poi
  static final globalController = Get.put(LoginController());

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
    globalPoisIdToMarkerIdx.clear();
    mainMapPoi = null;
    globalUserInfoObj = null;
  }
  static clearAll() async {
    // TODO add members to close
    globalAllPois.clear();
    globalUnhandledKeys.clear();
    globalPoisIdToMarkerIdx.clear();
    mainMapPoi = null;
    globalUserInfoObj = null;
  }

  // sort pois by user Preferences
  static int sortPoisByUserPreferences(String idA, String idB) {
    List<String> categoriesA = globalAllPois[idA]!.poi.Categories;
    List<String> categoriesB = globalAllPois[idB]!.poi.Categories;
    int intersectionsWithA = favoriteCategoriesSet.intersection(categoriesA.toSet()).length;
    int intersectionsWithB = favoriteCategoriesSet.intersection(categoriesB.toSet()).length;
    return intersectionsWithB - intersectionsWithA;

  }

}
