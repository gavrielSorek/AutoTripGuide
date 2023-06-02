import 'package:cached_network_image/cached_network_image.dart';
import 'package:final_project/Map/types.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:share_plus/share_plus.dart';

import '../General Wigets/stretching_widget.dart';
import 'globals.dart';

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
    return Column(
      children: [
        Container(
          height: MediaQuery.of(context).size.height * 0.3,
          child: Stack(
            children: [
              PoiGuideImageWidget(
                imagePath:
                'https://www.shutterstock.com/image-photo/mountains-under-mist-morning-amazing-260nw-1725825019.jpg',
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
        Expanded(
          child: Container(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Center(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(children: [
                      Padding(
                        padding: EdgeInsets.only(left: 0, right: 0),
                        child: Row(
                          children: [
                            Flexible(
                              child: Container(
                                child: Text(
                                  'title',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontFamily: 'Inter',
                                      fontSize: 22,
                                      letterSpacing: 0.3499999940395355,
                                      fontWeight: FontWeight.normal,
                                      height: 1.2727272727272727),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
                        'Phasellus sed consequat libero. Etiam tempus, ligula non cursus '
                        'fringilla, augue libero ornare sapien, in commodo mauris diam '
                        'ac justo. Morbi maximus, mauris at efficitur eleifend, purus '
                        'mauris vulputate nulla, eu auctor leo leo a justo. Curabitur '
                        'molestie purus id dolor suscipit, nec rhoncus lacus ultrices. '
                        'In finibus quam ac ante semper, et tincidunt sapien faucibus. '
                        'Nam convallis, est at facilisis laoreet, enim dui placerat '
                        'enim, sed faucibus lectus mauris non elit. In sit amet dapibus '
                        'ac justo. Morbi maximus, mauris at efficitur eleifend, purus '
                        'mauris vulputate nulla, eu auctor leo leo a justo. Curabitur '
                        'molestie purus id dolor suscipit, nec rhoncus lacus ultrices. '
                        'In finibus quam ac ante semper, et tincidunt sapien faucibus. '
                        'Nam convallis, est at facilisis laoreet, enim dui placerat '
                        'enim, sed faucibus lectus mauris non elit. In sit amet dapibus '
                        'purus. Donec dignissim justo eu tellus accumsan convallis. '
                        'In consequat purus in nisi efficitur lobortis. Nam nec tempus '
                        'risus, at laoreet lacus. Quisque id scelerisque lectus.',
                        style: TextStyle(
                            color: Color(0xff6C6F70),
                            fontFamily: 'Inter',
                            fontSize: 16,
                            letterSpacing: 0,
                            fontWeight: FontWeight.normal,
                            height: 1.5),
                        textAlign: TextAlign.left,
                      )
                    ]),
                  ),
                ),
                //color: backgroundColor,
              )),
        ),
        BottomBarWidget(
          poi: Poi(id: 'a', latitude: 38, longitude: 38, Categories: []),
        )
      ],
    );
  }
}

class PoiGuideImageWidget extends StatelessWidget {
  final String imagePath;
  final BoxDecoration boxDecoration;

  const PoiGuideImageWidget(
      {Key? key, required this.imagePath, required this.boxDecoration})
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
          child: GestureDetector(
            onTap: () {
              int mm = 6;
            },
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
        ),
      ],
    );
  }
}

class BottomBarWidget extends StatefulWidget {
  final Poi poi;

  BottomBarWidget({required this.poi});

  @override
  _BottomBarWidgetState createState() => _BottomBarWidgetState();
}

class _BottomBarWidgetState extends State<BottomBarWidget> {
  double bottomIconSize = 20;
  int poiPreference = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RawMaterialButton(
                onPressed: () {
                  Globals.globalAppLauncher.launchWaze(
                    widget.poi.latitude,
                    widget.poi.longitude,
                  );
                },
                elevation: 2.0,
                fillColor: Colors.blue,
                child: Icon(
                  Icons.directions,
                  size: bottomIconSize,
                ),
                shape: CircleBorder(),
              ),
              Opacity(
                opacity: poiPreference == -1 ? 1.0 : 0.5,
                child: RawMaterialButton(
                  onPressed: () {
                    Globals.appEvents.poiNavigationStarted(
                      widget.poi.poiName ?? '',
                      widget.poi.Categories,
                      widget.poi.id,
                    );
                    poiPreference = -1;
                    Globals.globalServerCommunication.insertPoiPreferences(
                      widget.poi.id,
                      Globals.globalUserInfoObj,
                      poiPreference,
                    );
                    setState(() {});
                  },
                  elevation: 2.0,
                  fillColor: Colors.red,
                  child: Icon(
                    Icons.thumb_down,
                    size: bottomIconSize,
                  ),
                  shape: CircleBorder(),
                ),
              ),
              Opacity(
                opacity: poiPreference == 1 ? 1.0 : 0.5,
                child: RawMaterialButton(
                  onPressed: () {
                    poiPreference = 1;
                    Globals.globalServerCommunication.insertPoiPreferences(
                      widget.poi.id,
                      Globals.globalUserInfoObj,
                      poiPreference,
                    );
                    setState(() {});
                  },
                  elevation: 2.0,
                  fillColor: Colors.green,
                  child: Icon(
                    Icons.thumb_up,
                    size: bottomIconSize,
                  ),
                  shape: CircleBorder(),
                ),
              ),
              RawMaterialButton(
                onPressed: () {
                  Globals.appEvents.poiShared(
                    widget.poi.poiName ?? '',
                    widget.poi.Categories,
                    widget.poi.id,
                  );
                  Share.share(
                    widget.poi.shortDesc ?? "",
                    subject: widget.poi.poiName,
                  );
                },
                elevation: 2.0,
                fillColor: Colors.blue,
                child: Icon(
                  Icons.share,
                  size: bottomIconSize,
                ),
                shape: CircleBorder(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
