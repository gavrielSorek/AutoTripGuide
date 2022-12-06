part of 'guide_bloc.dart';

@immutable
abstract class GuideDialogState {}

// class GuideInitial extends GuideDialogState {}
class PoisSearchingState extends GuideDialogState {}

class ShowStoriesState extends GuideDialogState {
  final MapPoi? currentPoi;
  final StoryView storyView;
  final StoryController controller;

  ShowStoriesState(
      {this.currentPoi,
      required this.storyView,
      required this.controller}) {}
  dispose() {
    this.controller.dispose();
  }
}


class ShowPoiState extends GuideDialogState {
  final ShowStoriesState savedStoriesState;
  final MapPoi currentPoi;
  ShowPoiState(
      {required this.savedStoriesState,
        required this.currentPoi}) {}
}
