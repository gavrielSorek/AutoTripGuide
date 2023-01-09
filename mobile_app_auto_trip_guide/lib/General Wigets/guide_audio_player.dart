import 'package:final_project/General%20Wigets/tts_audio_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GuideAudioPlayer extends StatefulWidget {
  final TtsAudioPlayer ttsAudioPlayer = TtsAudioPlayer();
  dynamic
  _onPressNext = null, _onPressPrev = null;

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

  // set onPause(dynamic onPause) {
  //   _onPause = onPause;
  // }

  // set onResume(dynamic onResume) {
  //   _onResume = onResume;
  // }

  set onStartPlaying(dynamic onStartPlaying) {
    ttsAudioPlayer.onPlay = onStartPlaying;
  }

  set onProgressChanged(dynamic onProgressChanged) {
    ttsAudioPlayer.onProgress = onProgressChanged;

    // _onProgressChanged = onProgressChanged;
  }

  Future<void> play() async {
    await ttsAudioPlayer.playAudio();
  }

  Future<void> pause() async {
    await ttsAudioPlayer.playAudio();
  }

  get isPlaying => ttsAudioPlayer.isPlaying;

  get isStopped => ttsAudioPlayer.isStopped;

  get isPaused => ttsAudioPlayer.isPaused;

  get isContinued => ttsAudioPlayer.isContinued;

  @override
  State<StatefulWidget> createState() {
    return _GuideAudioPlayerState();
  }
}

class _GuideAudioPlayerState extends State<GuideAudioPlayer> {
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
      setState(() {
        playerIcon = icons[widget.ttsAudioPlayer.status];
      });
    };

    super.initState();
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

  Widget _buildPlayer() =>
      Container(
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
                    if (widget.isPlaying) {
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
