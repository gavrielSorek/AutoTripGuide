import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../General Wigets/stretching_widget.dart';

class PoiGuide extends StatefulWidget {
  @override
  _PoiGuideState createState() => _PoiGuideState();
}

class _PoiGuideState extends State<PoiGuide> {
  @override
  Widget build(BuildContext context) {
    return StretchingWidget(
        collapsedChild: collapsedPoiInfo, expendedChild: expendedPoiInfo);
  }

  get collapsedPoiInfo {
    return Container(
        decoration: StretchingWidget.boxDecoration,
        child: Column(children: [
          Stack(children: [
            PoiGuideImageWidget(
              imagePath:
                  'https://www.shutterstock.com/image-photo/mountains-under-mist-morning-amazing-260nw-1725825019.jpg',
              boxDecoration: StretchingWidget.boxDecoration,
            )
            // Large square picture
          ])
        ]));
  }

  get expendedPoiInfo {
    return Container(
        decoration: StretchingWidget.boxDecoration,
        child: Column(children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.3 ,
            child: Stack(
              children: [
                PoiGuideImageWidget(
                  imagePath: 'https://www.shutterstock.com/image-photo/mountains-under-mist-morning-amazing-260nw-1725825019.jpg',
                  boxDecoration: StretchingWidget.boxDecoration,
                ),
                Align(
                  alignment: Alignment.center,
                  child: GuideControls(),
                ),
                // Large square picture
              ],
            ),
          ),
          SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
                      'Phasellus sed consequat libero. Etiam tempus, ligula non cursus '
                      'fringilla, augue libero ornare sapien, in commodo mauris diam '
                      'ac justo. Morbi maximus, mauris at efficitur eleifend, purus '
                      'mauris vulputate nulla, eu auctor leo leo a justo. Curabitur '
                      'molestie purus id dolor suscipit, nec rhoncus lacus ultrices. '
                      'In finibus quam ac ante semper, et tincidunt sapien faucibus. '
                      'Nam convallis, est at facilisis laoreet, enim dui placerat '
                      'enim, sed faucibus lectus mauris non elit. In sit amet dapibus '
                      'purus. Donec dignissim justo eu tellus accumsan convallis. '
                      'In consequat purus in nisi efficitur lobortis. Nam nec tempus '
                      'risus, at laoreet lacus. Quisque id scelerisque lectus.',
                ),
              ),
            ),
          ),
        ]));
  }
}

class PoiGuideImageWidget extends StatelessWidget {
  final String imagePath;
  final BoxDecoration boxDecoration;

  const PoiGuideImageWidget(
      {Key? key,
      required this.imagePath,
      required this.boxDecoration})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 400),
      width: MediaQuery.of(context).size.width,
      child: ClipRRect(
        borderRadius: boxDecoration.borderRadius,
        child: CachedNetworkImage(
          imageUrl: imagePath,
          fit: BoxFit.fill,
          placeholder: (context, url) => CircularProgressIndicator(),
          errorWidget: (context, url, error) =>
              Icon(Icons.error_outlined, size: 100),
        ),
      ),
    );
  }
}

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
            color: Colors.black.withOpacity(0.5), // Black color with 50% opacity
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
            color: Colors.black.withOpacity(0.5), // Black color with 50% opacity
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
            color: Colors.black.withOpacity(0.5), // Black color with 50% opacity
            shape: BoxShape.circle, // Assuming you want a circular background
          ),
          child: GestureDetector(
            onTap: (){
              int mm = 6;
            },
            child: IconButton(
              onPressed: () {
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
        ),
      ],
    );
  }
}
