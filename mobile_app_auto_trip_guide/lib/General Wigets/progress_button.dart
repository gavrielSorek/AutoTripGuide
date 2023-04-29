import 'dart:async';

import 'package:flutter/material.dart';

class ProgressButton extends StatefulWidget {
  final Color color;
  final Duration fillDuration;
  final Function onCountDownFinished;
  final Function onPressed;
  final double width;
  final double height;
  final String content;
  final StreamController<bool> animationStatusStream = StreamController<bool>();

  ProgressButton(
      {required this.color,
      required this.fillDuration,
      required this.onPressed,
      required this.onCountDownFinished,
      required this.width,
      required this.height,
      required this.content});

  void setAnimationActivityStatus(bool isActive) {
    animationStatusStream.add(isActive);
  }

  @override
  _ProgressButtonState createState() {
    return _ProgressButtonState(animationStatusStream.stream);
  }
}

class _ProgressButtonState extends State<ProgressButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late double fillingPercent = 0;
  late Stream _isAnimationActiveStream;
  late StreamSubscription _isAnimationActiveSubscription;

  _ProgressButtonState(Stream animationActivityStream) {
    _isAnimationActiveStream = animationActivityStream;
  }

  @override
  void initState() {
    super.initState();
    _isAnimationActiveSubscription =
        _isAnimationActiveStream.listen((isActive) {
      if (!isActive) {
        stopCountDown();
      }
    });
    _animationController =
        AnimationController(vsync: this, duration: widget.fillDuration);
    _animationController.addListener(() {
      setState(() {
        fillingPercent = _animationController.value;
      });
    });
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onCountDownFinished();
      }
    });
    _animationController.forward();
  }

  stopCountDown() {
    _animationController.stop();
  }

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      onPressed: () {
        widget.onPressed();
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.height / 2),
        child: SizedBox(
          height: widget.height,
          width: widget.width,
          child: Stack(
            children: [
              Container(
                color: Colors.grey,
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: fillingPercent,
                  heightFactor: 1,
                  child: Container(
                    color: widget.color,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  alignment: Alignment.center,
                  color: Colors.transparent,
                  child: Text(
                    widget.content,
                    style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Inter',
                        fontSize: 15,
                        letterSpacing: 0.3499999940395355,
                        fontWeight: FontWeight.normal,
                        height: 1.2727272727272727),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Future<void> dispose() async {
    super.dispose();
    _isAnimationActiveSubscription.cancel();
    _animationController.dispose();
  }
}
