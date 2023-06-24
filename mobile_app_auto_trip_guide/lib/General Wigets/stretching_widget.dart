import 'package:flutter/material.dart';

class Constants {
  Constants._();

  static const double padding = 2;
  static const double avatarRadius = 60;
  static const double edgesDist = 17;
  static const double sidesMarginOfPic = 42;
  static const double sidesMarginOfButtons = 10;
}

class StretchingWidget extends StatefulWidget {
  final Widget expendedChild;
  final Widget collapsedChild;
  dynamic onStretch, onCollapse;

  static get collapsedPercentFromAvailableSpace => 0.5;

  static get boxDecoration => BoxDecoration(
        shape: BoxShape.rectangle,
        color: Colors.white,
        borderRadius: BorderRadius.circular(34),
        boxShadow: [
          BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.25),
              offset: Offset(0, 0),
              blurRadius: 20)
        ],
      );

  StretchingWidget(
      {required this.expendedChild,
      required this.collapsedChild,
      this.onStretch,
      this.onCollapse,
      Key? key})
      : super(key: key);

  @override
  StretchingWidgetState createState() => StretchingWidgetState();
}

class StretchingWidgetState extends State<StretchingWidget> {
  late double _expandedHeight;
  late double _collapsedHeight;
  bool isSwipeInProgress = false;
  bool _isExpanded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _collapsedHeight = StretchingWidget.collapsedPercentFromAvailableSpace *
        MediaQuery.of(context).size.height;
    _expandedHeight = MediaQuery.of(context).size.height;
  }

  void stretch() {
    setState(() {
      _isExpanded = true;
    });
    if (widget.onStretch != null) {
      widget.onStretch();
    }
  }

  void collapse() {
    setState(() {
      _isExpanded = false;
    });
    if (widget.onCollapse != null) {
      widget.onCollapse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Padding(
        padding: const EdgeInsets.only(bottom: Constants.edgesDist),
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onVerticalDragUpdate: (DragUpdateDetails details) {
            if (!isSwipeInProgress) {
              isSwipeInProgress = true;
              if (details.delta.dy > 0) {
                // Swiped down
                collapse();
              } else if (details.delta.dy < 0) {
                // Swiped up
                stretch();
              }
              // Reset the flag after a short delay to allow the next swipe
              Future.delayed(const Duration(milliseconds: 500), () {
                isSwipeInProgress = false;
              });
            }
          },
          child: AnimatedContainer(
            duration: Duration(milliseconds: 500),
            height: _isExpanded ? _expandedHeight : _collapsedHeight,
            width: MediaQuery.of(context).size.width - 30,
            decoration: StretchingWidget.boxDecoration,
            child: _isExpanded ? widget.expendedChild : widget.collapsedChild,
          ),
        ),
      ),
    );
  }
}
