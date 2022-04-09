import 'dart:typed_data';

import 'package:final_project/Map/Audio_player_controller.dart';
import 'package:final_project/Map/location_types.dart';
import 'package:final_project/Map/map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:audioplayers/audioplayers.dart';

import 'BlurryDialog.dart';

class Guide {
  BuildContext context;
  GuideData guideData;
  AudioApp audioPlayer;

  Guide(this.context, this.guideData, this.audioPlayer);

  void setMapPoiColor(MapPoi mapPoi, Color color) {
    mapPoi.iconButton!.iconState!.setColor(Colors.black);
  }

  handleMapPoiVoice(MapPoi mapPoi) async{
    setMapPoiColor(mapPoi, Colors.black);
    BlurryDialog alert = BlurryDialog(
        "Do you want to hear about this poi", mapPoi.poi.poiName!, () async {
      // ok callback
      Navigator.of(context).pop();
      Audio audio = await UserMap.MAP_SERVER_COMMUNICATOR!.getAudioById(mapPoi.poi.id!);
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

  handleMapPoiText(MapPoi mapPoi) {
    setMapPoiColor(mapPoi, Colors.black);
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
