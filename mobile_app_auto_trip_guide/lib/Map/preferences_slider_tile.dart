import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PreferencesSliderTile extends StatefulWidget {
  final double initialRange;
  final ValueChanged<double> onChanged;
  final Widget title;
  final double minVal;
  final double maxVal;
  final String leftSuffix;
  final String rightSuffix;

  PreferencesSliderTile({
    Key? key,
    required this.initialRange,
    required this.onChanged,
    required this.title,
    required this.minVal,
    required this.maxVal,
    required this.leftSuffix,
    required this.rightSuffix,
  }) : super(key: key);

  @override
  _PreferencesSliderTileState createState() => _PreferencesSliderTileState();
}

class _PreferencesSliderTileState extends State<PreferencesSliderTile> {
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
      subtitle: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(widget.leftSuffix),
          Slider(
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
          Text(widget.rightSuffix),
        ],
      ),
    );
  }
}
