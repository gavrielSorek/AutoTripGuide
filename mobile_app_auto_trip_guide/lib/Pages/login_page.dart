import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Map/globals.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'dart:io';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);
  static const double PADDING_BETWEEN_BUTTONS = 15;
  static const double FONT_SIZE = 17;
  @override
  Widget build(BuildContext context) {
    return buildLoginWidget(context);
  }


  void _launchURL(String url) async {
    Uri uri = Uri.parse(url);
    try {
      await launchUrl(uri);
    } catch(e) {
      debugPrint(e.toString());
    }
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

                SizedBox(height: MediaQuery.of(context).size.height / 2.7),
                FloatingActionButton.extended(
                  onPressed: () async {
                    Globals.appEvents.signIn('google');
                    // TODO: google sign in failed ?
                    await Globals.globalController.login();
                    if (Globals.globalController.isUserGoogleSignIn) {
                      await Globals.loadUserDetails();
                      Globals.appEvents.email = Globals.globalUserInfoObj?.emailAddr ?? '';;                
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

              SizedBox(height: PADDING_BETWEEN_BUTTONS),
                Platform.isIOS ? FloatingActionButton.extended(
                onPressed: () async {
                  try {
                    Globals.appEvents.signIn('apple');
                    final credential =
                        await SignInWithApple.getAppleIDCredential(
                      scopes: [
                        AppleIDAuthorizationScopes.email,
                        AppleIDAuthorizationScopes.fullName,
                      ],
                    );
                    var savedEmail = (await SharedPreferences.getInstance()).getString('userEmail');
                    var nameFromEmail = (credential.email != null && credential.email!.contains('@')) ? credential.email!.split('@')[0] : null;
                    var savedName = (await SharedPreferences.getInstance()).getString('userName');
                    await Globals.loadUserDetails(loginMethod: LoginMethod.APPLE,userEmail: credential.email ?? savedEmail ,userName: credential.givenName?? nameFromEmail ??savedName!);
                    (await SharedPreferences.getInstance()).setString('userIdentifier',credential.userIdentifier!);
                    (await SharedPreferences.getInstance()).setString('userEmail',credential.email ?? savedEmail!);
                    (await SharedPreferences.getInstance()).setString('userName',credential.givenName?? nameFromEmail ??savedName!);
                    (await SharedPreferences.getInstance()).setString('lastLoginMethod','APPLE');    
                    Globals.appEvents.email = credential.email ?? savedEmail!;                  
                    Navigator.of(context).pushNamedAndRemoveUntil('/HomePage', (Route<dynamic> route) => false);
                  } catch (e) {
                    print(e);
                  }
                  // Use the credential to sign in to your backend service
                },
                icon: Image.asset(
                  "assets/images/apple_logo_black.png", // Change this to the path of your Apple logo asset
                  width: MediaQuery.of(context).size.width / 12,
                  height: MediaQuery.of(context).size.height / 12,
                ),
                label: const Text('Sign in with Apple'),
                backgroundColor: Colors.white70,
                foregroundColor: Colors.black,
                ) : Container(),
                SizedBox(height: PADDING_BETWEEN_BUTTONS),
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "By signing in you agree to the ",
                            style: TextStyle(color: Colors.white, fontSize: FONT_SIZE),
                          ),
                          TextSpan(
                            text: "terms of use",
                            style: TextStyle(
                              color: Colors.white,
                              decoration: TextDecoration.underline, fontSize: FONT_SIZE
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                _launchURL("https://www.getjournai.com/terms");
                              },
                          ),
                          TextSpan(
                            text: " and ",
                            style: TextStyle(color: Colors.white, fontSize: FONT_SIZE),
                          ),
                          TextSpan(
                            text: "privacy policy",
                            style: TextStyle(
                              color: Colors.white,
                              decoration: TextDecoration.underline,
                                fontSize: FONT_SIZE
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                _launchURL("https://www.getjournai.com/privacy");
                              },
                          ),
                        ],
                      ),
                    ),
                  ),
                )
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
