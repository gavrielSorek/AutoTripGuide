import 'dart:collection';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import '../../Adjusted Libs/story_view/adjusted_story_view.dart';
import '../../Adjusted Libs/story_view/story_controller.dart';
import '../../Adjusted Libs/story_view/story_view.dart';
import '../../General Wigets/generals.dart';
import '../globals.dart';
import '../personalize_recommendation.dart';
import '../types.dart';

part 'guide_event.dart';

part 'guide_state.dart';

class GuideBloc extends Bloc<GuideEvent, GuideDialogState> {
  GuideBloc() : super(PoisSearchingState()) {
    List<MapPoi> _poisToGuide = [];
    int currentIdx = 0;
    int maxListenedIdx = 0;
    ShowOptionalCategoriesState? _lastShowOptionalCategoriesState = null;

    void initAudioSettings() {
      Globals.globalGuideAudioPlayerHandler.onPressNext = () {
        if (Globals.globalUserMap.currentHighlightedPoi != null) {
          var poi = Globals.globalUserMap.currentHighlightedPoi;
          Globals.appEvents.poiPlaybackSkipped(
              poi!.poi.poiName!, poi.poi.Categories, poi.poi.id);
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
        if (Globals.globalUserMap.currentHighlightedPoi != null) {
          var poi = Globals.globalUserMap.currentHighlightedPoi;
          Globals.appEvents.poiPlaybackPaused(
              poi!.poi.poiName!, poi.poi.Categories, poi.poi.id);
        }
      };
      Globals.globalGuideAudioPlayerHandler.onResume = () {};
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
    }
    initAudioSettings();

    MapPoi? getNextMapPoi() {
      if (currentIdx >= _poisToGuide.length) return null;
      if (currentIdx >= maxListenedIdx) {
        maxListenedIdx = currentIdx;
        List<MapPoi> unGuidedPois =
            _poisToGuide.sublist(currentIdx, _poisToGuide.length);
        unGuidedPois.sort(PersonalizeRecommendation.sortMapPoisByDist);
        // Replace the original portion with the sorted sublist
        _poisToGuide.replaceRange(
            currentIdx, _poisToGuide.length, unGuidedPois);
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

    onGuideOnMapPoi(MapPoi currentMapPoi) {
      Globals.globalUserMap.highlightPoi(currentMapPoi);
      Globals.addGlobalVisitedPoi(VisitedPoi(
          poiName: currentMapPoi.poi.poiName,
          id: currentMapPoi.poi.id,
          time: Generals.getTime(),
          pic: currentMapPoi.poi.pic));
    }

    on<AddPoisToGuideEvent>((event, emit) {
      _poisToGuide.addAll(event.poisToGuide);
      if (state is ShowOptionalCategoriesState) {
        _lastShowOptionalCategoriesState = state as ShowOptionalCategoriesState;
      }
      if ((state is PoisSearchingState ||
          state is LoadingMorePoisState ||
          (state is ShowOptionalCategoriesState && event.startGuide))) {
        this.add(ShowNextPoiInfoEvent());
      }
      Globals.globalUserMap.setPoisScanningStatus(false);
    });

    on<ShowSearchingPoisAnimationEvent>((event, emit) {
      Globals.globalGuideAudioPlayerHandler.stop();
      // start loading animation
      Globals.globalUserMap.setPoisScanningStatus(true);
      emit(PoisSearchingState());
    });

    on<ShowLoadingMorePoisEvent>((event, emit) {
      // start loading animation
      Globals.globalUserMap.setPoisScanningStatus(true);
      emit(LoadingMorePoisState());
    });

    on<ShowNextPoiInfoEvent>((event, emit) {
      MapPoi? mapPoi = getNextMapPoi();
      if (mapPoi != null) {
        onGuideOnMapPoi(mapPoi);
        emit(ShowPoiState(currentPoi: mapPoi));
      } else {
        this.add(ShowLoadingMorePoisEvent());
      }
    });

    on<ShowPrevPoiInfoEvent>((event, emit) {
      MapPoi? mapPoi = getPrevMapPoi();
      if (mapPoi != null) {
        onGuideOnMapPoi(mapPoi);
        emit(ShowPoiState(currentPoi: mapPoi));
      }
    });

    on<playPoiEvent>((event, emit) {
      int index = _poisToGuide
          .indexWhere((mapPoi) => mapPoi.poi.id == event.mapPoi.poi.id);
      if (index != -1) {
        _poisToGuide.removeAt(index);
        if (index <= maxListenedIdx) {
          maxListenedIdx--;
        }
        if (index < currentIdx) {
          currentIdx--;
        }
      }
      _poisToGuide.insert(currentIdx, event.mapPoi);
      currentIdx++;
      Globals.globalGuideAudioPlayerHandler.stop();
      onGuideOnMapPoi(event.mapPoi);
      emit(ShowPoiState(currentPoi: event.mapPoi));
    });

    on<ShowLastOptionalCategories>((event, emit) {
      if (_lastShowOptionalCategoriesState != null) {
        Map<String, MapPoi> idToMapPoi = {};

        for (MapPoi mapPoi in _poisToGuide) {
          idToMapPoi[mapPoi.poi.id] = mapPoi;
        }

        this.add(ShowOptionalCategoriesEvent(
            pois: idToMapPoi,
            isCheckedCategory:
                _lastShowOptionalCategoriesState!.isCheckedCategory));
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
      Map<String, bool> isCheckedCategory = event.isCheckedCategory;

      if (isCheckedCategory.isEmpty) {
        // if not initialized
        categoriesToMapPois.keys.forEach((category) {
          isCheckedCategory[category] = false;
        });
      }
      emit(ShowOptionalCategoriesState(
          lastState: state is PoisSearchingState ? null : state,
          categoriesToPoisMap: categoriesToMapPois,
          isCheckedCategory: isCheckedCategory,
          idToPoisMap: event.pois,
          onShowStory: (StoryItem value) {}));
    });

    on<SetGuideState>((event, emit) {
      emit(event.state);
    });
  }
}
