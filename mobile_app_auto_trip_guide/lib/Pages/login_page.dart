import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:final_project/Pages/home_page.dart';
import '../Map/globals.dart';
import '../Map/types.dart';


class LoginPage extends StatelessWidget {
  //LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Obx(() {
            if (Globals.globalController.googleAccount.value == null) {
              return buildNewLogin();
            } else {
              addUser();
              return HomePage();
            }
          })
      ),
    );
  }


  void addUser() async {
     Globals.globalServerCommunication.addNewUser(
        UserInfo(Globals.globalController.googleAccount.value?.displayName ?? '', Globals.globalController.googleAccount.value?.email ?? '', "", [""], 0, Globals.globalFavoriteCategories));
     Globals.globalFavoriteCategories = await Globals.globalServerCommunication.getFavorCategories(Globals.globalController.googleAccount.value?.email ?? '');
  }

  FloatingActionButton buildLoginButton() {
    return FloatingActionButton.extended(
      onPressed: (){
        Globals.globalController.login();
      },
      icon: Icon(
        Icons.audiotrack,
        size: 32.0,
        color: Colors.green,
      ),
      label: Text('Sign in with Google'),
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
    );
  }

  Container buildNewLogin() {
    return Container(
        width: 1000,
        height: 1000,
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height:100 ,),
            Image.asset(
              'assets/images/auto_trip_guide_logo.png',
              width: 300,
              height: 200,
              fit: BoxFit.cover,
            ),
            SizedBox(height:80 ,),
            FloatingActionButton.extended(
              onPressed: (){
                Globals.globalController.login();
              },
              icon:
              Image.asset(
                "assets/images/google.png",
                width: 32,
                height: 32,
              ),
              label: Text('Sign in with Google'),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
            ),
          ],
        )
    );
  }


  Column buildProfileView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          backgroundImage: Image.network(Globals.globalController.googleAccount.value?.photoUrl ?? '').image,
          radius: 100,
        ),
        Text(Globals.globalController.googleAccount.value?.displayName ?? '',
          style: Get.textTheme.headline4,),
        Text(Globals.globalController.googleAccount.value?.email ?? '',
            style: Get.textTheme.headline5),
        SizedBox(height:16 ,),
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