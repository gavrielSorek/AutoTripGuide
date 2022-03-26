import 'dart:convert';

import 'package:final_project/Map/location_types.dart';
import 'package:http/http.dart' as http;
class ServerCommunication {
  String serverGetPoisUrl;
  ServerCommunication(this.serverGetPoisUrl);

  static Uri addLocationInfoToUrl(String url,LocationInfo locationInfo) {
    final queryParameters = {
      'lat': locationInfo.lat.toString(),
      'lng': locationInfo.lat.toString(),
      'heading': locationInfo.heading.toString(),
      'speed': locationInfo.speed.toString(),
    };
    final uri = Uri.https(url, '', queryParameters);
    return uri;
  }

  Future<List<Poi>> getPoisByLocation(LocationInfo locationInfo) async{
    Uri newUri = addLocationInfoToUrl(serverGetPoisUrl, locationInfo);
    var response = await http.get(newUri);
    if (response.statusCode == 200) {
      // parse the JSON.
      Iterable iterator = json.decode(response.body);
      return List<Poi>.from(iterator.map((poi)=> Poi.fromJson(poi)));
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load Pois');
    }
  }
}
