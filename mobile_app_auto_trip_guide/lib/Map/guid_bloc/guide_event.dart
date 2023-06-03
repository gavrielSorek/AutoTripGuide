part of 'guide_bloc.dart';

abstract class GuideEvent {}

class ShowSearchingPoisAnimationEvent extends GuideEvent {}

class ShowLoadingMorePoisEvent extends GuideEvent {}

class ShowNextPoiInfoEvent extends GuideEvent {}

class ShowPrevPoiInfoEvent extends GuideEvent {}


class playPoiEvent extends GuideEvent {
  MapPoi mapPoi;
  playPoiEvent({required this.mapPoi}) {}
}

class AddPoisToGuideEvent extends GuideEvent{
  final List<MapPoi> poisToGuide;
  bool startGuide;
  AddPoisToGuideEvent({required this.poisToGuide, this.startGuide = false}) {}

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
  final Map<String, bool> isCheckedCategory;

  ShowOptionalCategoriesEvent({
    required this.pois,
    required this.isCheckedCategory,
  }) {}
}

class ShowLastOptionalCategories extends GuideEvent {
}

class SetGuideState extends GuideEvent {
  final GuideDialogState state;

  SetGuideState({required this.state}) {}
}
