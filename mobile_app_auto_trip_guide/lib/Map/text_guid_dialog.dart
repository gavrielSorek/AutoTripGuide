import 'dart:ui';
import 'package:flutter/material.dart';

class TextGuideDialog extends StatelessWidget {
  String title;
  String content;
  VoidCallback nextCallBack;

  TextGuideDialog(this.title, this.content, this.nextCallBack, {Key? key})
      : super(key: key);
  TextStyle textStyle = const TextStyle(color: Colors.black);

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
        child: AlertDialog(
          title: Text(
            title,
            style: textStyle,
          ),
          content: Text(
            content,
            style: textStyle,
          ),
          actions: <Widget>[
            FlatButton(
              child: Text("next"),
              onPressed: () {
                nextCallBack();
              },
            ),
          ],
        ));
  }
}
