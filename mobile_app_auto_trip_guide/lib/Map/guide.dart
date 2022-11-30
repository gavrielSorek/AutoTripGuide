import 'dart:async';
import 'package:final_project/Map/audio_player_controller.dart';
import 'package:final_project/Map/types.dart';
import 'package:flutter/material.dart';
import 'guide_dialog_box.dart';
import 'globals.dart';

class Guide {
  BuildContext context;
  GuideData guideData;
  AudioApp audioPlayer = AudioApp();
  GuideState state = GuideState.waiting;
  late StoriesDialogBox storiesDialogBox;
  bool _inIntro = false;

  Guide(this.context, this.guideData) {
    storiesDialogBox = StoriesDialogBox(
        key: UniqueKey());
      }

  Future<void> handleMapPoi(MapPoi mapPoi) async {
  }



  void handlePois() async {
    storiesDialogBox.setPoisToPlayWhenFinished(Globals.globalAllPois);
  }

  void askPoi(MapPoi poi) {
    state = GuideState.working;
    preHandlePoi(poi);
  }

  void stop() {

    if (Globals.mainMapPoi != null) {
      Globals.globalUserMap.userMapState
          ?.unHighlightMapPoi(Globals.mainMapPoi!);
    }
    if (guideData.status == GuideStatus.voice) {
      audioPlayer.clearPlayer();
    }
    Globals.deleteMainMapPoi();
    Globals.globalUserMap.userMapState?.hideNextButton();
    // guideDialogBox.stopLoading();
    // guideDialogBox.hideDialog();
    state = GuideState.stopped;
  }



  void resumeGuide() {
    if (_inIntro) {
      _inIntro = false;
      stop();
      // handleMapPoiVoice(guideDialogBox.getMapPoi()!);
    }
  }

  // lunch before handle poi
  void preHandlePoi(MapPoi mapPoi) {
    Globals.setMainMapPoi(mapPoi);
    Globals.globalUserMap.userMapState?.highlightMapPoi(mapPoi);
    Globals.globalUserMap.userMapState?.showNextButton();
  }

  void guideStateChanged() {
    if (state == GuideState.working) {
      stop();
    }
  }


}

class GuidDialogBox extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    throw UnimplementedError();
  }
  
}
class _GuidDialogBoxState extends State<GuidDialogBox> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
  
}
