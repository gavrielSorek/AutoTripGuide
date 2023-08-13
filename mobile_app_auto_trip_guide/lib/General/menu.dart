import 'dart:collection';

import 'package:journ_ai/Map/map.dart';
import 'package:journ_ai/Map/pois_attributes_calculator.dart';
import 'package:journ_ai/Map/speed_slider_tile.dart';
import 'package:flutter/material.dart';

import '../Map/globals.dart';
import '../Map/searching_range_slider_tile.dart';
import 'internal_map_events.dart';

class NavigationDrawer extends StatefulWidget {
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
        iconSize: 38,
        color: Color(0xff0A84FF));
  }

  @override
  State<StatefulWidget> createState() {
    return _NavigationDrawerState();
  }
}

class _NavigationDrawerState extends State<NavigationDrawer> {
  Color chosenTileColor = Colors.lightBlueAccent;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountEmail: Text(''), // keep blank text because email is required
            accountName: Row(
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                    Navigator.pushNamed(context, '/personal-details-screen');
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(shape: BoxShape.circle),
                    child: CircleAvatar(
                      backgroundColor: Colors.blue,
                      backgroundImage: NetworkImage(Globals
                              .globalController.googleAccount.value?.photoUrl ??
                          ""),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      Globals.globalUserInfoObj?.name ?? "",
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      Globals.globalController.googleAccount.value?.email ?? "",
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ListTile(
            tileColor: ModalRoute.of(context)?.settings.name == '/HomePage'
                ? chosenTileColor
                : null,
            leading: Icon(
              Icons.location_on_sharp,
            ),
            title: const Text('Map'),
            onTap: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
          ListTile(
            tileColor:
                ModalRoute.of(context)?.settings.name == '/history-screen'
                    ? chosenTileColor
                    : null,
            leading: Icon(
              Icons.history,
            ),
            title: const Text('History'),
            onTap: () {
              NavigationDrawer.closeDrawer(
                  NavigationDrawer.pageNameToScaffoldKey[
                      ModalRoute.of(context)?.settings.name]);
              Navigator.of(context).popUntil((route) => route.isFirst);
              Navigator.pushNamed(context, '/history-screen');
            },
          ),
          // ListTile(
          //   tileColor:
          //   ModalRoute.of(context)?.settings.name == '/favorite-categories-screen'
          //       ? chosenTileColor
          //       : null,
          //   leading: Icon(
          //     Icons.settings,
          //   ),
          //   title: const Text('Preferences'),
          //   onTap: () {
          //     NavigationDrawer.closeDrawer(
          //         NavigationDrawer.pageNameToScaffoldKey[ModalRoute.of(context)
          //             ?.settings.name]);
          //     Navigator.of(context).popUntil((route) => route.isFirst);
          //     Navigator.pushNamed(context, '/favorite-categories-screen');
          //   },
          // ),
          Divider(),
          ListTile(
            leading: Icon(Icons.refresh),
            title: const Text("Reload POI's"),
            onTap: () {
              Globals.globalUserMapKey.currentState?.reloadPois();
              NavigationDrawer.closeDrawer(
                  NavigationDrawer.pageNameToScaffoldKey[
                      ModalRoute.of(context)?.settings.name]);
            },
          ),
          ListTile(
            leading: Icon(
              Icons.map_outlined,
            ),
            title: const Text('Map Style'),
            trailing: InkWell(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return Container(
                      child: Wrap(
                        children: UserMap.STYLE_NAME_TO_STYLE.keys
                            .toList()
                            .map((String style) {
                          return ListTile(
                            title: Text(style),
                            tileColor: style ==
                                    Globals.globalUserMapKey.currentState
                                        ?.currentStyle
                                ? Colors.blue[100]
                                : null,
                            // Check if current style
                            onTap: () {
                              Globals.globalUserMapKey.currentState
                                  ?.currentStyle = style;
                              Navigator.of(context).pop();
                            },
                          );
                        }).toList(),
                      ),
                    );
                  },
                );
              },
              child: CircleAvatar(
                backgroundColor: Colors.grey[300], // Choose your desired color
                child: Icon(
                  Icons.arrow_drop_down,
                  size: 30.0, // Increase the size as needed
                ),
              ),
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.exit_to_app,
              color: Colors.red,
            ),
            title: Text(
              'Sign out',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () async {
              await Globals.globalController.logout();
              await Globals.stopAll();
              Navigator.of(context).popUntil((route) => route.isFirst);
              Navigator.pushReplacementNamed(context, '/init-screen');
            },
          ),
          SpeedSliderTile(
            initialSpeed: Globals.globalGuideAudioPlayerHandler.speed *
                SpeedSliderTile.DEFAULT_MAX,
            onChanged: (double val) {
              Globals.globalGuideAudioPlayerHandler
                  .setSpeed(val / SpeedSliderTile.DEFAULT_MAX);
            },
            title: Container(
              alignment: Alignment.center,
              child: Text('Audio Speed:'),
            ),
          ),
          SearchingRangeSliderTile(
            initialRange: PoisAttributesCalculator.getMaxDist(), // e.g., 2000.0
            onChanged: (double val) {
              PoisAttributesCalculator.setMaxDist(val);
              InternaMapEvents.instance.reloadPoisEvent.add(null);
            },
            title: Container(
              alignment: Alignment.center,
              child: Text('Search Range:'),
            ),
          ),
        ],
      ),
    );
  }
}
