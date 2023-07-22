import 'package:journ_ai/General/menu.dart' as menu;
import 'package:flutter/material.dart';
import '../Map/globals.dart';

class FavoriteCategoriesPage extends StatefulWidget {
  const FavoriteCategoriesPage({Key? key}) : super(key: key);

  @override
  FavoriteCategories createState() => FavoriteCategories();
}

class FavoriteCategories extends State<FavoriteCategoriesPage> {
  GlobalKey<ScaffoldState> _scaffoldState = GlobalKey<ScaffoldState>();

  List<String> categories = Globals.globalCategories?.keys.toList() ?? [];
  bool favorChanged = false;
  List<String> favorCategories = Globals.globalFavoriteCategories;

  List<Widget> buildCategoriesChips() {
    List<Widget> chips = [];
    for (String category in categories) {
      Widget item = Padding(
        padding: const EdgeInsets.only(left: 10, right: 5),
        child: FilterChip(
          backgroundColor: Colors.white38,
          shape: StadiumBorder(side: BorderSide(color: Globals.globalColor)),
          avatar: CircleAvatar(
            backgroundColor: favorCategories.contains(category)
                ? Globals.globalColor
                : Globals.globalColor,
            child: Text(
              category[0].toUpperCase(),
              style: TextStyle(color: Colors.white),
            ),
          ),
          label: Text(category, style: TextStyle(color: Colors.black)),
          selected: favorCategories.contains(category),
          selectedColor: Globals.globalColor,
          onSelected: (bool selected) {
            setState(() {
              if (selected) {
                favorCategories.add(category);
              } else {
                favorCategories.removeWhere((String name) {
                  return name == category;
                });
              }
              favorChanged = true;
            });
          },
        ),
      );
      chips.add(item);
    }
    return chips;
  }

  Container buildBackButton(BuildContext context) {
    return Container(
        height: MediaQuery.of(context).size.height / 22,
        color: Colors.transparent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              margin:
                  EdgeInsets.only(left: MediaQuery.of(context).size.width / 15),
              width: MediaQuery.of(context).size.width / 10,
              child: FloatingActionButton(
                backgroundColor: Globals.globalColor,
                heroTag: null,
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15.0))),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height / 50),
          ],
        ));
  }

  ElevatedButton buildApplyButton(BuildContext context) {
    return ElevatedButton(
      child: const Text('Apply'),
      onPressed: () {
        if (favorChanged) {
          Globals.setFavoriteCategories(favorCategories);
          Globals.globalServerCommunication.updateFavorCategories(
              Globals.globalController.googleAccount.value?.email ?? '');
          final snackBar = SnackBar(
            content: const Text('Your Favorite Categories Saved!'),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      },
      style: ElevatedButton.styleFrom(
          backgroundColor: Globals.globalColor,
          padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width / 2.5,
              vertical: MediaQuery.of(context).size.height / 100),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          textStyle:
              const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
    );
  }

  @override
  Widget build(BuildContext context) {
    menu.NavigationDrawer.pageNameToScaffoldKey['/favorite-categories-screen'] =
        _scaffoldState;
    return Scaffold(
        key: _scaffoldState,
        backgroundColor: Colors.white,
        // appBar: AppBar(
        //   toolbarHeight: 0.0,
        //   title: const Text('Favorite Categories'),
        //   titleSpacing: MediaQuery.of(context).size.width / 50,
        //   elevation: 0,
        //   leading: const BackButton(),
        //   centerTitle: true,),
        drawer: menu.NavigationDrawer(),
        body: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: MediaQuery.of(context).size.height / 50),
            Container(
                margin: const EdgeInsets.only(top: 60),
                alignment: Alignment.topLeft,
                child: menu.NavigationDrawer.buildNavigationDrawerButton(context)),
            // buildBackButton(context),

            SizedBox(height: MediaQuery.of(context).size.height / 50),
            Text(
              "Choose your favorite categories",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 25,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: MediaQuery.of(context).size.height / 80),
            Text(
              "You can choose more than one",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.black54,
                  fontSize: 15,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: MediaQuery.of(context).size.height / 40),
            Container(
              margin: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width / 15,
                  right: MediaQuery.of(context).size.width / 15),
              height: MediaQuery.of(context).size.height / 1.75,
              child:
                  ListView(primary: true, shrinkWrap: true, children: <Widget>[
                Wrap(
                  // menu row
                  spacing: 3,
                  runSpacing: 0.0,
                  //direction: Axis.horizontal,
                  children: buildCategoriesChips(),
                )
              ]),
            ),
            const Spacer(),
            Row(
              // menu row
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 35.0),
                  child: buildApplyButton(context),
                )
              ],
            ),
          ],
        ));
  }
}
