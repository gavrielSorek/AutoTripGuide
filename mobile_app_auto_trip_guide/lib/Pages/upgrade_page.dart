import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Utils/app_info.dart';

class UpgradePage extends StatefulWidget {
  final UpdateStatus upgradeStatus;

  UpgradePage(this.upgradeStatus);

  @override
  _UpgradePageState createState() => _UpgradePageState();
}

class _UpgradePageState extends State<UpgradePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Disable the back button
      child: Scaffold(
        appBar: AppBar(
          title: Text('Upgrade Page'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Upgrade in progress...'),
              // Add additional widgets for the upgrading screen as needed
            ],
          ),
        ),
      ),
    );
  }
}