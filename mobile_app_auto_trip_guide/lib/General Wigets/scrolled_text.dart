import 'package:flutter/material.dart';
import 'package:final_project/Adjusted Libs/story_view/story_view.dart';


class ScrolledText extends StatelessWidget {
  /// Short hand to create text-only page.
  ///
  /// [title] is the text to be displayed on [backgroundColor]. The text color
  /// alternates between [Colors.black] and [Colors.white] depending on the
  /// calculated contrast. This is to ensure readability of text.
  ///
  /// Works for inline and full-page stories. See [StoryView.inline] for more on
  /// what inline/full-page means.
  static StoryItem textStory({
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
              Text(title,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                  )),
              Text(
                text,
                style: textStyle?.copyWith(
                      color: contrast > 1.8 ? Colors.white : Colors.black,
                    ) ??
                    TextStyle(
                      color: contrast > 1.8 ? Colors.white : Colors.black,
                      fontSize: 18,
                    ),
                textAlign: TextAlign.center,
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

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final double itemHeight = (size.height - kToolbarHeight - 24) / 2;
    final double itemWidth = size.width;

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Text(
        "GeeksForGeeks : Learn Any\n \n \n \n\ n\n\\n\ n\n\n\n\ n\n\nn\thing, Anywhere",
        style: TextStyle(
          color: Colors.green,
          fontWeight: FontWeight.bold,
          fontSize: 20.0,
        ),
      ),
    );
  }
}