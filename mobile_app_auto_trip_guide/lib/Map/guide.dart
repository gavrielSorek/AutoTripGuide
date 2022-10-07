import 'dart:async';
import 'package:final_project/Map/audio_player_controller.dart';
import 'package:final_project/Map/types.dart';
import 'package:flutter/material.dart';
import '../Pages/poi_reading_page.dart';
import 'dialog_box.dart';
import 'pois_attributes_calculator.dart';
import 'globals.dart';
import 'map.dart';

class Guide {
  BuildContext context;
  GuideData guideData;
  AudioApp audioPlayer = AudioApp();
  GuideState state = GuideState.waiting;
  MapPoi? lastMapPoiHandled;
  late GuideDialogBox guideDialogBox;
  int loadingAnimationTime = 10; // default
  bool _inIntro = false;

  Guide(this.context, this.guideData) {
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
    Poi dialogBoxCurrentPoi = guideDialogBox.getMapPoi()!.poi;
    String directionString = PoisAttributesCalculator.getDirection(
        UserMap.USER_LOCATION.latitude,
        UserMap.USER_LOCATION.longitude,
        dialogBoxCurrentPoi.latitude,
        dialogBoxCurrentPoi.longitude);

    String distString = PoisAttributesCalculator.getDistBetweenPoints(
        UserMap.USER_LOCATION.latitude,
        UserMap.USER_LOCATION.longitude,
        dialogBoxCurrentPoi.latitude,
        dialogBoxCurrentPoi.longitude).toInt().toString();

    // sets intro text
    audioPlayer.setText("The poi is " + directionString + " of you" + "in distance of " + distString + " meters", 'en');
    audioPlayer.setOnPlayerFinishedFunc(() {
      _inIntro = false;
      audioPlayer.setText(mapPoi.poi.shortDesc ?? "No description",
          mapPoi.poi.language ?? 'en');
      audioPlayer.setOnPlayerFinishedFunc(() {
        stop();
        askNextPoi();
      });
      // play poi info
      audioPlayer.playAudio();
    });

    _inIntro = true;
    // play intro
    audioPlayer.playAudio(playWithProgressBar: false);
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
    MapPoi mapPoiElement =
        Globals.globalAllPois[Globals.globalUnhandledKeys[0]]!;
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
      audioPlayer.clearPlayer();
    }
    Globals.deleteMainMapPoi();
    Globals.globalUserMap.userMapState?.hideNextButton();
    guideDialogBox.stopLoading();
    guideDialogBox.hideDialog();
    state = GuideState.stopped;
  }

  void pauseGuide() {
    audioPlayer.pauseAudio();
    pauseGuideDialogBox();
  }

  void resumeGuide() {
    if (_inIntro) {
      _inIntro = false;
      stop();
      handleMapPoiVoice(guideDialogBox.getMapPoi()!);
    }
    unpauseGuideDialogBox();
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

  void guideStateChanged() {
    if (state == GuideState.working) {
      stop();
      askPoi(lastMapPoiHandled!);
    }
  }

  String getTime() {
    DateTime now = new DateTime.now();
    DateTime date =
        DateTime(now.year, now.month, now.day, now.hour, now.minute);
    String dateToday = date.toString().substring(0, 16);
    return dateToday;
  }

  void onUserClickedOk() {
    handleMapPoi(guideDialogBox.getMapPoi()!);
    guideDialogBox.hideDialog();
    VisitedPoi currentPoi = VisitedPoi(
        id: guideDialogBox.getMapPoi()!.poi.id,
        poiName: guideDialogBox.getMapPoi()?.poi.poiName,
        time: getTime(),
        pic: guideDialogBox.getMapPoi()?.poi.pic);
    Globals.addGlobalVisitedPoi(currentPoi);
    Globals.globalServerCommunication.insertPoiToHistory(currentPoi);
  }

  void pauseGuideDialogBox() {
    guideDialogBox.pauseLoading();
  }

  void unpauseGuideDialogBox() {
    if (guideDialogBox.isLoadingPaused()) {
      guideDialogBox.continueLoading();
    }
  }
}

class GuideDialogBox extends StatefulWidget {
  dynamic onPressOk, onPressNext, onLoadingFinished;
  int loadingAnimationTime;
  bool _stopLoading = false;

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
    _stopLoading = false;
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

  void continueLoading() {
    guideDialogBoxState?.continueLoading();
  }

  void pauseLoading() {
    guideDialogBoxState?.pauseLoading();
  }

  void stopLoading() {
    guideDialogBoxState?.stopLoading();
  }

  bool isLoadingPaused() {
    if (guideDialogBoxState == null) {
      return false;
    }
    return guideDialogBoxState!.isLoadingPaused();
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
  bool pause = false;
  int numberOfSteps = 10;
  Timer? loadTimer;

  bool isLoadingPaused() {
    return pause;
  }

  void startLoading() {
    stopLoading();
    progress = 0;
    pause = false;
    loadStep();
  }

  void pauseLoading() {
    loadTimer?.cancel();
    pause = true;
  }

  void stopLoading() {
    progress = 0;
    loadTimer?.cancel();
  }

  void continueLoading() {
    pause = false;
    loadStep();
  }

  void loadStep() {
    loadTimer = Timer(
        Duration(
            seconds: (widget.loadingAnimationTime / numberOfSteps).round()),
        () {
      if (widget._stopLoading) {
        return;
      }
      double progressEveryStep = 1 / numberOfSteps;
      progress += progressEveryStep;
      dialogBox?.setProgress(progress);
      if (progress <= 1) {
        loadStep();
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
      leftButtonText: "  Ok  ",
      rightButtonText: "Next",
      img: Image.network(mainPoi?.poi.pic ??
          "https://assets.hyatt.com/content/dam/hyatt/hyattdam/images/2019/02/07/1127/Andaz-Costa-Rica-P834-Aerial-Culebra-Bay-View.jpg/Andaz-Costa-Rica-P834-Aerial-Culebra-Bay-View.16x9.jpg"),
      key: UniqueKey(),
      onPressLeft: () {
        widget._stopLoading = true;
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
