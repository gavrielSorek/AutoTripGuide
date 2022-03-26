

class LocationInfo {
  double lat;
  double lng;
  double heading;
  double speed;
  LocationInfo(this.lat, this.lng, this.heading, this.speed);
}


class Poi {
  String? poiName;
  double? latitude;
  double? longitude;
  String? shortDesc;
  List<String>? language;
  dynamic? audio;
  String? source;
  String? Contributor;
  String? CreatedDate;
  String? ApprovedBy;
  String? UpdatedBy;
  String? LastUpdatedDate;
  String? country;
  List<String>? Categories;
  Poi({
    this.poiName,
    this.latitude,
    this.longitude,
    this.shortDesc,
    this.language,
    this.audio,
    this.source,
    this.Contributor,
    this.CreatedDate,
    this.ApprovedBy,
    this.UpdatedBy,
    this.LastUpdatedDate,
    this.country,
    this.Categories,
  });


  factory Poi.fromJson(Map<String, dynamic> json) {
    return Poi(
      poiName: json['_poiName'],
      latitude: json['_latitude'],
      longitude: json['_longitude'],
      shortDesc: json['_shortDesc'],
      language: json['_language'],
      audio: json['_audio'],
      source: json['_source'],
      Contributor: json['_Contributor'],
      CreatedDate: json['_CreatedDate'],
      ApprovedBy: json['_ApprovedBy'],
      UpdatedBy: json['_UpdatedBy'],
      LastUpdatedDate: json['_LastUpdatedDate'],
      country: json['_country'],
      Categories: json['_Categories'],
    );
  }
}