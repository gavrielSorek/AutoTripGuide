import 'dart:convert';
import 'package:final_project/Map/types.dart';
import 'package:http/http.dart' as http;
import 'package:http/retry.dart';

class ServerCommunication {
  // String serverUrl = "https://autotripguidemobile.loca.lt";
  // String serverUrl = "autotripguidemobile.loca.lt";
  String serverUrl = "204f-77-126-184-189.ngrok.io";

  var client = RetryClient(http.Client());

  // var client = http.Client();

  static Uri addLocationInfoToUrl(
      String url, String path, LocationInfo locationInfo) {
    final queryParameters = {
      'lat': locationInfo.lat.toString(),
      'lng': locationInfo.lng.toString(),
      'heading': locationInfo.heading.toString(),
      'speed': locationInfo.speed.toString()
    };
    final uri = Uri.https(url, path, queryParameters);
    return uri;
  }

  Future<List<Poi>> getPoisByLocation(LocationInfo? locationInfo) async {
    Uri newUri =
        addLocationInfoToUrl(serverUrl, '/searchNearbyPois', locationInfo!);

    // var client = http.Client();
    try {
      var response = await client.get(newUri);
      if (response.statusCode == 200 && response.contentLength! > 0) {
        final parsed = jsonDecode(response.body).cast<Map<String, dynamic>>();
        return parsed.map<Poi>((json) => Poi.fromJson(json)).toList();
      } else {
        if (response.contentLength == 0) {
          return [];
        }
        // If the server did not return a 200 OK response,
        // then throw an exception.
        throw Exception('Failed to load Pois');
      }
    } finally {
      // client.close();
    }
  }

  static Uri addPoiInfoToUrl(String url, String path, String poiId) {
    final queryParameters = {
      'poiId': poiId,
    };
    final uri = Uri.https(url, path, queryParameters);
    return uri;
  }

  Future getAudioById(String poiId) async {
    Uri newUri = addPoiInfoToUrl(serverUrl, '/getAudio', poiId);

    // var client = http.Client();
    try {
      var response = await client.get(newUri);
      if (response.statusCode == 200 && response.contentLength! > 0) {
        return Audio.fromJson(jsonDecode(response.body));
        // final parsed = jsonDecode(response.body).cast<Map<String, dynamic>>();
        // return parsed.map<Poi>((json) => Poi.fromJson(json)).toList();
      } else {
        // If the server did not return a 200 OK response,
        // then throw an exception.
        print('failed to load audio');
        return [];

        // throw Exception('Failed to load audio');
      }
    } finally {
      // client.close();
    }
  }

  static Uri addUserInfoToUrl(String url, String path, UserInfo userInfo) {
    final queryParameters = {
      'name': userInfo.name.toString(),
      'emailAddr': userInfo.emailAddr.toString(),
      'gender': userInfo.gender.toString(),
      'languages': userInfo.languages.toString(),
      'age': userInfo.age.toString(),
      'categories': userInfo.categories.toString()
    };
    final uri = Uri.https(url, path, queryParameters);
    return uri;
  }

  void addNewUser(UserInfo? userInfo) async {
    Uri newUri = addUserInfoToUrl(serverUrl, '/addNewUser', userInfo!);
    try {
      var response = await client.get(newUri);
      if (response.statusCode == 200 && response.contentLength! > 0) {
        print("the user added successfully");
      } else {
        if (response.contentLength == 0) {
          print("the user already exist");
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
