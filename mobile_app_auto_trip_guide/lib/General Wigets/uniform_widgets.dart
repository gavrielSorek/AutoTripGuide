import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

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

  static IconButton getGuidePreferencesButton({required dynamic onPressed}) {
    final String assetName = 'assets/images/settings_horizontal_lines.svg';
    return IconButton(icon: SvgPicture.asset(
        assetName,
        color: Color.fromRGBO(10, 132, 255, 1),
        semanticsLabel: 'Label'
    ), onPressed: onPressed);
  }

  static IconButton getReturnDialogButton({required dynamic onPressed}) {
    final String assetName = 'assets/images/return.svg';
    return IconButton(icon: SvgPicture.asset(
        assetName,
        color: Color.fromRGBO(10, 132, 255, 1),
        semanticsLabel: 'Label'
    ), onPressed: onPressed);
  }
}