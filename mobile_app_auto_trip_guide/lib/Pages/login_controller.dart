import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginController extends GetxController {
  var _googleSignin = GoogleSignIn();
  var googleAccount = Rx<GoogleSignInAccount?>(null);
  bool _isSignedIn = false;

  login() async {
    googleAccount.value = await _googleSignin.signIn();
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
