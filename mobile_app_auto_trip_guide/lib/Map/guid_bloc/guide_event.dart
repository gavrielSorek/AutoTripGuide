part of 'guide_bloc.dart';

abstract class GuideEvent {}

class ShowSearchingPoisAnimationEvent extends GuideEvent{}

class SetStoriesListEvent extends GuideEvent{
  late Map<String, MapPoi> poisToPlay;
  late dynamic onFinished;
  SetStoriesListEvent({required this.poisToPlay, dynamic onFinished = null}) {
    this.onFinished = onFinished;
  }
}
class ShowStoriesFinishedEvent extends GuideEvent{}


