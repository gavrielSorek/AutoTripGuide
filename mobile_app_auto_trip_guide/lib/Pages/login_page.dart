import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Map/globals.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return buildLoginWidget(context);
  }

  Widget buildLoginWidget(BuildContext context) {
    return WillPopScope(
      onWillPop: () async { return false; },
      child: Scaffold(
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
                    Stack(
                      children: <Widget>[
                        Container(
                          width: MediaQuery.of(context).size.width / 1.1,
                          height: MediaQuery.of(context).size.height / 4,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                                begin: FractionalOffset.topCenter,
                                end: FractionalOffset.bottomCenter,
                                colors: [
                                  Colors.white.withOpacity(0.1),
                                  Colors.white.withOpacity(0.1),
                                ],
                                stops: [
                                  0.5,
                                  1.0
                                ]
                            ),
                          ),
                        ),
                        Image.asset(
                          'assets/images/logo.png',
                          width: MediaQuery.of(context).size.width / 1.1,
                          height: MediaQuery.of(context).size.height / 4,
                          //fit: BoxFit.cover,
                        ),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: MediaQuery.of(context).size.height / 2),
                FloatingActionButton.extended(
                  onPressed: () async {
                    Globals.appEvents.signIn('google');
                    // TODO: google sign in failed ?
                    await Globals.globalController.login();
                    if (Globals.globalController.isUserSignIn) {
                      await Globals.loadUserDetails();
                      Navigator.of(context).pushNamedAndRemoveUntil('/HomePage', (Route<dynamic> route) => false);
                    }
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
      ),
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
          style: Get.textTheme.headlineMedium,
        ),
        Text(Globals.globalController.googleAccount.value?.email ?? '',
            style: Get.textTheme.headlineSmall),
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
