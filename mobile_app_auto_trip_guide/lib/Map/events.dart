
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';

import '../Pages/account_page.dart';

void mapButtonClickedEvent(BuildContext context) {
}
void accountButtonClickedEvent(BuildContext context) {
  Navigator.of(context).push(MaterialPageRoute(builder: (context) => AccountPage()));
}
void reviewsButtonClickedEvent(BuildContext context) {

}
void settingButtonClickedEvent(BuildContext context) {

}
//
// class Compass {
//
//   Widget _buildCompass() {
//     return StreamBuilder<CompassEvent>(
//       stream: FlutterCompass.events,
//       builder: (context, snapshot) {
//         if (snapshot.hasError) {
//           return Text('Error reading heading: ${snapshot.error}');
//         }
//
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return Center(
//             child: CircularProgressIndicator(),
//           );
//         }
//
//         double? direction = snapshot.data!.heading;
//
//         // if direction is null, then device does not support this sensor
//         // show error message
//         if (direction == null)
//           return Center(
//             child: Text("Device does not have sensors !"),
//           );
//
//         return Material(
//           shape: CircleBorder(),
//           clipBehavior: Clip.antiAlias,
//           elevation: 4.0,
//           child: Container(
//             padding: EdgeInsets.all(16.0),
//             alignment: Alignment.center,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//             ),
//             child: Transform.rotate(
//               angle: (direction * (math.pi / 180) * -1),
//               child: Image.asset('assets/compass.jpg'),
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//
// }