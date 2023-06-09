import 'package:cached_network_image/cached_network_image.dart';
import 'package:final_project/Map/types.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../General Wigets/stretching_widget.dart';
import 'globals.dart';

class PoiGuide extends StatefulWidget {
  Poi poi;
  Widget? widgetOnPic;
  Widget? preferencesButton;

  PoiGuide({required this.poi, this.widgetOnPic, this.preferencesButton});

  @override
  _PoiGuideState createState() => _PoiGuideState();
}

class _PoiGuideState extends State<PoiGuide> {
  final GlobalKey<StretchingWidgetState> stretchingWidgetKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return StretchingWidget(
        key: stretchingWidgetKey,
        collapsedChild: collapsedPoiInfo,
        expendedChild: expendedPoiInfo);
  }

  get poiScrolledText {
    return Expanded(
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
              Text(
                widget.poi.shortDesc ?? '',
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
    );
  }

  Widget getTopPart(bool isExpanded) {
    return Stack(
      children: [
        PoiGuideImageWidget(
          imagePath: widget.poi.pic ?? '',
        ),
        Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: widget.preferencesButton,
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black,
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withOpacity(0.5),
                  Colors.black.withOpacity(0),
                ],
              ),
              shape: BoxShape.rectangle,
            ),
            child: Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.3 * 0.4,
              child: Stack(
                children: [
                  Positioned(
                    bottom: 25, // change this value to adjust text position
                    left: 0,
                    right: 0,
                    child: Text(
                      widget.poi.poiName ?? '',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Inter',
                          fontSize: 20,
                          letterSpacing: 0.3499999940395355,
                          fontWeight: FontWeight.normal,
                          height: 1),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  Positioned(
                    bottom: -10, // keeps the IconButton at the bottom
                    left: 0,
                    right: 0,
                    child: IconButton(
                      onPressed: () {
                        if (isExpanded)
                          stretchingWidgetKey.currentState!.collapse();
                        else
                          stretchingWidgetKey.currentState!.stretch();
                      },
                      icon: isExpanded
                          ? Icon(
                        Icons.arrow_drop_down,
                        size: 30,
                        color: Colors.white,
                      )
                          : Icon(
                        Icons.arrow_drop_up,
                        size: 30,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: widget.widgetOnPic,
        ),
      ],
    );
  }


  get collapsedPoiInfo {
    return Column(
      children: [
        Container(
          height: MediaQuery.of(context).size.height *
              0.5 *
              StretchingWidget.collapsedPercentFromAvailableSpace,
          child: getTopPart(false),
        ),
        poiScrolledText,
        BottomBarWidget(
          poi: widget.poi,
        )
      ],
    );
  }

  get expendedPoiInfo {
    return Column(
      children: [
        Container(
          height: MediaQuery.of(context).size.height * 0.3,
          child: getTopPart(true),
        ),
        poiScrolledText,
        BottomBarWidget(
          poi: widget.poi,
        ),
      ],
    );
  }
}

class PoiGuideImageWidget extends StatelessWidget {
  final String imagePath;

  get borderRadius => BorderRadius.only(
        topLeft: Radius.circular(34),
        topRight: Radius.circular(34),
        bottomLeft: Radius.zero,
        bottomRight: Radius.zero,
      );

  const PoiGuideImageWidget({Key? key, required this.imagePath})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 400),
      width: MediaQuery.of(context).size.width,
      child: ClipRRect(
        borderRadius: borderRadius,
        child: FittedBox(
          fit: BoxFit.fill,
          child: CachedNetworkImage(
            imageUrl: imagePath,
            placeholder: (context, url) => CircularProgressIndicator(),
            errorWidget: (context, url, error) =>
                Icon(Icons.error_outlined, size: 100),
          ),
        ),
      ),
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
    Globals.globalServerCommunication
        .getPoiPreferences(widget.poi.id, Globals.globalUserInfoObj)
        .then((value) {
      if (mounted) {
        setState(() {
          poiPreference = value ?? 0;
        });
      }
    });
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
