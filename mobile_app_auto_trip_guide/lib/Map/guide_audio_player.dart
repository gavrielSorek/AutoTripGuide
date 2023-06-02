import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../General Wigets/tts_audio_player.dart';
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
    super.initState();
  }

  void updatePlayerButton() {
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
            color: Colors.black.withOpacity(0.5),
            // Black color with 50% opacity
            shape: BoxShape.circle, // Assuming you want a circular background
          ),
          child: GestureDetector(
            onDoubleTap: () {
              if (widget.audioHandler.onPressPrev != null) {
                widget.audioHandler.onPressPrev();
              }
            },
            child: IconButton(
              onPressed: () {},
              icon: SvgPicture.asset(
                'assets/images/double-chevron-left-svgrepo-com.svg',
                width: 22,
                height: 22,
                color: Colors.white,
              ),
              iconSize: 35,
              color: Colors.white,
            ),
          ),
        ),
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
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
                        setState(() {
                          widget.audioHandler.play();
                        });
                      } else {
                        setState(() {
                          widget.audioHandler.pause();
                        });
                      }
                    },
              icon: playerIcon,
              iconSize: 35),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            // Black color with 50% opacity
            shape: BoxShape.circle, // Assuming you want a circular background
          ),
          child: IconButton(
            onPressed: () {
              if (widget.audioHandler.onPressNext != null) {
                widget.audioHandler.onPressNext();
              }
            },
            icon: SvgPicture.asset(
              'assets/images/double-right-chevron-svgrepo-com.svg',
              width: 22,
              height: 22,
              color: Colors.white,
            ),
            iconSize: 35,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
