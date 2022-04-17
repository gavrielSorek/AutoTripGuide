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

  Future<void> handleMapPoiVoice(MapPoi mapPoi) async {
    // setMapPoiColor(mapPoi, Colors.black);
    if (lastMapPoiHandled != null) {
      UserMap.USER_MAP!.userMapState?.unHighlightMapPoi(lastMapPoiHandled!);
    }
    Globals.setMainMapPoi(mapPoi);
    UserMap.USER_MAP!.userMapState?.highlightMapPoi(mapPoi);
    UserMap.USER_MAP!.userMapState?.showNextButton();
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
      state = GuideState.waiting;
      handleNextPoi();
    }, () {
      // cancel
      Navigator.of(context).pop();
      state = GuideState.waiting;
    });
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future<void> handleMapPoiText(MapPoi mapPoi) async {
    if (lastMapPoiHandled != null) {
      UserMap.USER_MAP!.userMapState?.unHighlightMapPoi(lastMapPoiHandled!);
    }
    UserMap.USER_MAP!.userMapState?.highlightMapPoi(mapPoi);
    UserMap.USER_MAP!.userMapState?.showNextButton();

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
      state = GuideState.waiting;

      handleNextPoi();
    }, () {
      // cancel
      Navigator.of(context).pop();
      state = GuideState.waiting;
    });
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future<void> handleMapPoi (MapPoi mapPoi) async {
    state = GuideState.working;
    if (guideData.status == GuideStatus.voice) {
      await handleMapPoiVoice(mapPoi);
    } else {
      await handleMapPoiText(mapPoi);
    }
    Globals.globalUnhandledPois.remove(mapPoi.poi.id);
    state = GuideState.waiting;

  }

  void handleNextPoi() async {
    if (state == GuideState.working || Globals.globalUnhandledPois.isEmpty) {
      print("error in handleNextPoi in Guide or pois map is empty");
      return;
    }
    MapPoi mapPoiElement = Globals.globalUnhandledPois.values.first;
    await handleMapPoi(mapPoiElement);
    if (Globals.globalUnhandledPois.isNotEmpty && state != GuideState.stopped) {
    } else {
      if (Globals.globalUnhandledPois.isEmpty) {
        stop();
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
  }

  void stop() {
    if (guideData.status == GuideStatus.voice) {
      audioPlayer.stopAudio();
    }
    Globals.deleteMainMapPoi();
    UserMap.USER_MAP!.userMapState?.hideNextButton();

    state = GuideState.stopped;
  }
}
