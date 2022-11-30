import 'package:flutter/material.dart';
import '../General Wigets/menu.dart';
import '../General Wigets/scrolled_text.dart';
import '../Map/globals.dart';


class HomePage extends StatelessWidget {
  GlobalKey<ScaffoldState> _scaffoldState = GlobalKey<ScaffoldState>();
  HomePage({Key? key}) : super(key: key);

  GlobalKey<ScaffoldState> getScaffoldKey() {
    return _scaffoldState;
  }

  @override
  Widget build(BuildContext context) {
    NavigationDrawer.pageNameToScaffoldKey['/HomePage'] = _scaffoldState;
    return Scaffold(
      key: _scaffoldState,
      drawer: NavigationDrawer(),
      body: Stack(
        children: [
          Column(
            children: [
              // NavigationDrawer(),
              Expanded(
                  child: Container(
                child: Globals.globalUserMap,
              )),
            ],
          ),
        ],
      ),
    );
  }
}
