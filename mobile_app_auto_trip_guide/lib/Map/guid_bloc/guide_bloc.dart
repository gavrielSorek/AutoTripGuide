import 'dart:collection';

import 'package:bloc/bloc.dart';
import 'package:final_project/Map/map.dart';
import 'package:flutter/material.dart';
import '../../Adjusted Libs/story_view/adjusted_story_view.dart';
import '../../Adjusted Libs/story_view/story_controller.dart';
import '../../Adjusted Libs/story_view/story_view.dart';
import '../../Adjusted Libs/story_view/utils.dart';
import '../../General Wigets/generals.dart';
import '../../General Wigets/scrolled_text.dart';
import '../globals.dart';
import '../guide.dart';
import '../personalize_recommendation.dart';
import '../pois_attributes_calculator.dart';
import '../types.dart';

part 'guide_event.dart';

part 'guide_state.dart';

class GuideBloc extends Bloc<GuideEvent, GuideDialogState> {
  GuideBloc() : super(PoisSearchingState()) {

    List<MapPoi> _poisToGuide = [];


    void onGuideOnPoi(int idx) {
      Poi currentPoi = _poisToGuide[idx].poi;
      Globals.globalGuideAudioPlayerHandler.clearPlayer();
      Globals.appEvents.poiStartedPlaying(
          currentPoi.poiName!, currentPoi.Categories, currentPoi.id);
      String poiIntro = PoisAttributesCalculator.getPoiIntro(currentPoi);
      Globals.globalGuideAudioPlayerHandler
          .setTextToPlay(poiIntro + " " + currentPoi.shortDesc!, 'en-US');
      Globals.globalGuideAudioPlayerHandler.trackTitle = currentPoi.poiName;
      Globals.globalGuideAudioPlayerHandler.picUrl = currentPoi.pic;


      Globals.globalGuideAudioPlayerHandler.onPressNext = () {
        if(Globals.globalUserMap.currentHighlightedPoi != null){
          var poi =Globals.globalUserMap.currentHighlightedPoi;
          Globals.appEvents.poiPlaybackSkipped(poi!.poi.poiName!, poi.poi.Categories, poi.poi.id);
        }
        Globals.globalGuideAudioPlayerHandler.stop();
        if (_poisToGuide.length > idx + 1) {
          this.add(ShowFullPoiInfoByIdxEvent(idx: idx + 1));
        }
      };

      Globals.globalGuideAudioPlayerHandler.onPressPrev = () async {
        if (Globals.globalGuideAudioPlayerHandler.isAtBeginning) {
          if (idx - 1 > 0) {
            Globals.globalGuideAudioPlayerHandler.stop();
            this.add(ShowFullPoiInfoByIdxEvent(idx: idx - 1));
          }
        } else {
          Globals.globalGuideAudioPlayerHandler.restartPlaying();
        }
      };

      Globals.globalGuideAudioPlayerHandler.onDoublePrev = () async {
        await Globals.globalGuideAudioPlayerHandler.stop();
        if (idx - 1 > 0) {
          this.add(ShowFullPoiInfoByIdxEvent(idx: idx - 1));
        }
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
          if (_poisToGuide.length > idx + 1) {
            this.add(ShowFullPoiInfoByIdxEvent(idx: idx + 1));
          } else {
            this.add(ShowSearchingPoisAnimationEvent());
          }
        });
      };

      Globals.globalUserMap.highlightPoi(_poisToGuide[idx]);
      Globals.addGlobalVisitedPoi(VisitedPoi(
          poiName: currentPoi.poiName,
          id: currentPoi.id,
          time: Generals.getTime(),
          pic: currentPoi.pic));
    }

    on<AddPoisToGuideEvent>((event, emit) {
      _poisToGuide.addAll(event.poisToGuide);
      // TODO ShowOptionalCategoriesState MUST pass value that obliges to load stories
      if ((state is PoisSearchingState || state is ShowOptionalCategoriesState) && !_poisToGuide.isEmpty) {
        this.add(ShowFullPoiInfoByIdxEvent(idx: 0));
      }
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


    void initAudioPlayerByController(StoryController storyController) {
      Globals.globalGuideAudioPlayerHandler.onPressNext = () {
        if(Globals.globalUserMap.currentHighlightedPoi != null){
          var poi =Globals.globalUserMap.currentHighlightedPoi;
          Globals.appEvents.poiPlaybackSkipped(poi!.poi.poiName!, poi.poi.Categories, poi.poi.id);
        }
        Globals.globalGuideAudioPlayerHandler.stop();
        storyController.pause();
        storyController.next();
      };
      Globals.globalGuideAudioPlayerHandler.onPressPrev = () async {
        if (Globals.globalGuideAudioPlayerHandler.isAtBeginning) {
          await Globals.globalGuideAudioPlayerHandler.stop();
          storyController.previous();
        } else {
          Globals.globalGuideAudioPlayerHandler.restartPlaying();
        }
      };

      Globals.globalGuideAudioPlayerHandler.onDoublePrev = () async {
        await Globals.globalGuideAudioPlayerHandler.stop();
        storyController.previous();
      };

      Globals.globalGuideAudioPlayerHandler.onPause = () {
        if(Globals.globalUserMap.currentHighlightedPoi != null){
          var poi =Globals.globalUserMap.currentHighlightedPoi;
          Globals.appEvents.poiPlaybackPaused(poi!.poi.poiName!, poi.poi.Categories, poi.poi.id);
        }
        storyController.pause();
      };
      Globals.globalGuideAudioPlayerHandler.onResume = () {
        storyController.play();
      };
      Globals.globalGuideAudioPlayerHandler.onProgressChanged =
          (double progress) {
        storyController.setProgressValue(progress);
      };
      Globals.globalGuideAudioPlayerHandler.onPlayerFinishedFunc = () {
        final int secondToWaitBetweenStories = 3;
        Future.delayed(Duration(seconds: secondToWaitBetweenStories), () {
          storyController.next();
        });
      };
    }

    on<SetStoriesListEvent>((event, emit) {
      final ShowOptionalCategoriesState lastShowOptionalCategoriesState;
      if (state is ShowOptionalCategoriesState) {
        lastShowOptionalCategoriesState = state as ShowOptionalCategoriesState;
      } else {
        return;
      }

      StoryController controller = StoryController();
      initAudioPlayerByController(controller);

      List<MapPoi> poisToPlay = List.from(event.poisToPlay.values);
      for (MapPoi poi in poisToPlay) {
        Globals.globalUserMap.mapPoiActionStreamController.add(MapPoiAction(
            color: PoiIconColor.grey, action: PoiAction.add, mapPoi: poi));
      }

      // sorting the pois
      poisToPlay.sort(PersonalizeRecommendation.sortMapPoisByWeightedScore);

      final List<StoryItem> storyItems = [];
      poisToPlay.forEach((mapPoi) {
        storyItems.add(ScrolledText.textStory(
            id: mapPoi.poi.id,
            title: mapPoi.poi.poiName ?? 'No Name',
            text: mapPoi.poi.shortDesc,
            backgroundColor: Colors.white,
            key: Key(mapPoi.poi.id),
            // duration: Duration(seconds: double.infinity.toInt()))); // infinite
            duration: Duration(hours: 100))); // infinite
      });

      emit(ShowStoriesState(
          adjustedStoryView: AdjustedStoryView(maxItemsPerStory: 1, onComplete: () {  }, onVerticalSwipeComplete: (Direction? direction ) {  }, onStoryShow: (StoryItem value) {  }, progressPosition: ProgressPosition.bottom, repeat: false, controller: StoryController(), storyItems: [],),
          controller: controller,
          lastShowOptionalCategoriesState: lastShowOptionalCategoriesState));
    });

    on<ShowFullPoiInfoByIdxEvent>((event, emit){
      onGuideOnPoi(event.idx);
      Globals.globalGuideAudioPlayerHandler.play();
      emit(ShowPoiState(currentPoi: _poisToGuide[event.idx]));
    });    // on<SetCurrentPoiEvent>((event, emit) {
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
          idToPoisMap: event.pois,
          onFinishedFunc: event.storiesEvents.onStoriesFinished, onShowStory: (StoryItem value) {  }));
    });

    on<SetGuideState>((event, emit) {
      emit(event.state);
    });
  }
}
