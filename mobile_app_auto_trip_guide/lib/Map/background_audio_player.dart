import 'package:final_project/Map/globals.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../General Wigets/tts_audio_player.dart';
import 'package:audio_service/audio_service.dart';

class BackgroundAudioHandler extends BaseAudioHandler
    with QueueHandler, SeekHandler {
  dynamic _onPressNext = null, _onPressPrev = null;
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

  set onPressPrev(dynamic onPressPrev) {
    _onPressPrev = onPressPrev;
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

  set onPause(dynamic onPause) {
    ttsAudioPlayer.onPause = onPause;
  }

  set onResume(dynamic onResume) {
    ttsAudioPlayer.onResume = onResume;
  }

  set onPlay(dynamic onPlay) {
    ttsAudioPlayer.onPlay = onPlay;
  }

  get speed => ttsAudioPlayer.speed;

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

class GuideAudioPlayerUI extends StatefulWidget {
  late BackgroundAudioHandler _audioHandler;

  GuideAudioPlayerUI(BackgroundAudioHandler audioHandler) {
    _audioHandler = audioHandler;
  }

  @override
  State<StatefulWidget> createState() {
    return _GuideAudioPlayerUIState();
  }
}

class _GuideAudioPlayerUIState extends State<GuideAudioPlayerUI> {
  final playerStatesList = List.of(TtsState.values);
  bool _isPlayerButtonDisabled = false;
  List<Icon> icons = [
    Icon(Icons.pause),
    Icon(Icons.play_arrow),
    Icon(Icons.play_arrow),
    Icon(Icons.pause)
  ]; //in the length of TtsState
  Icon playerIcon = Icon(Icons.play_arrow);

  @override
  void initState() {
    widget._audioHandler.onPause = () {
      updatePlayerButton();
    };

    widget._audioHandler.onResume = () {
      updatePlayerButton();
    };

    widget._audioHandler.onPlay = () {
      updatePlayerButton();
    };
    super.initState();
  }

  void updatePlayerButton() {
    setState(() {
      playerIcon = icons[
          playerStatesList.indexOf(widget._audioHandler.ttsAudioPlayer.status)];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.min,
          children: [
            Material(child: _buildPlayer()),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayer() => Container(
        width: double.infinity,
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Spacer(),
          Container(
              width: 47,
              height: 47,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.25),
                      offset: Offset(0, 2),
                      blurRadius: 10)
                ],
                color: Color(0xff0A84FF),
              ),
              child: IconButton(
                onPressed: () {
                  if (widget._audioHandler._onPressPrev != null) {
                    widget._audioHandler._onPressPrev();
                  }
                  ;
                },
                icon: Icon(Icons.keyboard_double_arrow_left_outlined),
                color: Colors.white,
                iconSize: 35,
              )),
          Spacer(),
          Container(
              width: 117,
              height: 47,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.25),
                      offset: Offset(0, 2),
                      blurRadius: 10)
                ],
                color: Color(0xff0A84FF),
              ),
              child: IconButton(
                  color: Colors.white,
                  onPressed: _isPlayerButtonDisabled
                      ? null
                      : () {
                          if (widget._audioHandler.isStopped ||
                              widget._audioHandler.isPaused) {
                            setState(() {
                              widget._audioHandler.play();
                            });
                          } else {
                            setState(() {
                              widget._audioHandler.pause();
                            });
                          }
                        },
                  icon: playerIcon,
                  iconSize: 35)),
          Spacer(),
          Container(
              width: 47,
              height: 47,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.25),
                      offset: Offset(0, 2),
                      blurRadius: 10)
                ],
                color: Color(0xff0A84FF),
              ),
              child: IconButton(
                onPressed: () {
                  if (widget._audioHandler._onPressNext != null) {
                    widget._audioHandler._onPressNext();
                  }
                  ;
                },
                icon: Icon(Icons.keyboard_double_arrow_right_rounded),
                iconSize: 35,
                color: Colors.white,
              )),
          Spacer()
        ]),
      );
}
