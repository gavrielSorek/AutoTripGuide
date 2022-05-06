import 'package:final_project/Map/events.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Toolbar extends StatelessWidget {
  const Toolbar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      // menu row
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Container(
          child: ElevatedButton(
            onPressed: () => mapButtonClickedEvent(context),
            child: Icon(Icons.map),
            onLongPress: () => mapButtonLongClickedEvent(context),
          ),
          height: MediaQuery.of(context).size.height / 11,
          width: MediaQuery.of(context).size.width / 4,
        ),
        Container(
          child: ElevatedButton(
            onPressed: () => accountButtonClickedEvent(context),
            child: Icon(Icons.account_box_outlined),
          ),
          height: MediaQuery.of(context).size.height / 11,
          width: MediaQuery.of(context).size.width / 4,
        ),
        Container(
          child: ElevatedButton(
            onPressed: () => reviewsButtonClickedEvent(context),
            child: Icon(Icons.rate_review),
          ),
          height: MediaQuery.of(context).size.height / 11,
          width: MediaQuery.of(context).size.width / 4,
        ),
        Container(
          child: ElevatedButton(
            onPressed: () => settingButtonClickedEvent(context),
            child: Icon(Icons.settings),
          ),
          height: MediaQuery.of(context).size.height / 11,
          width: MediaQuery.of(context).size.width / 4,
        ),
      ],
    );
  }
}
