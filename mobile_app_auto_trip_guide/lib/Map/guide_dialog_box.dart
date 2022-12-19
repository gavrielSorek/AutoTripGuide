import 'dart:collection';
import 'dart:ffi';
import 'package:final_project/Map/types.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:final_project/Adjusted Libs/story_view/story_view.dart';
import 'package:final_project/Adjusted Libs/story_view/story_controller.dart';

import '../General Wigets/scrolled_text.dart';
import 'audio_player_controller.dart';
import 'globals.dart';

class Constants {
  Constants._();

  static const double padding = 2;
  static const double avatarRadius = 60;
  static const double edgesDist = 10;
}

class StoriesDialogBox extends StatefulWidget {
  Map<String, MapPoi> _poisToPlay = HashMap<String, MapPoi>();
  Map<String, MapPoi> _queuedPois = HashMap<String, MapPoi>();
  final audioApp = AudioApp();
  dynamic? onPressLeft, onPressRight;

  StoriesDialogBox({required Key key}) : super(key: key);

  static String getTime() {
    DateTime now = new DateTime.now();
    DateTime date =
        DateTime(now.year, now.month, now.day, now.hour, now.minute);
    String dateToday = date.toString().substring(0, 16);
    return dateToday;
  }

  setPoisToPlayWhenFinished(Map<String, MapPoi> poisForQueuing) {
    _queuedPois.addAll(poisForQueuing);
    if (this._poisToPlay.isEmpty) {
      setPoisToPlay(_queuedPois);
    }
  }

  setPoisToPlay(Map<String, MapPoi> poisToPlay) {
    this._poisToPlay.clear();
    this._poisToPlay.addAll(poisToPlay);
    if (_guideDialogBoxState != null) {
      _guideDialogBoxState!.updateStories();
    }
  }

  _StoriesDialogBoxState? _guideDialogBoxState;

  @override
  _StoriesDialogBoxState createState() {
    _guideDialogBoxState = _StoriesDialogBoxState();
    return _guideDialogBoxState!;
  }
}

class _StoriesDialogBoxState extends State<StoriesDialogBox> {
  final controller = StoryController();
  Widget? _storyWidget = null;
  MapPoi? _currentPoi = null, _lastPoi = null;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void initState() {
    super.initState();
    widget.audioApp.onPressNext = () {
      widget.audioApp.stopAudio();
      controller.pause();
      controller.next();
    };
    widget.audioApp.onPressPrev = () {
      widget.audioApp.stopAudio();
      controller.previous();
    };
    widget.audioApp.onPause = () {
      controller.pause();
    };
    widget.audioApp.onResume = () {
      controller.play();
    };
    widget.audioApp.onProgressChanged = (double progress) {
      controller.setProgressValue(progress);
    };
    widget.audioApp.onPlayerFinishedFunc = () {
      controller.next();
    };
  }

  updateStories() {
    _storyWidget = storyWidget();
    updateState();
  }

  void updateState() {
    setState(() {});
  }

  Widget storyWidget() {
    final List<StoryItem> storyItems = [];
    widget._poisToPlay.forEach((key, mapPoi) {
      storyItems.add(ScrolledText.textStory(
        id: mapPoi.poi.id,
          title: mapPoi.poi.poiName ?? 'No Name',
          text: mapPoi.poi.shortDesc,
          backgroundColor: Colors.white,
          key: Key(mapPoi.poi.id),
          // duration: Duration(seconds: double.infinity.toInt()))); // infinite
          duration: Duration(hours: 100))); // infinite
    });

    return StoryView(
      controller: controller,
      repeat: true,
      progressPosition: ProgressPosition.bottom,
      onStoryShow: (s) async {
        widget.audioApp.stopAudio();
        controller.setProgressValue(0);
        String poiId =
            s.view.key.toString().replaceAll(RegExp(r"<|>|\[|\]|'"), '');
        _currentPoi = widget._poisToPlay[poiId];
        widget.audioApp.setText(
            _currentPoi!.poi.shortDesc!, _currentPoi!.poi.language ?? 'en');
        widget.audioApp.playAudio();
        if (_lastPoi != null) {
          Globals.globalUserMap.userMapState?.unHighlightMapPoi(_lastPoi!);
        }
        Globals.globalUserMap.userMapState?.highlightMapPoi(_currentPoi!);
        _lastPoi = _currentPoi;

        setState(() {});
        Globals.addGlobalVisitedPoi(VisitedPoi(
            poiName: _currentPoi!.poi.poiName,
            id: _currentPoi!.poi.id,
            time: StoriesDialogBox.getTime(),
            pic: _currentPoi!.poi.pic));
      },
      onComplete: () {
        if (!widget._queuedPois.isEmpty) {
          widget.setPoisToPlay(widget._queuedPois);
        }
      },

      storyItems:
          storyItems, // To disable vertical swipe gestures, ignore this parameter.
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(Constants.edgesDist),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Constants.padding),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  contentBox(context) {
    Widget? stories = _storyWidget;
    if (stories == null || widget._poisToPlay.isEmpty) {
      stories = SizedBox.shrink();
    }
    return Stack(
      children: <Widget>[
        Container(
            height: double.infinity,
            padding: const EdgeInsets.only(
                left: Constants.padding,
                top: Constants.avatarRadius + Constants.padding,
                right: Constants.padding,
                bottom: Constants.padding),
            margin: const EdgeInsets.only(top: Constants.avatarRadius),
            decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                color: Colors.white,
                borderRadius: BorderRadius.circular(Constants.padding),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black,
                      offset: Offset(0, 5),
                      blurRadius: 10),
                ]),
            child: Column(
              children: [
                Expanded(child: stories),
                Container(child: widget.audioApp, height: 56)
              ],
            )),
        Positioned(
          left: Constants.padding,
          right: Constants.padding,
          child: CircleAvatar(
              backgroundColor: Colors.transparent,
              radius: Constants.avatarRadius,
              child: ClipRRect(
                borderRadius:
                    BorderRadius.all(Radius.circular(Constants.avatarRadius)),
                child: Image.network(_currentPoi?.poi.pic ?? ""),
              )),
        ),
      ],
    );
  }
}
