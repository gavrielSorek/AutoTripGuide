import 'dart:async';
import 'dart:collection';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import '../../Adjusted Libs/story_view/adjusted_story_view.dart';
import '../../Adjusted Libs/story_view/story_controller.dart';
import '../../Adjusted Libs/story_view/story_view.dart';
import '../../General/generals.dart';
import '../globals.dart';
import '../personalize_recommendation.dart';
import '../pois_attributes_calculator.dart';
import '../types.dart';

part 'guide_event.dart';

part 'guide_state.dart';

class GuideBloc extends Bloc<GuideEvent, GuideDialogState> {
  GuideBloc() : super(PoisSearchingState()) {
    List<MapPoi> _poisToGuide = [];
    int nextIdx = 0;
    int minUnheardIdx = 0;
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
          await Globals.globalGuideAudioPlayerHandler.stop();
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
        if (nextIdx > 0) {
          Poi poi = _poisToGuide[nextIdx - 1].poi;
          Globals.appEvents.poiFinishedPlaying(poi.poiName ?? "Unknown", poi.Categories, poi.id);
        }
        final int secondToWaitBetweenStories = 3;
        Future.delayed(Duration(seconds: secondToWaitBetweenStories), () {
          this.add(ShowNextPoiInfoEvent());
        });
      };
    }
    initAudioSettings();

    MapPoi? getNextMapPoi() {
      if (nextIdx >= _poisToGuide.length) return null;
      if (nextIdx >= minUnheardIdx) {
        minUnheardIdx = nextIdx;
        List<MapPoi> unGuidedPois =
            _poisToGuide.sublist(nextIdx, _poisToGuide.length);
        unGuidedPois = PoisAttributesCalculator.filterMapPoisByDistance(unGuidedPois, Globals.globalUserMap.userLocation);
        unGuidedPois.sort(PersonalizeRecommendation.sortMapPoisByDist);
        // Replace the original portion with the sorted sublist
        _poisToGuide.replaceRange(
            nextIdx, _poisToGuide.length, unGuidedPois);
      }
      MapPoi nextPoi = _poisToGuide[nextIdx];
      nextIdx++;
      return nextPoi;
    }

    MapPoi? getPrevMapPoi() {
      if (nextIdx - 2 < 0) // - 2 is the prev because current is the next
        return null;
      nextIdx--;
      return _poisToGuide[nextIdx - 1];
    }

    onGuideOnMapPoi(MapPoi currentMapPoi) {
      Globals.globalUserMap.highlightPoi(currentMapPoi);
      Globals.addGlobalVisitedPoi(VisitedPoi(
          poiName: currentMapPoi.poi.poiName,
          id: currentMapPoi.poi.id,
          time: Generals.getTime(),
          pic: currentMapPoi.poi.pic));
    }

    bool isCheckedCategoryExistOrNewCategoryInPoi(List<String> poisCategories, Map<String, bool> categoriesToChecked) {
      for (String category in poisCategories) {
        if (categoriesToChecked[category] == null || categoriesToChecked[category] == true) {
          return true;
        }
      }
      return false;
    }

    bool isMainCategoryCheckedOrNewCategoryInPoi(List<String> poisCategories, Map<String, bool> categoriesToChecked) {
      if (poisCategories.isEmpty)
        return true;
      if (categoriesToChecked[poisCategories[0]] == null || categoriesToChecked[poisCategories[0]] == true)
        return true;
      return false;
    }

    on<AddPoisToGuideEvent>((event, emit) {
      if (state is ShowOptionalCategoriesState) {
        _lastShowOptionalCategoriesState = state as ShowOptionalCategoriesState;
      }

      for (MapPoi mapPoi in event.poisToGuide) {
        _lastShowOptionalCategoriesState!.idToPoisMap[mapPoi.poi.id] = mapPoi;
        if (isMainCategoryCheckedOrNewCategoryInPoi(mapPoi.poi.Categories, _lastShowOptionalCategoriesState!.isCheckedCategory))
          {
            _poisToGuide.add(mapPoi);
          }
      }

      if (state is ShowOptionalCategoriesState && event.startGuide) {
        this.add(ShowNextPoiInfoEvent());
      } else if (state is PoisSearchingState || state is LoadingMorePoisState) {
        this.add(ShowNextPoiInfoEvent());
        Globals.globalUserMap.setPoisScanningStatus(false);
      }
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
        if (index <= minUnheardIdx && nextIdx > minUnheardIdx) {
          minUnheardIdx--;
        }
        if (index < nextIdx) {
          nextIdx--;
        }
      }
      _poisToGuide.insert(nextIdx, event.mapPoi);
      nextIdx++;
      Globals.globalGuideAudioPlayerHandler.stop();
      onGuideOnMapPoi(event.mapPoi);
      emit(ShowPoiState(currentPoi: event.mapPoi));
    });

    on<ShowLastOptionalCategories>((event, emit) {
      Set<MapPoi> mapPoisSet = {};

      if (_lastShowOptionalCategoriesState != null) {
        mapPoisSet.addAll(_lastShowOptionalCategoriesState!.idToPoisMap.values);
      }

      mapPoisSet.addAll(_poisToGuide);

      List<MapPoi> mapPois = mapPoisSet.toList();

      this.add(ShowOptionalCategoriesEvent(
          pois: mapPois,
          isCheckedCategory: _lastShowOptionalCategoriesState?.isCheckedCategory ?? HashMap<String, bool>()));
    });

    on<ShowOptionalCategoriesEvent>((event, emit) {
      // stop loading animation
      Globals.globalUserMap.setPoisScanningStatus(false);
      this.add(ClearAllPois());

      Globals.globalGuideAudioPlayerHandler.stop();
      List<MapPoi> mapPoisList = event.pois;
      // the map will not guide on far away pois
      mapPoisList = PoisAttributesCalculator.filterMapPoisByDistance(mapPoisList, Globals.globalUserMap.userLocation);
      Map<String, List<MapPoi>> categoriesToMapPois =
          HashMap<String, List<MapPoi>>();
      //patch to all categories
      categoriesToMapPois['All'] = <MapPoi>[];
      categoriesToMapPois['All']?.addAll(mapPoisList);

      mapPoisList.forEach((mapPoi) {
        String? mainCategory = mapPoi.poi.Categories.isEmpty ? null : mapPoi.poi.Categories[0];
        if (mainCategory != null) {
          if (!categoriesToMapPois.containsKey(mainCategory)) {
            categoriesToMapPois[mainCategory] = <MapPoi>[];
          }
          categoriesToMapPois[mainCategory]?.add(mapPoi);
        }
      });

      Map<String, bool> isCheckedCategory = event.isCheckedCategory;

      if (isCheckedCategory.isEmpty) {
        // if not initialized
        categoriesToMapPois.keys.forEach((category) {
          isCheckedCategory[category] = true;
        });
      }

      Map<String, MapPoi> idAndPoiMap = {};
      for (MapPoi mapPoi in mapPoisList) {
        idAndPoiMap[mapPoi.poi.id] = mapPoi;
      }

      emit(ShowOptionalCategoriesState(
          lastState: state is PoisSearchingState ? null : state,
          categoriesToPoisMap: categoriesToMapPois,
          isCheckedCategory: isCheckedCategory,
          idToPoisMap: idAndPoiMap,
          onShowStory: (StoryItem value) {}));
    });

    on<SetGuideState>((event, emit) {
      emit(event.state);
    });

    on<ClearUnheardPois>((event, emit) {
      _poisToGuide = _poisToGuide.sublist(0, minUnheardIdx);
    });

    on<ClearAllPois>((event, emit) {
      _poisToGuide = [];
      minUnheardIdx = 0;
      nextIdx = 0;
    });
  }

  
}
