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

  void loadUserDetails() async{
    if (Globals.globalUserInfoObj == null) {
      Map<String, String> userInfo = await Globals.globalServerCommunication.getUserInfo(Globals.globalEmail);
      Globals.globalUserInfoObj = UserInfo(userInfo["name"], Globals.globalEmail, userInfo["gender"] ?? " ", userInfo["languages"] ?? " ", userInfo["age"], Globals.globalFavoriteCategories);
    }
    Globals.globalCategories ??= await Globals.globalServerCommunication.getCategories(Globals.globalDefaultLanguage);
  }

  void _navigateToNextScreen(String screenName, BuildContext context) async{
    if (screenName == "Personal Detail") {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => PersonalDetailsPage()));
    } else if (screenName == "Favorite Categories") {
      Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => FavoriteCategoriesPage()));
    }
  }

  Container buildCard(String cardName, BuildContext context) {
    return Container(
        height: MediaQuery.of(context).size.height / 8,
        width: MediaQuery.of(context).size.width / 0.5,
        child: Card(
          color: const Color.fromRGBO(30, 61, 123, 1.0),
          semanticContainer: true,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          child: Center(
            child: InkWell(
              onTap: () {
                _navigateToNextScreen(cardName, context);
              },
              child: Center(
                child: Text(cardName,
                    style: const TextStyle(
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
          margin: const EdgeInsets.all(20),
        ));
  }

  Widget buildName() => Column(
    children: [
      Text(
        Globals.globalUserInfoObj?.name ?? '',
        style: const TextStyle(
            fontWeight: FontWeight.bold, fontSize: 24, color: Colors.white),
      ),
      const SizedBox(height: 4),
      Text(
        Globals.globalUserInfoObj?.emailAddr ?? '',
        style: const TextStyle(color: Colors.grey),
      )
    ],
  );

  @override
  Widget build(BuildContext context) {
    //loadUserDetails();
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
            SizedBox(height: MediaQuery.of(context).size.height / 30),
            ProfileWidget(
              imagePath:
              Globals.globalController.googleAccount.value?.photoUrl ?? "",
              onClicked: () async {},
            ),
            SizedBox(height: MediaQuery.of(context).size.height / 30),
            buildName(),
            SizedBox(height: MediaQuery.of(context).size.height / 30),
            buildCard("Personal Detail", context),
            SizedBox(height: MediaQuery.of(context).size.height / 50),
            buildCard("Favorite Categories", context),
            Spacer(),
            const Toolbar(),
          ],
        ));
  }
}

class ProfileWidget extends StatelessWidget {
  final String imagePath;
  final VoidCallback onClicked;

  const ProfileWidget({
    Key? key,
    required this.imagePath,
    required this.onClicked,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;

    return Center(
      child: Stack(
        children: [
          buildImage(),
        ],
      ),
    );
  }

  Widget buildImage() {
    if (imagePath == "") {
      return const ClipOval(
        child: Material(
          color: Colors.transparent,
        ),
      );
    }
    final image = NetworkImage(imagePath);
    return ClipOval(
      child: Material(
        color: Colors.transparent,
        child: Ink.image(
          image: image,
          fit: BoxFit.cover,
          width: 128,
          height: 128,
          child: InkWell(onTap: onClicked),
        ),
      ),
    );
  }

  Widget buildEditIcon(Color color) => buildCircle(
    color: Colors.white,
    all: 3,
    child: buildCircle(
      color: color,
      all: 8,
      child: const Icon(
        Icons.edit,
        color: Colors.white,
        size: 20,
      ),
    ),
  );

  Widget buildCircle({
    required Widget child,
    required double all,
    required Color color,
  }) =>
      ClipOval(
        child: Container(
          padding: EdgeInsets.all(all),
          color: color,
          child: child,
        ),
      );
}
