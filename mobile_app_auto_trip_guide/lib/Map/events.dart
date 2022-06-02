import 'package:final_project/Pages/home_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../Pages/account_page.dart';
import '../Pages/history_page.dart';
import 'globals.dart';

void logOut(BuildContext context) {
  Globals.clearAll();
  Globals.globalController.logout();
  Navigator.of(context).popUntil((route) => route.isFirst);
}

void returnToHomePage(BuildContext context) {
  Navigator.of(context).popUntil((route) => route.isFirst);
}

void mapButtonClickedEvent(BuildContext context) {
  returnToHomePage(context);
}

void mapButtonLongClickedEvent(BuildContext context) {
  returnToHomePage(context);
  print("triggering guide");
  Globals.globalUserMap.userMapState?.triggerGuide();
}

void accountButtonClickedEvent(BuildContext context) {
  Globals.globalAudioPlayer.pauseAudio();
  returnToHomePage(context);
  Navigator.of(context)
      .push(MaterialPageRoute(builder: (context) => AccountPage()));
}

void reviewsButtonClickedEvent(BuildContext context) {
  Globals.globalAudioPlayer.pauseAudio();
  returnToHomePage(context);
  Navigator.of(context)
      .push(MaterialPageRoute(builder: (context) => HistoryPage()));
}

