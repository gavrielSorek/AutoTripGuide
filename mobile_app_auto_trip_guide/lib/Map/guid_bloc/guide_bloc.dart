import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import '../../Adjusted Libs/story_view/story_controller.dart';
import '../../Adjusted Libs/story_view/story_view.dart';
import '../../General Wigets/generals.dart';
import '../../General Wigets/scrolled_text.dart';
import '../audio_player_controller.dart';
import '../globals.dart';
import '../types.dart';

part 'guide_event.dart';

part 'guide_state.dart';

class GuideBloc extends Bloc<GuideEvent, GuideDialogState> {
  GuideBloc() : super(PoisSearchingState()) {
    on<ShowSearchingPoisAnimationEvent>((event, emit) {
      // start loading animation
      Globals.globalUserMap.setLoadingAnimationState(true);
      emit(PoisSearchingState());
    });
    on<SetStoriesListEvent>((event, emit) {
      // stop loading animation
      Globals.globalUserMap.setLoadingAnimationState(false);

      StoryController controller = StoryController();
      Globals.globalAudioApp.onPressNext = () {
        Globals.globalAudioApp.stopAudio();
        controller.pause();
        controller.next();
      };
      Globals.globalAudioApp.onPressPrev = () {
        Globals.globalAudioApp.stopAudio();
        controller.previous();
      };
      Globals.globalAudioApp.onPause = () {
        controller.pause();
      };
      Globals.globalAudioApp.onResume = () {
        controller.play();
      };
      Globals.globalAudioApp.onProgressChanged = (double progress) {
        controller.setProgressValue(progress);
      };
      Globals.globalAudioApp.onPlayerFinishedFunc = () {
        controller.next();
      };

      final List<StoryItem> storyItems = [];
      event.poisToPlay.forEach((key, mapPoi) {
        storyItems.add(ScrolledText.textStory(
            title: mapPoi.poi.poiName ?? 'No Name',
            text: mapPoi.poi.shortDesc,
            backgroundColor: Colors.blueGrey.shade200,
            key: Key(mapPoi.poi.id),
            // duration: Duration(seconds: double.infinity.toInt()))); // infinite
            duration: Duration(hours: 100))); // infinite
      });

      StoryView storyView = StoryView(
        controller: controller,
        repeat: true,
        progressPosition: ProgressPosition.bottom,
        onStoryShow: event.onShowStory,
        onComplete: () {
          event.onFinishedFunc();
        },
        storyItems:
            storyItems, // To disable vertical swipe gestures, ignore this parameter.
      );
      emit(ShowStoriesState(storyView: storyView, controller: controller));
    });
    on<SetCurrentPoiEvent>((event, emit) {
      if (state is ShowStoriesState) {
        final state = this.state as ShowStoriesState;
        Globals.globalAudioApp.clearPlayer();
        state.controller.setProgressValue(0);
        String poiId =
        event.storyItem.view.key.toString().replaceAll(RegExp(r"<|>|\[|\]|'"), '');
        MapPoi currentPoi = Globals.globalAllPois[poiId]!;
        Globals.globalAudioApp.setText(
            currentPoi!.poi.shortDesc!, currentPoi!.poi.language ?? 'en');
        Globals.globalAudioApp.playAudio();
        Globals.globalUserMap.highlightPoi(currentPoi!);
        Globals.addGlobalVisitedPoi(VisitedPoi(
            poiName: currentPoi!.poi.poiName,
            id: currentPoi!.poi.id,
            time: Generals.getTime(),
            pic: currentPoi!.poi.pic));
        emit(ShowStoriesState(
            currentPoi: currentPoi,
            storyView: state.storyView,
        controller: state.controller));
      }
    });

    on<ShowFullPoiInfoEvent>((event, emit) {
      if (state is ShowStoriesState) {
        final state = this.state as ShowStoriesState;
        emit(ShowPoiState(savedStoriesState: state, currentPoi: state.currentPoi!));
      }
    });

    on<SetLoadedStoriesEvent>((event, emit) {
      emit(ShowStoriesState( storyView: event.storyView,
          controller: event.controller));
    });
  }
}
