import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Map/globals.dart';

class NavigationDrawer extends StatelessWidget {
  static Map<String, GlobalKey<ScaffoldState>> pageNameToScaffoldKey =
      HashMap();

  static void openDrawer(GlobalKey<ScaffoldState>? key) {
    key?.currentState?.openDrawer();
  }
  static void closeDrawer(GlobalKey<ScaffoldState>? key) {
    key?.currentState?.closeDrawer();
  }
  static Widget buildNavigationDrawerButton(BuildContext context) {
    return IconButton(
        onPressed: () {
          GlobalKey<ScaffoldState>? key =
              pageNameToScaffoldKey[ModalRoute.of(context)?.settings.name];
          print(ModalRoute.of(context)?.settings.name);
          openDrawer(key);
        },
        icon: Icon(Icons.menu),
        color: Colors.black);
  }

  @override
  Widget build(BuildContext context) {
    print(ModalRoute.of(context)?.settings.name);
    return Drawer(
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountEmail: Text(''), // keep blank text because email is required
            accountName: Row(
              children: <Widget>[
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(shape: BoxShape.circle),
                  child: CircleAvatar(
                    backgroundColor: Colors.redAccent,
                    backgroundImage: NetworkImage(Globals
                            .globalController.googleAccount.value?.photoUrl ??
                        ""),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                        margin: EdgeInsets.only(left: 5),
                        child: Text(Globals.globalUserInfoObj?.name ?? ""))
                  ],
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.map,
            ),
            title: const Text('Map'),
            onTap: () {
              print(ModalRoute.of(context)?.settings.name);
              // Navigator.of(context).pushNamedAndRemoveUntil('/HomePage', (Route<dynamic> route) => false);
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
          ListTile(
            leading: Icon(
              Icons.history,
            ),
            title: const Text('History'),
            onTap: () {
              closeDrawer(pageNameToScaffoldKey[ModalRoute.of(context)?.settings.name]);
              Navigator.of(context).popUntil((route) => route.isFirst);
              // Navigator.of(context).pushNamedAndRemoveUntil('/history-screen', (Route<dynamic> route) => false);
              Navigator.pushNamed(context, '/history-screen');
            },
          ),
        ],
      ),
    );

    // return Scaffold(
    //   key: _scaffoldState,
    //   drawer: DrawerView(),
    //   body: ThemeScreen(
    //     header: Column(
    //       crossAxisAlignment: CrossAxisAlignment.start,
    //       children: [
    //         IconButton(
    //           icon: Icon(Icons.menu,
    //               color: Colors.white,
    //               size: 15),
    //           onPressed: (){
    //             _scaffoldState.currentState.openDrawer();
    //           },
    //         ),
    //       ],
    //     ),
    //   ),
    // );
  }
}
