part of 'guide_bloc.dart';

abstract class GuideEvent {}

class ShowSearchingPoisAnimationEvent extends GuideEvent{}

class SetStoriesListEvent extends GuideEvent{
  Map<String, MapPoi> poisToPlay;
  ValueChanged<StoryItem> onShowStory;
  dynamic onFinishedFunc;
  dynamic onStoryTap = null;
  SetStoriesListEvent({required this.poisToPlay, required this.onShowStory, this.onFinishedFunc, this.onStoryTap}) {
  }
}

class SetCurrentPoiEvent extends GuideEvent{
  StoryItem storyItem;
  SetCurrentPoiEvent({required this.storyItem}) {}
}


class ShowFullPoiInfoEvent extends GuideEvent{
  ShowFullPoiInfoEvent() {}
}

class SetLoadedStoriesEvent extends GuideEvent{
  final StoryView storyView;
  final StoryController controller;
  SetLoadedStoriesEvent({required this.storyView, required this.controller}) {}
}


