import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class GuideControls extends StatefulWidget {
  @override
  _GuideControlsState createState() => _GuideControlsState();
}

class _GuideControlsState extends State<GuideControls> {
  Icon playingIcon = Icon(Icons.play_arrow);
  Icon pauseIcon = Icon(Icons.pause);
  bool isPlaying = false;

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
          child: IconButton(
            onPressed: () {
              // if (widget._audioHandler._onPressPrev != null) {
              //   widget._audioHandler._onPressPrev();
              // }
            },
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
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            // Black color with 50% opacity
            shape: BoxShape.circle, // Assuming you want a circular background
          ),
          child: IconButton(
            onPressed: () {
              setState(() {
                isPlaying = !isPlaying;
              });
            },
            icon: isPlaying ? playingIcon : pauseIcon,
            iconSize: 35,
            color: Colors.white,
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            // Black color with 50% opacity
            shape: BoxShape.circle, // Assuming you want a circular background
          ),
          child: IconButton(
            onPressed: () {},
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
