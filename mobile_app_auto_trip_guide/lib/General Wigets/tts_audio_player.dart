import 'package:flutter_tts/flutter_tts.dart';
import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

enum TtsState { playing, stopped, paused, continued }

class TtsAudioPlayer {
  late FlutterTts flutterTts;
  String _allTextToPlay = '';
  int _textLength = 0;
  String _restOfTextToPlay = '';
  dynamic _onFinishedFunc = null;
  dynamic _onProgress = null;
  dynamic _onPlay = null, _onPause = null;
  String? _language;
  String? _engine;
  double _volume = 0.5;
  double _pitch = 1.0;
  double _rate = 0.5;
  bool _isCurrentLanguageInstalled = false;
  TtsState _ttsState = TtsState.stopped;

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
      if(_onPlay != null) {
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
      _onPause != null ? _onPause : null;
    });

    flutterTts.setContinueHandler(() {
      print("Continued");
      _ttsState = TtsState.continued;
    });

    flutterTts.setProgressHandler((text, start, end, word) {
      print('______________________________________');
      // print(text);
      // print(start);
      // print(end);
      // print(word);
      int pos = (_textLength - text.length) + end; // position in the original text
      print(pos / _textLength);
      if (_onProgress != null) {
        _textLength > 0 ? _onProgress(pos / _textLength) : null;
      }
      print('_____________________________');

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
    _restOfTextToPlay = '';
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
    var result = await flutterTts.stop();
    if (result == 1)
      _ttsState = TtsState.stopped;
  }

  Future pauseAudio() async {
    var result = await flutterTts.pause();
    if (result == 1)
      _ttsState = TtsState.paused;
  }
}
