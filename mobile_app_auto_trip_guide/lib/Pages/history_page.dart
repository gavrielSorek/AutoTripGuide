import 'dart:async';

import 'package:flutter/material.dart';
import '../General Wigets/Menu.dart';
import '../Map/globals.dart';
import '../Map/types.dart';

class HistoryPage extends StatefulWidget {
  HistoryPage({Key? key}) : super(key: key);
  _HistoryPageState? _historyPageState;

  void visitedPoisListUpdated() {
    _historyPageState?.visitedPoisListUpdated();
  }

  @override
  _HistoryPageState createState() {
    _historyPageState = _HistoryPageState();
    return _historyPageState!;
  }
}

class _HistoryPageState extends State<HistoryPage> {
  GlobalKey<ScaffoldState> _scaffoldState = GlobalKey<ScaffoldState>();

  List<VisitedPoi> visitedPoisList = Globals.globalVisitedPoi;
  int visitedPoisListLength = Globals.globalVisitedPoi.length;
  Stream stream = Globals.globalVisitedPoiStream.stream;

  @override
  void initState() {
    super.initState();
    stream.listen((value) {
      //TODO DELETE
      visitedPoisListUpdated();
      setState(() {

      });
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
  void visitedPoisListUpdated() {
    setState(() {
      visitedPoisList = Globals.globalVisitedPoi;
      visitedPoisListLength = Globals.globalVisitedPoi.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    NavigationDrawer.pageNameToScaffoldKey['/history-screen'] = _scaffoldState;

    return Scaffold(
        // appBar: buildAppBar(context),
        key: _scaffoldState,
        drawer: NavigationDrawer(),
        body: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            margin: const EdgeInsets.only(top: 60),
            alignment: Alignment.topLeft,

            child: NavigationDrawer.buildNavigationDrawerButton(context),
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
