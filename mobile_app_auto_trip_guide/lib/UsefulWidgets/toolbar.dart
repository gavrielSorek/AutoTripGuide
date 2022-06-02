import 'package:final_project/Map/events.dart';
import 'package:final_project/Pages/home_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Pages/account_page.dart';
import '../Pages/history_page.dart';

class ToolbarWidget extends StatefulWidget {
  const ToolbarWidget({Key? key}) : super(key: key);

  @override
  Toolbar createState() => Toolbar();
}

class Toolbar extends State<ToolbarWidget> {
  int _selectedScreenIndex = 0;
  final List _screens = [
    {"screen":  HomePage(), "title": "Screen A Title"},
    {"screen":  AccountPage(), "title": "Screen B Title"},
    {"screen":  HistoryPage(), "title": "Screen B Title"}
  ];

  void _selectScreen(int index) {
    setState(() {
      _selectedScreenIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedScreenIndex]["screen"],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedScreenIndex,
        onTap: _selectScreen,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.account_box_outlined), label: "Account"),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "History")
        ],
      ),
    );
  }
}
