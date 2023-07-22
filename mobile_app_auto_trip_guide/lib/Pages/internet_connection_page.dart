import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class InternetUtils {
  static Future<void> checkAndRequestInternetConnection(
      BuildContext context) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => InternetConnectionPage(),
        ),
      );
    }
  }
}

class InternetConnectionPage extends StatefulWidget {
  @override
  _InternetConnectionPageState createState() => _InternetConnectionPageState();
}

class _InternetConnectionPageState extends State<InternetConnectionPage> {
  late ConnectivityResult connectivityResult;

  @override
  void initState() {
    super.initState();
    verifyInternetConnectionAndContinue();
  }

  Future<void> verifyInternetConnectionAndContinue() async {
    connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      _showInternetDialog();
    } else {
      Navigator.of(context).pop();
    }
  }

  void _showInternetDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16.0)),
        ),
        title: Text(
          'Enable Internet',
          style: TextStyle(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        content: Text(
          'Please enable internet to use this app.',
          style: TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
        actionsPadding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        actions: <Widget>[
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.blue),
              minimumSize: MaterialStateProperty.all(
                  Size(double.infinity, 60)), // Change the height here
              shape: MaterialStateProperty.all(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                    10), // Change the border radius here
              )),
            ),
            child: Text(
              'Close',
              style: TextStyle(fontSize: 18),
            ),
          ),
          SizedBox(width: 8.0),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false; // the user wont be able to pop this page, only the application
      },
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 40),
                Text(
                  'Internet Required',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Our app requires internet connectivity to provide you with personalized recommendations and a better overall experience.',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 20),
                Image.asset('assets/images/logo.png'),
                SizedBox(height: 20),
                Text(
                  'We take your privacy seriously and will only use your data for the purposes stated in our privacy policy.',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {
                    verifyInternetConnectionAndContinue();
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue,
                    padding:
                        EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                  ),
                  child: Text(
                    'Continue',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
