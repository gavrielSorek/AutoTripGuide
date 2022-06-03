import 'package:flutter/material.dart';
import '../Map/events.dart';
import '../Map/globals.dart';
import '../Map/types.dart';
import '../UsefulWidgets/toolbar.dart';

class HistoryPage extends StatefulWidget {
  HistoryPage({Key? key}) : super(key: key);

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<VisitedPoi> visitedPoisList = Globals.globalVisitedPoi;
  int visitedPoisListLength = Globals.globalVisitedPoi.length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: buildAppBar(context),
        body: Column(mainAxisSize: MainAxisSize.min, children: [
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
      title: const Text('History'),
      centerTitle: true,
      elevation: 0,
    );
  }
}
