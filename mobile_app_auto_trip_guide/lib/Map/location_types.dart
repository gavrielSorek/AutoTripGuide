

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
  String? language;
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
    return  Poi(
      poiName: json['_poiName'] as String,
      latitude: json['_latitude'] as double,
      longitude: json['_longitude'] as double,
      shortDesc: json['_shortDesc'] as String,
      language: json['_language'] as String,
      audio: json['_audio'] as String,
      source: json['_source'] as String,
      Contributor: json['_Contributor'] as String,
      CreatedDate: json['_CreatedDate'] as String,
      ApprovedBy: json['_ApprovedBy'] as String,
      UpdatedBy: json['_UpdatedBy'] as String,
      LastUpdatedDate: json['_LastUpdatedDate']as String,
      country: json['_country'] as String,
      Categories: json['_Categories'].split(',') as List<String>,
    );
  }
}