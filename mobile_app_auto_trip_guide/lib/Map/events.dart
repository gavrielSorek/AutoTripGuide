import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../Pages/account_page.dart';
import 'map.dart';

void mapButtonClickedEvent(BuildContext context) {
  Navigator.popUntil(context, (route) {
    if (route.settings.name == '/') {
      return true;
    }
    return false;
  });
  while (!ModalRoute.of(context)!.isCurrent) {
    Navigator.pop(context);
  }
}

void mapButtonLongClickedEvent(BuildContext context) {
  mapButtonClickedEvent(context); //get to home page
  print("triggering guide");
  UserMap.USER_MAP!.userMapState?.triggerGuide();
}

void accountButtonClickedEvent(BuildContext context) {
  Navigator.of(context)
      .push(MaterialPageRoute(builder: (context) => AccountPage()));
}

void reviewsButtonClickedEvent(BuildContext context) {}

void settingButtonClickedEvent(BuildContext context) {}
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
