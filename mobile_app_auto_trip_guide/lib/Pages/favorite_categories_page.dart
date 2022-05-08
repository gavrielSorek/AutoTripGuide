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
  List<String> categories = Globals.globalCategories.keys.toList();
  bool favorChanged = false;
  List<String> favorCategories = Globals.globalFavoriteCategories;

  List<Widget> buildCategoriesChips () {
    List<Widget> chips = [];
    for (String category in categories) {
      Widget item =  Padding(
        padding: const EdgeInsets.only(left:10, right: 5),
        child: FilterChip(
          backgroundColor: Color.fromRGBO(0, 204, 204, 1.0),
          avatar: CircleAvatar(
            backgroundColor: favorCategories.contains(category)?Color.fromRGBO(89, 0, 179, 1.0):Color.fromRGBO(0, 128, 128, 1.0),
            child: Text(category[0].toUpperCase(),style: TextStyle(color: Colors.white),),
          ),
          label: Text(category,style: TextStyle(color: Colors.white)),
          selected: favorCategories.contains(category),
          selectedColor: Color.fromRGBO(135,88,244, 1.0),
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


  ElevatedButton buildApplyButton(BuildContext context){
    return ElevatedButton(
      child: const Text('Apply'),
      onPressed: () {
        if(favorChanged) {
          Globals.globalFavoriteCategories = favorCategories;
          Globals.globalServerCommunication.updateFavorCategories(Globals.globalController.googleAccount.value?.email ?? '');
          final snackBar = SnackBar(
            content: const Text('Your Favorite Categories Saved!'),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      },
      style: ElevatedButton.styleFrom(
          primary: Color.fromRGBO(135,88,244, 1.0),
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
      backgroundColor: Color.fromRGBO(0, 26, 51, 1.0),
        appBar: AppBar(
          title: const Text('Favorite Categories'),
          titleSpacing: MediaQuery.of(context).size.width / 50,
          backgroundColor: Color.fromRGBO(38, 77, 115,1.0),
          leading: const BackButton(),
          centerTitle: true,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: () {
                logOut(context);
              }
            ),
          ],),
        body: Column(
          children: [
            SizedBox(height:MediaQuery.of(context).size.height / 20),
            Text("Choose your favorite categories", style: TextStyle(
                color: Colors.white,
                fontSize: 20),
                ),
            SizedBox(height:MediaQuery.of(context).size.height / 20),
            Wrap( // menu row
              spacing: 8,
              direction: Axis.horizontal,
              children:
              buildCategoriesChips(),
            ),
            SizedBox(height:MediaQuery.of(context).size.height / 3.5),
            Row( // menu row
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                buildApplyButton(context)
              ],
            ),
          ],
        )
    );
  }
}