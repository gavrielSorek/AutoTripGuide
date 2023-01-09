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
  double _volume = 0.5;
  double _pitch = 1.0;
  double _rate = 0.5;
  bool _isCurrentLanguageInstalled = false;
  TtsState _ttsState = TtsState.stopped;
  Timer? _periodicProgressTimer;

  get isPlaying => _ttsState == TtsState.playing;

  get isStopped => _ttsState == TtsState.stopped;

  get isPaused => _ttsState == TtsState.paused;

  get isContinued => _ttsState == TtsState.continued;

  get status => _ttsState;

  bool get isIOS => !kIsWeb && Platform.isIOS;

  bool get isAndroid => !kIsWeb && Platform.isAndroid;

  bool get isWindows => !kIsWeb && Platform.isWindows;

  bool get isWeb => kIsWeb;

  void setTextToPlay(String textToPlay, String language) {
    _textLength = textToPlay.length;
    _allTextToPlay = textToPlay;
    _language = language;
  }

  set onResume(dynamic onResume) {
    _onResume = onResume;
  }

  set onFinished(dynamic onFinishedFunc) {
    _onFinishedFunc = onFinishedFunc;
  }

  set onProgress(dynamic onProgress) {
    _onProgress = onProgress;
  }

  set onPlay(dynamic onPlay) {
    _onPlay = onPlay;
  }

  set onPause(dynamic onPause) {
    _onPause = onPause;
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
            (end_pos + 1) / _textLength; // 1 - for the space
        double estimatedProgress = startRangeProgress;
        _onProgress(estimatedProgress);

        double range = endRangeProgress - startRangeProgress;
        double addParam = (range / word.length) * 2;
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
            Timer.periodic(Duration(milliseconds: 100), (timer) {
          estimatedProgress += addParam;
          if (estimatedProgress < endRangeProgress) {
            _onProgress(estimatedProgress);
            // print("***************");
            // print(estimatedProgress);
            // print("***************");
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
    await flutterTts.setLanguage(_language ?? 'en-GB');
    await flutterTts.speak(_allTextToPlay);
  }

  void unPauseAudio() async {
    await flutterTts.speak(_allTextToPlay);
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
  }

  Future pauseAudio() async {
    await flutterTts.pause();
  }
}
