part of 'guide_bloc.dart';

abstract class GuideEvent {}

class ShowSearchingPoisAnimationEvent extends GuideEvent {}

class SetStoriesListEvent extends GuideEvent {
  Map<String, MapPoi> poisToPlay;
  ValueChanged<StoryItem> onShowStory;
  dynamic onFinishedFunc;
  dynamic onStoryTap = null;
  dynamic onVerticalSwipeComplete = null;

  SetStoriesListEvent(
      {required this.poisToPlay,
      required this.onShowStory,
      this.onFinishedFunc,
      this.onStoryTap,
      this.onVerticalSwipeComplete}) {}
}

class SetCurrentPoiEvent extends GuideEvent {
  StoryItem storyItem;

  SetCurrentPoiEvent({required this.storyItem}) {}
}

class playPoiEvent extends GuideEvent {
  MapPoi mapPoi;

  playPoiEvent({required this.mapPoi}) {}
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
  ValueChanged<StoryItem> onShowStory;
  dynamic onFinishedFunc;
  final Map<String, bool> isCheckedCategory;

  ShowOptionalCategoriesEvent({
    required this.pois,
    required this.onShowStory,
    this.onFinishedFunc,
    required this.isCheckedCategory,
  }) {}
}
