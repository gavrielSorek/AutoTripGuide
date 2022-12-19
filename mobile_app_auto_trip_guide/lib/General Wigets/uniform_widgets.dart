

import 'package:flutter/material.dart';

class UniformButtons {
  static getPreferenceButton({required dynamic onPressed}) {
    return OutlinedButton(
      onPressed: onPressed,
      child: Text('Preferences',
        style: TextStyle(
        fontFamily: 'Inter',
        fontSize: 18,
        letterSpacing: 0,
        fontWeight: FontWeight.bold,
        height: 1.33,
        color: Color(0xff0A84FF),
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