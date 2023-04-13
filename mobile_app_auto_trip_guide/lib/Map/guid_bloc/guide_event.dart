part of 'guide_bloc.dart';

abstract class GuideEvent {}

class ShowSearchingPoisAnimationEvent extends GuideEvent {}

class ShowLoadingMorePoisEvent extends GuideEvent {}

class SetStoriesListEvent extends GuideEvent {
  Map<String, MapPoi> poisToPlay;
  final StoriesEvents storiesEvents;

  SetStoriesListEvent(
      {required this.poisToPlay, required this.storiesEvents}) {}
}

class SetCurrentPoiEvent extends GuideEvent {
  StoryItem storyItem;

  SetCurrentPoiEvent({required this.storyItem}) {}
}

class playPoiEvent extends GuideEvent {
  MapPoi mapPoi;
  StoriesEvents? storiesEvents;
  playPoiEvent({required this.mapPoi, this.storiesEvents}) {}
}

class ShowFullPoiInfoEvent extends GuideEvent {
  ShowFullPoiInfoEvent() {}
}

class SetLoadedStoriesEvent extends GuideEvent {
  final StoryView storyView;
  final StoryController controller;

  SetLoadedStoriesEvent({required this.storyView, required this.controller}) {}
}

class ShowOptionalCategoriesEvent extends GuideEvent {
  final Map<String, MapPoi> pois;
  final StoriesEvents storiesEvents;
  final Map<String, bool> isCheckedCategory;

  ShowOptionalCategoriesEvent({
    required this.pois,
    required this.storiesEvents,
    required this.isCheckedCategory,
  }) {}
}
