import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BlurryDialog extends StatelessWidget {

  String title;
  String content;
  VoidCallback nextCallBack;
  VoidCallback okCallBack;
  VoidCallback cancelCallBack;



  BlurryDialog(this.title, this.content, this.okCallBack, this.nextCallBack,this.cancelCallBack);
  TextStyle textStyle = TextStyle (color: Colors.black);

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
        child:  AlertDialog(
          title: Text(title,style: textStyle,),
          content: Text(content, style: textStyle,),
          actions: <Widget>[
            FlatButton(
              child: Text("ok"),
              onPressed: () {
                okCallBack();
              },
            ),
            FlatButton(
              child: Text("next"),
              onPressed: () {
                nextCallBack();
              },
            ),
            FlatButton(
              child: Text("Cancel"),
              onPressed: () {
                cancelCallBack();
              },
            ),
          ],
        ));
  }
}
