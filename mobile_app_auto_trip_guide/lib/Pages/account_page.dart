import 'package:final_project/Pages/personal_details_page.dart';
import 'package:final_project/UsefulWidgets/toolbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:final_project/Pages/login_controller.dart';
import 'package:get/get.dart';
import 'package:final_project/Pages/favorite_categories_page.dart';

import '../Map/events.dart';
import '../Map/globals.dart';
import '../Map/types.dart';

class AccountPage extends StatelessWidget {
  AccountPage({Key? key}) : super(key: key);

  void _navigateToNextScreen(String screenName, BuildContext context) async{
    if (screenName == "Personal details") {
      if (Globals.globalUserInfoObj == null) {
        Map<String, String> userInfo = await Globals.globalServerCommunication.getUserInfo(Globals.globalEmail);
        Globals.globalUserInfoObj = UserInfo(userInfo["name"], Globals.globalEmail, userInfo["gender"] ?? " ", userInfo["languages"], userInfo["age"], Globals.globalFavoriteCategories);
      }
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => PersonalDetailsPage()));
    } else if (screenName == "Favorite categories") {
      // if globals categories = null bring it from the server
      Globals.globalCategories ??= await Globals.globalServerCommunication.getCategories(Globals.globalDefaultLanguage);
      Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => FavoriteCategoriesPage()));
    }
  }

  Container buildCard(String cardName, BuildContext context) {
    return Container(
        height: MediaQuery.of(context).size.height / 4,
        width: MediaQuery.of(context).size.width / 2,
        child: Card(
          color: Color.fromRGBO(30, 61, 123, 1.0),
          semanticContainer: true,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          child: Center(
            child: InkWell(
              onTap: () {
                _navigateToNextScreen(cardName, context);
              },
              child: Center(
                child: Text(cardName,
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20),
                    textAlign: TextAlign.center),
              ),
            ),
          ),
          elevation: 8,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          //shadowColor: Colors.white,
          margin: EdgeInsets.all(20),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromRGBO(0, 26, 51, 1.0),
        appBar: AppBar(
          title: const Text('Account'),
          leading: const BackButton(),
          centerTitle: true,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: () {
                logOut(context);
              },
            ),
          ],
        ),
        body: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).size.height / 20),
            Row(
              // menu row
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                buildCard("Personal details", context),
                buildCard("Favorite categories", context),
              ],
            ),
            Spacer(),
            const Toolbar(),
          ],
        ));
  }
}
