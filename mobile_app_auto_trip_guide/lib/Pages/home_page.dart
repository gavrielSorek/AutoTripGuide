

import 'package:final_project/Map/events.dart';
import 'package:final_project/Map/map.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Auto Trip Guide'), centerTitle: true),
        body: Column(
          children: [
            Expanded(
                child: Container(
                  child: UserMap.USER_MAP,
                )),
            Row( // menu row
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  child: const ElevatedButton(onPressed: mapButtonClickedEvent, child: Icon(Icons.map),
                  ),
                  height: MediaQuery.of(context).size.height / 11,
                  width: MediaQuery.of(context).size.width / 4,
                  color: Colors.cyan,
                ),
                Container(
                  child: const ElevatedButton(onPressed: accountButtonClickedEvent, child: Icon(Icons.account_box_outlined),
                  ),
                  height: MediaQuery.of(context).size.height / 11,
                  width: MediaQuery.of(context).size.width / 4,
                  color: Colors.cyan,
                ),
                Container(
                  child: const ElevatedButton(onPressed: reviewsButtonClickedEvent, child: Icon(Icons.rate_review),
                  ),
                  height: MediaQuery.of(context).size.height / 11,
                  width: MediaQuery.of(context).size.width / 4,
                  color: Colors.cyan,
                ),
                Container(
                  child: const ElevatedButton(onPressed: settingButtonClickedEvent, child: Icon(Icons.settings),
                  ),
                  height: MediaQuery.of(context).size.height / 11,
                  width: MediaQuery.of(context).size.width / 4,
                  color: Colors.cyan,
                ),
              ],
            )
          ],
        )
    );
  }
}
