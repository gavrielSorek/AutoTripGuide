import 'package:final_project/UsefulWidgets/toolbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Map/types.dart';
import 'my_webview.dart';

class PoiReadingPage extends StatelessWidget {
  Poi poi;
  late Widget widgetToShow;

  PoiReadingPage({Key? key, required this.poi}) : super(key: key) {
    if (poi.source == "" || poi.source == null) {
      // if there is no source
      widgetToShow = Material(
        color: Colors.transparent,
        child: Text(
          poi.shortDesc ?? "No info",
          style: const TextStyle(
            fontFamily: 'custom font', // remove this if don't have custom font
            fontSize: 26.0, // text size
            color: Colors.black, // text color
          ),
        ),
      );
    } else {
      widgetToShow = MyWebView(
        title: poi.poiName ?? "No name",
        selectedUrl: poi.source!,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: widgetToShow);
  }
}
