import 'dart:async';
import 'dart:ffi';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:math';

typedef void OnError(Exception exception);

class AudioApp extends StatefulWidget {
  dynamic onPlayerFinishedFunc;
  Uint8List byteData = Uint8List(0);

  void setAudioBytes(Uint8List audioBytes) {
    byteData = audioBytes;
    if (byteData.isNotEmpty) {
      _audioAppState?.setPlayButtonColor(Colors.cyan);
    }
  }

  void playAudio() {
    _audioAppState?.play();
  }

  void stopAudio() {
    _audioAppState?.stop();
  }

  void pauseAudio() {
    _audioAppState?.pause();
  }

  clearPlayer() {
    // byteData = Uint8List(0);
    _audioAppState!.clearPlayer();
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
  Icon playIcon = Icon(Icons.play_arrow);
  Icon pauseIcon = Icon(Icons.pause);
  Icon playPauseIcon = Icon(Icons.play_arrow); // default
  AudioPlayer audioPlayer = AudioPlayer();
  Color playButtonColor = Colors.grey;

  PlayerState playerState = PlayerState.STOPPED;

  get isPlaying => playerState == PlayerState.PLAYING;

  get isPaused => playerState == PlayerState.PAUSED;

  get durationText =>
      duration != null ? duration.toString().split('.').first : '';

  get positionText =>
      position != null ? position.toString().split('.').first : '';

  bool isMuted = false;

  late StreamSubscription _positionSubscription;
  late StreamSubscription _audioPlayerStateSubscription;

  Future<String> saveAudioBytesToLocalFile(Uint8List byteData) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    File file = File('$path/myAudio.mp3');
    await file.writeAsBytes(byteData);
    return file.path;
  }

  void setPlayButtonColor(Color color) {
    setState(() {
      playButtonColor = color;
    });
  }

  void clearPlayer() {
    stop();
  }

  @override
  void initState() {
    super.initState();
    initAudioPlayer();
  }

  @override
  void dispose() {
    _positionSubscription.cancel();
    _audioPlayerStateSubscription.cancel();
    audioPlayer.stop();
    super.dispose();
  }

  void initAudioPlayer() {
    // audioPlayer = AudioPlayer();
    _positionSubscription = audioPlayer.onAudioPositionChanged
        .listen((p) => setState(() => position = p));
    _audioPlayerStateSubscription =
        audioPlayer.onPlayerStateChanged.listen((s) async {
      if (s == PlayerState.PLAYING) {
        // print("-------------------------------");
        // int ddd = await audioPlayer.getDuration();
        // print(ddd);
        // setState(() => duration = Duration(seconds: 1000));
      } else if (s == PlayerState.STOPPED) {
        onComplete();
        setState(() {
          position = duration;
        });
      }
    }, onError: (msg) {
      setState(() {
        playerState = PlayerState.STOPPED;
        duration = Duration(seconds: 0);
        position = Duration(seconds: 0);
      });
    });
    audioPlayer.onDurationChanged.listen((Duration newDuration) {
      // duration = newDuration;
      setState(() => duration = newDuration);

      // if (playerState == PlayerState.PLAYING) {
      //   setState(() => duration = newDuration);
      // }
    });
    audioPlayer.onPlayerCompletion.listen((event) {
      if(widget.onPlayerFinishedFunc != null) {
        widget.onPlayerFinishedFunc();
      }
    });
  }

  Future play() async {
    playPauseIcon = pauseIcon;
    if (isPaused) {
      await audioPlayer.resume();
    } else {
      if (Platform.isAndroid) {
        await audioPlayer.playBytes(widget.byteData);
      } else if (Platform.isIOS) {
        String urlPath = await saveAudioBytesToLocalFile(widget.byteData);
        await audioPlayer.play(urlPath, isLocal: true);
      }
    }
    setState(() {
      playerState = PlayerState.PLAYING;
    });
  }

  // Future _playLocal() async {
  //   print("play local");
  //   // await audioPlayer.play(localFilePath, isLocal: true);
  //   setState(() => playerState = PlayerState.PLAYING);
  // }

  Future pause() async {
    playPauseIcon = playIcon;
    await audioPlayer.pause();
    setState(() => playerState = PlayerState.PAUSED);
  }

  Future stop() async {
    await audioPlayer.stop();
    setState(() {
      playerState = PlayerState.STOPPED;
      position = Duration();
      playPauseIcon = playIcon;
    });
  }

  // Future mute(bool muted) async {
  //   await audioPlayer.setVolume(0.0);
  //   // await audioPlayer.mute(muted);
  //   setState(() {
  //     isMuted = muted;
  //   });
  // }

  void onComplete() {
    setState(() => playerState = PlayerState.STOPPED);
  }

  // Future _loadFile() async {
  //   print("load file!!!!!!!!!!!! pressed");
  // }

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
            onPressed: () {
              if (widget.byteData.isEmpty) {
                return;
              }
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
          // IconButton(
          //   onPressed: isPlaying || isPaused ? () => stop() : null,
          //   iconSize: 30.0,
          //   icon: Icon(Icons.stop),
          //   color: Colors.cyan,
          // ),
          Expanded(
            child: Slider(
                value: position.inMilliseconds.toDouble(),
                onChanged: (double value) {
                  audioPlayer.seek(Duration(milliseconds: value.round()));
                },
                min: 0.0,
                max: duration > position ? duration.inMilliseconds.toDouble() : position.inMilliseconds.toDouble()),
          ),
          _buildProgressView()
        ]),
      );

  Row _buildProgressView() => Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
            margin: const EdgeInsets.only(left: 10.0, right: 10.0),
            child: Text(
              position != null
                  ? "${positionText ?? ''} / ${(duration > position ? durationText: positionText)  ?? ''}"
                  : duration != null
                      ? durationText
                      : '',
              style: TextStyle(fontSize: 12.0),
            ))
      ]);
}
