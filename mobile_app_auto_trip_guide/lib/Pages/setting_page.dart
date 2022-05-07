import 'package:final_project/Pages/personal_details_page.dart';
import 'package:final_project/UsefulWidgets/toolbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:final_project/Pages/login_controller.dart';
import 'package:get/get.dart';
import 'package:final_project/Pages/favorite_categories_page.dart';

class SettingsPage extends StatelessWidget {
  SettingsPage({Key? key}) : super(key: key);
  final controller = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromRGBO(0, 26, 51, 1.0),
        appBar: AppBar(
          title: const Text('Settings'),
          leading: const BackButton(),
          centerTitle: true,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: controller.logout,
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
              ],
            ),
            Spacer(),
            const Toolbar(),
          ],
        ));
  }
}
