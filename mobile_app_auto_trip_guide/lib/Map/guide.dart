import 'dart:async';
import 'dart:collection';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:final_project/Map/types.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../Adjusted Libs/story_view/story_view.dart';
import '../Adjusted Libs/story_view/utils.dart';
import '../General Wigets/uniform_widgets.dart';
import 'guid_bloc/guide_bloc.dart';
import 'guide_dialog_box.dart';
import 'globals.dart';
import 'package:share_plus/share_plus.dart';

class Guide {
  BuildContext context;
  GuideData guideData;
  GuideState guideState = GuideState.waiting;
  Map<String, MapPoi> _poisToPlay = HashMap<String, MapPoi>();
  Map<String, MapPoi> _queuedPoisToPlay = HashMap<String, MapPoi>();
  late GuidDialogBox storiesDialogBox;

  Guide(this.context, this.guideData) {
    storiesDialogBox = GuidDialogBox(onFinishedStories: onStoryFinished);

    Stream stream = Globals.globalClickedPoiStream.stream;
    stream.listen((mapPoi) {
      mapPoiClicked(mapPoi);
    });
    // StoriesDialogBox(key: UniqueKey());
  }

  Future<void> mapPoiClicked(MapPoi mapPoi) async {
    context.read<GuideBloc>().add(playPoiEvent(mapPoi: mapPoi));
  }

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
      storiesDialogBox.setPoiToPlay(_poisToPlay);
    }
  }

  void onStoryFinished() {
    print("onStoryFinished");
    _poisToPlay.clear();
    _poisToPlay.addAll(_queuedPoisToPlay);
    if (!_poisToPlay.isEmpty) {
      storiesDialogBox.setPoiToPlay(_poisToPlay);
    }
  }

  void askPoi(MapPoi poi) {
    guideState = GuideState.working;
    preHandlePoi(poi);
  }

  // lunch before handle poi
  void preHandlePoi(MapPoi mapPoi) {
    Globals.setMainMapPoi(mapPoi);
    Globals.globalUserMap.userMapState?.highlightMapPoi(mapPoi);
    Globals.globalUserMap.userMapState?.showNextButton();
  }
}

class GuidDialogBox extends StatefulWidget {
  final dynamic onFinishedStories;
  final StreamController<Map<String, MapPoi>> queuedPoisToPlayController =
      StreamController<HashMap<String, MapPoi>>.broadcast();

  GuidDialogBox({required this.onFinishedStories}) {
    print(queuedPoisToPlayController);
  }

  setPoiToPlay(Map<String, MapPoi> mapPois) {
    queuedPoisToPlayController.add(mapPois);
  }

  @override
  State<StatefulWidget> createState() {
    return _GuidDialogBoxState(queuedPoisToPlayController);
  }
}

class _GuidDialogBoxState extends State<GuidDialogBox> {
  late Stream queuedPoisListStream;

  _GuidDialogBoxState(
      StreamController<Map<String, MapPoi>> queuedPoisToPlayController) {
    ValueChanged<StoryItem> onShowStory = (s) async {
      context.read<GuideBloc>().add(SetCurrentPoiEvent(storyItem: s));
    };

    queuedPoisListStream = queuedPoisToPlayController.stream;
    queuedPoisListStream.listen((event) {
      context.read<GuideBloc>().add(
            SetStoriesListEvent(
                poisToPlay: event,
                onShowStory: onShowStory,
                onFinishedFunc: widget.onFinishedStories,
                onStoryTap: (story) {
                  context.read<GuideBloc>().add(ShowFullPoiInfoEvent());
                },
                onVerticalSwipeComplete: (Direction? d) {
                  context.read<GuideBloc>().add(ShowFullPoiInfoEvent());
                }),
          );
    });
  }

  Widget buildSearchingWidget() {
    return Dialog(
        insetPadding: const EdgeInsets.all(Constants.edgesDist),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Constants.padding),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Column(
          children: [
            Spacer(),
            Stack(children: <Widget>[
              Container(
                alignment: Alignment.topLeft,
                height: 239,
                width: MediaQuery.of(context).size.width - 30,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(34),
                  boxShadow: [
                    BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.25),
                        offset: Offset(0, 0),
                        blurRadius: 20)
                  ],
                  color: Color.fromRGBO(255, 255, 255, 0.75),
                ),
                child: Column(
                  children: [
                    Padding(
                        padding: EdgeInsets.only(left: 11, top: 16),
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Scanning...",
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontStyle: FontStyle.normal,
                                fontWeight: FontWeight.w500,
                                fontSize: 22,
                                letterSpacing: 0.35,
                                color: Colors.black,
                                height: 28 / 22,
                              ),
                            ))),
                    Padding(
                        padding: EdgeInsets.only(left: 11, right: 11, top: 16),
                        child: Text(
                          "Auto Trip is searching for interesting places near you. \n you can adjust the search by selecting your interests in the preferences screen.",
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontStyle: FontStyle.normal,
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                            letterSpacing: 0,
                            color: Color(0xff6C6F70),
                            height: 1.5,
                          ),
                        )),
                  ],
                ),
              ),
            ]),
          ],
        ));
  }

  Widget buildStoriesWidget(state) {
    return Column(
      children: [
        Spacer(),
        Dialog(
            insetPadding: const EdgeInsets.all(Constants.edgesDist),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Constants.padding),
            ),
            elevation: 0,
            backgroundColor: Colors.transparent,
            child: Column(children: [
              Stack(
                children: <Widget>[
                  Container(
                      alignment: Alignment.bottomCenter,
                      height: MediaQuery.of(context).size.height / 2.2,
                      width: MediaQuery.of(context).size.width - 30,
                      padding: const EdgeInsets.only(
                          left: Constants.padding,
                          top: Constants.avatarRadius + Constants.padding,
                          right: Constants.padding,
                          bottom: Constants.padding),
                      margin:
                          const EdgeInsets.only(top: Constants.avatarRadius),
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        color: Colors.white,
                        // borderRadius: BorderRadius.circular(Constants.padding),
                        // boxShadow: const [
                        //   BoxShadow(
                        //       color: Colors.black,
                        //       offset: Offset(0, 5),
                        //       blurRadius: 10),
                        // ]
                        borderRadius: BorderRadius.circular(34),
                        boxShadow: [
                          BoxShadow(
                              color: Color.fromRGBO(0, 0, 0, 0.25),
                              offset: Offset(0, 0),
                              blurRadius: 20)
                        ],
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: 15),
                          ),
                          Expanded(child: state.storyView),
                          Padding(
                              padding: EdgeInsets.only(top: 15),
                              child: Container(
                                  child: Globals.globalAudioApp, height: 56)),
                          Container(
                            child: UniformButtons.getPreferenceButton(
                                onPressed: () {
                              Navigator.pushNamed(
                                  context, '/favorite-categories-screen');
                            }),
                          )
                        ],
                      )),
                  Positioned(
                    left: Constants.padding,
                    right: Constants.padding,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onVerticalDragUpdate: (details) {
                              int sensitivity = 8;
                              if (details.delta.dy < -sensitivity) {
                                // Up Swipe
                                context
                                    .read<GuideBloc>()
                                    .add(ShowFullPoiInfoEvent());
                              }
                            },
                            child: CircleAvatar(
                                backgroundColor: Colors.transparent,
                                radius: Constants.avatarRadius,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(Constants.avatarRadius)),
                                  child: CachedNetworkImage(
                                    imageUrl: state.currentPoi?.poi.pic ?? "",
                                    placeholder: (context, url) =>
                                        new CircularProgressIndicator(),
                                    errorWidget: (context, url, error) =>
                                        new Icon(Icons.error_outlined,
                                            size: 100),
                                  ),
                                )),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            ])),
      ],
    );
  }

  Widget buildFullPoiInfo(state) {
    double bottomIconSize = 20;
    final showPoiState = state as ShowPoiState;
    return Column(children: [
      Spacer(),
      Stack(
        children: <Widget>[
          Container(
              alignment: Alignment.bottomCenter,
              height: MediaQuery.of(context).size.height / 1.45,
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
                  Row(
                    children: [
                      Container(
                        // margin: EdgeInsets.only(
                        //     right: MediaQuery.of(context).size.width / 30),
                        width: MediaQuery.of(context).size.width / 10,
                        child: FloatingActionButton(
                          backgroundColor: Globals.globalColor,
                          heroTag: null,
                          onPressed: () {
                            context.read<GuideBloc>().add(SetLoadedStoriesEvent(
                                storyView: state.savedStoriesState.storyView,
                                controller:
                                    state.savedStoriesState.controller));
                          },
                          child:
                              const Icon(Icons.arrow_back, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  Container(
                      margin: EdgeInsets.only(top: 10),
                      child: Text(
                        showPoiState.currentPoi.poi.poiName ?? "",
                        style: TextStyle(
                          fontFamily: 'Arial',
                          fontSize: 25,
                          color: Colors.blueGrey,
                          height: 1,
                        ),
                      )),
                  Expanded(
                      child: Container(
                          alignment: Alignment.topCenter,
                          margin: EdgeInsets.only(top: 15),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: Text(
                              showPoiState.currentPoi.poi.shortDesc ?? "",
                              style: TextStyle(
                                fontFamily: 'Arial',
                                fontSize: 20,
                                color: Colors.black,
                                height: 1,
                              ),
                            ),
                          ))),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // ElevatedButton(
                        //     onPressed: () {},
                        //     child: null,
                        //     style: ButtonStyle(
                        //         foregroundColor: MaterialStateProperty.all<Color>(
                        //             Colors.white),
                        //         backgroundColor:
                        //             MaterialStateProperty.all<Color>(Colors.blueAccent),
                        //         shape: MaterialStateProperty.all<
                        //                 RoundedRectangleBorder>(
                        //             RoundedRectangleBorder(
                        //                 borderRadius: BorderRadius.circular(18.0),
                        //                 side: BorderSide(color: Colors.blueAccent)))))
                        RawMaterialButton(
                          onPressed: () {
                            Globals.globalAppLauncher.launchWaze(
                                showPoiState.currentPoi.poi.latitude,
                                showPoiState.currentPoi.poi.longitude);
                          },
                          elevation: 2.0,
                          fillColor: Colors.blue,
                          child: Icon(
                            Icons.directions,
                            size: bottomIconSize,
                          ),
                          padding: EdgeInsets.all(15.0),
                          shape: CircleBorder(),
                        ),
                        RawMaterialButton(
                          onPressed: () {},
                          elevation: 2.0,
                          fillColor: Colors.red,
                          child: Icon(
                            Icons.thumb_down,
                            size: bottomIconSize,
                          ),
                          padding: EdgeInsets.all(15.0),
                          shape: CircleBorder(),
                        ),
                        RawMaterialButton(
                          onPressed: () {},
                          elevation: 2.0,
                          fillColor: Colors.green,
                          child: Icon(
                            Icons.thumb_up,
                            size: bottomIconSize,
                          ),
                          padding: EdgeInsets.all(15.0),
                          shape: CircleBorder(),
                        ),
                        RawMaterialButton(
                          onPressed: () {
                            Share.share(
                                showPoiState.currentPoi.poi.shortDesc ?? "",
                                subject: showPoiState.currentPoi.poi.poiName);
                          },
                          elevation: 2.0,
                          fillColor: Colors.blue,
                          child: Icon(
                            Icons.share,
                            size: bottomIconSize,
                          ),
                          padding: EdgeInsets.all(15.0),
                          shape: CircleBorder(),
                        )
                      ],
                    ),
                  ),
                  Container(
                    child: UniformButtons.getPreferenceButton(onPressed: () {
                      Navigator.pushNamed(
                          context, '/favorite-categories-screen');
                    }),
                  )
                ],
              )),
          Positioned(
            left: Constants.padding,
            right: Constants.padding,
            child: GestureDetector(
              onVerticalDragUpdate: (details) {
                int sensitivity = 8;
                if (details.delta.dy > sensitivity) {
                  // Down Swipe
                  context.read<GuideBloc>().add(SetLoadedStoriesEvent(
                      storyView: state.savedStoriesState.storyView,
                      controller: state.savedStoriesState.controller));
                } else if (details.delta.dy < -sensitivity) {
                  // Up Swipe
                }
              },
              child: CircleAvatar(
                  backgroundColor: Colors.transparent,
                  radius: Constants.avatarRadius,
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(
                        Radius.circular(Constants.avatarRadius)),
                    child: CachedNetworkImage(
                      imageUrl: showPoiState.currentPoi?.poi.pic ?? "",
                      placeholder: (context, url) =>
                          new CircularProgressIndicator(),
                      errorWidget: (context, url, error) =>
                          new Icon(Icons.error_outlined, size: 100),
                    ),
                  )),
            ),
          ),
        ],
      )
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GuideBloc, GuideDialogState>(
      builder: (BuildContext context, state) {
        if (state is PoisSearchingState) {
          return buildSearchingWidget();
        } else if (state is ShowStoriesState) {
          return buildStoriesWidget(state);
        } else if (state is ShowPoiState) {
          return buildFullPoiInfo(state);
        } else {
          // } else {
          return buildSearchingWidget();
        }
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
