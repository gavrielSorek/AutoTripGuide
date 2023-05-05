import 'dart:collection';

import 'package:bloc/bloc.dart';
import 'package:final_project/Map/map.dart';
import 'package:final_project/Map/pois_attributes_calculator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import '../../Adjusted Libs/story_view/story_controller.dart';
import '../../Adjusted Libs/story_view/story_view.dart';
import '../../General Wigets/generals.dart';
import '../../General Wigets/scrolled_text.dart';
import '../globals.dart';
import '../guide.dart';
import '../personalize_recommendation.dart';
import '../types.dart';

part 'guide_event.dart';

part 'guide_state.dart';

class GuideBloc extends Bloc<GuideEvent, GuideDialogState> {
  GuideBloc() : super(PoisSearchingState()) {
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

    StoryView createStoryView(
        StoryController controller, StoriesEvents storiesEvents, storyItems) {
      return StoryView(
        controller: controller,
        repeat: true,
        progressPosition: ProgressPosition.bottom,
        onStoryShow: storiesEvents.onShowStory,
        onComplete: () {
          storiesEvents.onStoriesFinished();
        },
        storyItems: storyItems,
        // To disable vertical swipe gestures, ignore this parameter.
        onStoryTap: storiesEvents.onStoryTap,
        onVerticalSwipeComplete: storiesEvents.onVerticalSwipeComplete,
      );
    }

    void initAudioPlayerByController(StoryController storyController) {
      Globals.globalGuideAudioPlayerHandler.onPressNext = () {
        Globals.globalGuideAudioPlayerHandler.stop();
        storyController.pause();
        storyController.next();
      };
      Globals.globalGuideAudioPlayerHandler.onPressPrev = () {
        Globals.globalGuideAudioPlayerHandler.stop();
        storyController.previous();
      };
      Globals.globalGuideAudioPlayerHandler.onPause = () {
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

      final StoryView storyView =
          createStoryView(controller, event.storiesEvents, storyItems);
      emit(ShowStoriesState(
          storyView: storyView,
          controller: controller,
          lastShowOptionalCategoriesState: lastShowOptionalCategoriesState));
    });

    on<SetCurrentPoiEvent>((event, emit) {
      if (state is ShowStoriesState) {
        final state = this.state as ShowStoriesState;
        Globals.globalGuideAudioPlayerHandler.clearPlayer();
        state.controller.setProgressValue(0);
        String poiId = event.storyItem.view.key
            .toString()
            .replaceAll(RegExp(r"<|>|\[|\]|'"), '');
        MapPoi currentPoi = Globals.globalAllPois[poiId]!;
        String poiIntro = PoisAttributesCalculator.getPoiIntro(currentPoi.poi);
        Globals.globalGuideAudioPlayerHandler.setTextToPlay(
            poiIntro + " " + currentPoi!.poi.shortDesc!, 'en-US');
        Globals.globalGuideAudioPlayerHandler.trackTitle =
            currentPoi!.poi.poiName;
        Globals.globalGuideAudioPlayerHandler.picUrl = currentPoi!.poi.pic;
        Globals.globalGuideAudioPlayerHandler.play();
        Globals.globalUserMap.highlightPoi(currentPoi!);
        Globals.addGlobalVisitedPoi(VisitedPoi(
            poiName: currentPoi!.poi.poiName,
            id: currentPoi!.poi.id,
            time: Generals.getTime(),
            pic: currentPoi!.poi.pic));
        emit(ShowStoriesState(
            currentPoi: currentPoi,
            storyView: state.storyView,
            controller: state.controller,
            lastShowOptionalCategoriesState:
                state.lastShowOptionalCategoriesState));
      }
    });

    on<ShowFullPoiInfoEvent>((event, emit) {
      if (state is ShowStoriesState) {
        Globals.globalGuideAudioPlayerHandler.pause();
        final state = this.state as ShowStoriesState;
        emit(ShowPoiState(
            savedStoriesState: state, currentPoi: state.currentPoi!));
      }
    });

    on<SetLoadedStoriesEvent>((event, emit) {
      if (state is ShowPoiState) {
        final state = this.state as ShowPoiState;
        emit(ShowStoriesState(
            storyView: event.storyView,
            controller: event.controller,
            lastShowOptionalCategoriesState:
                state.savedStoriesState.lastShowOptionalCategoriesState));
      } else if (state is ShowOptionalCategoriesState) {
        final state = this.state as ShowOptionalCategoriesState;
        emit(ShowStoriesState(
            storyView: event.storyView,
            controller: event.controller,
            lastShowOptionalCategoriesState: state));
      }
    });

    on<playPoiEvent>((event, emit) {
      Globals.globalGuideAudioPlayerHandler.stop();
      Globals.globalUserMap.highlightPoi(event.mapPoi);
      if (state is ShowStoriesState) {
        final state = this.state as ShowStoriesState;
        StoryItem requestedStoryItem = ScrolledText.textStory(
            id: event.mapPoi.poi.id,
            title: event.mapPoi.poi.poiName ?? 'No Name',
            text: event.mapPoi.poi.shortDesc,
            backgroundColor: Colors.white,
            key: Key(event.mapPoi.poi.id),
            // duration: Duration(seconds: double.infinity.toInt()))); // infinite
            duration: Duration(hours: 100));

        state.controller.setStoryViewToStoryItem(requestedStoryItem);
        emit(ShowStoriesState(
            storyView: state.storyView,
            controller: state.controller,
            lastShowOptionalCategoriesState:
                state.lastShowOptionalCategoriesState));
      } else if (event.storiesEvents != null) {
        //create story of one story
        StoryController controller = StoryController();
        initAudioPlayerByController(controller);

        Globals.globalUserMap.mapPoiActionStreamController.add(MapPoiAction(
            color: PoiIconColor.grey,
            action: PoiAction.add,
            mapPoi: event.mapPoi));

        final List<StoryItem> storyItems = [];
        storyItems.add(ScrolledText.textStory(
            id: event.mapPoi.poi.id,
            title: event.mapPoi.poi.poiName ?? 'No Name',
            text: event.mapPoi.poi.shortDesc,
            backgroundColor: Colors.white,
            key: Key(event.mapPoi.poi.id),
            // duration: Duration(seconds: double.infinity.toInt()))); // infinite
            duration: Duration(hours: 100)));

        final StoryView storyView =
            createStoryView(controller, event.storiesEvents!, storyItems);

        emit(ShowStoriesState(
            storyView: storyView,
            controller: controller,
            lastShowOptionalCategoriesState: null));
      }
    });

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
          onShowStory: event.storiesEvents.onShowStory,
          idToPoisMap: event.pois,
          onFinishedFunc: event.storiesEvents.onStoriesFinished));
    });

    on<SetGuideState>((event, emit) {
      emit(event.state);
    });
  }
}
