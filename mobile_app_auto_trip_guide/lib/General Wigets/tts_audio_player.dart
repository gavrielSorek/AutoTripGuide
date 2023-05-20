import 'dart:math';

import 'package:flutter_tts/flutter_tts.dart';
import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

enum TtsState { playing, stopped, paused, continued }

class TtsAudioPlayer {
  late FlutterTts flutterTts;
  String _allTextToPlay = '';
  int _textLength = 0;
  dynamic _onFinishedFunc = null;
  dynamic _onProgress = null;
  dynamic _onPlay = null, _onPause = null, _onResume = null;
  String? _language;
  String? _engine;
  double _volume = 1;
  double _pitch = 1.0;
  double _rate = 0.5;
  bool _isCurrentLanguageInstalled = false;
  TtsState _ttsState = TtsState.stopped;
  Timer? _periodicProgressTimer;
  double _estimatedProgress = 0;

  get isPlaying => _ttsState == TtsState.playing;

  get isStopped => _ttsState == TtsState.stopped;

  get isPaused => _ttsState == TtsState.paused;

  get isContinued => _ttsState == TtsState.continued;

  get status => _ttsState;

  get speed => _rate;

  get estimatedProgress => _estimatedProgress;

  bool get isIOS => !kIsWeb && Platform.isIOS;

  bool get isAndroid => !kIsWeb && Platform.isAndroid;

  bool get isWindows => !kIsWeb && Platform.isWindows;

  bool get isWeb => kIsWeb;

  void setTextToPlay(String textToPlay, String language) {
    _textLength = textToPlay.length;
    _allTextToPlay = textToPlay;
    _language = language;
  }

  get onResume => _onResume;
  set onResume(dynamic onResume) {
    _onResume = onResume;
  }

  set onFinished(dynamic onFinishedFunc) {
    _onFinishedFunc = onFinishedFunc;
  }

  set onProgress(dynamic onProgress) {
    _onProgress = onProgress;
  }

  get onPlay => _onPlay;
  set onPlay(dynamic onPlay) {
    _onPlay = onPlay;
  }

  get onPause => _onPause;
  set onPause(dynamic onPause) {
    _onPause = onPause;
  }

  void setSpeed(double speed) async{
    _rate = speed;
    if (isPlaying || isContinued) {
      await pauseAudio();
      await flutterTts.setSpeechRate(_rate);
      await resumeAudio();
    } else {
      await flutterTts.setSpeechRate(_rate);
    }
  }

  TtsAudioPlayer() {
    flutterTts = FlutterTts();
  }

  // must be called before using the audio player
  iniPlayer() async {
    await flutterTts.awaitSpeakCompletion(true);

    if (isAndroid) {
      _getDefaultEngine();
      _getDefaultVoice();
    } else if (isIOS){
      await flutterTts.setIosAudioCategory(IosTextToSpeechAudioCategory.playback, [
        IosTextToSpeechAudioCategoryOptions.defaultToSpeaker
      ]);
    }

    await flutterTts.setVolume(_volume);
    await flutterTts.setSpeechRate(_rate);
    await flutterTts.setPitch(_pitch);

    flutterTts.setStartHandler(() {
      print("Playing");
      _ttsState = TtsState.playing;
      if (_onPlay != null) {
        _onPlay();
      }
    });

    if (isAndroid) {
      flutterTts.setInitHandler(() {
        print("TTS Initialized");
      });
    }

    flutterTts.setCompletionHandler(() {
      print("Complete");
      if(_ttsState == TtsState.stopped){
        // fix the bug for ios, the 'complete' handler is called after pressing on next, the 'cancel' handler is not called and changed the status to 'stooped'
        return;
      }
      _ttsState = TtsState.stopped;
      if (_onFinishedFunc != null) {
        _onFinishedFunc();
      }
    });

    flutterTts.setCancelHandler(() {
      print("Cancel");
      _ttsState = TtsState.stopped;
    });

    flutterTts.setPauseHandler(() {
      print("Paused");
      _ttsState = TtsState.paused;
      _onPause != null ? _onPause() : null;
    });

    flutterTts.setContinueHandler(() {
      print("Continued");
      _ttsState = TtsState.continued;
      _onResume != null ? _onResume() : null;
    });

    flutterTts.setProgressHandler((text, start, end, word) {
      _periodicProgressTimer?.cancel();
      int end_pos =
          (_textLength - text.length) + end; // position in the original text
      print(end_pos / _textLength);
      int start_pos = end_pos - word.length;
      if (_onProgress != null && _textLength > 0) {
        double startRangeProgress = start_pos / _textLength;
        double endRangeProgress =
            min((end_pos + 1) / _textLength, 1); // 1 - for the space
        _estimatedProgress = startRangeProgress;
        _onProgress(_estimatedProgress);

        double range = endRangeProgress - startRangeProgress;
        double addParam = (range / word.length) * 3;
        // print('______________________________________');
        // print(start);
        // print(end);
        // print(word);
        // print(start_pos);
        // print(end_pos);
        // print(startRangeProgress);
        // print(endRangeProgress);
        // print('_____________________________');
        _periodicProgressTimer =
            Timer.periodic(Duration(milliseconds: 200), (timer) {
              _estimatedProgress += addParam;
          if (_estimatedProgress < endRangeProgress) {
            if (status == TtsState.playing) {
              _onProgress(_estimatedProgress);
              // print("***************");
              // print(estimatedProgress);
              // print("***************");
            }
          }
        });
      }
    });

    flutterTts.setErrorHandler((msg) {
      print("error: $msg");
      _ttsState = TtsState.stopped;
    });
  }

  Future<void> playAudio() async {
    _periodicProgressTimer?.cancel();
    await flutterTts.setLanguage(_language ?? 'en-GB');
    await flutterTts.speak(_allTextToPlay);
  }

  Future<void> resumeAudio() async {
    await flutterTts.speak(_allTextToPlay);
  }

  restartPlaying() async {
    await stopAudio();
    await playAudio();
  }

  clearPlayer() {
    _allTextToPlay = '';
  }

  Future<dynamic> _getLanguages() async => await flutterTts.getLanguages;

  Future<dynamic> _getEngines() async => await flutterTts.getEngines;

  Future _getDefaultEngine() async {
    var engine = await flutterTts.getDefaultEngine;
    if (engine != null) {
      print(engine);
    }
  }

  Future _getDefaultVoice() async {
    var voice = await flutterTts.getDefaultVoice;
    if (voice != null) {
      print(voice);
    }
  }

  Future _setAwaitOptions() async {
    await flutterTts.awaitSpeakCompletion(true);
  }

  Future stopAudio() async {
    await flutterTts.stop();
    _ttsState = TtsState.stopped;
  }

  Future pauseAudio() async {
    await flutterTts.pause();
  }
}
