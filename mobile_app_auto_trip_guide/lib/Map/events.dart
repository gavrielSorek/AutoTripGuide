import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../Pages/account_page.dart';
import 'globals.dart';

void mapButtonClickedEvent(BuildContext context) {
  Navigator.popUntil(context, (route) {
    if (route.settings.name == '/') {
      return true;
    }
    return false;
  });
  while (!ModalRoute.of(context)!.isCurrent) {
    Navigator.pop(context);
  }
}

void mapButtonLongClickedEvent(BuildContext context) {
  mapButtonClickedEvent(context); //get to home page
  print("triggering guide");
  Globals.globalUserMap.userMapState?.triggerGuide();
}

void accountButtonClickedEvent(BuildContext context) {
  Navigator.of(context)
      .push(MaterialPageRoute(builder: (context) => AccountPage()));
}

void reviewsButtonClickedEvent(BuildContext context) {}

void settingButtonClickedEvent(BuildContext context) {}
