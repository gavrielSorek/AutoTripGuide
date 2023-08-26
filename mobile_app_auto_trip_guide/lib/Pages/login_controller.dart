import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Map/globals.dart';

class LoginController extends GetxController {
  final GoogleSignIn _googleSignin = GoogleSignIn();
  var googleAccount = Rx<GoogleSignInAccount?>(null);
  var _isSignedIn = false.obs;  // Using an observable for the signed-in state

  Future<void> login() async {
    // First, try silent sign-in
    googleAccount.value = await _googleSignin.signInSilently();

    // If silent sign-in returns null, show the dialog
    if (googleAccount.value == null) {
      try {
        googleAccount.value = await _googleSignin.signIn();
        (await SharedPreferences.getInstance()).setString('lastLoginMethod','GOOGLE');
      } catch (e) {
        // You can handle or log the exception here if required
        await Future.delayed(Duration(seconds: 5));
        return login();  // Retry the login method
      }
    }
    _updateSignInStatus();
  }

  Future<void> logout() async {
    googleAccount.value = await _googleSignin.signOut();
    _updateSignInStatus();
  }

  Future<void> init() async {
    _updateSignInStatus();
  }

  void _updateSignInStatus() async {
    _isSignedIn.value = await _googleSignin.isSignedIn();
  }

  bool get isUserGoogleSignIn => _isSignedIn.value;
}