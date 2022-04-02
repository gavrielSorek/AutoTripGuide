import 'dart:convert';
import 'dart:io';

import 'package:final_project/Map/location_types.dart';
import 'package:http/http.dart' as http;
class ServerCommunication {
  // String serverUrl = "https://autotripguidemobile.loca.lt";
  String serverUrl = "autotripguidemobile.loca.lt";

  ServerCommunication();

  static Uri addLocationInfoToUrl(String url, String path,LocationInfo locationInfo) {
    final queryParameters = {
      'lat': locationInfo.lat.toString(),
      'lng': locationInfo.lng.toString(),
      'heading': locationInfo.heading.toString(),
      'speed': locationInfo.speed.toString()
    };
    final uri = Uri.https(url, path, queryParameters);
    return uri;
  }

  Future<List<Poi>> getPoisByLocation(LocationInfo? locationInfo) async{
    Uri newUri = addLocationInfoToUrl(serverUrl , '/searchNearbyPois', locationInfo!);

    var client = http.Client();
    try {
      var response = await client.get(newUri, headers: {"Access-Control-Allow-Origin": "*"});
      if (response.statusCode == 200 && response.contentLength! > 0) {
        final parsed = jsonDecode(response.body).cast<Map<String, dynamic>>();
        return parsed.map<Poi>((json) => Poi.fromJson(json)).toList();
      } else {
        if (response.contentLength == 0) {return [];}
        // If the server did not return a 200 OK response,
        // then throw an exception.
        throw Exception('Failed to load Pois');
      }
    } finally {
      client.close();
    }
  }
}



// import 'dart:convert';
// import 'dart:io';
//
// import 'package:final_project/Map/location_types.dart';
// import 'package:http/http.dart' as http;
// import 'package:http/http.dart';
// class ServerCommunication {
//   // String serverUrl = "https://autotripguidemobile.loca.lt";
//   String serverUrl = "autotripguidemobile.loca.lt";
//
//   ServerCommunication();
//
//   static Uri addLocationInfoToUrl(String url, String path,LocationInfo locationInfo) {
//     final queryParameters = {
//       'lat': locationInfo.lat.toString(),
//       'lng': locationInfo.lng.toString(),
//       'heading': locationInfo.heading.toString(),
//       'speed': locationInfo.speed.toString()
//     };
//     final uri = Uri.https(url, path, queryParameters);
//     return uri;
//   }
//
//   Future<List<Poi>> getPoisByLocation(LocationInfo? locationInfo) async{
//     Uri newUri = addLocationInfoToUrl(serverUrl , '/searchNearbyPois', locationInfo!);
//     // var cl = HttpClient();
//     // var res = await cl.get("localhost", 5600, "");
//     // print(res);
//     final response = await http.get(
//       newUri
//       // Uri.parse('https://autotripguidemobile.loca.lt'),
//     );
//     print(response.body);
//
//     var client = http.Client();
//     try {
//       var response = await client.get(newUri, headers: {"Access-Control-Allow-Origin": "*"});
//       if (response.statusCode == 200) {
//         final parsed = jsonDecode(response.body).cast<Map<String, dynamic>>();
//         return parsed.map<Poi>((json) => Poi.fromJson(json)).toList();
//       } else {
//         // If the server did not return a 200 OK response,
//         // then throw an exception.
//         throw Exception('Failed to load Pois');
//       }
//     } finally {
//       client.close();
//     }
//   }
// }