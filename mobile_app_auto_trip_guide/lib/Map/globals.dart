import 'dart:collection';
import 'package:final_project/Map/audio_player_controller.dart';
import 'package:final_project/Map/types.dart';
import 'package:final_project/Map/server_communication.dart';
import 'apps_launcher.dart';
import 'map.dart';

class Globals {
  // static UserMap globalUserMap = UserMap();
  static ServerCommunication globalServerCommunication = ServerCommunication();
  static AudioApp globalAudioPlayer = AudioApp();
  static Map globalAllPois = HashMap<String, MapPoi>();
  static Map globalUnhandledPois = HashMap<String, MapPoi>();
  static Map globalPoisIdToMarkerIdx = HashMap<String, int>();

  static Map globalInterestingPois = HashMap<String, MapPoi>();
  static AppLauncher globalAppLauncher = AppLauncher();
  static MapPoi? mainMapPoi; // spoken poi

  static setMainMapPoi(MapPoi mapPoi) {
    if (UserMap.USER_MAP!.userMapState != null) {
      UserMap.USER_MAP!.userMapState!.showNavButton();
    }
    mainMapPoi = mapPoi;
  }

  static deleteMainMapPoi() {
    if (UserMap.USER_MAP!.userMapState != null) {
      UserMap.USER_MAP!.userMapState!.hideNavButton();
    }
    mainMapPoi = null;
  }

  static init() async {
    // initialization order is very important
    await UserMap.mapInit();
  }
}
