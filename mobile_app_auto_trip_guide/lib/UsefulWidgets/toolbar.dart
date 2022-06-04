import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../Map/globals.dart';


class ToolbarWidget extends StatefulWidget {
  Toolbar? toolbar;
  ToolbarWidget({Key? key}) : super(key: key);

  @override
  Toolbar createState() => Toolbar();
}

class Toolbar extends State<ToolbarWidget> {
  int _selectedScreenIndex = 0;

  void _selectScreen(int index) {
    // if the index is different from map page
    if(index != 0) {
      // always pause dialog box when not in the map page
      Globals.globalUserMap.userMapState?.guideTool.pauseGuideDialogBox();
      if (Globals.globalAudioPlayer.isPlaying() || Globals.globalAudioPlayer.isPlayingIntro()) {
        Globals.globalAudioPlayer.pauseAudio();
      }
    } else { // if map page
      if (Globals.globalAudioPlayer.isIntroPaused()) {
        Globals.globalAudioPlayer.playAudio();
      } else {
      Globals.globalUserMap.userMapState?.guideTool.unpauseGuideDialogBox();
      }
    }
    setState(() {
      _selectedScreenIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedScreenIndex,
        children: Globals.globalPagesList,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedScreenIndex,
        onTap: _selectScreen,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_box_outlined), label: "Account"),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "History")
        ],
      ),
    );
  }
}
