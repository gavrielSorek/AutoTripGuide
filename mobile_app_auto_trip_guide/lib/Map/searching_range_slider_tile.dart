import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SearchingRangeSliderTile extends StatefulWidget {
  final double initialRange;
  final ValueChanged<double> onChanged;
  final Widget title;
  final double minVal;
  final double maxVal;


  SearchingRangeSliderTile({
    Key? key,
    required this.initialRange,
    required this.onChanged,
    required this.title,
    required this.minVal,
    required this.maxVal,
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
        min: widget.minVal,
        max: widget.maxVal,
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
