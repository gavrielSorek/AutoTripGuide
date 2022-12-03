part of 'guide_bloc.dart';

abstract class GuideEvent {}

class ShowSearchingPoisAnimationEvent extends GuideEvent{}

class SetStoriesListEvent extends GuideEvent{
  Map<String, MapPoi> poisToPlay;
  ValueChanged<StoryItem> onShowStory;
  StoryController storyController;
  dynamic onFinishedFunc;
  SetStoriesListEvent({required this.poisToPlay, required this.onShowStory, required this.storyController, this.onFinishedFunc}) {
  }
}

class SetCurrentPoiEvent extends GuideEvent{
  StoryController controller;
  StoryItem storyItem;
  SetCurrentPoiEvent({required this.storyItem, required this.controller}) {}
}

class ShowStoriesFinishedEvent extends GuideEvent{}


