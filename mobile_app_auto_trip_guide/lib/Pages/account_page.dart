import 'package:final_project/Pages/personal_details_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:final_project/Pages/login_controller.dart';
import 'package:get/get.dart';
import 'package:final_project/Pages/favorite_categories_page.dart';


class AccountPage extends StatelessWidget {
  AccountPage({Key? key}) : super(key: key);
  final controller = Get.put(LoginController());

  void _navigateToNextScreen(String screenName, BuildContext context) {
    if(screenName == "Personal details") {
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => PersonalDetailsPage()));
    } else if(screenName == "Favorite categories") {
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => FavoriteCategoriesPage()));
    }
  }

  Container buildCard(String cardName, BuildContext context) {
    return Container(
        height: MediaQuery.of(context).size.height / 4,
        width: MediaQuery.of(context).size.width / 2,
        child: Card(
          semanticContainer: true,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          child: Center(
            child: InkWell(
              onTap: () {
                _navigateToNextScreen(cardName, context);
              },
              child: Center(
                child: Text(cardName, style: TextStyle(
                    color: Colors.grey[800],
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
                    textAlign: TextAlign.center),
              ),
            ),
          ),
          elevation: 8,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0)),
          shadowColor: Colors.cyan,
          margin: EdgeInsets.all(20),
        ));
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Account'),
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
                buildCard("Personal details", context),
                buildCard("Favorite categories", context),
              ],
            )
          ],
        )
    );
  }
}
