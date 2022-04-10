import 'dart:collection';

import 'package:final_project/Map/Audio_player_controller.dart';
import 'package:final_project/Map/location_types.dart';
import 'package:final_project/Map/server_communication.dart';

import 'map.dart';

class Globals {
  static UserMap globalUserMap = UserMap();
  static ServerCommunication globalServerCommunication = ServerCommunication();
  static AudioApp globalAudioPlayer = AudioApp();
  static Map globalAllPois = HashMap<String, MapPoi>();
  static Map globalInterestingPois = HashMap<String, MapPoi>();
  static init() async {
    // initialization order is very important
    await UserMap.mapInit();



  }

}