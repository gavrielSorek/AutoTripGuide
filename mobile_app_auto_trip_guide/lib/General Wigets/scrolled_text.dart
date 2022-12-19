import 'package:flutter/material.dart';
import 'package:final_project/Adjusted Libs/story_view/story_view.dart';

class ScrolledText {
  /// Short hand to create text-only page.
  ///
  /// [title] is the text to be displayed on [backgroundColor]. The text color
  /// alternates between [Colors.black] and [Colors.white] depending on the
  /// calculated contrast. This is to ensure readability of text.
  ///
  /// Works for inline and full-page stories. See [StoryView.inline] for more on
  /// what inline/full-page means.
  static StoryItem textStory({
    required String id,
    required String title,
    text,
    required Color backgroundColor,
    Key? key,
    TextStyle? textStyle,
    bool shown = false,
    bool roundedTop = false,
    bool roundedBottom = false,
    Duration? duration,
  }) {
    double contrast = ContrastHelper.contrast([
      backgroundColor.red,
      backgroundColor.green,
      backgroundColor.blue,
    ], [
      255,
      255,
      255
    ] /** white text */);

    return StoryItem(
      id: id,
      Container(
        key: key,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(roundedTop ? 8 : 0),
            bottom: Radius.circular(roundedBottom ? 8 : 0),
          ),
        ),
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
                    Text(
                      title,
                      style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'Inter',
                          fontSize: 22,
                          letterSpacing: 0.3499999940395355,
                          fontWeight: FontWeight.normal,
                          height: 1.2727272727272727),
                      textAlign: TextAlign.left,
                    ),
                    IconButton(
                      onPressed: () {
                        print("Press to see full poi info");
                        // context.read<GuideBloc>().add(SetCurrentPoiEvent(storyItem: s));
                      },
                      icon: Icon(
                        Icons.arrow_forward_ios_sharp,
                        size: 15,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                text ?? "",
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
      ),
      shown: shown,
      duration: duration ?? Duration(seconds: 3),
    );
  }
}
