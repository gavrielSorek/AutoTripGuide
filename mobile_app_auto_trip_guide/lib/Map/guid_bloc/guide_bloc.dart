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
      emit(PoisSearchingState());
    });
    // on<ShowStoriesEvent>((event, emit) {
    //   // TODO: implement event handler
    // });
    on<SetStoriesListEvent>((event, emit) {
      // final state = this.state as ShowStoriesState;
      emit(
          ShowStoriesState(event.poisToPlay, onFinished: event.onFinished)
      );
    });
  }
}
