// import 'package:easy_sidemenu/easy_sidemenu.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
//
// class Menu extends StatelessWidget {
//   Menu({Key? key}) : super(key: key);
//   PageController page = PageController();
//
//   List<SideMenuItem> items = [
//     SideMenuItem(
//       // Priority of item to show on SideMenu, lower value is displayed at the top
//       priority: 0,
//       title: 'Dashboard',
//       // onTap: () => page.jumpToPage(0),
//       icon: Icon(Icons.home),
//       badgeContent: Text(
//         '3',
//         style: TextStyle(color: Colors.white),
//       ),
//     ),
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       //padding: AppTheme.padding,
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: <Widget>[
//           RotatedBox(
//             quarterTurns: 4,
//             child: Icon(Icons.menu, color: Colors.black54),
//           ),
//           ClipRRect(
//             borderRadius: BorderRadius.all(Radius.circular(13)),
//             child: Container(
//               decoration: BoxDecoration(
//                 color: Theme.of(context).backgroundColor,
//                 boxShadow: <BoxShadow>[
//                   BoxShadow(
//                       color: Color(0xfff8f8f8),
//                       blurRadius: 10,
//                       spreadRadius: 10),
//                 ],
//               ),
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }