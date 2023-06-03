part of 'guide_bloc.dart';

@immutable
abstract class GuideDialogState {}

// class GuideInitial extends GuideDialogState {}
class PoisSearchingState extends GuideDialogState {}
class LoadingMorePoisState extends GuideDialogState {}
class ShowPoiState extends GuideDialogState {
  final MapPoi currentPoi;
  ShowPoiState({required this.currentPoi}) {}
}

class ShowOptionalCategoriesState extends GuideDialogState {
  final GuideDialogState? lastState;
  final Map<String, List<MapPoi>> categoriesToPoisMap;
  final Map<String,MapPoi> idToPoisMap;
  final Map<String, bool> isCheckedCategory;
  final ValueChanged<StoryItem> onShowStory;

  ShowOptionalCategoriesState({
    this.lastState,
    required this.categoriesToPoisMap,
    required this.isCheckedCategory,
    required this.onShowStory,
    required this.idToPoisMap,
  }) {}
}
