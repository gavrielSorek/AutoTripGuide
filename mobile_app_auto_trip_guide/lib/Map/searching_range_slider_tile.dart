import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SearchingRangeSliderTile extends StatefulWidget {
  final double initialRange;
  final ValueChanged<double> onChanged;
  final Widget title;

  static const double DEFAULT_MIN = 500.0;
  static const double DEFAULT_MAX = 5000.0;

  SearchingRangeSliderTile({
    Key? key,
    required this.initialRange,
    required this.onChanged,
    required this.title,
  }) : super(key: key);

  @override
  _SearchingRangeSliderTileState createState() => _SearchingRangeSliderTileState();
}

class _SearchingRangeSliderTileState extends State<SearchingRangeSliderTile> {
  late double _currentRange;

  @override
  void initState() {
    super.initState();
    _currentRange = widget.initialRange;
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: widget.title,
      subtitle: Slider(
        value: _currentRange,
        min: SearchingRangeSliderTile.DEFAULT_MIN,
        max: SearchingRangeSliderTile.DEFAULT_MAX,
        divisions: 90, // This is the added line for 50 value jumps.
        onChanged: (double newValue) {
          setState(() {
            _currentRange = newValue;
          });
        },
        onChangeEnd: (double finalValue) {
          widget.onChanged(finalValue);
        },
      ),
      trailing: Text('${_currentRange.round()} m'),
    );
  }
}
