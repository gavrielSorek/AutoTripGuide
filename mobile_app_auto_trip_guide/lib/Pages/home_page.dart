import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../General/menu.dart' as menu;
import '../Map/globals.dart';
import '../Map/guid_bloc/guide_bloc.dart';

class HomePage extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey<ScaffoldState>();

  HomePage({Key? key}) : super(key: key);

  GlobalKey<ScaffoldState> getScaffoldKey() {
    return _scaffoldState;
  }

  @override
  Widget build(BuildContext context) {
    menu.NavigationDrawer.pageNameToScaffoldKey['/HomePage'] = _scaffoldState;
    return MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) =>
            GuideBloc()
              ..add(ShowSearchingPoisAnimationEvent()),
          )
        ],
        child: Scaffold(
          key: _scaffoldState,
          drawer: menu.NavigationDrawer(),
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
        )
    );
  }
}
