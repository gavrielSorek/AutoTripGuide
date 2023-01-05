import 'package:flutter/material.dart';

class ProgressButton extends StatefulWidget {
  final Color color;
  final Duration fillDuration;
  final Function onPressed;
  late final double width;
  late final double height;

  ProgressButton({
    required this.color,
    required this.fillDuration,
    required this.onPressed,
    required this.width,
    required this.height

  });

  @override
  _ProgressButtonState createState() => _ProgressButtonState();
}

class _ProgressButtonState extends State<ProgressButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late double fillingPercent = 0;

  @override
  void initState() {
    super.initState();

    super.initState();
    _animationController = AnimationController(vsync: this, duration: widget.fillDuration);
    _animationController.addListener(() {
      setState(() {
        fillingPercent = _animationController.value;
        print(_animationController.value);
      });
    });
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
       print("pushhh");
      }
    });
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.height / 2),

      child: SizedBox(
        height: widget.height ,
        width: widget.width ,
        child: Stack(
          children: [
            Container(
              color: Colors.grey,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: widget.width * fillingPercent,
                color: widget.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}