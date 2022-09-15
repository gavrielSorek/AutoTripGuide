import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../Map/globals.dart';


class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            toolbarHeight: 0.0,
          title: const Text('Auto Trip Guide'),
          elevation: 0,
          centerTitle: true,
          ),
        body: Column(
          children: [
            Expanded(
                child: Container(
                  child: Globals.globalUserMap,
                )),
          ],
        ),
    );
  }
}
