import 'package:flutter/material.dart';
import '../General Wigets/Menu.dart';
import '../General Wigets/scrolled_text.dart';
import '../Map/globals.dart';


class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
