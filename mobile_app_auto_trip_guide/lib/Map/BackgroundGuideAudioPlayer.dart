import 'package:final_project/Map/globals.dart';

import 'guide_audio_player.dart';
import 'package:audio_service/audio_service.dart';

class BackgroundGuideAudioPlayer extends GuideAudioPlayer {

  @override
  initAudioPlayer() async {

    return super.initAudioPlayer();
  }
  @override
  Future<void> play() {
    var item = MediaItem(
      id: 'https://example.com/audio.mp3',
      album: 'Album name',
      title: 'Track title',
      artist: 'Artist name',
      duration: const Duration(milliseconds: 123456),
      artUri: Uri.parse('https://example.com/album.jpg'),
    );
    Globals.globalAudioHandler.playMediaItem(item);
    Globals.globalAudioHandler.addQueueItem(item);

    return super.play();
  }

}

class BackgroundAudioHandler extends BaseAudioHandler
    with QueueHandler, // mix in default queue callback implementations
        SeekHandler { // mix in default seek callback implementations

  // The most common callbacks:
  Future<void> play() async {
    // All 'play' requests from all origins route to here. Implement this
    // callback to start playing audio appropriate to your app. e.g. music.
  }
  Future<void> pause() async {}
  Future<void> stop() async {}
  Future<void> seek(Duration position) async {}
  Future<void> skipToQueueItem(int i) async {}
}