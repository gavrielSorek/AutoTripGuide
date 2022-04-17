import 'dart:typed_data';

import 'package:final_project/Map/audio_player_controller.dart';
import 'package:final_project/Map/text_guid_dialog.dart';
import 'package:final_project/Map/types.dart';
import 'package:final_project/Map/map.dart';
import 'package:flutter/material.dart';
import 'blurry_dialog.dart';
import 'globals.dart';

class Guide {
  BuildContext context;
  GuideData guideData;
  AudioApp audioPlayer;
  GuideState state = GuideState.waiting;
  MapPoi? lastMapPoiHandled;

  Guide(this.context, this.guideData, this.audioPlayer);

  void handleMapPoiVoice(MapPoi mapPoi) async {
    // setMapPoiColor(mapPoi, Colors.black);
    if (lastMapPoiHandled != null) {
      UserMap.USER_MAP!.userMapState?.unHighlightMapPoi(lastMapPoiHandled!);
    }
    Globals.setMainMapPoi(mapPoi);
    UserMap.USER_MAP!.userMapState?.highlightMapPoi(mapPoi);
    lastMapPoiHandled = mapPoi;
    BlurryDialog alert = BlurryDialog(
        "Do you want to hear about this poi", mapPoi.poi.poiName!, () async {
      // ok callback
      Navigator.of(context).pop();
      Audio audio =
          await Globals.globalServerCommunication.getAudioById(mapPoi.poi.id!);

      List<int> intList = audio.audio.cast<int>().toList();
      Uint8List byteData =
          Uint8List.fromList(intList); // Load audio as a byte array here.
      audioPlayer.byteData = byteData;
      audioPlayer.playAudio();
    }, () {
      // next callback
      Navigator.of(context).pop();
      handleNextPoi();
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

  void handleMapPoiText(MapPoi mapPoi) async {
    if (lastMapPoiHandled != null) {
      UserMap.USER_MAP!.userMapState?.unHighlightMapPoi(lastMapPoiHandled!);
    }
    UserMap.USER_MAP!.userMapState?.highlightMapPoi(mapPoi);
    lastMapPoiHandled = mapPoi;
    BlurryDialog alert = BlurryDialog(
        "Do you want to read about this poi", mapPoi.poi.poiName!, () async {
      // ok callback
      Navigator.of(context).pop();
      TextGuideDialog textDialog = TextGuideDialog(
          mapPoi.poi.poiName ?? "?", mapPoi.poi.shortDesc ?? "?", () {
        Navigator.of(context).pop();
        //next callback
      });

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return textDialog;
        },
      );
    }, () {
      // next callback
      Navigator.of(context).pop();
      handleNextPoi();
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

  void handleNextPoi() async {
    if (state == GuideState.working || Globals.globalUnhandledPois.isEmpty) {
      print("error in handleNextPoi in Guide or pois map is empty");
      return;
    }
    state = GuideState.working;
    MapPoi mapPoiElement = Globals.globalUnhandledPois.values.first;
    if (guideData.status == GuideStatus.voice) {
      handleMapPoiVoice(mapPoiElement);
    } else {
      handleMapPoiText(mapPoiElement);
    }
    Globals.globalUnhandledPois.remove(mapPoiElement.poi.id);
    if (Globals.globalUnhandledPois.isNotEmpty && state != GuideState.stopped) {
      handleNextPoi();
    } else {
      if (Globals.globalUnhandledPois.isEmpty) {
        state = GuideState.waiting;
      }
    }
  }

  void handlePois() async {
    print("in handlePois");
    // Globals.globalUnhandledPois.forEach(void f(K key, V value));
    if (state == GuideState.working) {
      return;
    }
    handleNextPoi();
    // state = GuideState.working;
    // Map clonePois = Map.from(Globals.globalUnhandledPois);
    // clonePois.forEach((var poiId, var mapPoi) {
    //   MapPoi mapPoiElement = mapPoi as MapPoi;
    //   if (guideData.status == GuideStatus.voice) {
    //     handleMapPoiVoice(mapPoiElement);
    //   } else {
    //     handleMapPoiText(mapPoiElement);
    //   }
    //   Globals.globalUnhandledPois.remove(poiId);
    //
    // });
    // if (Globals.globalUnhandledPois.isNotEmpty) {
    //   handlePois();
    // } else {
    //   state = GuideState.waiting;
    // }
  }
}
