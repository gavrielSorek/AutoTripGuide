part of 'guide_bloc.dart';

@immutable
abstract class GuideDialogState {}

// class GuideInitial extends GuideDialogState {}
class PoisSearchingState extends GuideDialogState {}
class LoadingMorePoisState extends GuideDialogState {}
class ShowStoriesState extends GuideDialogState {
  final MapPoi? currentPoi;
  final AdjustedStoryView adjustedStoryView;
  final StoryController controller;
  final ShowOptionalCategoriesState? lastShowOptionalCategoriesState;

  ShowStoriesState(
      {this.currentPoi, required this.adjustedStoryView, required this.controller,required this.lastShowOptionalCategoriesState}) {}
  dispose() {
    this.controller.dispose();
  }
}

class ShowPoiState extends GuideDialogState {
  final ShowStoriesState savedStoriesState;
  final MapPoi currentPoi;
  ShowPoiState({required this.savedStoriesState, required this.currentPoi}) {}
}

class ShowOptionalCategoriesState extends GuideDialogState {
  final GuideDialogState? lastState;
  final Map<String, List<MapPoi>> categoriesToPoisMap;
  final Map<String,MapPoi> idToPoisMap;
  final Map<String, bool> isCheckedCategory;
  final ValueChanged<StoryItem> onShowStory;
  final dynamic onFinishedFunc;

  ShowOptionalCategoriesState({
    this.lastState,
    required this.categoriesToPoisMap,
    required this.isCheckedCategory,
    required this.onShowStory,
    required this.idToPoisMap,
    this.onFinishedFunc,
  }) {}
}
