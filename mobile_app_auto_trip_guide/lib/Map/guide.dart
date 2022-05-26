import 'dart:async';
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
  late GuideDialogBox guideDialogBox;
  int loadingAnimationTime = 10; // default

  Guide(this.context, this.guideData, this.audioPlayer) {
    guideDialogBox = GuideDialogBox(
        onPressOk: onUserClickedOk,
        onPressNext: () {
          stop();
          askNextPoi();
        },
        onLoadingFinished: () {
          onUserClickedOk();
        },
        loadingAnimationTime: loadingAnimationTime);
  }

  Future<void> handleMapPoiVoice(MapPoi mapPoi) async {
    Audio audio =
        await Globals.globalServerCommunication.getAudioById(mapPoi.poi.id);

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
    preHandlePoi(mapPoi);
    if (guideData.status == GuideStatus.voice) {
      await handleMapPoiVoice(mapPoi);
    } else {
      await handleMapPoiText(mapPoi);
    }
  }

  void handlePois() async {
    askNextPoi();
  }

  void askNextPoi() {
    if (state == GuideState.working || Globals.globalUnhandledKeys.isEmpty) {
      print("error in handleNextPoi in Guide or pois map is empty");
      return;
    }
    // MapPoi mapPoiElement = Globals.globalUnhandledPois.values.first;
    MapPoi mapPoiElement = Globals.globalAllPois[Globals.globalUnhandledKeys[0]]!;
    Globals.removeUnhandledPoiKey(0);
    askPoi(mapPoiElement);
  }

  void askPoi(MapPoi poi) {
    state = GuideState.working;
    preHandlePoi(poi);
    guideDialogBox.updateGuideStatus(guideData.status);
    guideDialogBox.setMapPoi(poi);
    guideDialogBox.showDialog();
    guideDialogBox.startLoading();
  }

  void stop() {
    // unhighlight last map poi
    if (lastMapPoiHandled != null) {
      Globals.globalUserMap.userMapState?.unHighlightMapPoi(lastMapPoiHandled!);
    }
    if (Globals.mainMapPoi != null) {
      Globals.globalUserMap.userMapState
          ?.unHighlightMapPoi(Globals.mainMapPoi!);
    }
    if (guideData.status == GuideStatus.voice) {
      audioPlayer.stopAudio();
    }
    Globals.deleteMainMapPoi();
    Globals.globalUserMap.userMapState?.hideNextButton();
    guideDialogBox.hideDialog();
    state = GuideState.stopped;
  }

  // lunch before handle poi
  void preHandlePoi(MapPoi mapPoi) {
    Globals.setMainMapPoi(mapPoi);
    if (lastMapPoiHandled != null) {
      Globals.globalUserMap.userMapState?.unHighlightMapPoi(lastMapPoiHandled!);
    }
    Globals.globalUserMap.userMapState?.highlightMapPoi(mapPoi);
    Globals.globalUserMap.userMapState?.showNextButton();
    lastMapPoiHandled = mapPoi;
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

  String getTime() {
    DateTime now = new DateTime.now();
    DateTime date = new DateTime(now.year, now.month, now.day, now.hour, now.minute);
    String dateToday = date.toString().substring(0,16);
    return dateToday;
  }

  void onUserClickedOk() {
    handleMapPoi(guideDialogBox.getMapPoi()!);
    guideDialogBox.hideDialog();
    VisitedPoi currentPoi = VisitedPoi(id: guideDialogBox.getMapPoi()!.poi.id, poiName: guideDialogBox.getMapPoi()?.poi.poiName, time: getTime(), pic: guideDialogBox.getMapPoi()?.poi.pic);
    Globals.globalVisitedPoi.add(currentPoi);
    Globals.globalServerCommunication.insertPoiToHistory(currentPoi);
  }
}

class GuideDialogBox extends StatefulWidget {
  dynamic onPressOk, onPressNext, onLoadingFinished;
  int loadingAnimationTime = 10; // default
  bool stopLoading = false;


  GuideDialogBox(
      {Key? key,
      this.onPressOk,
      this.onPressNext,
      this.onLoadingFinished,
      required this.loadingAnimationTime})
      : super(key: key);

  _GuideDialogBoxState? guideDialogBoxState;

  void setMapPoi(MapPoi poi) {
    guideDialogBoxState!.setMapPoi(poi);
    stopLoading = false;
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

  void startLoading() {
    guideDialogBoxState?.startLoading();
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
  CustomDialogBox? dialogBox;
  double progress = 0;

  void startLoading() {
    progress = 0;
    int numberOfSteps = 10;
    loadStep(numberOfSteps);
  }

  void loadStep(int numberOfSteps) {
    double progressEveryStep = 1 / numberOfSteps;
    int stepTime = (widget.loadingAnimationTime / numberOfSteps).round();
    Future.delayed(Duration(seconds: stepTime), () {
      if (widget.stopLoading) {
        return;
      }
      progress += progressEveryStep;
      dialogBox?.setProgress(progress);
      if (progress <= 1) {
        loadStep(numberOfSteps);
      } else {
        // finished loading
        widget.onLoadingFinished();
      }
    });
  }

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
    dialogBox = CustomDialogBox(
      title: mainPoi?.poi.poiName ?? "No information",
      descriptions: ask + (mainPoi?.poi.poiName ?? "No information") + "?",
      leftButtonText: "Ok",
      rightButtonText: "Next",
      img: Image.network(mainPoi?.poi.pic ??
          "https://assets.hyatt.com/content/dam/hyatt/hyattdam/images/2019/02/07/1127/Andaz-Costa-Rica-P834-Aerial-Culebra-Bay-View.jpg/Andaz-Costa-Rica-P834-Aerial-Culebra-Bay-View.16x9.jpg"),
      key: UniqueKey(),
      onPressLeft: () {
        widget.stopLoading = true;
        widget.onPressOk();
      },
      onPressRight: widget.onPressNext,
    );

    return AnimatedOpacity(
        opacity: WidgetVisibility.view == dialogVisibility ? 1.0 : 0.0,
        duration: Duration(milliseconds: 500),
        child: dialogBox);
  }
}
