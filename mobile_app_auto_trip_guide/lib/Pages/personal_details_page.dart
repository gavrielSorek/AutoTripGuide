import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Map/types.dart';
import 'login_controller.dart';


class PersonalDetailsPage extends StatelessWidget {
  PersonalDetailsPage({Key? key}) : super(key: key);
  final controller = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    UserInfo userInfo = UserInfo(controller.googleAccount.value?.displayName ?? '', controller.googleAccount.value?.email ?? '', "", [""], 0, [""]);
    //chnage userInfo with get info req from db

    return Scaffold(
        appBar: buildAppBar(context),
        body: ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            ProfileWidget(
              imagePath: controller.googleAccount.value?.photoUrl ?? '',
              onClicked: () async {},
            ),
            const SizedBox(height: 24),
            buildName(userInfo),
            const SizedBox(height: 24),
            buildDetail(userInfo),
          ],
        )
    );
  }

  Widget buildName(UserInfo userInfo) => Column(
    children: [
      Text(
        userInfo.name?? '',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
      ),
      const SizedBox(height: 4),
      Text(
        userInfo.emailAddr?? '',
        style: const TextStyle(color: Colors.grey),
      )
    ],
  );

  Widget buildDetail(UserInfo userInfo) => Column(
    children: <Widget>[
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 25, 20, 4),
        child: Container(
          height: 60,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(userInfo.name?? '', style: const TextStyle(color: Colors.black),),
            ),
          ), decoration: BoxDecoration(borderRadius: const BorderRadius.all(Radius.circular(20)),border: Border.all(width: 1.0, color: Colors.black)),
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 25, 20, 4),
        child: Container(
          height: 60,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Languages           ', style: TextStyle(color: Colors.black),),
            ),
          ), decoration: BoxDecoration(borderRadius: const BorderRadius.all(Radius.circular(20)),border: Border.all(width: 1.0, color: Colors.black)),
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 25, 20, 4),
        child: Container(
          height: 60,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Age                         ', style: TextStyle(color: Colors.black),),
            ),
          ), decoration: BoxDecoration(borderRadius: const BorderRadius.all(Radius.circular(20)),border: Border.all(width: 1.0, color: Colors.black)),
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 25, 20, 4),
        child: Container(
          height: 60,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(userInfo.emailAddr?? '', style: TextStyle(color: Colors.black),),
            ),
          ), decoration: BoxDecoration(borderRadius: const BorderRadius.all(Radius.circular(20)),border: Border.all(width: 1.0, color: Colors.black)),
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 25, 20, 4),
        child: Container(
          height: 60,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(userInfo.gender?? '', style: TextStyle(color: Colors.black),),
            ),
          ), decoration: BoxDecoration(borderRadius: const BorderRadius.all(Radius.circular(20)),border: Border.all(width: 1.0, color: Colors.black)),
        ),
      )
    ],
  );

}


AppBar buildAppBar(BuildContext context) {
  const icon = CupertinoIcons.moon_stars;

  return AppBar(
    leading: const BackButton(),
    backgroundColor: Colors.black, //change to backgroundColor: Colors.transparent,
    elevation: 0,
    actions: [
      IconButton(
        icon: const Icon(icon),
        onPressed: () {},
      ),
    ],
  );
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
          Positioned(
            bottom: 0,
            right: 4,
            child: buildEditIcon(color),
          ),
        ],
      ),
    );
  }

  Widget buildImage() {
    if (imagePath == "") {
      return ClipOval(
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


