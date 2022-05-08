import 'package:final_project/Map/events.dart';
import 'package:final_project/Map/map.dart';
import 'package:final_project/UsefulWidgets/toolbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../Map/globals.dart';


class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Auto Trip Guide'),
          centerTitle: true,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: () {
                UserMap.preUnmountMap();
                logOut(context);
              },
            ),
          ],),
        body: Column(
          children: [
            Expanded(
                child: Container(
                  child: Globals.globalUserMap,
                )),
            const Toolbar(),
          ],
        )
    );
  }
}
