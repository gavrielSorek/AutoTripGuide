import 'dart:convert';
import 'package:journ_ai/Map/types.dart';
import 'package:http/http.dart' as http;
import 'package:http/retry.dart';

import 'globals.dart';

class ServerCommunication {
  //String serverUrl = "192.168.1.180:5600";
   String serverUrl = "212.80.207.83:5600";

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
    final uri = Uri.http(url, path, queryParameters);
    return uri;
  }

  static Uri addInfoToUrl(String url, String path, Map<String, String> info) {
    return Uri.http(url, path, info);
  }

  Future<List<Poi>> getPoisByLocation(LocationInfo? locationInfo) async {
    Uri newUri =
        addLocationInfoToUrl(serverUrl, '/searchNearbyPois', locationInfo!);

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

  Future<Poi?> getPoiById(String poiId) async {
    Map<String, String> params = {'poiId': poiId};
    Uri newUri = Uri.http(serverUrl, '/getPoiById', params);

    try {
      var response = await client.get(newUri);
      if (response.statusCode == 200 && response.contentLength! > 0) {
        final parsed = jsonDecode(response.body);
        return Poi.fromJson(parsed);
      } else {
        return null;
      }
    } finally {
      // client.close();
    }
  }

  Future<int?> getPoiPreferences(String poiId, UserInfo? userInfo) async {
    if (userInfo == null) {
      return 0;
    }

    Map<String, String> params = {
      'emailAddr': userInfo.emailAddr!,
      'poiId': poiId,
    };
    Uri newUri = Uri.http(serverUrl, '/getUserPoiPreference', params);

    try {
      var response = await client.get(newUri);
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final parsed = jsonDecode(response.body);
        final preference = parsed['preference'];
        return int.tryParse(preference);
      } else {
        return null;
      }
    } finally {
      // client.close();
    }
  }

  void insertPoiPreferences(
      String poiId, UserInfo? userInfo, int preference) async {
    if (userInfo == null) {
      return;
    }

    Map<String, dynamic> params = {
      'emailAddr': userInfo.emailAddr!,
      'poiId': poiId,
      'preference': preference.toString()
    };

    Uri newUri = Uri.http(serverUrl, '/insertUserPoiPreference', params);

    try {
      var response = await client.post(newUri);
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        print('insertPoiPreferences succeeded');
      } else {
        return null;
      }
    } finally {
      // client.close();
    }
  }

  static Uri addPoiInfoToUrl(String url, String path, String poiId) {
    final queryParameters = {
      'poiId': poiId,
    };
    final uri = Uri.http(url, path, queryParameters);
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
        return Audio.fromJson(jsonDecode('{"type":"Buffer","data":[]}'));

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
    final uri = Uri.http(url, path, queryParameters);
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

  void dispose() {
    client.close();
  }

  static Uri addLangToUrl(String url, String path, String language) {
    final queryParameters = {'language': language.toString()};
    final uri = Uri.http(url, path, queryParameters);
    return uri;
  }

  Future<Map<String, List<String>>> getCategories(String language) async {
    Uri newUri = addLangToUrl(serverUrl, '/getCategories', language);
    try {
      var response = await client.get(newUri);
      if (response.statusCode == 200 && response.contentLength! > 0) {
        final categoriesMap = jsonDecode(response.body);
        Map<String, List<String>> newMap =
            Map.from(categoriesMap.map((key, value) {
          List<dynamic> values = List.from(value);
          return MapEntry(
              key.toString(),
              values.map((theValue) {
                return theValue.toString();
              }).toList());
        }));
        return newMap;
      } else {
        if (response.contentLength == 0) {
          return {};
        }
        // If the server did not return a 200 OK response,
        // then throw an exception.
        throw Exception('Failed to get categories');
      }
    } finally {
      // client.close();
    }
  }

  Future<List<String>> getFavorCategories(String emailAddr) async {
    Map<String, String> params = {};
    params.putIfAbsent('email', () => emailAddr);
    Uri newUri = addInfoToUrl(serverUrl, '/getFavorCategories', params);
    try {
      var response = await client.get(newUri);
      if (response.statusCode == 200 && response.contentLength! > 0) {
        final favorCategoriesMap = jsonDecode(response.body);
        try {
          List<String> favorCategoriesList = favorCategoriesMap.cast<String>();
          return favorCategoriesList;
        } catch (e) {
          return [];
        }
      } else {
        if (response.contentLength == 0) {
          return [];
        }
        // If the server did not return a 200 OK response,
        // then throw an exception.
        throw Exception('Failed to get favorite categories');
      }
    } finally {
      // client.close();
    }
  }

  static Uri addMailAndCategoriesToUrl(
      String url, String path, String emailAddr) {
    final queryParameters = {
      'email': emailAddr.toString(),
      'categories': Globals.globalFavoriteCategories
    };
    final uri = Uri.http(url, path, queryParameters);
    return uri;
  }

  void updateFavorCategories(String emailAddr) async {
    Uri newUri = addMailAndCategoriesToUrl(
        serverUrl, '/updateFavorCategories', emailAddr);
    try {
      var response = await client.get(newUri);
      if (response.statusCode == 200 && response.contentLength! > 0) {
        print("the favorite categories update successfully");
      } else {
        // If the server did not return a 200 OK response,
        // then throw an exception.
        throw Exception('Failed to update favorite categories');
      }
    } finally {
      // client.close();
    }
  }

  Future<Map<String, String>> getUserInfo(String emailAddr) async {
    Map<String, String> params = {};
    params.putIfAbsent('email', () => emailAddr);
    Uri newUri = addInfoToUrl(serverUrl, '/getUserInfo', params);
    try {
      var response = await client.get(newUri);
      if (response.statusCode == 200 && response.contentLength! > 0) {
        final UserInfoMap = jsonDecode(response.body);
        Map<String, String> newMap = Map<String, String>.from(UserInfoMap);
        return newMap;
      } else {
        if (response.contentLength == 0) {
          return {};
        }
        // If the server did not return a 200 OK response,
        // then throw an exception.
        throw Exception('Failed to get user info');
      }
    } finally {
      // client.close();
    }
  }

  static Uri addUpdatedUserInfoToUrl(
      String url, String path, UserInfo? userInfo) {
    final queryParameters = {
      'email': userInfo?.emailAddr.toString(),
      'name': userInfo?.name.toString(),
      'gender': userInfo?.gender.toString(),
      'languages': userInfo?.languages.toString(),
      'age': userInfo?.age.toString()
    };
    final uri = Uri.http(url, path, queryParameters);
    return uri;
  }

  void updateUserInfo() async {
    Uri newUri = addUpdatedUserInfoToUrl(
        serverUrl, '/updateUserInfo', Globals.globalUserInfoObj);
    try {
      var response = await client.get(newUri);
      if (response.statusCode == 200 && response.contentLength! > 0) {
        print("the user info update successfully");
      } else {
        // If the server did not return a 200 OK response,
        // then throw an exception.
        throw Exception('Failed to update favorite categories');
      }
    } finally {
      // client.close();
    }
  }

  static Uri addVisitedPoiToUrl(
      String url, String path, VisitedPoi visitedPoi) {
    final queryParameters = {
      'id': visitedPoi.id.toString(),
      'poiName': visitedPoi.poiName.toString(),
      'time': visitedPoi.time.toString(),
      'pic': visitedPoi.pic.toString(),
      'emailAddr': Globals.globalEmail
    };
    final uri = Uri.http(url, path, queryParameters);
    return uri;
  }

  void insertPoiToHistory(VisitedPoi visitedPoi) async {
    Uri newUri =
        addVisitedPoiToUrl(serverUrl, '/insertPoiToHistory', visitedPoi);
    try {
      var response = await client.get(newUri);
      if (response.statusCode == 200 && response.contentLength! > 0) {
        print("the poi insert to history");
      } else {
        // If the server did not return a 200 OK response,
        // then throw an exception.
        throw Exception('Failed insert poi to history');
      }
    } finally {
      // client.close();
    }
  }

  Future<List<VisitedPoi>> getPoisHistory(String emailAddr) async {
    Map<String, String> params = {};
    params.putIfAbsent('email', () => emailAddr);
    Uri newUri = addInfoToUrl(serverUrl, '/getPoisHistory', params);
    try {
      var response = await client.get(newUri);
      if (response.statusCode == 200 && response.contentLength! > 0) {
        final parsed = jsonDecode(response.body).cast<Map<String, dynamic>>();
        return parsed
            .map<VisitedPoi>((json) => VisitedPoi.fromJson(json))
            .toList();
      } else {
        if (response.contentLength == 0) {
          return [];
        }
        // If the server did not return a 200 OK response,
        // then throw an exception.
        throw Exception('Failed to get pois history');
      }
    } finally {
      // client.close();
    }
  }
}
