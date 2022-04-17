import 'dart:typed_data';

import 'package:final_project/Map/audio_player_controller.dart';
import 'package:final_project/Map/types.dart';
import 'package:final_project/Map/map.dart';
import 'package:flutter/material.dart';
import 'blurry_dialog.dart';
import 'globals.dart';

class Guide {
  BuildContext context;
  GuideData guideData;
  AudioApp audioPlayer;
  GuideState state = GuideState.stopped;

  Guide(this.context, this.guideData, this.audioPlayer);

  void setMapPoiColor(MapPoi mapPoi, Color color) {

    mapPoi.iconButton!.iconState?.setColor(Colors.black);
  }

  void handleMapPoiVoice(MapPoi mapPoi) async{
    setMapPoiColor(mapPoi, Colors.black);
    BlurryDialog alert = BlurryDialog(
        "Do you want to hear about this poi", mapPoi.poi.poiName!, () async {
      // ok callback
      Navigator.of(context).pop();
      Audio audio = await Globals.globalServerCommunication.getAudioById(mapPoi.poi.id!);
      print(audio);
      List<int> intList = audio.audio.cast<int>().toList();
      Uint8List byteData = Uint8List.fromList(intList); // Load audio as a byte array here.
      audioPlayer.byteData = byteData;

      // AudioPlayer audioPlayer = AudioPlayer();
      // int result = await audioPlayer.playBytes(byteData);


    }, () {
      // next callback
      Navigator.of(context).pop();
    }, () {
      // cancel
      Navigator.of(context).pop();
    });
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void handleMapPoiText(MapPoi mapPoi) {
    setMapPoiColor(mapPoi, Colors.black);


  }
  void handlePois() async {
    print("in handlePois");
    // Globals.globalUnhandledPois.forEach(void f(K key, V value));

    if (state == GuideState.working) {
      return;
    }
    state = GuideState.working;
    Map clonePois = Map.from(Globals.globalUnhandledPois);
    clonePois.forEach((var poiId, var mapPoi) {
      MapPoi mapPoiElement = mapPoi as MapPoi;
      if (guideData.status == GuideStatus.voice) {
        handleMapPoiVoice(mapPoiElement);
      } else {
        handleMapPoiText(mapPoiElement);
      }
      Globals.globalUnhandledPois.remove(poiId);

    });
    if (Globals.globalUnhandledPois.isNotEmpty) {
      handlePois();
    } else {
      state = GuideState.stopped;
    }
  }




}

// _showDialog(BuildContext context)
// {
//
//   VoidCallback continueCallBack = () => {
//     Navigator.of(context).pop(),
//     // code on continue comes here
//
//   };
//   BlurryDialog  alert = BlurryDialog("Abort","Are you sure you want to abort this operation?",continueCallBack);
//
//
//   showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return alert;
//     },
//   );
// }
