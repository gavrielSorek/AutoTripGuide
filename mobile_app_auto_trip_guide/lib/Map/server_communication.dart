import 'dart:convert';
import 'package:final_project/Map/location_types.dart';
import 'package:http/http.dart' as http;
import 'package:http/retry.dart';


class ServerCommunication {
  // String serverUrl = "https://autotripguidemobile.loca.lt";
  String serverUrl = "autotripguidemobile.loca.lt";
  //String serverUrl = "6a42b107629f55.lhrtunnel.link";

  static var client = RetryClient(http.Client());


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

    // var client = http.Client();
    try {
      var response = await client.get(newUri);
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
      // client.close();
    }
  }

  static Uri addUserInfoToUrl(String url, String path,UserInfo userInfo) {
    final queryParameters = {
      'name': userInfo.name.toString(),
      'emailAddr': userInfo.emailAddr.toString()
    };
    final uri = Uri.https(url, path, queryParameters);
    return uri;
  }

  Future<int> addNewUser(UserInfo? userInfo) async{
    Uri newUri = addUserInfoToUrl(serverUrl , '/addNewUser', userInfo!);
    try {
      var response = await client.get(newUri);
      if (response.statusCode == 200 && response.contentLength! > 0) {
        print("the user added successfully");
        return 1;
      } else {
        if (response.contentLength == 0) {
          print("the user already exist");
          return 0;
        }
        // If the server did not return a 200 OK response,
        // then throw an exception.
        throw Exception('Failed to add user');
      }
    } finally {
      // client.close();
    }
  }

  @override
  void dispose() {
    client.close();
  }
}