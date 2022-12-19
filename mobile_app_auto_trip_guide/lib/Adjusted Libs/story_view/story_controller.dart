import 'dart:ffi';

import 'package:rxdart/rxdart.dart';

enum PlaybackState { pause, play, next, previous }

/// Controller to sync playback between animated child (story) views. This
/// helps make sure when stories are paused, the animation (gifs/slides) are
/// also paused.
/// Another reason for using the controller is to place the stories on `paused`
/// state when a media is loading.
class StoryController {
  /// Stream that broadcasts the playback state of the stories.
  final playbackNotifier = BehaviorSubject<PlaybackState>();
  /// Stream that broadcasts the wanted duration of the current story.
  final durationNotifier = BehaviorSubject<Duration>();
  /// Stream that broadcasts the wanted duration with beginning and end.
  final progressNotifier = BehaviorSubject<double>();
  /// Stream that broadcasts the wanted id of wanted story
  final wantedStoryItemIdNotifier = BehaviorSubject<String>();

  /// Notify listeners with a [PlaybackState.pause] state
  void pause() {
    playbackNotifier.add(PlaybackState.pause);
  }

  /// Notify listeners with a [PlaybackState.play] state
  void play() {
    playbackNotifier.add(PlaybackState.play);
  }

  void next() {
    playbackNotifier.add(PlaybackState.next);
  }

  void previous() {
    playbackNotifier.add(PlaybackState.previous);
  }

  void setCurrentDuration(Duration duration) {
    durationNotifier.add(duration);
  }

  void setProgressValue(double value) {
    progressNotifier.add(value);
  }
  /// Remember to call dispose when the story screen is disposed to close
  /// the notifier stream.
  void dispose() {
    playbackNotifier.close();
    durationNotifier.close();
    progressNotifier.close();
    wantedStoryItemIdNotifier.close();
  }

  void setStoryViewToStoryItemById(String id) {
    wantedStoryItemIdNotifier.add(id);
  }
}
