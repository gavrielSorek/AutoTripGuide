import 'dart:collection';
import 'package:final_project/Map/audio_player_controller.dart';
import 'package:final_project/Map/types.dart';
import 'package:final_project/Map/server_communication.dart';
import 'apps_launcher.dart';
import 'map.dart';

class Globals {
  static UserMap globalUserMap = UserMap();
  static ServerCommunication globalServerCommunication = ServerCommunication();
  static AudioApp globalAudioPlayer = AudioApp();
  static Map globalAllPois = HashMap<String, MapPoi>();
  static Map globalUnhandledPois = HashMap<String, MapPoi>();
  static Map globalPoisIdToMarkerIdx = HashMap<String, int>();
  static String globalDefaultLanguage = "eng";
  static Map<String, List<String>> globalCategories = {};
  static List<String> globalFavoriteCategories = [];
  static Map globalInterestingPois = HashMap<String, MapPoi>();
  static AppLauncher globalAppLauncher = AppLauncher();
  static MapPoi? mainMapPoi; // spoken poi

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
    globalCategories = await Globals.globalServerCommunication.getCategories(globalDefaultLanguage);
  }
}
