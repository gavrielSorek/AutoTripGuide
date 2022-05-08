import 'package:final_project/UsefulWidgets/toolbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../Map/globals.dart';

class ReviewsPage extends StatelessWidget {
  ReviewsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromRGBO(0, 26, 51, 1.0),
        appBar: AppBar(
          title: const Text('Reviews'),
          leading: const BackButton(),
          centerTitle: true,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: Globals.globalController.logout,
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
