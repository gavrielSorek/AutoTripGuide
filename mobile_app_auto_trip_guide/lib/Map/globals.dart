import 'dart:collection';
import 'dart:math';
import 'package:final_project/Map/audio_player_controller.dart';
import 'package:final_project/Map/types.dart';
import 'package:final_project/Map/server_communication.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:location/location.dart';
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

  // calculate the distance between two locations from LatLng
  static double calculateDistance(lat1, lon1, lat2, lon2){
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 - c((lat2 - lat1) * p)/2 +
        c(lat1 * p) * c(lat2 * p) *
            (1 - c((lon2 - lon1) * p))/2;
    return 12742 * asin(sqrt(a));
  }

  // get distance of poi from user
  static int getDistanceInKm(String id) {
    LocationData? userLocation = UserMap.USER_LOCATION_DATA;
    double latitude = globalAllPois[id]!.poi.latitude;
    double longitude = globalAllPois[id]!.poi.longitude;
    int dist = calculateDistance(userLocation?.latitude ?? latitude, userLocation?.longitude ?? longitude, latitude, longitude).round();
    return dist;
  }

  // get score of poi according to user's preferences
  static int getPreferenceScore(String id) {
    List<String> categories = globalAllPois[id]!.poi.Categories;
    int intersections = favoriteCategoriesSet.intersection(categories.toSet()).length;
    int totalCategoriesLength = globalCategories?.length ?? 0;
    return totalCategoriesLength - intersections;
  }

  // sort pois by user Preferences
  static List<int> sortPoisByUserPreferences(String idA, String idB) {
    List<String> categoriesA = globalAllPois[idA]!.poi.Categories;
    List<String> categoriesB = globalAllPois[idB]!.poi.Categories;
    int intersectionsWithA = favoriteCategoriesSet.intersection(categoriesA.toSet()).length;
    int intersectionsWithB = favoriteCategoriesSet.intersection(categoriesB.toSet()).length;
    int totalCategoriesLength = globalCategories?.length ?? 0;
    return [totalCategoriesLength - intersectionsWithA, totalCategoriesLength - intersectionsWithB];
  }

  // sort pois by weighted score of preferences and distance
  static int sortPoisByWeightedScore(String idA, String idB) {
    int distanceA = getDistanceInKm(idA);
    int distanceB = getDistanceInKm(idB);
    int preferencesScoreA = getPreferenceScore(idA);
    int preferencesScoreB = getPreferenceScore(idB);
    int weightedScoreA = (0.7 * distanceA + 0.3 * preferencesScoreA).round();
    int weightedScoreB = (0.7 * distanceB + 0.3 * preferencesScoreB).round();
    return weightedScoreB - weightedScoreA;
  }
}
