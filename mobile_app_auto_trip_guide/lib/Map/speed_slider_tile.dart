import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SpeedSliderTile extends StatefulWidget {
  static const double DEFAULT_MIN = 0.5, DEFAULT_MAX = 1.5;
  final double initialSpeed;
  final Function(double) onChanged;
  final Widget? title;
  final double min, max;

  SpeedSliderTile(
      {required this.initialSpeed,
      required this.onChanged,
      this.title,
      this.min = DEFAULT_MIN,
      this.max = DEFAULT_MAX});

  @override
  _SpeedSliderTileState createState() => _SpeedSliderTileState();
}

class _SpeedSliderTileState extends State<SpeedSliderTile> {
  double _speed = 1.0;

  @override
  void initState() {
    super.initState();
    _speed = widget.initialSpeed;
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: widget.title,
      subtitle: Slider(
        value: _speed,
        min: widget.min,
        max: widget.max,
        divisions: 10,
        onChanged: (value) {
          setState(() {
            _speed = value;
          });
          widget.onChanged(value);
        },
      ),
      trailing: Text('${_speed.toStringAsFixed(1)}x'),
    );
  }
}
