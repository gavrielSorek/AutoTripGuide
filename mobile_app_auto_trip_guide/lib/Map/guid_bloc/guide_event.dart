part of 'guide_bloc.dart';

abstract class GuideEvent {}

class ShowSearchingPoisAnimationEvent extends GuideEvent{}

class SetStoriesListEvent extends GuideEvent{
  Map<String, MapPoi> poisToPlay;
  ValueChanged<StoryItem> onShowStory;
  dynamic onFinishedFunc;
  SetStoriesListEvent({required this.poisToPlay, required this.onShowStory, this.onFinishedFunc}) {
  }
}

class SetCurrentPoiEvent extends GuideEvent{
  StoryItem storyItem;
  SetCurrentPoiEvent({required this.storyItem}) {}
}

class ShowStoriesFinishedEvent extends GuideEvent{}


