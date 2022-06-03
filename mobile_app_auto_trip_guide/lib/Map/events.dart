import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'globals.dart';

void logOut(BuildContext context) {
  Globals.clearAll();
  Globals.globalController.logout();
  Navigator.of(context).popUntil((route) => route.isFirst);
}

