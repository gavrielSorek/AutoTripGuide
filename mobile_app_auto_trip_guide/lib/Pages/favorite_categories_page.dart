import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../Map/events.dart';
import '../Map/globals.dart';

class FavoriteCategoriesPage extends StatefulWidget {
  const FavoriteCategoriesPage({Key? key}) : super(key: key);
  @override
  FavoriteCategories createState() => FavoriteCategories();
}

class FavoriteCategories extends State<FavoriteCategoriesPage> {
  List<String> categories = Globals.globalCategories?.keys.toList() ?? [];
  bool favorChanged = false;
  List<String> favorCategories = Globals.globalFavoriteCategories;

  List<Widget> buildCategoriesChips () {
    List<Widget> chips = [];
    for (String category in categories) {
      Widget item =  Padding(
        padding: const EdgeInsets.only(left:10, right: 5),
        child: FilterChip(
          backgroundColor: Colors.white38,
          shape: StadiumBorder(side: BorderSide(color: Color.fromRGBO(97, 157, 175, 0.8))),
        avatar: CircleAvatar(
            backgroundColor: favorCategories.contains(category)?Colors.white:Color.fromRGBO(0, 128, 128, 0.6),
            child: Text(category[0].toUpperCase(),style: TextStyle(color: Colors.white),),
          ),
          label: Text(category,style: TextStyle(color: Colors.black)),
          selected: favorCategories.contains(category),
          selectedColor: Color.fromRGBO(97, 157, 175, 1),
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
        child:
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width / 15),
              width: MediaQuery.of(context).size.width / 10,
              child: FloatingActionButton(
                backgroundColor: Color.fromRGBO(225, 245, 246, 0.8),
                heroTag: null,
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Icon(
                  Icons.arrow_back,
                  color: Color.fromRGBO(97, 157, 175, 1),
                ),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15.0))
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height / 50),
          ],));
  }


  ElevatedButton buildApplyButton(BuildContext context){
    return ElevatedButton(
      child: const Text('Apply'),
      onPressed: () {
        if(favorChanged) {
          Globals.setFavoriteCategories(favorCategories);
          Globals.globalServerCommunication.updateFavorCategories(Globals.globalController.googleAccount.value?.email ?? '');
          final snackBar = SnackBar(
            content: const Text('Your Favorite Categories Saved!'),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      },
      style: ElevatedButton.styleFrom(
          primary: Color.fromRGBO(97, 157, 175, 1),
          padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width / 2.5, vertical: MediaQuery.of(context).size.height / 100),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15)),
          textStyle:
          const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          toolbarHeight: 0.0,
          title: const Text('Favorite Categories'),
          titleSpacing: MediaQuery.of(context).size.width / 50,
          elevation: 0,
          leading: const BackButton(),
          centerTitle: true,),
        body: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: MediaQuery.of(context).size.height / 50),
            buildBackButton(context),
            SizedBox(height:MediaQuery.of(context).size.height / 50),
            Text("Choose your favorite categories", textAlign: TextAlign.center, style: TextStyle(
                color: Colors.black,
                fontSize: 25, fontWeight: FontWeight.bold),
                ),
            SizedBox(height:MediaQuery.of(context).size.height / 80),
            Text("You can choose more than one", textAlign: TextAlign.center, style: TextStyle(
                color: Colors.black54,
                fontSize: 15, fontWeight: FontWeight.bold),
            ),
            SizedBox(height:MediaQuery.of(context).size.height / 40),
            Container(
              margin: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width / 15, right: MediaQuery.of(context).size.width / 15),
              height: MediaQuery.of(context).size.height / 1.75,
              child: ListView(
                  primary: true,
                  shrinkWrap: true,
                  children: <Widget>[
                    Wrap( // menu row
                      spacing: 3,
                      runSpacing: 0.0,
                      //direction: Axis.horizontal,
                      children:
                      buildCategoriesChips(),
                    )]),
            ),
            const Spacer(),
            Row( // menu row
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 35.0),
                  child: buildApplyButton(context),
                )
              ],
            ),
          ],
        )
    );
  }
}