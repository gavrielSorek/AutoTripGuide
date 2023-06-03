import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../General Wigets/tts_audio_player.dart';
import 'package:audio_service/audio_service.dart';

class BackgroundAudioHandler extends BaseAudioHandler
    with QueueHandler, SeekHandler {
  dynamic _onPressNext = null, _onPressPrev = null, _onDoublePrev = null;
  final TtsAudioPlayer ttsAudioPlayer = TtsAudioPlayer();
  String _albumName = '', _trackTitle = '', _artistName = '', _picUrl = '';
  late MediaItem _currentMediaItem;

  BackgroundAudioHandler() {
    _currentMediaItem = MediaItem(
        id: '',
        album: _albumName,
        title: _trackTitle,
        artist: _artistName,
        artUri: Uri.parse(_picUrl));
    playbackState.add(playbackState.value.copyWith(
      controls: [MediaControl.play],
      processingState: AudioProcessingState.ready,
    ));
  }

  set picUrl(dynamic picUrl) {
    _picUrl = picUrl;
  }

  set albumName(dynamic albumName) {
    _albumName = albumName;
  }

  set trackTitle(dynamic trackTitle) {
    _trackTitle = trackTitle;
  }

  set artistName(dynamic artistName) {
    _artistName = artistName;
  }

  set onPressNext(dynamic onPressNext) {
    _onPressNext = onPressNext;
  }

  get onPressNext => _onPressNext;

  set onPressPrev(dynamic onPressPrev) {
    _onPressPrev = onPressPrev;
  }

  get onPressPrev => _onPressPrev;

  get onDoublePrev => _onDoublePrev;

  set onDoublePrev(dynamic onDoublePrev) {
    _onDoublePrev = onDoublePrev;
  }

  @override
  Future<void> setSpeed(double speed) async {
    ttsAudioPlayer.setSpeed(speed);
  }

  // must be called before using the player
  initAudioPlayer() async {
    await ttsAudioPlayer.iniPlayer();
  }

  set onPlayerFinishedFunc(dynamic onPlayerFinishedFunc) {
    ttsAudioPlayer.onFinished = onPlayerFinishedFunc;
  }

  set onProgressChanged(dynamic onProgressChanged) {
    ttsAudioPlayer.onProgress = onProgressChanged;
  }

  get onPause => ttsAudioPlayer.onPause;

  set onPause(dynamic onPause) {
    ttsAudioPlayer.onPause = onPause;
  }

  get onResume => ttsAudioPlayer.onResume;

  set onResume(dynamic onResume) {
    ttsAudioPlayer.onResume = onResume;
  }

  get onPlay => ttsAudioPlayer.onPlay;

  set onPlay(dynamic onPlay) {
    ttsAudioPlayer.onPlay = onPlay;
  }

  get onStop => ttsAudioPlayer.onStop;

  set onStop(dynamic onStop) {
    ttsAudioPlayer.onStop = onStop;
  }

  get speed => ttsAudioPlayer.speed;

  get isAtBeginning {
    return (ttsAudioPlayer.estimatedProgress < 0.03);
  }

  restartPlaying() {
    ttsAudioPlayer.restartPlaying();
  }

  @override
  Future<void> skipToNext() async {
    _onPressNext();
  }

  @override
  Future<void> skipToPrevious() async {
    _onPressPrev();
  }

  @override
  Future<void> play() async {
    playbackState.add(playbackState.value.copyWith(
      playing: true,
      controls: [
        MediaControl.skipToPrevious,
        MediaControl.pause,
        MediaControl.skipToNext
      ],
    ));
    _currentMediaItem = _currentMediaItem.copyWith(
        album: _albumName,
        title: _trackTitle,
        artist: _artistName,
        artUri: Uri.parse(_picUrl));
    mediaItem.add(_currentMediaItem);
    await ttsAudioPlayer.playAudio();
  }

  @override
  Future<void> pause() async {
    playbackState.add(playbackState.value.copyWith(
      playing: false,
      controls: [
        MediaControl.skipToPrevious,
        MediaControl.play,
        MediaControl.skipToNext
      ],
    ));
    await ttsAudioPlayer.pauseAudio();
  }

  @override
  Future<void> stop() async {
    await ttsAudioPlayer.stopAudio();
    mediaItem.add(_currentMediaItem);
    // Set the audio_service state to `idle` to deactivate the notification.
    // playbackState.add(playbackState.value.copyWith(
    //   processingState: AudioProcessingState.idle,
    // ));
  }

  get isPlaying => ttsAudioPlayer.isPlaying;

  get isStopped => ttsAudioPlayer.isStopped;

  get isPaused => ttsAudioPlayer.isPaused;

  get isContinued => ttsAudioPlayer.isContinued;

  void clearPlayer() {
    ttsAudioPlayer.clearPlayer();
  }

  void setTextToPlay(String text, String language) {
    ttsAudioPlayer.setTextToPlay(text, language);
  }
}
