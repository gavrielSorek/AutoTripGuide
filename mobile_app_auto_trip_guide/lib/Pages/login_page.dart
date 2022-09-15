import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Map/globals.dart';
import '../Map/types.dart';
import '../UsefulWidgets/toolbar.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Obx(() {
        if (Globals.globalController.googleAccount.value == null) {
          return buildLoginWidget(context);
        } else {
          addUser();
          return ToolbarWidget();
        }
      })),
    );
  }

  void loadUserDetails() async {
    if (Globals.globalUserInfoObj == null) {
      Map<String, String> userInfo = await Globals.globalServerCommunication
          .getUserInfo(Globals.globalEmail);
      Globals.globalUserInfoObj = UserInfo(
          userInfo["name"],
          Globals.globalEmail,
          userInfo["gender"] ?? " ",
          userInfo["languages"] ?? " ",
          userInfo["age"],
          Globals.globalFavoriteCategories);
    }
    Globals.globalCategories ??= await Globals.globalServerCommunication
        .getCategories(Globals.globalDefaultLanguage);
    Globals.setFavoriteCategories(await Globals.globalServerCommunication
        .getFavorCategories(
            Globals.globalController.googleAccount.value?.email ?? ' '));
    Globals.setGlobalVisitedPoisList(await Globals.globalServerCommunication
        .getPoisHistory(Globals.globalEmail));
  }

  void addUser() async {
    Globals.globalEmail =
        Globals.globalController.googleAccount.value?.email ?? ' ';
    Globals.globalServerCommunication.addNewUser(UserInfo(
        Globals.globalController.googleAccount.value?.displayName ?? ' ',
        Globals.globalEmail,
        ' ',
        ' ',
        ' ',
        Globals.globalFavoriteCategories));
    loadUserDetails();
  }

  Widget buildLoginWidget(BuildContext context) {
    return Scaffold(
      body: Container(
          width: MediaQuery.of(context).size.width / 1,
          height: MediaQuery.of(context).size.height / 1,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/login_bg.jpeg"),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height / 10),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 10,
                  ),
                  Image.asset(
                    'assets/images/logo.png',
                    width: MediaQuery.of(context).size.width / 1.1,
                    height: MediaQuery.of(context).size.height / 4,
                    //fit: BoxFit.cover,
                  )
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height / 2),
              FloatingActionButton.extended(
                onPressed: () {
                  Globals.globalController.login();
                },
                icon: Image.asset(
                  "assets/images/google.png",
                  width: MediaQuery.of(context).size.width / 12,
                  height: MediaQuery.of(context).size.height / 12,
                ),
                label: const Text('Sign in with Google'),
                backgroundColor: Colors.white70,
                foregroundColor: Colors.black,
              ),
            ],
          )),
    );
  }

  Column buildProfileView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          backgroundImage: Image.network(
                  Globals.globalController.googleAccount.value?.photoUrl ?? '')
              .image,
          radius: 100,
        ),
        Text(
          Globals.globalController.googleAccount.value?.displayName ?? '',
          style: Get.textTheme.headline4,
        ),
        Text(Globals.globalController.googleAccount.value?.email ?? '',
            style: Get.textTheme.headline5),
        SizedBox(
          height: 16,
        ),
        ActionChip(
          avatar: Icon(Icons.logout),
          label: Text('Logout'),
          onPressed: () {
            Globals.globalController.logout();
          },
        ),
      ],
    );
  }
}
