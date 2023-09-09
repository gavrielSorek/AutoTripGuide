import 'package:flutter/material.dart';
import '../General/tts_audio_player.dart';
import 'background_audio_player.dart';

class GuideAudioPlayer extends StatefulWidget {
  late final BackgroundAudioHandler audioHandler;

  GuideAudioPlayer({required this.audioHandler}) {}

  @override
  _GuideAudioPlayer createState() => _GuideAudioPlayer();
}

class _GuideAudioPlayer extends State<GuideAudioPlayer> {
  final playerStatesList = List.of(TtsState.values);
  bool _isPlayerButtonDisabled = false;
  List<Icon> icons = [
    Icon(Icons.pause),
    Icon(Icons.play_arrow),
    Icon(Icons.play_arrow),
    Icon(Icons.pause)
  ];
  Icon playerIcon = Icon(Icons.play_arrow);

  @override
  void initState() {
    dynamic savedOnPause = widget.audioHandler.onPause;
    widget.audioHandler.onPause = () {
      updatePlayerButton();
      savedOnPause != null ? savedOnPause() : null;
    };

    dynamic savedOnResume = widget.audioHandler.onResume;
    widget.audioHandler.onResume = () {
      updatePlayerButton();
      savedOnResume != null ? savedOnResume() : null;
    };

    dynamic savedOnPlay = widget.audioHandler.onPlay;
    widget.audioHandler.onPlay = () {
      updatePlayerButton();
      savedOnPlay != null ? savedOnPlay() : null;
    };
    updatePlayerButton();
    super.initState();
  }

  void updatePlayerButton() {
    if (!mounted)
      return;
    setState(() {
      playerIcon = icons[
          playerStatesList.indexOf(widget.audioHandler.ttsAudioPlayer.status)];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            // Black color with 50% opacity
            shape: BoxShape.circle, // Assuming you want a circular background
          ),
          child: GestureDetector(
            onDoubleTap: () {
              // the audioHandler have no other logic then just hold onDoublePrev
              if (widget.audioHandler.onDoublePrev != null) {
                widget.audioHandler.onDoublePrev();
                updatePlayerButton();
              }
            },
            child: IconButton(
              onPressed: () {
                if (widget.audioHandler.onPressPrev != null) {
                  widget.audioHandler.onPressPrev();
                  updatePlayerButton();
                }
              },
              icon: Icon(Icons.skip_previous),
              iconSize: 35,
              color: Colors.white,
            ),
          ),
        ),
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            // Black color with 50% opacity
            shape: BoxShape.circle, // Assuming you want a circular background
          ),
          child: IconButton(
              color: Colors.white,
              onPressed: _isPlayerButtonDisabled
                  ? null
                  : () {
                      if (widget.audioHandler.isStopped ||
                          widget.audioHandler.isPaused) {
                        widget.audioHandler.play();

                      } else {
                        widget.audioHandler.pause();
                      }
                      updatePlayerButton();
                    },
              icon: playerIcon,
              iconSize: 35),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            // Black color with 50% opacity
            shape: BoxShape.circle, // Assuming you want a circular background
          ),
          child: IconButton(
            onPressed: () {
              if (widget.audioHandler.onPressNext != null) {
                widget.audioHandler.onPressNext();
                updatePlayerButton();
              }
            },
            icon: Icon(Icons.skip_next),
            iconSize: 35,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
