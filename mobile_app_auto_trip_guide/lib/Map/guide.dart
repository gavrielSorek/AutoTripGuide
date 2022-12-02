import 'dart:async';
import 'dart:collection';
import 'package:final_project/Map/types.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'guid_bloc/guide_bloc.dart';
import 'guide_dialog_box.dart';
import 'globals.dart';

class Guide {
  BuildContext context;
  GuideData guideData;
  GuideState guideState = GuideState.waiting;
  Map<String, MapPoi> _poisToPlay = HashMap<String, MapPoi>();
  Map<String, MapPoi> _queuedPoisToPlay = HashMap<String, MapPoi>();

  late GuidDialogBox storiesDialogBox;
  bool _inIntro = false;

  Guide(this.context, this.guideData) {
    storiesDialogBox = GuidDialogBox();
    // StoriesDialogBox(key: UniqueKey());
  }

  Future<void> handleMapPoi(MapPoi mapPoi) async {}

  void setPoisInQueue(List<Poi> pois) {
    bool poisWereEmpty = _poisToPlay.isEmpty;
    for (Poi poi in pois) {
      if (Globals.globalAllPois.containsKey(poi.id)) {
        _queuedPoisToPlay[poi.id] = Globals.globalAllPois[poi.id]!;
      }
    }
    if (_poisToPlay.isEmpty) {
      _poisToPlay.addAll(_queuedPoisToPlay);
    }
    if (poisWereEmpty && !_poisToPlay.isEmpty) {
      context.read<GuideBloc>().add(SetStoriesListEvent(
          poisToPlay: _poisToPlay, onFinished: onStoryFinished));
    }
  }

  void onStoryFinished() {
    _poisToPlay.clear();
    _poisToPlay.addAll(_queuedPoisToPlay);
    if (!_poisToPlay.isEmpty) {
      context.read<GuideBloc>().add(SetStoriesListEvent(
          poisToPlay: _poisToPlay, onFinished: onStoryFinished));
    }

  }
  void askPoi(MapPoi poi) {
    guideState = GuideState.working;
    preHandlePoi(poi);
  }

  // void stop() {
  //   if (Globals.mainMapPoi != null) {
  //     Globals.globalUserMap.userMapState
  //         ?.unHighlightMapPoi(Globals.mainMapPoi!);
  //   }
  //   if (guideData.status == GuideStatus.voice) {
  //     // audioPlayer.clearPlayer();
  //   }
  //   Globals.deleteMainMapPoi();
  //   Globals.globalUserMap.userMapState?.hideNextButton();
  //   // guideDialogBox.stopLoading();
  //   // guideDialogBox.hideDialog();
  //   state = GuideState.stopped;
  // }

  // void resumeGuide() {
  //   if (_inIntro) {
  //     _inIntro = false;
  //     stop();
  //     // handleMapPoiVoice(guideDialogBox.getMapPoi()!);
  //   }
  // }

  // lunch before handle poi
  void preHandlePoi(MapPoi mapPoi) {
    Globals.setMainMapPoi(mapPoi);
    Globals.globalUserMap.userMapState?.highlightMapPoi(mapPoi);
    Globals.globalUserMap.userMapState?.showNextButton();
  }
//
// void guideStateChanged() {
//   if (state == GuideState.working) {
//     stop();
//   }
// }
}

class GuidDialogBox extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _GuidDialogBoxState();
  }
}

class _GuidDialogBoxState extends State<GuidDialogBox> {
  Widget buildSearchingWidget() {
    return Dialog(
        insetPadding: const EdgeInsets.all(Constants.edgesDist),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Constants.padding),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Stack(children: <Widget>[
          Container(
            alignment: Alignment.topLeft,
            // width: 240.0,
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24.0),
              color: Colors.white.withOpacity(0.8),
            ),
            child: Center(
              child: Text(
                "Scanning... \nAuto Trip is searching for interesting places near you. \n you can adjust the search by selecting your interests in the preferences screen.",
                style: TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 20,
                  color: Colors.black,
                  height: 1,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ]));
    // decoration: BoxDecoration(
    //     shape: BoxShape.rectangle,
    //     color: Colors.white.withOpacity(0.1),
    //     borderRadius: BorderRadius.circular(Constants.padding),
    //     boxShadow: const [
    //       BoxShadow(
    //           color: Colors.black,
    //           offset: Offset(0, 5),
    //           blurRadius: 10),
    //     ]),

    // child: Column(children: [
    //   Container(
    //       alignment: Alignment.topLeft,
    //       // width: MediaQuery.of(context).size.width,
    //       // height: MediaQuery.of(context).size.height,
    //       child: Text(
    //           "Scanning... \nAuto Trip is searching for interesting places near you. \n you can adjust the search by selecting your interests in the preferences screen.",
    //           style: TextStyle(
    //               color: Colors.grey[800],
    //               fontWeight: FontWeight.bold,
    //               fontSize: 28)))
    // ])),
    // ],
    //   ),
    // );
  }

  Widget buildStoriesWidget(state) {
    final storiesState = state as ShowStoriesState;
    return Dialog(
        insetPadding: const EdgeInsets.all(Constants.edgesDist),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Constants.padding),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Stack(
          children: <Widget>[
            Container(
                height: double.infinity,
                padding: const EdgeInsets.only(
                    left: Constants.padding,
                    top: Constants.avatarRadius + Constants.padding,
                    right: Constants.padding,
                    bottom: Constants.padding),
                margin: const EdgeInsets.only(top: Constants.avatarRadius),
                decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(Constants.padding),
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.black,
                          offset: Offset(0, 5),
                          blurRadius: 10),
                    ]),
                child: Column(
                  children: [
                    Expanded(child: storiesState.stories),
                    Container(child: Globals.globalAudioApp, height: 56)
                  ],
                )),
            Positioned(
              left: Constants.padding,
              right: Constants.padding,
              child: CircleAvatar(
                  backgroundColor: Colors.transparent,
                  radius: Constants.avatarRadius,
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(
                        Radius.circular(Constants.avatarRadius)),
                    child:
                        Image.network(storiesState.currentPoi?.poi.pic ?? ""),
                  )),
            ),
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GuideBloc, GuideDialogState>(
      builder: (BuildContext context, state) {
        if (state is PoisSearchingState) {
          return buildSearchingWidget();
        }
        if (state is ShowStoriesState) {
          return buildStoriesWidget(state);
        } else {
          return buildSearchingWidget();
        }
      },
    );
  }
}
