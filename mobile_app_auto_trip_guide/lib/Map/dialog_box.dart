import 'dart:math';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Constants {
  Constants._();

  static const double padding = 20;
  static const double avatarRadius = 45;
  static const double edgesDist = 18;
}

class CustomDialogBox extends StatefulWidget {
  final String title, descriptions, leftButtonText, rightButtonText;
  final Image img;
  dynamic? onPressLeft, onPressRight;

  CustomDialogBox(
      {required Key key,
        required this.title,
        required this.descriptions,
        required this.leftButtonText,
        required this.rightButtonText,
        required this.img,
        this.onPressLeft,
        this.onPressRight})
      : super(key: key);

  // progress between 0 - 1
  setProgress(progress) {
    _customDialogBoxState?.setProgress(progress);
  }

  _CustomDialogBoxState? _customDialogBoxState;

  @override
  _CustomDialogBoxState createState() {
    _customDialogBoxState = _CustomDialogBoxState();
    return _customDialogBoxState!;
  }
}

class _CustomDialogBoxState extends State<CustomDialogBox> {
  double progress = 0; // the smallest progress that possible
  // progress between 0 - 1
  setProgress(progress) {
    if (!mounted) {
      return; // Just do nothing if the widget is disposed.
    }
    setState(() {
      // progress in reality can be [0, 1]
      this.progress = min(1,max(progress, 0));
    });
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
    double maxLoadingWidth = MediaQuery.of(context).size.width - 2 * Constants.edgesDist - 2 *Constants.padding;
    double minLoadingWidth = 0;

    return Stack(
      children: <Widget>[
        Container(
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
            child: Column(children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.only(
                      left: Constants.padding,
                      right: Constants.padding,
                      top: 5,),
                    color: Colors.green,
                    width: min(maxLoadingWidth, max(progress * MediaQuery.of(context).size.width , minLoadingWidth)),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.only(
                    top: 5),
                color: Colors.transparent,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      widget.title,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Text(
                      widget.descriptions,
                      style: const TextStyle(fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(
                      height: 22,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        FlatButton(
                            onPressed: () {
                              if (widget.onPressLeft != null) {
                                widget.onPressLeft();
                              }
                            },
                            child: Text(
                              widget.leftButtonText,
                              style: TextStyle(fontSize: 18),
                            )),
                        FlatButton(
                            onPressed: () {
                              if (widget.onPressRight != null) {
                                widget.onPressRight();
                              }
                            },
                            child: Text(
                              widget.rightButtonText,
                              style: TextStyle(fontSize: 18),
                            )),
                      ],
                    )
                  ],
                ),
              )
            ])),
        Positioned(
          left: Constants.padding,
          right: Constants.padding,
          child: CircleAvatar(
              backgroundColor: Colors.transparent,
              radius: Constants.avatarRadius,
              child: ClipRRect(
                borderRadius:
                BorderRadius.all(Radius.circular(Constants.avatarRadius)),
                child: widget.img,
              )),
        ),
      ],
    );
  }
}
