import 'package:final_project/Pages/personal_details_page.dart';
import 'package:final_project/UsefulWidgets/toolbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:final_project/Pages/favorite_categories_page.dart';

import '../Map/events.dart';
import '../Map/globals.dart';
import '../Map/map.dart';
import '../Map/types.dart';

class AccountPage extends StatelessWidget {
  AccountPage({Key? key}) : super(key: key);
  String personalDetailsStr = "PERSONAL DETAILS";
  String favoriteCategoriesStr = "FAVORITE CATEGORIES";


  void loadUserDetails() async{
    if (Globals.globalUserInfoObj == null) {
      Map<String, String> userInfo = await Globals.globalServerCommunication.getUserInfo(Globals.globalEmail);
      Globals.globalUserInfoObj = UserInfo(userInfo["name"], Globals.globalEmail, userInfo["gender"] ?? " ", userInfo["languages"] ?? " ", userInfo["age"], Globals.globalFavoriteCategories);
    }
    Globals.globalCategories ??= await Globals.globalServerCommunication.getCategories(Globals.globalDefaultLanguage);
  }

  void _navigateToNextScreen(String screenName, BuildContext context) async{
    if (screenName == personalDetailsStr) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => PersonalDetailsPage()));
    } else if (screenName == favoriteCategoriesStr) {
      Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => FavoriteCategoriesPage()));
    }
  }

  Container buildCard(String cardName, BuildContext context) {
    Icon iconCard;
    if (cardName == personalDetailsStr) {
      iconCard = Icon( // <-- Icon
        Icons.person_outline,
        size: 30.0,
        color: Color.fromRGBO(97, 157, 175, 1),
      );
    } else {
      iconCard = Icon( // <-- Icon
        Icons.favorite_border_outlined,
        size: 30.0,
        color: Color.fromRGBO(97, 157, 175, 1),
      );
    }
    return Container(
        height: MediaQuery.of(context).size.height / 7,
        width: MediaQuery.of(context).size.width / 0.8,
        color: Color.fromRGBO(225, 245, 246, 0.8),
        child:
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
                primary: Color.fromRGBO(225, 245, 246, 0.8)
            ),
          onPressed: () {
            _navigateToNextScreen(cardName, context);
          },
          icon: iconCard,
          label: Text(cardName,
                style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 20),
                textAlign: TextAlign.center), // <-- Text
          ),);
  }

  Widget buildName() => Column(
    children: [
      Text(
        Globals.globalController.googleAccount.value?.displayName ?? " ",
        style: const TextStyle(
          fontWeight: FontWeight.bold, fontSize: 26, color: Colors.black87,),
      ),
      const SizedBox(height: 4),
      Text(
        Globals.globalController.googleAccount.value?.email ?? " ",
        style: const TextStyle(color: Colors.black54),
      )
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Account'),
          centerTitle: true,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: () {
                UserMap.preUnmountMap();
                logOut(context);
              },
            ),
          ],
        ),
        body: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).size.height / 50),
            ProfileWidget(
              imagePath:
              Globals.globalController.googleAccount.value?.photoUrl ?? "",
              onClicked: () async {},
            ),
            buildName(),
            const Spacer(),
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 1.9,
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: Colors.white,
              borderRadius: BorderRadius.only(
              topLeft: Radius.circular(100.0),
              topRight: Radius.circular(100.0),
              bottomLeft: Radius.zero,
              bottomRight: Radius.zero,
              ),
              ),
              child: Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height / 20),
                  buildCard(personalDetailsStr, context),
                  SizedBox(height: MediaQuery.of(context).size.height / 20),
                  buildCard(favoriteCategoriesStr, context),]),
            ),
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
