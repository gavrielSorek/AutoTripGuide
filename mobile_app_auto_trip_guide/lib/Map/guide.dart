import 'dart:async';
import 'dart:collection';
import 'package:async/async.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:final_project/Map/types.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../Adjusted Libs/story_view/story_view.dart';
import '../Adjusted Libs/story_view/utils.dart';
import '../General Wigets/progress_button.dart';
import '../General Wigets/uniform_widgets.dart';
import 'guid_bloc/guide_bloc.dart';
import 'globals.dart';
import 'package:share_plus/share_plus.dart';

class Constants {
  Constants._();

  static const double padding = 2;
  static const double avatarRadius = 60;
  static const double edgesDist = 10;
  static const double sidesMarginOfPic = 42;
  static const double sidesMarginOfButtons = 10;
}

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
      _queuedPoisToPlay.clear();
    }
    if (poisWereEmpty && !_poisToPlay.isEmpty) {
      storiesDialogBox.setPoiToPlay(_poisToPlay);
    }
  }

  void onStoryFinished() {
    if (_queuedPoisToPlay.isEmpty) return;

    _poisToPlay.clear();
    _poisToPlay.addAll(_queuedPoisToPlay);
    if (!_poisToPlay.isEmpty) {
      storiesDialogBox.setPoiToPlay(_poisToPlay);
    }
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
  late StreamSubscription _queuedPoisListSubscription;
  late ValueChanged<StoryItem> onShowStory;

  _GuidDialogBoxState(
      StreamController<Map<String, MapPoi>> queuedPoisToPlayController) {
    onShowStory = (s) async {
      context.read<GuideBloc>().add(SetCurrentPoiEvent(storyItem: s));
    };

    queuedPoisListStream = queuedPoisToPlayController.stream;
  }

  @override
  void initState() {
    _queuedPoisListSubscription = queuedPoisListStream.listen((event) {
      context.read<GuideBloc>().add(
          ShowOptionalCategoriesEvent(
              pois: event,
              onShowStory: onShowStory,
              onFinishedFunc: widget.onFinishedStories,
              isCheckedCategory: HashMap<String, bool>()));
    });
    super.initState();
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
                                child: Container(
                                  margin: const EdgeInsets.only(
                                      left: Constants.sidesMarginOfPic,
                                      right: Constants.sidesMarginOfPic),
                                  child: ClipRRect(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(50)),
                                    child: CachedNetworkImage(
                                      imageUrl: state.currentPoi?.poi.pic ?? "",
                                      height: 180,
                                      width: 220,
                                      fit: BoxFit.fill,
                                      placeholder: (context, url) =>
                                          new CircularProgressIndicator(),
                                      errorWidget: (context, url, error) =>
                                          new Icon(Icons.error_outlined,
                                              size: 100),
                                    ),
                                  ),
                                )),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: Constants.avatarRadius,
                    right: Constants.sidesMarginOfButtons,
                    child: Container(child:
                        UniformButtons.getGuidePreferencesButton(onPressed: () {
                      context.read<GuideBloc>().add(ShowOptionalCategoriesEvent(
                          pois:
                              state.lastShowOptionalCategoriesState.idToPoisMap,
                          onShowStory:
                              state.lastShowOptionalCategoriesState.onShowStory,
                          onFinishedFunc: state
                              .lastShowOptionalCategoriesState.onFinishedFunc,
                          isCheckedCategory: state
                              .lastShowOptionalCategoriesState
                              .isCheckedCategory));
                    })),
                  )
                ],
              )
            ])),
      ],
    );
  }

  Widget buildFullPoiInfo(state) {
    double bottomIconSize = 20;
    final showPoiState = state as ShowPoiState;
    return Dialog(
      insetPadding: const EdgeInsets.all(Constants.edgesDist),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Constants.padding),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Column(children: [
        Spacer(),
        Stack(
          children: <Widget>[
            Container(
                alignment: Alignment.bottomCenter,
                height: MediaQuery.of(context).size.height / 1.55,
                width: MediaQuery.of(context).size.width - 30,
                //TODO HANDLE ALL SIZES OF SCREENS
                padding: const EdgeInsets.only(
                    left: Constants.padding,
                    top: Constants.avatarRadius + Constants.padding,
                    right: Constants.padding,
                    bottom: Constants.padding),
                margin: const EdgeInsets.only(top: Constants.avatarRadius),
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
                    // Container(
                    //     margin: EdgeInsets.only(top: 10),
                    //     child: Text(
                    //       showPoiState.currentPoi.poi.poiName ?? "",
                    //       style: TextStyle(
                    //         color: Colors.black,
                    //           fontFamily: 'Inter',
                    //           fontSize: 22,
                    //           letterSpacing: 0.3499999940395355,
                    //           fontWeight: FontWeight.normal,
                    //           height: 1.2727272727272727),
                    //       textAlign: TextAlign.left,

                    //     )),
                    Padding(
                      padding: EdgeInsets.only(left: 24, right: 0),
                      child: Row(
                        children: [
                          Flexible(
                            child: Container(
                              child: Text(
                                showPoiState.currentPoi.poi.poiName ?? "",
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: 'Inter',
                                    fontSize: 22,
                                    letterSpacing: 0.3499999940395355,
                                    fontWeight: FontWeight.normal,
                                    height: 1.2727272727272727),
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                        child: Container(
                            alignment: Alignment.topCenter,
                            child: SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                child: Padding(
                                  padding: EdgeInsets.only(left: 24, right: 24),
                                  child: Text(
                                    showPoiState.currentPoi.poi.shortDesc ?? "",
                                    style: TextStyle(
                                        color: Color(0xff6C6F70),
                                        fontFamily: 'Inter',
                                        fontSize: 16,
                                        letterSpacing: 0,
                                        fontWeight: FontWeight.normal,
                                        height: 1.5),
                                    textAlign: TextAlign.left,
                                  ),
                                )))),
                    Padding(
                        padding: EdgeInsets.only(top: 15),
                        child: Column(
                          children: [
                            Container(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  RawMaterialButton(
                                    onPressed: () {
                                      Globals.globalAppLauncher.launchWaze(
                                          showPoiState.currentPoi.poi.latitude,
                                          showPoiState
                                              .currentPoi.poi.longitude);
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
                                          showPoiState
                                                  .currentPoi.poi.shortDesc ??
                                              "",
                                          subject: showPoiState
                                              .currentPoi.poi.poiName);
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
                              child: UniformButtons.getPreferenceButton(
                                  onPressed: () {
                                Navigator.pushNamed(
                                    context, '/favorite-categories-screen');
                              }),
                            )
                          ],
                        )),
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
                    child: Container(
                      margin: const EdgeInsets.only(
                          left: Constants.sidesMarginOfPic,
                          right: Constants.sidesMarginOfPic),
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        child: CachedNetworkImage(
                          imageUrl: state.currentPoi?.poi.pic ?? "",
                          height: 180,
                          width: 250,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              new CircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
                              new Icon(Icons.error_outlined, size: 100),
                        ),
                      ),
                    )),
              ),
            ),
            Positioned(
              top: Constants.avatarRadius,
              right: Constants.sidesMarginOfButtons,
              child: Container(child:
                  UniformButtons.getGuidePreferencesButton(onPressed: () {
                context.read<GuideBloc>().add(ShowOptionalCategoriesEvent(
                    pois: state.savedStoriesState
                        .lastShowOptionalCategoriesState.idToPoisMap,
                    onShowStory: state.savedStoriesState
                        .lastShowOptionalCategoriesState.onShowStory,
                    onFinishedFunc: state.savedStoriesState
                        .lastShowOptionalCategoriesState.onFinishedFunc,
                    isCheckedCategory: state.savedStoriesState
                        .lastShowOptionalCategoriesState.isCheckedCategory));
              })),
            ),
            Positioned(
                top: Constants.avatarRadius,
                child: UniformButtons.getReturnDialogButton(onPressed: () {
                  context.read<GuideBloc>().add(SetLoadedStoriesEvent(
                      storyView: state.savedStoriesState.storyView,
                      controller: state.savedStoriesState.controller));
                }))
          ],
        )
      ]),
    );
  }

  Widget buildOptionalCategoriesSelectionWidget(state) {
    final showOptionalCategoriesState = state as ShowOptionalCategoriesState;
    return OptionalCategoriesSelection(
      state: showOptionalCategoriesState,
      onPoiClicked: () {
        context.read<GuideBloc>().add(ShowFullPoiInfoEvent());
      },
    );
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
        } else if (state is ShowOptionalCategoriesState) {
          return buildOptionalCategoriesSelectionWidget(state);
        } else {
          return buildSearchingWidget();
        }
      },
    );
  }

  @override
  void dispose() {
    _queuedPoisListSubscription.cancel();
    super.dispose();
  }
}

class OptionalCategoriesSelection extends StatefulWidget {
  final ShowOptionalCategoriesState state;
  final dynamic onPoiClicked;

  OptionalCategoriesSelection(
      {required this.state, required this.onPoiClicked}) {}

  @override
  State<StatefulWidget> createState() {
    return _OptionalCategoriesSelection();
  }
}

class _OptionalCategoriesSelection extends State<OptionalCategoriesSelection> {
  static String getImageFromCategory(List<MapPoi> items) {
    return items[0].poi.pic ?? '';
  }

  void handleSelectedCatrgotyClicked(selectedCategory) {
    bool currentValue =
        (widget.state.isCheckedCategory[selectedCategory] ?? false);
    setState(() {
      widget.state.isCheckedCategory[selectedCategory] = !currentValue;
    });
    //Handle the 'All' CASE
    if (selectedCategory == 'All') {
      for (String key in widget.state.categoriesToPoisMap.keys) {
        setState(() {
          widget.state.isCheckedCategory[key] = !currentValue;
        });
      }
    }
    if (currentValue) {
      setState(() {
        widget.state.isCheckedCategory['All'] = false;
      });
    }
    num selected = widget.state.isCheckedCategory.values.where((x) => x).length;
    num total = widget.state.categoriesToPoisMap.keys.length;
    if (selected + 1 >= total) {
      setState(() {
        widget.state.isCheckedCategory['All'] = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ProgressButton playButton = ProgressButton(
      color: Colors.blue,
      fillDuration: Duration(seconds: 10),
      onPressed: () {
        Set<MapPoi> filteredPois = Set();
        widget.state.isCheckedCategory.forEach((key, value) {
          if (value) {
            filteredPois.addAll(widget.state.categoriesToPoisMap[key] ?? []);
          }
        });
        Map<String, MapPoi> filteredMapPois = Map.fromIterable(
            filteredPois.toList(),
            key: (item) => item.poi.id,
            value: (item) => item);
        if (filteredPois.length > 0) {
          context.read<GuideBloc>().add(
                SetStoriesListEvent(
                    poisToPlay: filteredMapPois,
                    onShowStory: widget.state.onShowStory,
                    onFinishedFunc: widget.state.onFinishedFunc,
                    onStoryTap: (story) {
                      widget.onPoiClicked();
                    },
                    onVerticalSwipeComplete: (Direction? d) {
                      widget.onPoiClicked();
                    }),
              );
        }
      },
      content: "Start Playing",
      width: 140,
      height: 40,
    );
    List<String> categoriesList =
        widget.state.categoriesToPoisMap.keys.toList();
    return Dialog(
        insetPadding: const EdgeInsets.all(Constants.edgesDist),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Constants.padding),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
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
            width: double.infinity,
            height: double.infinity,
            child: Column(
              children: [
                Padding(
                    padding: EdgeInsets.only(left: 11, top: 16),
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.only(left: 11, right: 11),
                          child: Text(
                            widget.state.idToPoisMap.keys.length.toString() +
                                " Places near you: ",
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontStyle: FontStyle.normal,
                              fontWeight: FontWeight.w500,
                              fontSize: 22,
                              letterSpacing: 0.35,
                              color: Colors.black,
                              height: 28 / 22,
                            ),
                          ),
                        ))),
                Padding(
                  padding: EdgeInsets.only(left: 11, right: 11, top: 16),
                  child: Text(
                    "Select your preferred category and start playing: ",
                    overflow: TextOverflow.visible,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                      letterSpacing: 0,
                      color: Color(0xff6C6F70),
                      height: 1.5,
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onPanDown: (val) {
                      playButton.setAnimationActivityStatus(false);
                    },
                    child: Padding(
                        padding: EdgeInsets.only(left: 11, right: 11),
                        child: GridView.count(
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 0,
                          childAspectRatio: (1.45),
                          crossAxisCount: 2,
                          children: List.generate(
                              widget.state.categoriesToPoisMap.length, (index) {
                            return GestureDetector(
                                onTap: () => {
                                      handleSelectedCatrgotyClicked(
                                          categoriesList[index])
                                    },
                                child: Center(
                                  child: Stack(children: [
                                    ClipRRect(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(20)),
                                      child: CachedNetworkImage(
                                        imageUrl: getImageFromCategory(
                                            widget.state.categoriesToPoisMap[
                                                categoriesList[index]]!),
                                        height: 100,
                                        width: 200,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                        left: 3,
                                        right: 0,
                                        bottom: 0,
                                        child: Container(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                                colors: [
                                                  Color.fromRGBO(0, 0, 0, 0),
                                                  Color.fromRGBO(0, 0, 0, 0.75),
                                                ],
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                    flex: 2,
                                                    child: Text(
                                                      categoriesList[index] +
                                                          " (" +
                                                          widget
                                                              .state
                                                              .categoriesToPoisMap[
                                                                  categoriesList[
                                                                      index]]!
                                                              .length
                                                              .toString() +
                                                          ")",
                                                      style: TextStyle(
                                                        fontFamily: 'Inter',
                                                        fontStyle:
                                                            FontStyle.normal,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: 15,
                                                        letterSpacing: 0,
                                                        color: Colors.white,
                                                      ),
                                                    )),
                                                Expanded(
                                                    child: Checkbox(
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10)),
                                                        side: BorderSide(
                                                            width: 1.8,
                                                            color:
                                                                Colors.white),
                                                        value: widget.state
                                                                    .isCheckedCategory[
                                                                categoriesList[
                                                                    index]] ??
                                                            false,
                                                        onChanged: (value) {
                                                          handleSelectedCatrgotyClicked(
                                                              categoriesList[
                                                                  index]);
                                                          // //Handle the 'All' CASE
                                                          // if (categoriesList[index] ==
                                                          //     'All') {
                                                          //   for (String key in widget
                                                          //       .state
                                                          //       .categoriesToPoisMap
                                                          //       .keys) {
                                                          //     setState(() {
                                                          //       widget.state
                                                          //               .isCheckedCategory[
                                                          //           key] = value ?? false;
                                                          //     });
                                                          //   }
                                                          // }
                                                          // if (value == false) {
                                                          //   setState(() {
                                                          //     widget.state
                                                          //             .isCheckedCategory[
                                                          //         'All'] = value ?? false;
                                                          //   });
                                                          // }
                                                          // setState(() {
                                                          //   widget.state
                                                          //           .isCheckedCategory[
                                                          //       categoriesList[
                                                          //           index]] = value ??
                                                          //       false;
                                                          // });
                                                        })),
                                              ],
                                            )))
                                  ]),
                                ));
                          }),
                        )),
                  ),
                ),
                Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                    child: playButton),
              ],
            )));
  }
}
