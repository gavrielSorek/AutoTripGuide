import 'dart:async';
import 'dart:ffi';
import 'dart:typed_data';
import 'package:final_project/Map/audio_player_controller.dart';
import 'package:final_project/Map/types.dart';
import 'package:flutter/material.dart';
import '../Pages/poi_reading_page.dart';
import 'dialog_box.dart';
import 'globals.dart';

class Guide {
  BuildContext context;
  GuideData guideData;
  AudioApp audioPlayer;
  GuideState state = GuideState.waiting;
  MapPoi? lastMapPoiHandled;
  bool userClickedOkOnPoi = false;
  late GuideDialogBox guideDialogBox;
  Timer? timerToGuideOnPoi;

  Guide(this.context, this.guideData, this.audioPlayer) {
    guideDialogBox = GuideDialogBox(
        onPressOk: onUserClickedOk,
        onPressNext: () {
          stop();
          askNextPoi();
        });
  }

  Future<void> handleMapPoiVoice(MapPoi mapPoi) async {
    Audio audio =
        await Globals.globalServerCommunication.getAudioById(mapPoi.poi.id!);

    List<int> intList = audio.audio.cast<int>().toList();
    Uint8List byteData =
        Uint8List.fromList(intList); // Load audio as a byte array here.
    audioPlayer.byteData = byteData;
    audioPlayer.playAudio();
  }

  Future<void> handleMapPoiText(MapPoi mapPoi) async {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => PoiReadingPage(
              poi: mapPoi.poi,
            )));
  }

  Future<void> handleMapPoi(MapPoi mapPoi) async {
    state = GuideState.working;
    Globals.setMainMapPoi(mapPoi);
     if (lastMapPoiHandled != null) {
       Globals.globalUserMap.userMapState?.unHighlightMapPoi(lastMapPoiHandled!);
     }
    Globals.globalUserMap.userMapState?.highlightMapPoi(mapPoi);
    Globals.globalUserMap.userMapState?.showNextButton();
    lastMapPoiHandled = mapPoi;
    if (guideData.status == GuideStatus.voice) {
      await handleMapPoiVoice(mapPoi);
    } else {
      await handleMapPoiText(mapPoi);
    }
  }

  void handlePois() async {
    askNextPoi();
    // print("in handlePois");
    // // Globals.globalUnhandledPois.forEach(void f(K key, V value));
    // if (state == GuideState.working || Globals.globalUnhandledPois.isEmpty) {
    //   print("error in handleNextPoi in Guide or pois map is empty");
    //   return;
    // }
    // MapPoi mapPoiElement = Globals.globalUnhandledPois.values.first;
    // guideDialogBox.setMapPoi(mapPoiElement);
    // guideDialogBox.showDialog();
  }

  void askNextPoi() {
    if (state == GuideState.working || Globals.globalUnhandledPois.isEmpty) {
      print("error in handleNextPoi in Guide or pois map is empty");
      return;
    }
    MapPoi mapPoiElement = Globals.globalUnhandledPois.values.first;
    Globals.globalUnhandledPois.remove(
        mapPoiElement.poi.id); // handling poi so remove from UnhandledPois
    askPoi(mapPoiElement);
  }

  void askPoi(MapPoi poi) {
    timerToGuideOnPoi?.cancel(); // cancel timer for last poi

    // highlight wanted poi
    Globals.setMainMapPoi(poi);
    if (lastMapPoiHandled != null) {
      Globals.globalUserMap.userMapState?.unHighlightMapPoi(lastMapPoiHandled!);
    }
    Globals.globalUserMap.userMapState?.highlightMapPoi(poi);

    userClickedOkOnPoi = false;
    //handleMapPoi(poi);
    guideDialogBox.updateGuideStatus(guideData.status);
    guideDialogBox.setMapPoi(poi);
    guideDialogBox.showDialog();

    timerToGuideOnPoi = Timer(const Duration(seconds: 10), () {
      if (!userClickedOkOnPoi) {
        onUserClickedOk();
      }
    });
  }

  void stop() {
    // unhighlight last map poi
    if (lastMapPoiHandled != null) {
      Globals.globalUserMap.userMapState?.unHighlightMapPoi(lastMapPoiHandled!);
    }
    if (Globals.mainMapPoi != null) {
      Globals.globalUserMap.userMapState?.unHighlightMapPoi(Globals.mainMapPoi!);
    }
    if (guideData.status == GuideStatus.voice) {
      audioPlayer.stopAudio();
    }
    Globals.deleteMainMapPoi();
    Globals.globalUserMap.userMapState?.hideNextButton();
    guideDialogBox.hideDialog();
    state = GuideState.stopped;
  }

  void postPoiHandling() {
    // if (Globals.globalUnhandledPois.isNotEmpty && state == GuideState.waiting) {
    //   askNextPoi();
    // } else {
    //   if (Globals.globalUnhandledPois.isEmpty) {
    //     stop();
    //   }
    // }
  }

  void guideStateChanged() {
    if (state == GuideState.working) {
      stop();
      askPoi(lastMapPoiHandled!);
    }
  }

  void onUserClickedOk() {
    userClickedOkOnPoi = true;
    handleMapPoi(guideDialogBox.getMapPoi()!);
    guideDialogBox.hideDialog();
  }
}

class GuideDialogBox extends StatefulWidget {
  dynamic onPressOk, onPressNext;

  GuideDialogBox({Key? key, this.onPressOk, this.onPressNext})
      : super(key: key);

  _GuideDialogBoxState? guideDialogBoxState;

  void setMapPoi(MapPoi poi) {
    guideDialogBoxState!.setMapPoi(poi);
  }

  void updateGuideStatus(GuideStatus status) {
    guideDialogBoxState!.updateGuideStatus(status);
  }

  void showDialog() {
    guideDialogBoxState!.showDialog();
  }

  void hideDialog() {
    guideDialogBoxState!.hideDialog();
  }

  MapPoi? getMapPoi() {
    return guideDialogBoxState!.getMapPoi();
  }

  _GuideDialogBoxState getDialogBoxState() {
    if (guideDialogBoxState == null) {
      print("error in getDialogBoxState");
    }
    return guideDialogBoxState!;
  }

  @override
  _GuideDialogBoxState createState() {
    guideDialogBoxState = _GuideDialogBoxState();
    return guideDialogBoxState!;
  }
}

class _GuideDialogBoxState extends State<GuideDialogBox> {
  MapPoi? mainPoi;
  GuideStatus guideStatus = GuideStatus.voice;
  String ask = "Do you want to hear about ";
  WidgetVisibility dialogVisibility = WidgetVisibility.hide;

  MapPoi? getMapPoi() {
    return mainPoi;
  }

  void setMapPoi(MapPoi poi) {
    setState(() {
      mainPoi = poi;
    });
  }

  void updateGuideStatus(GuideStatus status) {
    setState(() {
      guideStatus = status;
      if (guideStatus == GuideStatus.voice) {
        ask = "Do you want to hear about ";
      } else {
        ask = "Do you want to read about ";
      }
    });
  }

  void showDialog() {
    setState(() {
      dialogVisibility = WidgetVisibility.view;
    });
  }

  void hideDialog() {
    setState(() {
      dialogVisibility = WidgetVisibility.hide;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
        opacity: WidgetVisibility.view == dialogVisibility ? 1.0 : 0.0,
        duration: Duration(milliseconds: 500),
        child: CustomDialogBox(
          title: mainPoi?.poi.poiName ?? "No information",
          descriptions: ask + (mainPoi?.poi.poiName ?? "No information") + "?",
          leftButtonText: "Ok",
          rightButtonText: "Next",
          // img: Image.network(
          //     "https://assets.hyatt.com/content/dam/hyatt/hyattdam/images/2019/02/07/1127/Andaz-Costa-Rica-P834-Aerial-Culebra-Bay-View.jpg/Andaz-Costa-Rica-P834-Aerial-Culebra-Bay-View.16x9.jpg"),
          img: Image.network(mainPoi?.poi.pic ??
              "https://assets.hyatt.com/content/dam/hyatt/hyattdam/images/2019/02/07/1127/Andaz-Costa-Rica-P834-Aerial-Culebra-Bay-View.jpg/Andaz-Costa-Rica-P834-Aerial-Culebra-Bay-View.16x9.jpg"),
          key: UniqueKey(),
          onPressLeft: widget.onPressOk,
          onPressRight: widget.onPressNext,
        ));
  }
}
