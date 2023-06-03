import 'dart:collection';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import '../../Adjusted Libs/story_view/adjusted_story_view.dart';
import '../../Adjusted Libs/story_view/story_controller.dart';
import '../../Adjusted Libs/story_view/story_view.dart';
import '../../General Wigets/generals.dart';
import '../globals.dart';
import '../personalize_recommendation.dart';
import '../pois_attributes_calculator.dart';
import '../types.dart';

part 'guide_event.dart';

part 'guide_state.dart';

class GuideBloc extends Bloc<GuideEvent, GuideDialogState> {
  GuideBloc() : super(PoisSearchingState()) {
    List<MapPoi> _poisToGuide = [];
    int currentIdx = 0;
    int maxListenedIdx = 0;
    ShowOptionalCategoriesState? _lastShowOptionalCategoriesState = null;

    MapPoi? getNextMapPoi() {
      if (currentIdx >= _poisToGuide.length)
        return null;
      if (currentIdx >= maxListenedIdx) {
        maxListenedIdx = currentIdx;
        List<MapPoi> unGuidedPois = _poisToGuide.sublist(currentIdx, _poisToGuide.length);
        unGuidedPois.sort(PersonalizeRecommendation.sortMapPoisByDist);
        // Replace the original portion with the sorted sublist
        _poisToGuide.replaceRange(currentIdx, _poisToGuide.length, unGuidedPois);
      }
      MapPoi nextPoi = _poisToGuide[currentIdx];
      currentIdx++;
      return nextPoi;
    }

    MapPoi? getPrevMapPoi() {
      if (currentIdx - 2 < 0) // - 2 is the prev because current is the next
        return null;
      currentIdx--;
      return _poisToGuide[currentIdx - 1];
    }

    void onGuideOnMapPoi(MapPoi currentMapPoi) {
      Globals.globalGuideAudioPlayerHandler.clearPlayer();
      Globals.appEvents.poiStartedPlaying(
          currentMapPoi.poi.poiName!, currentMapPoi.poi.Categories, currentMapPoi.poi.id);
      String poiIntro = PoisAttributesCalculator.getPoiIntro(currentMapPoi.poi);
      Globals.globalGuideAudioPlayerHandler
          .setTextToPlay(poiIntro + " " + currentMapPoi.poi.shortDesc!, 'en-US');
      Globals.globalGuideAudioPlayerHandler.trackTitle = currentMapPoi.poi.poiName;
      Globals.globalGuideAudioPlayerHandler.picUrl = currentMapPoi.poi.pic;


      Globals.globalGuideAudioPlayerHandler.onPressNext = () {
        if(Globals.globalUserMap.currentHighlightedPoi != null){
          var poi =Globals.globalUserMap.currentHighlightedPoi;
          Globals.appEvents.poiPlaybackSkipped(poi!.poi.poiName!, poi.poi.Categories, poi.poi.id);
        }
        Globals.globalGuideAudioPlayerHandler.stop();
        this.add(ShowNextPoiInfoEvent());
      };

      Globals.globalGuideAudioPlayerHandler.onPressPrev = () async {
        if (Globals.globalGuideAudioPlayerHandler.isAtBeginning) {
          this.add(ShowPrevPoiInfoEvent());
        } else {
          Globals.globalGuideAudioPlayerHandler.restartPlaying();
        }
      };

      Globals.globalGuideAudioPlayerHandler.onDoublePrev = () async {
        await Globals.globalGuideAudioPlayerHandler.stop();
        this.add(ShowPrevPoiInfoEvent());
      };

      Globals.globalGuideAudioPlayerHandler.onPause = () {
        if(Globals.globalUserMap.currentHighlightedPoi != null){
          var poi =Globals.globalUserMap.currentHighlightedPoi;
          Globals.appEvents.poiPlaybackPaused(poi!.poi.poiName!, poi.poi.Categories, poi.poi.id);
        }
      };
      Globals.globalGuideAudioPlayerHandler.onResume = () {
      };
      Globals.globalGuideAudioPlayerHandler.onProgressChanged =
          (double progress) {
        // storyController.setProgressValue(progress);
      };
      Globals.globalGuideAudioPlayerHandler.onPlayerFinishedFunc = () {
        Globals.globalGuideAudioPlayerHandler.stop();
        final int secondToWaitBetweenStories = 3;
        Future.delayed(Duration(seconds: secondToWaitBetweenStories), () {
          this.add(ShowNextPoiInfoEvent());
        });
      };

      Globals.globalUserMap.highlightPoi(currentMapPoi);
      Globals.addGlobalVisitedPoi(VisitedPoi(
          poiName: currentMapPoi.poi.poiName,
          id: currentMapPoi.poi.id,
          time: Generals.getTime(),
          pic: currentMapPoi.poi.pic));
    }

    on<AddPoisToGuideEvent>((event, emit) {
      _poisToGuide.addAll(event.poisToGuide);
      // TODO ShowOptionalCategoriesState MUST pass value that obliges to load stories
      if ((state is PoisSearchingState || state is ShowOptionalCategoriesState)) {
        this.add(ShowNextPoiInfoEvent());
      }
      Globals.globalUserMap.setPoisScanningStatus(false);
    });

    on<ShowSearchingPoisAnimationEvent>((event, emit) {
      // start loading animation
      Globals.globalUserMap.setPoisScanningStatus(true);
      emit(PoisSearchingState());
    });

    on<ShowLoadingMorePoisEvent>((event, emit) {
      // start loading animation
      Globals.globalUserMap.setPoisScanningStatus(true);
      emit(LoadingMorePoisState());
    });

    on<ShowNextPoiInfoEvent>((event, emit){
      MapPoi? mapPoi = getNextMapPoi();
      if (mapPoi != null) {
        onGuideOnMapPoi(mapPoi);
        Globals.globalGuideAudioPlayerHandler.play();
        emit(ShowPoiState(currentPoi: mapPoi));
      }
      else {
        this.add(ShowLoadingMorePoisEvent());
      }
    });

    on<ShowPrevPoiInfoEvent>((event, emit){
      MapPoi? mapPoi = getPrevMapPoi();
      if (mapPoi != null) {
        onGuideOnMapPoi(mapPoi);
        Globals.globalGuideAudioPlayerHandler.play();
        emit(ShowPoiState(currentPoi: mapPoi));
      }
    });

    on<playPoiEvent>((event, emit){
      int index = _poisToGuide.indexWhere((mapPoi) =>
      mapPoi.poi.id == event.mapPoi.poi.id);
      if (index != -1) {
        _poisToGuide.removeAt(index);
        if (index < maxListenedIdx) {
          maxListenedIdx--;
        }
      }
      _poisToGuide.insert(currentIdx, event.mapPoi);
      currentIdx++;
      Globals.globalGuideAudioPlayerHandler.stop();
      onGuideOnMapPoi(event.mapPoi);
      Globals.globalGuideAudioPlayerHandler.play();
      emit(ShowPoiState(currentPoi: event.mapPoi));
    });
    // on<SetCurrentPoiEvent>((event, emit) {
    //   if (state is ShowStoriesState) {
    //     final state = this.state as ShowStoriesState;
    //     Globals.globalGuideAudioPlayerHandler.clearPlayer();
    //     state.controller.setProgressValue(0);
    //     String poiId = event.storyItem.view.key
    //         .toString()
    //         .replaceAll(RegExp(r"<|>|\[|\]|'"), '');
    //     MapPoi currentPoi = Globals.globalAllPois[poiId]!;
    //     Globals.appEvents.poiStartedPlaying(currentPoi.poi.poiName!, currentPoi.poi.Categories, currentPoi.poi.id);
    //     String poiIntro = PoisAttributesCalculator.getPoiIntro(currentPoi.poi);
    //     Globals.globalGuideAudioPlayerHandler.setTextToPlay(
    //         poiIntro + " " + currentPoi.poi.shortDesc!, 'en-US');
    //     Globals.globalGuideAudioPlayerHandler.trackTitle =
    //         currentPoi.poi.poiName;
    //     Globals.globalGuideAudioPlayerHandler.picUrl = currentPoi.poi.pic;
    //     Globals.globalGuideAudioPlayerHandler.play();
    //     Globals.globalUserMap.highlightPoi(currentPoi);
    //     Globals.addGlobalVisitedPoi(VisitedPoi(
    //         poiName: currentPoi.poi.poiName,
    //         id: currentPoi.poi.id,
    //         time: Generals.getTime(),
    //         pic: currentPoi.poi.pic));
    //     emit(ShowStoriesState(
    //         currentPoi: currentPoi,
    //         adjustedStoryView: state.adjustedStoryView,
    //         controller: state.controller,
    //         lastShowOptionalCategoriesState:
    //             state.lastShowOptionalCategoriesState));
    //   }
    // });

    // on<ShowFullPoiInfoEvent>((event, emit) {
    //   //emit(ShowPoiState(currentPoi: event.mapPoi));
    // });

    // on<ShowFullPoiInfoEvent>((event, emit) {
    //   if (state is ShowStoriesState) {
    //     Globals.globalGuideAudioPlayerHandler.pause();
    //     final state = this.state as ShowStoriesState;
    //     Globals.appEvents.poiExpanded(state.currentPoi!.poi.poiName ?? '', state.currentPoi!.poi.Categories, state.currentPoi!.poi.id);
    //     emit(ShowPoiState(currentPoi: state.currentPoi!));
    //   }
    // });

    // on<SetLoadedStoriesEvent>((event, emit) {
    //   if (state is ShowPoiState) {
    //     final state = this.state as ShowPoiState;
    //     Globals.appEvents.poiCollapsed(state.currentPoi.poi.poiName ?? '', state.currentPoi.poi.Categories, state.currentPoi.poi.id);
    //
    //     emit(ShowStoriesState(
    //         adjustedStoryView: event.adjustedStoryView,
    //         controller: event.controller,
    //         lastShowOptionalCategoriesState:
    //             state.savedStoriesState.lastShowOptionalCategoriesState));
    //   } else if (state is ShowOptionalCategoriesState) {
    //     final state = this.state as ShowOptionalCategoriesState;
    //     emit(ShowStoriesState(
    //         adjustedStoryView: event.adjustedStoryView,
    //         controller: event.controller,
    //         lastShowOptionalCategoriesState: state));
    //   }
    // });

    // on<playPoiEvent>((event, emit) {
    //   Globals.globalGuideAudioPlayerHandler.stop();
    //   Globals.globalUserMap.highlightPoi(event.mapPoi);
    //   if (state is ShowStoriesState) {
    //     final state = this.state as ShowStoriesState;
    //     StoryItem requestedStoryItem = ScrolledText.textStory(
    //         id: event.mapPoi.poi.id,
    //         title: event.mapPoi.poi.poiName ?? 'No Name',
    //         text: event.mapPoi.poi.shortDesc,
    //         backgroundColor: Colors.white,
    //         key: Key(event.mapPoi.poi.id),
    //         // duration: Duration(seconds: double.infinity.toInt()))); // infinite
    //         duration: Duration(hours: 100));
    //
    //     state.controller.setStoryViewToStoryItem(requestedStoryItem);
    //     emit(ShowStoriesState(
    //         adjustedStoryView: state.adjustedStoryView,
    //         controller: state.controller,
    //         lastShowOptionalCategoriesState:
    //             state.lastShowOptionalCategoriesState));
    //   } else if (event.storiesEvents != null) {
    //     //create story of one story
    //     StoryController controller = StoryController();
    //     initAudioPlayerByController(controller);
    //
    //     Globals.globalUserMap.mapPoiActionStreamController.add(MapPoiAction(
    //         color: PoiIconColor.grey,
    //         action: PoiAction.add,
    //         mapPoi: event.mapPoi));
    //
    //     final List<StoryItem> storyItems = [];
    //     storyItems.add(ScrolledText.textStory(
    //         id: event.mapPoi.poi.id,
    //         title: event.mapPoi.poi.poiName ?? 'No Name',
    //         text: event.mapPoi.poi.shortDesc,
    //         backgroundColor: Colors.white,
    //         key: Key(event.mapPoi.poi.id),
    //         // duration: Duration(seconds: double.infinity.toInt()))); // infinite
    //         duration: Duration(hours: 100)));
    //
    //     final AdjustedStoryView storyView =
    //         createStoryView(controller, event.storiesEvents!, storyItems);
    //
    //     emit(ShowStoriesState(
    //         adjustedStoryView: storyView,
    //         controller: controller,
    //         lastShowOptionalCategoriesState: null));
    //   }
    // });

    on<ShowOptionalCategoriesEvent>((event, emit) {
      // stop loading animation
      Globals.globalUserMap.setPoisScanningStatus(false);

      Globals.globalGuideAudioPlayerHandler.stop();
      List<MapPoi> mapPoisList = event.pois.values.toList();
      Map<String, List<MapPoi>> categoriesToMapPois =
          HashMap<String, List<MapPoi>>();
      //patch to all categories
      categoriesToMapPois['All'] = <MapPoi>[];
      categoriesToMapPois['All']?.addAll(mapPoisList);

      mapPoisList.forEach((mapPoi) {
        mapPoi.poi.Categories.forEach((category) {
          if (!categoriesToMapPois.containsKey(category)) {
            categoriesToMapPois[category] = <MapPoi>[];
          }
          categoriesToMapPois[category]?.add(mapPoi);
        });
      });
      Map<String, bool>isCheckedCategory = event.isCheckedCategory;

      if (isCheckedCategory.isEmpty) { // if not initialized
        categoriesToMapPois.keys.forEach((category) {
          isCheckedCategory[category] = false;
        });
      }
      emit(ShowOptionalCategoriesState(
          lastState: state is PoisSearchingState ? null : state,
          categoriesToPoisMap: categoriesToMapPois,
          isCheckedCategory: isCheckedCategory,
          idToPoisMap: event.pois, onShowStory: (StoryItem value) {  }));
    });

    on<SetGuideState>((event, emit) {
      emit(event.state);
    });
  }
}
