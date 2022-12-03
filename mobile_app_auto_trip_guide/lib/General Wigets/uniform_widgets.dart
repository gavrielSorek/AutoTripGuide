

import 'package:flutter/material.dart';

class UniformButtons {
  static getPreferenceButton({required dynamic onPressed}) {
    return OutlinedButton(
      onPressed: onPressed,
      child: Text('Preferences',
        style: TextStyle(
          fontFamily: 'Arial',
          fontSize: 17,
          color: Colors.blue,
          height: 1,
        ),
      ),
      style: OutlinedButton.styleFrom(
        side: BorderSide(
          color: Colors.transparent,
        ),
      ),
    );
  }

}