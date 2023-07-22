import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Utils/app_info.dart';

class UpgradePage extends StatefulWidget {
  final UpdateStatus upgradeStatus;

  UpgradePage(this.upgradeStatus);

  @override
  _UpgradePageState createState() => _UpgradePageState();
}

class _UpgradePageState extends State<UpgradePage> {
  String descText = '';

  @override
  void initState() {
    if (widget.upgradeStatus == UpdateStatus.available) {
      descText = "We’ve made some significant enhancements to the app.\n\n" +
          "To benefit from them, we recommend that you upgrade to the latest version.";
    } else {
      descText = "We’ve made some significant enhancements to the app.\n\n"
          + "To benefit from them, please upgrade to the latest version.";
    }
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // disable back button
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // First column with BoxDecoration and image
            Padding(
              padding: const EdgeInsets.only(top: 100.0),
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/update.jpg'),
                    // Ensure this path matches to your asset
                    fit: BoxFit.none,
                  ),
                ),
                child: SizedBox(
                  height: 200, // Adjust the height as needed
                ),
              ),
            ),
            // Second column with Text widget
            Padding(
              padding: EdgeInsets.only(top: 20.0),
              child: Center(
                child: Text(
                  'Upgrade Available!',
                  style: TextStyle(
                    fontSize: 35,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0, bottom: 10),
              child: Container(
                child: Text(
                  descText,
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            // Adding buttons
            Padding(
                padding: EdgeInsets.only(top: 60.0, left: 30.0, right: 30.0, bottom: 10),
                child: ElevatedButton(
                    onPressed: () async {
                      final Uri androidUrl = Uri.parse('https://play.google.com/store/apps/details?id=<your_package_name>'); //TODO change to our app url
                      final Uri iosUrl = Uri.parse('https://apps.apple.com/us/app/apple-store/<your_app_id>');

                      if (Theme.of(context).platform == TargetPlatform.android) {
                        // Android-specific code
                        if (await canLaunchUrl(androidUrl)) {
                          await launchUrl(androidUrl);
                        } else {
                          debugPrint('Could not launch $androidUrl');
                        }
                      } else if (Theme.of(context).platform == TargetPlatform.iOS) {
                        // iOS-specific code
                        if (await canLaunchUrl(iosUrl)) {
                          await launchUrl(iosUrl);
                        } else {
                          debugPrint('Could not launch $androidUrl');
                        }
                      }
                    },
                  child: Text('Upgrade'),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.blue),
                    minimumSize: MaterialStateProperty.all(
                        Size(double.infinity, 60)), // Change the height here
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          10), // Change the border radius here
                    )),
                  ),
                ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 0.0),
              child: widget.upgradeStatus != UpdateStatus.requiredImmediately ? ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  },
                child: Text(
                  'Later',
                  style: TextStyle(
                    color: Color(0xFF6C6F70), // Change the text color here
                  ),
                ),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.transparent),
                  shadowColor: MaterialStateProperty.all(Colors.transparent),
                  minimumSize: MaterialStateProperty.all(Size(double.infinity, 60)), // Change the height here
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // Change the border radius here
                  )),
                ),
              ) : null,
            ),
          ],
        ),
      ),
    );
  }
}