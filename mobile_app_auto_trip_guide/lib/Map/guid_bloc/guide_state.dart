part of 'guide_bloc.dart';

@immutable
abstract class GuideDialogState {}

// class GuideInitial extends GuideDialogState {}
class PoisSearchingState extends GuideDialogState {}

class ShowStoriesState extends GuideDialogState {
  late Widget stories;
  final controller = StoryController();
  MapPoi? _lastShownPoi;
  MapPoi? currentPoi;
  dynamic onFinished = false;
  ShowStoriesState(Map<String, MapPoi> poisToPlay, {dynamic onFinished = null} ) {
    this.onFinished = onFinished;
    final List<StoryItem> storyItems = [];
    poisToPlay.forEach((key, mapPoi) {
      storyItems.add(ScrolledText.textStory(
          title: mapPoi.poi.poiName ?? 'No Name',
          text: mapPoi.poi.shortDesc,
          backgroundColor: Colors.blueGrey.shade200,
          key: Key(mapPoi.poi.id),
          // duration: Duration(seconds: double.infinity.toInt()))); // infinite
          duration: Duration(hours: 100))); // infinite
    });
    this.stories = StoryView(
      controller: controller,
      repeat: true,
      progressPosition: ProgressPosition.bottom,
      onStoryShow: (s) async {
        Globals.globalAudioApp.stopAudio();
        controller.setProgressValue(0);
        String poiId =
            s.view.key.toString().replaceAll(RegExp(r"<|>|\[|\]|'"), '');
        currentPoi = poisToPlay[poiId]!;
        Globals.globalAudioApp.setText(currentPoi!.poi.shortDesc!, currentPoi!.poi.language ?? 'en');
        Globals.globalAudioApp.playAudio();
        if (_lastShownPoi != null) {
          Globals.globalUserMap.userMapState?.unHighlightMapPoi(_lastShownPoi!);
        }
        Globals.globalUserMap.userMapState?.highlightMapPoi(currentPoi!);
        _lastShownPoi = currentPoi;

        Globals.addGlobalVisitedPoi(VisitedPoi(
            poiName: currentPoi!.poi.poiName,
            id: currentPoi!.poi.id,
            time: Generals.getTime(),
            pic: currentPoi!.poi.pic));
      },
      onComplete: () {
        if (onFinished != null) {
          onFinished();
        }
      },

      storyItems:
          storyItems, // To disable vertical swipe gestures, ignore this parameter.
    );
    initStoriesConfig();
  }
  initStoriesConfig() {
    Globals.globalAudioApp.onPressNext = () {
      Globals.globalAudioApp.stopAudio();
      controller.pause();
      controller.next();
    };
    Globals.globalAudioApp.onPressPrev = () {
      Globals.globalAudioApp.stopAudio();
      controller.previous();
    };
    Globals.globalAudioApp.onPause = () {
      controller.pause();
    };
    Globals.globalAudioApp.onResume = () {
      controller.play();
    };
    Globals.globalAudioApp.onProgressChanged = (double progress) {
      controller.setProgressValue(progress);
    };
    Globals.globalAudioApp.onPlayerFinishedFunc = () {
      controller.next();
    };
  }

  dispose() {
    controller.dispose();
  }
}
