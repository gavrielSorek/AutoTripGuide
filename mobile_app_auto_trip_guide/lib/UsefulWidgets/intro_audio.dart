import 'dart:typed_data';
import 'package:flutter/services.dart';

class IntroAudio {

  static Map<String, String> directionStringToAudioFile = {
    'North': "assets/audio/north_direction.wav",
    'South': "assets/audio/south_direction.wav",
    'East': "assets/audio/east_direction.wav",
    'West': "assets/audio/west_direction.wav",
    'Northeast': "assets/audio/northeast_direction.wav",
    'Northwest': "assets/audio/northwest_direction.wav",
    'Southeast': "assets/audio/southeast_direction.wav",
    'Southwest': "assets/audio/southwest_direction.wav",
  };

  static Future<Uint8List> getAudioByDirection(String direction) async{
    String? filePath = getAudioFilePathByDirection(direction);
    if (filePath == null){
      return Uint8List(0);
    }
    ByteData soundBytes = await rootBundle.load(filePath); //load sound from assets
    Uint8List audio = soundBytes.buffer.asUint8List(soundBytes.offsetInBytes, soundBytes.lengthInBytes);
    return audio;
  }

  static String? getAudioFilePathByDirection(String direction) {
    return directionStringToAudioFile[direction]  ?? null;
  }
}
