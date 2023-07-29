import 'dart:async';
import 'dart:collection';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:journ_ai/Map/poi_guide_info.dart';
import 'package:journ_ai/Map/pois_attributes_calculator.dart';
import 'package:journ_ai/Map/types.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../General/Image_from_url_list.dart';
import '../General/progress_button.dart';
import '../General/uniform_widgets.dart';
import 'guid_bloc/guide_bloc.dart';
import 'globals.dart';
import 'guide_audio_player.dart';

extension StringExtension on String {
  String removeParenthesesAndBrackets() {
    return this.replaceAll(RegExp(r'(\(.*?\)|\[.*?\])'), '');
  }
}

class Constants {
  Constants._();

  static const double padding = 2;
  static const double avatarRadius = 60;
  static const double edgesDist = 17;
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
    Stream deepLinkPoisIdStream = Globals.globalsIdsFromDeepLinksBuffer.stream;
    stream.listen((mapPoiId) {
      mapPoiClicked(Globals.globalAllPois[mapPoiId]!);
    });

    deepLinkPoisIdStream.listen((mapPoiId) async{
      Poi? poi = await Globals.globalServerCommunication.getPoiById(mapPoiId);
      if (poi != null)
        {
          _alreadyInsertedPois.add(poi.id); // cause not to show the filter screen after/ in the middle
          context.read<GuideBloc>().add(playPoiEvent(mapPoi: MapPoi(poi)));
        }
    });
    storiesDialogBox = GuidDialogBox();
  }

  void reloadPois() {
    clearAllPois();
    context.read<GuideBloc>().add(ClearAllPois());
    context.read<GuideBloc>().add(ShowSearchingPoisAnimationEvent());
  }

  Future<void> mapPoiClicked(MapPoi mapPoi) async {
    context.read<GuideBloc>().add(playPoiEvent(mapPoi: mapPoi));
  }

  void setPoisInQueue(List<Poi> pois) {
    bool isFirstInQ = _alreadyInsertedPois.isEmpty;
    for (Poi poi in pois) {
      if (Globals.globalAllPois.containsKey(poi.id) &&
          !_alreadyInsertedPois.contains(poi.id)) {
        _queuedPoisToPlay.add(Globals.globalAllPois[poi.id]!);
        _alreadyInsertedPois.add(poi.id);
      }
    }
    if (_queuedPoisToPlay.isEmpty) return;
    if (isFirstInQ) {
      Map<String, MapPoi> idAndPoiMap = {};
      for (MapPoi mapPoi in _queuedPoisToPlay) {
        idAndPoiMap[mapPoi.poi.id] = mapPoi;
      }
      context.read<GuideBloc>().add(ShowOptionalCategoriesEvent(
          pois: idAndPoiMap, isCheckedCategory: HashMap<String, bool>()));
    } else {
      context.read<GuideBloc>().add(AddPoisToGuideEvent(
          poisToGuide: _queuedPoisToPlay.toList(), startGuide: true));
    }
    _queuedPoisToPlay.clear();
  }

  void clearAllPois() {
    _alreadyInsertedPois.clear();
    _queuedPoisToPlay.clear();
  }
}

class GuidDialogBox extends StatefulWidget {
  GuidDialogBox() {}

  @override
  State<StatefulWidget> createState() {
    return _GuidDialogBoxState();
  }
}

class _GuidDialogBoxState extends State<GuidDialogBox> {
  _GuidDialogBoxState() {}

  Widget buildDialogContainedWidgets(List<Widget> widgetList) {
    return Container(
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
    );
  }

  Widget buildLoadingNewPoisWidget() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 17),
      child: buildDialogContainedWidgets([
        Padding(
            padding: EdgeInsets.only(left: 11, top: 16),
            child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Discovering nearby places...\n\n Get ready!",
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
      ]),
    );
  }

  Widget buildSearchingWidget() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 17),
      child: buildDialogContainedWidgets([
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
              "JournAi is searching for interesting places near you. \n",
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
      ]),
    );
  }

  Widget buildOptionalCategoriesSelectionWidget(state) {
    final showOptionalCategoriesState = state as ShowOptionalCategoriesState;
    return OptionalCategoriesSelection(
        state: showOptionalCategoriesState);
  }

  Widget buildPoiGuide(ShowPoiState state) {
    // update the audio player with the relevant data of this poi
    Globals.globalGuideAudioPlayerHandler.clearPlayer();
    Globals.appEvents.poiStartedPlaying(state.currentPoi.poi.poiName!,
        state.currentPoi.poi.Categories, state.currentPoi.poi.id);
    String poiIntro =
        PoisAttributesCalculator.getPoiIntro(state.currentPoi.poi);
    Globals.globalGuideAudioPlayerHandler.setTextToPlay(
        poiIntro +
            " " +
            state.currentPoi.poi.shortDesc!.removeParenthesesAndBrackets(),
        'en-US');
    Globals.globalGuideAudioPlayerHandler.trackTitle =
        state.currentPoi.poi.poiName;
    Globals.globalGuideAudioPlayerHandler.picUrl = state.currentPoi.poi.pic;
    Globals.globalGuideAudioPlayerHandler.play();

    return PoiGuide(
      poi: state.currentPoi.poi,
      widgetOnPic:
          GuideAudioPlayer(audioHandler: Globals.globalGuideAudioPlayerHandler),
      preferencesButton: Container(
          child: UniformButtons.getGuidePreferencesButton(onPressed: () {
            context.read<GuideBloc>().add(ShowLastOptionalCategories());
          })),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GuideBloc, GuideDialogState>(
      builder: (BuildContext context, state) {
        if (state is PoisSearchingState) {
          return buildSearchingWidget();
        } else if (state is ShowPoiState) {
          return buildPoiGuide(state);
        } else if (state is ShowOptionalCategoriesState) {
          return Expanded(child: buildOptionalCategoriesSelectionWidget(state));
        } else if (state is LoadingMorePoisState) {
          return buildLoadingNewPoisWidget();
        } else {
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

class OptionalCategoriesSelection extends StatefulWidget {
  final ShowOptionalCategoriesState state;

  OptionalCategoriesSelection(
      {required this.state}) {}

  @override
  State<StatefulWidget> createState() {
    return _OptionalCategoriesSelection();
  }
}

class _OptionalCategoriesSelection extends State<OptionalCategoriesSelection> {
  List<String> getImageUrlsFromCategory(List<MapPoi> items) {
    return items
        .map((item) => item.poi.pic ?? '')
        .where((url) => (url != ''))
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
            child: Padding(
              padding: const EdgeInsets.all(8.0),
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
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          // same borderRadius as ClipRRect
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
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 3),
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
                                        true,
                                    onChanged: (value) {
                                      handleSelectedCategoryClicked(
                                          categoriesList[index]);
                                    })),
                          ],
                        )))
              ]),
            ),
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
  initState() {
    super.initState();
  }

  void onStartGuideButtonPressed() {
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
  }

  @override
  Widget build(BuildContext context) {
    ProgressButton playButton = ProgressButton(
      color: Colors.blue,
      fillDuration: Duration(seconds: 10),
      onPressed: onStartGuideButtonPressed,
      onCountDownFinished: onStartGuideButtonPressed,
      content: "Start Playing",
      width: 140,
      height: 40,
    );
    return Dialog(
        insetPadding: const EdgeInsets.only(
            left: Constants.edgesDist,
            right: Constants.edgesDist,
            bottom: Constants.edgesDist),
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
                      mainAxisAlignment: MainAxisAlignment.start,
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
                        Spacer(),
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
                      color: Colors.black87,
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
                        padding: EdgeInsets.only(left: 0, right: 0, top: 0),
                        child: GridView.count(
                          crossAxisSpacing: 0,
                          mainAxisSpacing: 0,
                          childAspectRatio: (1.45),
                          crossAxisCount: 2,
                          padding: EdgeInsets.only(bottom: 20),
                          // add bottom padding to push grid items up
                          children:
                              buildGridView(widget.state.categoriesToPoisMap),
                        )),
                  ),
                ),
                Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 36),
                    child: playButton),
              ],
            )));
  }
}

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
