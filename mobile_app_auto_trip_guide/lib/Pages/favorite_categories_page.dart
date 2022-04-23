import 'dart:collection';
import 'package:final_project/Pages/personal_details_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:final_project/Pages/login_controller.dart';
import 'package:get/get.dart';
import '../Map/globals.dart';


class FavoriteCategoriesPage extends StatefulWidget {
  const FavoriteCategoriesPage({Key? key}) : super(key: key);
  @override
  FavoriteCategories createState() => FavoriteCategories();
}

class FavoriteCategories extends State<FavoriteCategoriesPage> {
  final controller = Get.put(LoginController());
  // Map<String, List<String>> categoriesMap = {'ALL':['A','B','C','E','F','G','H'], 'MY FAVORITE': ['A','B'], 'HISTORY':['F','G'], 'SPORT':['C','E']};
  Map<String, List<String>> categoriesMap = Globals.globalCategories;
  //List<String> categories = <String>['ALL', 'MY FAVORITE', 'HISTORY', 'SPORT'];
  List<String> categories = Globals.globalCategories.keys.toList();
  List<String> favorCategories = ['A','B'];
  int selectedIndex = 0;
  bool favorChanged = false;

  Container buildCategoryCard(BuildContext context) {
    return Container(
        height: MediaQuery.of(context).size.height / 1.5,
        width: MediaQuery.of(context).size.width / 1.1,
        child: Card(
          color: const Color.fromRGBO(64, 75, 96, .9),
          semanticContainer: true,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          child: ListView.separated(
            shrinkWrap: true,
            padding: const EdgeInsets.all(8),
            itemCount: categories.length,
            itemBuilder: (BuildContext context, int index) {
              return ExpansionTile(
                title: Text(categories[index], style: const TextStyle(
                    fontSize: 20),),
                backgroundColor: Color.fromRGBO(55, 55, 20, .20),
                iconColor : Colors.red,
                textColor:Colors.red,
                  children: <Widget>[
                  buildSubCategoryCard(categories[index], context),
                ],
              );
            },
            separatorBuilder: (BuildContext context, int index) => const Divider(color: Colors.white),
          ),
          elevation: 8,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0)),
          margin: EdgeInsets.all(20),
        ));
  }

  Container buildSubCategoryCard(String selectedCategory, BuildContext context) {
    return Container(
        height: MediaQuery.of(context).size.height / 2,
        width: MediaQuery.of(context).size.width / 1.05,
        child: Card(
          color: const Color.fromRGBO(64, 75, 96, .9),
          semanticContainer: true,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          child: ListView.separated(
            padding: const EdgeInsets.all(8),
            itemCount: categoriesMap[selectedCategory]!.length,
            itemBuilder: (BuildContext context, int index) {
              String category = categoriesMap[selectedCategory]![index];
              bool isFavor = favorCategories.contains(category);
              return ListTile(
                title: Text(category, style: TextStyle(
                    color: Colors.white,
                    fontSize: 20),
                    ),
                trailing: Icon(
                  isFavor ? Icons.favorite : Icons.favorite_border,
                  color: isFavor ? Colors.red : Colors.white,
                ),
                onTap: () {
                  setState(() {
                    if (isFavor) {
                      categoriesMap["MY FAVORITE"]?.remove(category);
                      favorCategories.remove(category);
                    } else {
                      categoriesMap["MY FAVORITE"]?.add(category);
                      favorCategories.add(category);
                    }
                    favorChanged = true;
                  });
                },
              );
            },
            separatorBuilder: (BuildContext context, int index) => const Divider(color: Colors.white),
          ),
          elevation: 8,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0)),
          margin: EdgeInsets.all(20),
        ));
  }

  Container buildApplyButton(BuildContext context) {
    return Container(
        height: 100,
        width: 120,
        child: Card(
          color: Color.fromRGBO(64, 75, 96, .9),
          semanticContainer: true,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          child: Center(
            child: InkWell(
              onTap: () {
                if(favorChanged) {
                  final snackBar = SnackBar(
                    content: const Text('Your Favorite Categories Saved!'),
                    action: SnackBarAction(
                      label: 'Undo',
                      onPressed: () {
                        // undo the change
                      },
                    ),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                }
              },
              child: const Center(
                child: Text("Apply", style: TextStyle(
                    color: Colors.yellow,
                    fontSize: 20),
                    textAlign: TextAlign.center),
              ),
            ),
          ),
          elevation: 8,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0)),
          margin: EdgeInsets.all(20),
        ));
  }

  //    Future<Map<String, List<String>>> map = getCategoriesFromDB();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
        appBar: AppBar(
          title: const Text('Favorite Categoriess'),
          leading: const BackButton(),
          centerTitle: true,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: controller.logout,
            ),
          ],),
        body: Column(
          children: [
            SizedBox(height:16),
            SizedBox(height:16),
            Row( // menu row
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                buildCategoryCard(context),
              ],
            ),
            Row( // menu row
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                buildApplyButton(context)
              ],
            )
          ],
        )
    );
  }
}