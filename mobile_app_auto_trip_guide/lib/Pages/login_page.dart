import 'package:flutter/material.dart';
import 'package:final_project/Pages/login_controller.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:final_project/Pages/home_page.dart';
import 'package:final_project/Map/server_communication.dart';
import '../Map/location_types.dart';


class LoginPage extends StatelessWidget {
  final controller = Get.put(LoginController());
  ServerCommunication MAP_SERVER_COMMUNICATOR = ServerCommunication();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Obx(() {
            if (controller.googleAccount.value == null) {
              return buildNewLogin();
            } else {
              addUser();
              return HomePage();  //return buildProfileView();
            }
          })
      ),
    );
  }


  void addUser() async {
    int val = await MAP_SERVER_COMMUNICATOR.addNewUser(
        UserInfo("sapir david", "sap@gmail.com"));
    //change user info: UserInfo(controller.googleAccount.value?.displayName ?? '', controller.googleAccount.value?.email ?? ''))
    print("the val is: ");
    print(val);
  }



  FloatingActionButton buildLoginButton() {
    return FloatingActionButton.extended(
      onPressed: (){
        controller.login();
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
                controller.login();
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
          backgroundImage: Image.network(controller.googleAccount.value?.photoUrl ?? '').image,
          radius: 100,
        ),
        Text(controller.googleAccount.value?.displayName ?? '',
          style: Get.textTheme.headline4,),
        Text(controller.googleAccount.value?.email ?? '',
            style: Get.textTheme.headline5),
        SizedBox(height:16 ,),
        ActionChip(
          avatar: Icon(Icons.logout),
          label: Text('Logout'),
          onPressed: () {
            controller.logout();
          },
        ),
      ],
    );
  }
}