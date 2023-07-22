import 'dart:async';

import 'package:flutter/material.dart';
import '../General/Menu.dart' as menu;
import '../Map/globals.dart';
import '../Map/types.dart';

class HistoryPage extends StatefulWidget {
  HistoryPage({Key? key}) : super(key: key);

  @override
  _HistoryPageState createState() {
    return _HistoryPageState();
  }
}

class _HistoryPageState extends State<HistoryPage> {
  GlobalKey<ScaffoldState> _scaffoldState = GlobalKey<ScaffoldState>();

  List<VisitedPoi> visitedPoisList = Globals.globalVisitedPoi;
  int visitedPoisListLength = Globals.globalVisitedPoi.length;
  Stream stream = Globals.globalVisitedPoiStream.stream;
  late StreamSubscription _visitedPoisStreamSubscription;

  @override
  void initState() {
    Globals.appEvents.introStarted();
    super.initState();
    _visitedPoisStreamSubscription = stream.listen((value) {
      //TODO DELETE
      visitedPoisListUpdated();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _visitedPoisStreamSubscription.cancel();

  }
  void visitedPoisListUpdated() {
    setState(() {
      visitedPoisList = Globals.globalVisitedPoi;
      visitedPoisListLength = Globals.globalVisitedPoi.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    menu.NavigationDrawer.pageNameToScaffoldKey['/history-screen'] = _scaffoldState;

    return Scaffold(
        // appBar: buildAppBar(context),
        key: _scaffoldState,
        drawer: menu.NavigationDrawer(),
        body: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            margin: const EdgeInsets.only(top: 60),
            alignment: Alignment.topLeft,

            child: menu.NavigationDrawer.buildNavigationDrawerButton(context),
          ),
          Expanded(
              child: ListView.separated(
            itemBuilder: (BuildContext, index) {
              int position = visitedPoisListLength - index - 1;
              return ListTile(
                leading: CircleAvatar(
                    backgroundColor: Colors.transparent,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(15)),
                      child: Image.network(visitedPoisList[position].pic ?? ""),
                    )),
                title: Text(visitedPoisList[position].poiName ??
                    "https://assets.hyatt.com/content/dam/hyatt/hyattdam/images/2019/02/07/1127/Andaz-Costa-Rica-P834-Aerial-Culebra-Bay-View.jpg/Andaz-Costa-Rica-P834-Aerial-Culebra-Bay-View.16x9.jpg"),
                subtitle: Text(visitedPoisList[position].time),
                onTap: () async {
                  Poi? poi = await Globals.globalServerCommunication.getPoiById(visitedPoisList[position].id);
                  if (poi != null) {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Row(
                            children: [
                              Icon(Icons.history, color: Colors.green),
                              SizedBox(width: 8),
                              Flexible(child: Text(poi.poiName!, overflow: TextOverflow.ellipsis)),
                            ],
                          ),
                          content: Text('Do you want to hear about ' + poi.poiName! + " ?"),
                          actions: <Widget>[
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white, backgroundColor: Colors.lightBlue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.0),
                                ),
                                elevation: 8.0,
                              ),
                              child: Text('OK', style: TextStyle(fontSize: 16.0)),
                              onPressed: () {
                                Navigator.of(context).popUntil((route) => route.isFirst);
                                Globals.globalAllPois[poi.id] = MapPoi(poi);
                                Navigator.of(context).popUntil((route) => route.isFirst); // return to the map
                                Globals.globalClickedPoiStream.add(poi.id);
                              },
                            ),
                            TextButton(
                              child: Text('Cancel', style: TextStyle(color: Colors.grey)),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  } else {
                    // show error dialog
                    Future dialogFuture = showDialog(
                      context: context, // Pass the BuildContext variable to showDialog
                      builder: (context) {
                        return AlertDialog(
                          title: Row(
                            children: [
                              Icon(Icons.clear, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Error', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                          content: Text('Cant find ' + visitedPoisList[position].poiName!)
                        );
                      },
                    );

                    // Check if the dialog is still displayed
                    bool dialogIsDisplayed = true;

                    dialogFuture.then((value) {
                      if (mounted) {
                        setState(() {
                          dialogIsDisplayed = false;
                        });
                      }
                    });

                    Future.delayed(Duration(seconds: 3), () {
                      if (dialogIsDisplayed) {
                        Navigator.of(context).pop();
                      }
                    });
                  }
                },
              );
            },
            separatorBuilder: (BuildContext, index) {
              return const Divider(height: 1);
            },
            itemCount: visitedPoisList.length,
            shrinkWrap: true,
            padding: const EdgeInsets.all(5),
            scrollDirection: Axis.vertical,
          )),
        ]));
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      toolbarHeight: 0.0,
      title: const Text('History'),
      centerTitle: true,
      elevation: 0,
    );
  }
}
