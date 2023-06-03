part of 'guide_bloc.dart';

abstract class GuideEvent {}

class ShowSearchingPoisAnimationEvent extends GuideEvent {}

class ShowLoadingMorePoisEvent extends GuideEvent {}

class SetStoriesListEvent extends GuideEvent {
  Map<String, MapPoi> poisToPlay;
  final GuideEvents storiesEvents;

  SetStoriesListEvent(
      {required this.poisToPlay, required this.storiesEvents}) {}
}

class SetCurrentPoiEvent extends GuideEvent {
  StoryItem storyItem;

  SetCurrentPoiEvent({required this.storyItem}) {}
}

class playPoiEvent extends GuideEvent {
  MapPoi mapPoi;
  GuideEvents? storiesEvents;
  playPoiEvent({required this.mapPoi, this.storiesEvents}) {}
}

class AddPoisToGuideEvent extends GuideEvent{
  final List<MapPoi> poisToGuide;
  AddPoisToGuideEvent({required this.poisToGuide}) {}

}

class ShowFullPoiInfoEvent extends GuideEvent {
  MapPoi mapPoi;
  ShowFullPoiInfoEvent({required this.mapPoi}) {}
}

class ShowFullPoiInfoByIdxEvent extends GuideEvent {
  int idx;
  ShowFullPoiInfoByIdxEvent({required this.idx}) {}
}

class SetLoadedStoriesEvent extends GuideEvent {
  final AdjustedStoryView adjustedStoryView;
  final StoryController controller;

  SetLoadedStoriesEvent({required this.adjustedStoryView, required this.controller}) {}
}

class ShowOptionalCategoriesEvent extends GuideEvent {
  final Map<String, MapPoi> pois;
  final GuideEvents storiesEvents;
  final Map<String, bool> isCheckedCategory;

  ShowOptionalCategoriesEvent({
    required this.pois,
    required this.storiesEvents,
    required this.isCheckedCategory,
  }) {}
}

class SetGuideState extends GuideEvent {
  final GuideDialogState state;

  SetGuideState({required this.state}) {}
}
