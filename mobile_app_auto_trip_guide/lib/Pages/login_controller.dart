import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginController extends GetxController {
  var _googleSignin = GoogleSignIn();
  var googleAccount = Rx<GoogleSignInAccount?>(null);
  bool _isSignedIn = false;

  login() async {
    bool success = false;

    while (!success) {
      try {
        googleAccount.value = await _googleSignin.signIn();
        _isSignedIn = await _googleSignin.isSignedIn();
        success = true;
      } catch (e) {
        // Wait for 5 seconds before retrying
        await Future.delayed(Duration(seconds: 5));
      }
    }
    _isSignedIn = await _googleSignin.isSignedIn();
  }

  logout() async {
    googleAccount.value = await _googleSignin.signOut();
    _isSignedIn = await _googleSignin.isSignedIn();
  }

  init() async {
    _isSignedIn = await _googleSignin.isSignedIn();
  }

  get isUserSignIn => _isSignedIn;
}
