
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';

typedef void OnError(Exception exception);

// const kUrl =
//     "https://www.mediacollege.com/downloads/sound-effects/nature/forest/rainforest-ambient.mp3";

// void main() {
//   runApp(MaterialApp(home: Scaffold(body: AudioApp())));
// }

// enum PlayerState { stopped, playing, paused }

class AudioApp extends StatefulWidget {
  Uint8List byteData = Uint8List(0);

  @override
  _AudioAppState createState() => _AudioAppState();
}

class _AudioAppState extends State<AudioApp> {
  Duration duration = Duration(seconds: 0);
  Duration position = Duration(seconds: 0);

  AudioPlayer audioPlayer = AudioPlayer();

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
        audioPlayer.onPlayerStateChanged.listen((s) {
          if (s == PlayerState.PLAYING) {
            setState(() => duration = Duration(seconds: 1000));
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
  }

  Future play() async {
    await audioPlayer.playBytes(widget.byteData);
    setState(() {
      playerState = PlayerState.PLAYING;
    });
  }

  Future _playLocal() async {
    print("play local");
    // await audioPlayer.play(localFilePath, isLocal: true);
    setState(() => playerState = PlayerState.PLAYING);
  }

  Future pause() async {
    await audioPlayer.pause();
    setState(() => playerState = PlayerState.PAUSED);
  }

  Future stop() async {
    await audioPlayer.stop();
    setState(() {
      playerState = PlayerState.STOPPED;
      position = Duration();
    });
  }

  Future mute(bool muted) async {
    await audioPlayer.setVolume(0.0);
    // await audioPlayer.mute(muted);
    setState(() {
      isMuted = muted;
    });
  }

  void onComplete() {
    setState(() => playerState = PlayerState.STOPPED);
  }


  Future _loadFile() async {
    print("load file!!!!!!!!!!!! pressed");
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Text(
            //   'Flutter Audioplayer',
            //   style: textTheme.headline1,
            // ),
            Material(child: _buildPlayer()),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayer() => Container(
    padding: EdgeInsets.all(5.0),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(mainAxisSize: MainAxisSize.min, children: [
          IconButton(
            onPressed: isPlaying ? null : () => play(),
            iconSize: 30.0,
            icon: Icon(Icons.play_arrow),
            color: Colors.cyan,
          ),
          IconButton(
            onPressed: isPlaying ? () => pause() : null,
            iconSize: 30.0,
            icon: Icon(Icons.pause),
            color: Colors.cyan,
          ),
          IconButton(
            onPressed: isPlaying || isPaused ? () => stop() : null,
            iconSize: 30.0,
            icon: Icon(Icons.stop),
            color: Colors.cyan,
          ),
        ]),
        if (duration != null)
          Slider(
              value: 0.0,
              // value: position.inMilliseconds.toDouble(),
              onChanged: (double value) {
                print("--------------------------");
                print(value);
                audioPlayer.seek(Duration(milliseconds: value.round()));

                // audioPlayer.seek(Duration(milliseconds: (value / 1000).round()));
              },
              min: 0.0,
              max: duration.inMilliseconds.toDouble()),
        if (position != null) _buildProgressView()
      ],
    ),
  );

  Row _buildProgressView() => Row(mainAxisSize: MainAxisSize.min, children: [
    Padding(
      padding: EdgeInsets.all(5.0),
      child: CircularProgressIndicator(
        value: position != null && position.inMilliseconds > 0
            ? (position.inMilliseconds.toDouble()) /
            (duration.inMilliseconds.toDouble())
            : 0.0,
        valueColor: AlwaysStoppedAnimation(Colors.cyan),
        backgroundColor: Colors.grey.shade400,
      ),
    ),
    Text(
      position != null
          ? "${positionText ?? ''} / ${durationText ?? ''}"
          : duration != null ? durationText : '',
      style: TextStyle(fontSize: 12.0),
    )
  ]);

}