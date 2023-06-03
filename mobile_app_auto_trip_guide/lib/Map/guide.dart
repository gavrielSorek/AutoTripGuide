import 'dart:async';
import 'dart:collection';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:final_project/Map/poi_guide_info.dart';
import 'package:final_project/Map/types.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../General Wigets/Image_from_url_list.dart';
import '../General Wigets/progress_button.dart';
import '../General Wigets/stretching_widget.dart';
import '../General Wigets/uniform_widgets.dart';
import 'guid_bloc/guide_bloc.dart';
import 'globals.dart';

import 'guide_audio_player.dart';

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
  Set<String> _alreadyInsertedPois = {};
  List<MapPoi> _queuedPoisToPlay = [];
  late GuidDialogBox storiesDialogBox;

  Guide(this.context, this.guideData) {
    Stream stream = Globals.globalClickedPoiStream.stream;
    stream.listen((mapPoiId) {
      mapPoiClicked(Globals.globalAllPois[mapPoiId]!);
    });

    storiesDialogBox = GuidDialogBox(
        onRefreshFunc: () {
          clearAllPois();
          context.read<GuideBloc>().add(ShowSearchingPoisAnimationEvent());
          Globals.globalUserMap.userMapState?.loadNewPois();
        });
  }

  Future<void> mapPoiClicked(MapPoi mapPoi) async {
    context
        .read<GuideBloc>()
        .add(playPoiEvent(mapPoi: mapPoi));
  }

  void setPoisInQueue(List<Poi> pois) {
    for (Poi poi in pois) {
      if (Globals.globalAllPois.containsKey(poi.id) && !_alreadyInsertedPois.contains(poi.id)) {
        _queuedPoisToPlay.add(Globals.globalAllPois[poi.id]!);
        _alreadyInsertedPois.add(poi.id);
      }
    }
    context.read<GuideBloc>().add(AddPoisToGuideEvent(
        poisToGuide: _queuedPoisToPlay.toList(), startGuide: true));
    _queuedPoisToPlay.clear();
  }

  void setPoisToPlay(Map<String, MapPoi> mapPois) {
    context.read<GuideBloc>().add(ShowOptionalCategoriesEvent(
        pois: mapPois,
        isCheckedCategory: HashMap<String, bool>()));
  }

  void clearAllPois() {
    _queuedPoisToPlay.clear();
  }
}

class GuidDialogBox extends StatefulWidget {
  final dynamic onRefreshFunc;

  GuidDialogBox({required this.onRefreshFunc}) {}

  @override
  State<StatefulWidget> createState() {
    return _GuidDialogBoxState();
  }
}

class _GuidDialogBoxState extends State<GuidDialogBox> {
  _GuidDialogBoxState() {}

  @override
  void didChangeDependencies() {
    Globals.globalWidgetsSizes.poiGuideBoxTotalHeight =
        MediaQuery.of(context).size.height *
            StretchingWidget.collapsedPercentFromAvailableSpace;
    super.didChangeDependencies();
  }

  Widget buildDialogContainedWidgets(List<Widget> widgetList) {
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
                child: Column(children: widgetList),
              ),
            ]),
          ],
        ));
  }

  Widget buildLoadingNewPoisWidget() {
    return buildDialogContainedWidgets([
      Padding(
          padding: EdgeInsets.only(left: 11, top: 16),
          child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Loading more POIs...",
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
    ]);
  }

  Widget buildSearchingWidget() {
    return buildDialogContainedWidgets([
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
    ]);
  }

  Widget buildOptionalCategoriesSelectionWidget(state) {
    final showOptionalCategoriesState = state as ShowOptionalCategoriesState;
    return OptionalCategoriesSelection(
        state: showOptionalCategoriesState,
        onRefreshFunc: widget.onRefreshFunc);
  }

  Widget buildPoiGuide(ShowPoiState state) {
    return PoiGuide(
      poi: state.currentPoi.poi,
      widgetOnPic:
          GuideAudioPlayer(audioHandler: Globals.globalGuideAudioPlayerHandler),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GuideBloc, GuideDialogState>(
      builder: (BuildContext context, state) {
        if (state is PoisSearchingState) {
          return Expanded(child: buildSearchingWidget());
        } else if (state is ShowPoiState) {
          return buildPoiGuide(state);
        } else if (state is ShowOptionalCategoriesState) {
          return Expanded(child: buildOptionalCategoriesSelectionWidget(state));
        } else if (state is LoadingMorePoisState) {
          return Expanded(child: buildLoadingNewPoisWidget());
        } else {
          return Expanded(child: buildSearchingWidget());
        }
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class OptionalCategoriesSelection extends StatefulWidget {
  final ShowOptionalCategoriesState state;
  final dynamic onRefreshFunc;

  OptionalCategoriesSelection(
      {required this.state,
      required this.onRefreshFunc}) {}

  @override
  State<StatefulWidget> createState() {
    return _OptionalCategoriesSelection();
  }
}

class _OptionalCategoriesSelection extends State<OptionalCategoriesSelection> {
  List<String> getImageUrlsFromCategory(List<MapPoi> items) {
    return items
        .map((item) => item.poi.pic ?? '')
        .where((url) => !url.contains('no-photography-allowed'))
        .toList();
  }

  List<Widget> buildGridView(Map<String, List<MapPoi>> categoriesMap) {
    List<String> categoriesList = categoriesMap.keys.toList();
    List<Widget> generatedList =
        List.generate(widget.state.categoriesToPoisMap.length, (index) {
      return GestureDetector(
          key: Key(categoriesList[index]),
          onTap: () => {handleSelectedCategoryClicked(categoriesList[index])},
          child: Center(
            child: Stack(children: [
              ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                child: ImageFromUrlList(
                  imageUrlList: getImageUrlsFromCategory(
                      widget.state.categoriesToPoisMap[categoriesList[index]]!),
                  height: 100,
                  width: 200,
                  fit: BoxFit.cover,
                  category: categoriesList[index],
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
                                            categoriesList[index]]!
                                        .length
                                        .toString() +
                                    ")",
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontStyle: FontStyle.normal,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  letterSpacing: 0,
                                  color: Colors.white,
                                ),
                              )),
                          Expanded(
                              child: Checkbox(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  side: BorderSide(
                                      width: 1.8, color: Colors.white),
                                  value: widget.state.isCheckedCategory[
                                          categoriesList[index]] ??
                                      false,
                                  onChanged: (value) {
                                    handleSelectedCategoryClicked(
                                        categoriesList[index]);
                                  })),
                        ],
                      )))
            ]),
          ));
    });
    generatedList.sort((a, b) => a.key.toString().compareTo(b.key.toString()));
    return generatedList;
  }

  void handleSelectedCategoryClicked(selectedCategory) {
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
          context.read<GuideBloc>().add(AddPoisToGuideEvent(
              poisToGuide: filteredMapPois.values.toList(), startGuide: true));
        }
      },
      onCountDownFinished: () {
        Set<MapPoi> filteredPois = Set();
        widget.state.isCheckedCategory.forEach((key, value) {
          filteredPois.addAll(widget.state.categoriesToPoisMap[key] ?? []);
        });
        Map<String, MapPoi> filteredMapPois = Map.fromIterable(
            filteredPois.toList(),
            key: (item) => item.poi.id,
            value: (item) => item);
        if (filteredPois.length > 0) {
          context.read<GuideBloc>().add(AddPoisToGuideEvent(
              poisToGuide: filteredMapPois.values.toList()));
        }
      },
      content: "Start Playing",
      width: 140,
      height: 40,
    );
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
                    padding: EdgeInsets.only(top: 16),
                    child: Align(
                        child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        UniformButtons.getReturnDialogButton(
                            onPressed: () {
                              context.read<GuideBloc>().add(SetGuideState(
                                  state: widget.state.lastState!));
                            },
                            enabled: widget.state.lastState != null),
                        Text(
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
                        UniformButtons.getReloadDialogButton(onPressed: () {
                          widget.onRefreshFunc();
                        })
                      ],
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
                          children:
                              buildGridView(widget.state.categoriesToPoisMap),
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

// class FullPoiInfo extends StatefulWidget {
//   final ShowPoiState showPoiState;
//   final GuideEvents storiesEvents;
//
//   FullPoiInfo(
//       {Key? key, required this.showPoiState, required this.storiesEvents})
//       : super(key: key);
//
//   @override
//   _FullPoiInfoState createState() => _FullPoiInfoState();
// }
//
// class _FullPoiInfoState extends State<FullPoiInfo> {
//   int poiPreference = 0;
//
//   @override
//   initState() {
//     super.initState();
//     Globals.globalServerCommunication
//         .getPoiPreferences(
//             widget.showPoiState.currentPoi.poi.id, Globals.globalUserInfoObj)
//         .then((value) {
//       if (mounted) {
//         setState(() {
//           poiPreference = value ?? 0;
//         });
//       }
//     });
//   }
//
//   Widget buildBottomBar() {
//     double bottomIconSize = 20;
//     return Container(
//       child: Row(children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             RawMaterialButton(
//               onPressed: () {
//                 Globals.globalAppLauncher.launchWaze(
//                     widget.showPoiState.currentPoi.poi.latitude,
//                     widget.showPoiState.currentPoi.poi.longitude);
//               },
//               elevation: 2.0,
//               fillColor: Colors.blue,
//               child: Icon(
//                 Icons.directions,
//                 size: bottomIconSize,
//               ),
//               shape: CircleBorder(),
//             ),
//             Opacity(
//               opacity: poiPreference == -1 ? 1.0 : 0.5,
//               child: RawMaterialButton(
//                 onPressed: () {
//                   Globals.appEvents.poiNavigationStarted(widget.showPoiState.currentPoi.poi.poiName ?? '', widget.showPoiState.currentPoi.poi.Categories, widget.showPoiState.currentPoi.poi.id);
//                   poiPreference = -1;
//                   Globals.globalServerCommunication.insertPoiPreferences(
//                       widget.showPoiState.currentPoi.poi.id,
//                       Globals.globalUserInfoObj,
//                       poiPreference);
//                   setState(() {});
//                 },
//                 elevation: 2.0,
//                 fillColor: Colors.red,
//                 child: Icon(
//                   Icons.thumb_down,
//                   size: bottomIconSize,
//                 ),
//                 shape: CircleBorder(),
//               ),
//             ),
//             Opacity(
//               opacity: poiPreference == 1 ? 1.0 : 0.5,
//               child: RawMaterialButton(
//                 onPressed: () {
//                   poiPreference = 1;
//                   Globals.globalServerCommunication.insertPoiPreferences(
//                       widget.showPoiState.currentPoi.poi.id,
//                       Globals.globalUserInfoObj,
//                       poiPreference);
//                   setState(() {});
//                 },
//                 elevation: 2.0,
//                 fillColor: Colors.green,
//                 child: Icon(
//                   Icons.thumb_up,
//                   size: bottomIconSize,
//                 ),
//                 shape: CircleBorder(),
//               ),
//             ),
//             RawMaterialButton(
//               onPressed: () {
//                 Globals.appEvents.poiShared(widget.showPoiState.currentPoi.poi.poiName ?? '', widget.showPoiState.currentPoi.poi.Categories, widget.showPoiState.currentPoi.poi.id);
//                 Share.share(widget.showPoiState.currentPoi.poi.shortDesc ?? "",
//                     subject: widget.showPoiState.currentPoi.poi.poiName);
//               },
//               elevation: 2.0,
//               fillColor: Colors.blue,
//               child: Icon(
//                 Icons.share,
//                 size: bottomIconSize,
//               ),
//               shape: CircleBorder(),
//             )
//           ],
//         ),
//       ]),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//         insetPadding: const EdgeInsets.all(Constants.edgesDist),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(Constants.padding),
//         ),
//         elevation: 0,
//         backgroundColor: Colors.transparent,
//         child: Container(
//           child: Stack(children: [
//             Container(
//                 alignment: Alignment.bottomCenter,
//                 width: MediaQuery.of(context).size.width - 30,
//                 //TODO HANDLE ALL SIZES OF SCREENS
//                 padding: const EdgeInsets.only(
//                     left: Constants.padding,
//                     top: Constants.avatarRadius + Constants.padding,
//                     right: Constants.padding,
//                     bottom: Constants.padding),
//                 margin: const EdgeInsets.only(top: Constants.avatarRadius),
//                 decoration: BoxDecoration(
//                   shape: BoxShape.rectangle,
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(34),
//                   boxShadow: [
//                     BoxShadow(
//                         color: Color.fromRGBO(0, 0, 0, 0.25),
//                         offset: Offset(0, 0),
//                         blurRadius: 20)
//                   ],
//                 ),
//                 child: Column(children: [
//                   Padding(
//                     padding: EdgeInsets.only(left: 24, right: 0),
//                     child: Row(
//                       children: [
//                         Flexible(
//                           child: Container(
//                             child: Text(
//                               widget.showPoiState.currentPoi.poi.poiName ?? "",
//                               overflow: TextOverflow.ellipsis,
//                               style: TextStyle(
//                                   color: Colors.black,
//                                   fontFamily: 'Inter',
//                                   fontSize: 22,
//                                   letterSpacing: 0.3499999940395355,
//                                   fontWeight: FontWeight.normal,
//                                   height: 1.2727272727272727),
//                               textAlign: TextAlign.left,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   Expanded(
//                       child: Container(
//                           alignment: Alignment.topCenter,
//                           child: SingleChildScrollView(
//                               scrollDirection: Axis.vertical,
//                               child: Padding(
//                                 padding: EdgeInsets.only(left: 24, right: 24),
//                                 child: Text(
//                                   widget.showPoiState.currentPoi.poi
//                                           .shortDesc ??
//                                       "",
//                                   style: TextStyle(
//                                       color: Color(0xff6C6F70),
//                                       fontFamily: 'Inter',
//                                       fontSize: 16,
//                                       letterSpacing: 0,
//                                       fontWeight: FontWeight.normal,
//                                       height: 1.5),
//                                   textAlign: TextAlign.left,
//                                 ),
//                               )))),
//                   buildBottomBar(),
//                 ])),
//             Positioned(
//               left: Constants.padding,
//               right: Constants.padding,
//               child: GestureDetector(
//                 onVerticalDragUpdate: (details) {
//                   int sensitivity = 8;
//                   if (details.delta.dy > sensitivity) {
//                     // Down Swipe
//
//                     context.read<GuideBloc>().add(SetLoadedStoriesEvent(
//                         adjustedStoryView:
//                             widget.showPoiState.savedStoriesState.adjustedStoryView,
//                         controller:
//                             widget.showPoiState.savedStoriesState.controller));
//                   } else if (details.delta.dy < -sensitivity) {
//                     // Up Swipe
//                   }
//                 },
//                 child: GuideImageWidget(
//                     imagePath: widget.showPoiState.currentPoi.poi.pic ?? ""),
//               ),
//             ),
//             Positioned(
//               top: Constants.avatarRadius,
//               right: Constants.sidesMarginOfButtons,
//               child: Container(
//                   child: UniformButtons.getGuidePreferencesButton(
//                       onPressed: () {
//                         context.read<GuideBloc>().add(
//                             ShowOptionalCategoriesEvent(
//                                 pois:
//                                     widget
//                                         .showPoiState
//                                         .savedStoriesState
//                                         .lastShowOptionalCategoriesState!
//                                         .idToPoisMap,
//                                 storiesEvents: widget.storiesEvents,
//                                 isCheckedCategory: widget
//                                     .showPoiState
//                                     .savedStoriesState
//                                     .lastShowOptionalCategoriesState!
//                                     .isCheckedCategory));
//                       },
//                       enabled: widget.showPoiState.savedStoriesState
//                               .lastShowOptionalCategoriesState !=
//                           null)),
//             ),
//             Positioned(
//                 top: Constants.avatarRadius,
//                 child: UniformButtons.getReturnDialogButton(onPressed: () {
//                   context.read<GuideBloc>().add(SetLoadedStoriesEvent(
//                       adjustedStoryView:
//                           widget.showPoiState.savedStoriesState.adjustedStoryView,
//                       controller:
//                           widget.showPoiState.savedStoriesState.controller));
//                 }))
//           ]),
//         ));
//   }
// }

class GuideImageWidget extends StatelessWidget {
  final String imagePath;

  const GuideImageWidget({Key? key, required this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: Colors.transparent,
      radius: Constants.avatarRadius,
      child: Container(
        margin: const EdgeInsets.only(
          left: Constants.sidesMarginOfPic,
          right: Constants.sidesMarginOfPic,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(50)),
          child: CachedNetworkImage(
            imageUrl: imagePath,
            height: 180,
            width: 220,
            fit: BoxFit.fill,
            placeholder: (context, url) => new CircularProgressIndicator(),
            errorWidget: (context, url, error) =>
                new Icon(Icons.error_outlined, size: 100),
          ),
        ),
      ),
    );
  }
}
