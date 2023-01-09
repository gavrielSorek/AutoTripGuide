import 'package:final_project/General%20Wigets/tts_audio_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GuideAudioPlayer extends StatefulWidget {
  final TtsAudioPlayer ttsAudioPlayer = TtsAudioPlayer();
  dynamic _onPressNext = null,
      _onPressPrev = null,
      _onPause = null,
      _onResume = null;

  // must be called before using the player
  initAudioPlayer() async {
    await ttsAudioPlayer.iniPlayer();
  }

  set onPlayerFinishedFunc(dynamic onPlayerFinishedFunc) {
    ttsAudioPlayer.onFinished = onPlayerFinishedFunc;
  }

  set onPressNext(dynamic onPressNext) {
    _onPressNext = onPressNext;
  }

  set onPressPrev(dynamic onPressPrev) {
    _onPressPrev = onPressPrev;
  }

  set onProgressChanged(dynamic onProgressChanged) {
    ttsAudioPlayer.onProgress = onProgressChanged;
  }

  set onPause(dynamic onPause) {
    _onPause = onPause;
  }

  set onResume(dynamic onResume) {
    _onResume = onResume;
  }

  Future<void> play() async {
    await ttsAudioPlayer.playAudio();
  }

  Future<void> pause() async {
    await ttsAudioPlayer.pauseAudio();
  }

  Future<void> stop() async {
    await ttsAudioPlayer.stopAudio();
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

  @override
  State<StatefulWidget> createState() {
    return _GuideAudioPlayerState();
  }
}

class _GuideAudioPlayerState extends State<GuideAudioPlayer> {
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
    widget.ttsAudioPlayer.onPause = () {
      widget._onPause();
      updatePlayerButton();
    };

    widget.ttsAudioPlayer.onResume = () {
      widget._onResume();
      updatePlayerButton();
    };

    widget.ttsAudioPlayer.onPlay = () {
      updatePlayerButton();
    };

    super.initState();
  }

  void updatePlayerButton() {
    setState(() {
      playerIcon =
          icons[playerStatesList.indexOf(widget.ttsAudioPlayer.status)];
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
                  if (widget._onPressPrev != null) {
                    widget._onPressPrev();
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
                          if (widget.isStopped || widget.isPaused) {
                            setState(() {
                              widget.play();
                            });
                          } else {
                            setState(() {
                              widget.pause();
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
                  if (widget._onPressNext != null) {
                    widget._onPressNext();
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
