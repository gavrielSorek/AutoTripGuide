import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter_tts/flutter_tts.dart';

import 'globals.dart';

typedef void OnError(Exception exception);

class AudioApp extends StatefulWidget {
  AudioPlayer audioPlayer = AudioPlayer();
  FlutterTts flutterTts = FlutterTts();
  dynamic onPlayerFinishedFunc;
  String text = "";
  String languageCode = "";
  var langToTtsLangCode = {'en': 'en-GB'};

  void setText(String text, String language) {
    this.text = text;
    this.languageCode = langToTtsLangCode[language]!;
  }

  bool isPlaying() {
    if (_audioAppState == null) {
      return false;
    }
    return _audioAppState!.playerState == PlayerState.playing;
  }

  void playAudio({bool playWithProgressBar = true}) {
    _audioAppState?.play(playWithProgressBar: playWithProgressBar);
  }

  void stopAudio() {
    _audioAppState?.stop();
  }

  void pauseAudio() {
    _audioAppState?.pause();
  }

  void unPauseAudio() async {
    await _audioAppState?.resume();
  }

  clearPlayer() {
    text = "";
    _audioAppState?.clearPlayer();
  }

  void setOnPlayerFinishedFunc(dynamic func) {
    onPlayerFinishedFunc = func;
  }

  _AudioAppState? _audioAppState;

  @override
  _AudioAppState createState() {
    _audioAppState = _AudioAppState();
    return _audioAppState!;
  }
}

class _AudioAppState extends State<AudioApp> {
  Duration duration = Duration(seconds: 0);
  Duration position = Duration(seconds: 0);

  List<Icon> icons = [
    Icon(Icons.play_arrow),
    Icon(Icons.pause),
    Icon(Icons.play_arrow),
    Icon(Icons.play_arrow)
  ];
  Icon playPauseIcon = Icon(Icons.play_arrow);

  double speechRate = 0.4;
  double pitch = 1;

  Color playButtonColor = Colors.grey;
  bool isPlayerButtonDisabled = false;
  bool _playWithProgressBar = false;
  PlayerState playerState = PlayerState.stopped;

  get isPlaying => playerState == PlayerState.playing;

  get isPaused => playerState == PlayerState.paused;

  get durationText =>
      duration != null ? duration.toString().split('.').first : '';

  get positionText =>
      position != null ? position.toString().split('.').first : '';

  bool isMuted = false;

  late StreamSubscription _positionSubscription;
  late StreamSubscription _audioPlayerStateSubscription;

  Future<String> convertTextToAudioFile(String text) async {
    String fileName = Platform.isAndroid ? "tts.wav" : "tts.caf";
    String? path;
    if (Platform.isAndroid) {
      path = (await getExternalStorageDirectory())?.path;
    } else {
      path = (await getApplicationSupportDirectory()).path;
    }
    await widget.flutterTts.synthesizeToFile(widget.text, fileName);
    return '$path/$fileName';
  }

  void setPlayButtonColor(Color color) {
    setState(() {
      playButtonColor = color;
    });
  }

  void clearPlayer() {
    stop();
    disablePlayerButton();
  }

  @override
  void initState() {
    super.initState();
    initAudioPlayer();
    initTts();
  }

  initTts() {
    widget.flutterTts.awaitSynthCompletion(true);
    // _setAwaitOptions();
    //
    // if (isAndroid) {
    //   _getDefaultEngine();
    //   _getDefaultVoice();
    // }
    //
    // flutterTts.setStartHandler(() {
    //   setState(() {
    //     print("Playing");
    //     ttsState = TtsState.playing;
    //   });
    // });
    //
    // flutterTts.setCompletionHandler(() {
    //   setState(() {
    //     print("Complete");
    //     ttsState = TtsState.stopped;
    //   });
    // });
    //
    // flutterTts.setCancelHandler(() {
    //   setState(() {
    //     print("Cancel");
    //     ttsState = TtsState.stopped;
    //   });
    // });
    //
    // if (isWeb || isIOS || isWindows) {
    //   flutterTts.setPauseHandler(() {
    //     setState(() {
    //       print("Paused");
    //       ttsState = TtsState.paused;
    //     });
    //   });
    //
    //   flutterTts.setContinueHandler(() {
    //     setState(() {
    //       print("Continued");
    //       ttsState = TtsState.continued;
    //     });
    //   });
    // }
    //
    // flutterTts.setErrorHandler((msg) {
    //   setState(() {
    //     print("error: $msg");
    //     ttsState = TtsState.stopped;
    //   });
    // });
  }

  @override
  void dispose() {
    _positionSubscription.cancel();
    _audioPlayerStateSubscription.cancel();
    widget.audioPlayer.stop();
    super.dispose();
  }

  void initAudioPlayer() {
    _positionSubscription =
        widget.audioPlayer.onPositionChanged.listen((p) => setState(() {
              if (!_playWithProgressBar) {
                return;
              }
              position = p;
            }));
    _audioPlayerStateSubscription =
        widget.audioPlayer.onPlayerStateChanged.listen((newState) async {
      if (!_playWithProgressBar) {
        return;
      }
      if (newState == PlayerState.playing) {
        this.playerState = PlayerState.playing;
        this.playPauseIcon = icons[PlayerState.playing.index];
        enablePlayerButton();
      } else if (newState == PlayerState.stopped) {
        this.playPauseIcon = icons[PlayerState.stopped.index];
        setState(() {
          this.playerState = PlayerState.stopped;
          position = Duration(milliseconds: 0);
        });
      } else if (newState == PlayerState.paused) {
        this.playerState = PlayerState.paused;
        this.playPauseIcon = icons[PlayerState.paused.index];
        setState(() {
          this.playerState = PlayerState.paused;
        });
      }
    }, onError: (msg) {
      setState(() {
        playerState = PlayerState.stopped;
        duration = Duration(seconds: 0);
        position = Duration(seconds: 0);
      });
    });
    widget.audioPlayer.onDurationChanged.listen((Duration newDuration) {
      if (!_playWithProgressBar) {
        return;
      }
      setState(() => duration = newDuration);
    });
    widget.audioPlayer.onPlayerComplete.listen((event) {
      if (widget.onPlayerFinishedFunc != null) {
        widget.onPlayerFinishedFunc();
      }
    });
  }

  Future play({bool playWithProgressBar = true}) async {
    _playWithProgressBar = playWithProgressBar;
    // TODO MOVE THIS SECTION
    await widget.flutterTts.setSpeechRate(speechRate);
    await widget.flutterTts.setPitch(pitch);
    await widget.flutterTts.setLanguage(widget.languageCode);

    if (isPaused) {
      await widget.audioPlayer.resume();
    } else {
      print("finish");
      String urlPath = await convertTextToAudioFile(widget.text);
      await widget.audioPlayer.play(UrlSource(urlPath));
    }
  }

  Future pause() async {
    await widget.audioPlayer.pause();
  }

  Future resume() async {
    await widget.audioPlayer.resume();
  }

  Future stop() async {
    await widget.audioPlayer.stop();
  }

  void enablePlayerButton() {
    isPlayerButtonDisabled = false;
    setPlayButtonColor(Globals.globalColor);
  }

  void disablePlayerButton() {
    isPlayerButtonDisabled = true;
    setPlayButtonColor(Colors.grey);
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
          IconButton(
            onPressed: isPlayerButtonDisabled
                ? null
                : () {
                    if (!isPlaying) {
                      setState(() {
                        play();
                      });
                    } else {
                      setState(() {
                        pause();
                      });
                    }
                  },
            iconSize: 30.0,
            icon: playPauseIcon,
            color: playButtonColor,
          ),
          Expanded(
            child: Slider(
                value: position.inMilliseconds.toDouble(),
                onChanged: (double value) {
                  setState(() {
                    position = Duration(milliseconds: value.round());
                  });
                  widget.audioPlayer
                      .seek(position);
                },
                min: 0.0,
                max: duration > position
                    ? duration.inMilliseconds.toDouble()
                    : position.inMilliseconds.toDouble()),
          ),
          _buildProgressView()
        ]),
      );

  Row _buildProgressView() => Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
            margin: const EdgeInsets.only(left: 10.0, right: 10.0),
            child: Text(
              position != null
                  ? "${positionText ?? ''} / ${(duration > position ? durationText : positionText) ?? ''}"
                  : duration != null
                      ? durationText
                      : '',
              style: TextStyle(fontSize: 12.0),
            ))
      ]);
}
