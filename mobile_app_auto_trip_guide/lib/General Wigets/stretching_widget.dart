
import 'package:flutter/material.dart';

class Constants {
  Constants._();

  static const double padding = 2;
  static const double avatarRadius = 60;
  static const double edgesDist = 10;
  static const double sidesMarginOfPic = 42;
  static const double sidesMarginOfButtons = 10;
}

class StretchingWidget extends StatefulWidget {
  final Widget expendedChild;
  final Widget collapsedChild;

  StretchingWidget({required this.expendedChild, required this.collapsedChild});

  @override
  _StretchingWidgetState createState() => _StretchingWidgetState();
}

class _StretchingWidgetState extends State<StretchingWidget> {
  late double _expandedHeight;
  late double _collapsedHeight;
  bool _isExpanded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _collapsedHeight = 0.3 * MediaQuery.of(context).size.height;
    _expandedHeight = MediaQuery.of(context).size.height;
  }

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: GestureDetector(
        onVerticalDragUpdate: (DragUpdateDetails details) {
          if (details.delta.dy > 0) {
            // Swiped down
            setState(() {
              _isExpanded = false;
            });
          } else if (details.delta.dy < 0) {
            // Swiped up
            setState(() {
              _isExpanded = true;
            });
          }
        },
        child: AnimatedContainer(
          duration: Duration(milliseconds: 500),
          height: _isExpanded ? _expandedHeight : _collapsedHeight,
          width: MediaQuery.of(context).size.width - 30,
          padding: const EdgeInsets.only(
              left: Constants.padding,
              top: Constants.avatarRadius + Constants.padding,
              right: Constants.padding,
              bottom: Constants.padding),
          margin:
          const EdgeInsets.only(top: Constants.avatarRadius),
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: Colors.white,
            borderRadius: BorderRadius.circular(34),
            boxShadow: [
              BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.25),
                  offset: Offset(0, 0),
                  blurRadius: 20)
            ],
          ),
          child: _isExpanded
              ? widget.expendedChild : widget.collapsedChild,
        ),
      ),
    );
  }
}