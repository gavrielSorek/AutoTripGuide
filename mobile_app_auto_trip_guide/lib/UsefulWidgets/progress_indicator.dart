import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class UserProgressIndicator extends StatefulWidget {
  const UserProgressIndicator({
    Key? key,
    this.color = const Color(0xFFFFE306),
    this.child,
  }) : super(key: key);

  final Color color;
  final Widget? child;

  @override
  State<UserProgressIndicator> createState() => _UserProgressIndicator();
}

class _UserProgressIndicator extends State<UserProgressIndicator> {

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      // transform: Matrix4.diagonal3Values(_size, _size, 1.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Text(
            'Searching For Pois...',

          ),
          const CircularProgressIndicator(),
        ],
      ),
    );
  }
}