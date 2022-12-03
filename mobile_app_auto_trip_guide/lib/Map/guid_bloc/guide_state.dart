part of 'guide_bloc.dart';

@immutable
abstract class GuideDialogState {}

// class GuideInitial extends GuideDialogState {}
class PoisSearchingState extends GuideDialogState {}

class ShowStoriesState extends GuideDialogState {
  final MapPoi? lastShownPoi;
  final MapPoi? currentPoi;
  final StoryView storyView;
  final StoryController controller;

  ShowStoriesState(
      {this.currentPoi,
      this.lastShownPoi = null,
      required this.storyView,
      required this.controller}) {}

  dispose() {
    this.controller.dispose();
  }
}
