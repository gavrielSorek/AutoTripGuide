import 'dart:io';
import 'package:final_project/Map/globals.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:device_info_plus/device_info_plus.dart';

class User {
  String email;
  late String device;
  late String region;

  User({required this.email}) {
    device = Platform.operatingSystemVersion;
    region = Platform.localeName;
  }

  Future<void>  init() async{
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    device = (Platform.isAndroid ? (await deviceInfo.androidInfo).model : (await deviceInfo.iosInfo).model)!;
  }
}

class AppEvents {
  
  late User user;
  static const String prefix = 'App_';

  AppEvents({required String email}) {
    user = User(email: email);
  }
  
  Future<void> init() async{
    await user.init();
  }
  set email(String email){
    user.email = email;
  }
  void pushEvent(String eventName, [Map<String, dynamic>? properties]){
        Map<String, dynamic> combinedProperties = {
      'Device': user.device,
      'OS': Platform.operatingSystem,
    };

    if (properties != null) {
      combinedProperties.addAll(properties);
  }
    Globals.mixpanel.track(eventName,properties: combinedProperties);
  }

  void appOpen(bool firstTimeOpen) {
    String eventName = prefix + 'App_Open';
    Map<String, dynamic> properties = {
      'First_time_open': firstTimeOpen,
    };

    // send event to analytics
  }

  void introStarted() {
    String eventName = prefix + 'Intro_Started';
    // send event to analytics
    pushEvent(eventName);
  }

  void introCompleted() {
    String eventName = prefix + 'Intro_Completed';
    // send event to analytics
  }

  void introSkipped() {
    String eventName = prefix + 'Intro_Skipped';
    // send event to analytics
  }

  void signIn(String signInType) {
    String eventName = prefix + 'Sign_In';
    Map<String, dynamic> properties = {'Sign_in_type': signInType};
    // send event to analytics
  }

  void signInCompleted(String status) {
    String eventName = prefix + 'Sign_In_Completed';
    Map<String, dynamic> properties = {'Status': status};
    // send event to analytics
  }

  void mainScreenLoaded(bool currentLocation) {
    String eventName = prefix + 'Mainscreen_Loaded';
    Map<String, dynamic> properties = {'Current_location': currentLocation};
    // send event to analytics
  }

  void scanningStarted(bool initialScanning, bool withUI, double lat,
      double long, String country, String location) {
    String eventName = prefix + 'Scanning_Started';
    Map<String, dynamic> properties = {
      'Initial_scanning': initialScanning,
      'With_UI': withUI,
      'Lat': lat,
      'Long': long,
      'Country': country,
      'Location': location
    };
    // send event to analytics
  }

  void scanningFinished(
      bool initialScanning, int numberOfPOIsFound, List<dynamic> more) {
    String eventName = prefix + 'Scanning_Finished';
    Map<String, dynamic> properties = {
      'Initial_scanning': initialScanning,
      'Number_of_POIs_found': numberOfPOIsFound,
      'More': more
    };
    // send event to analytics
  }

  void categoriesSheetShown(int numberOfPOIs, int numberOfCategories) {
    String eventName = prefix + 'Categories_Sheet_Shown';
    Map<String, dynamic> properties = {
      'Number_of_POIs': numberOfPOIs,
      'Number_of_categories': numberOfCategories
    };
    // send event to analytics
  }

  void categoriesSelected(String nameOfCategory, bool valueSet) {
    String eventName = prefix + 'Categories_Selected';
    Map<String, dynamic> properties = {
      'Name_of_category': nameOfCategory,
      'Value_set': valueSet ? 'checked' : 'unchecked'
    };
    // send event to analytics
  }

  void poiStartedPlaying(String nameOfPOI, String nameOfCategory, String poiID) {
    String eventName = prefix + 'POI_Started_Playing';
    Map<String, dynamic> properties = {
      'Name_of_POI': nameOfPOI,
      'Name_of_Category': nameOfCategory,
      'POI_ID': poiID
    };
    // send event to analytics
  }

  void poiFinishedPlaying(String nameOfPOI, String nameOfCategory, String poiID) {
    String eventName = prefix + 'POI_Finished_Playing';
    Map<String, dynamic> properties = {
      'Name_of_POI': nameOfPOI,
      'Name_of_Category': nameOfCategory,
      'POI_ID': poiID
    };
    // send event to analytics
  }

  void poiPlaybackSkipped(
      String nameOfPOI, String nameOfCategory, String poiID) {
    String eventName = prefix + 'POI_Playback_Skipped';
    Map<String, dynamic> properties = {
      'Name_of_POI': nameOfPOI,
      'Name_of_Category': nameOfCategory,
      'POI_ID': poiID
    };
    // send event to analytics
  }

  void poiPlaybackPaused(
      String nameOfPOI, String nameOfCategory, String poiID) {
    String eventName = prefix + 'POI_Playback_Paused';
    Map<String, dynamic> properties = {
      'Name_of_POI': nameOfPOI,
      'Name_of_Category': nameOfCategory,
      'POI_ID': poiID
    };
    // send event to analytics
  }

  void poiExpanded(String nameOfPOI, String nameOfCategory, String poiID) {
    String eventName = prefix + 'POI_Expanded';
    Map<String, dynamic> properties = {
      'Name_of_POI': nameOfPOI,
      'Name_of_Category': nameOfCategory,
      'POI_ID': poiID
    };
    // send event to analytics
  }

  void poiCollapsed(String nameOfPOI, String nameOfCategory, String poiID) {
    String eventName = prefix + 'POI_Collapsed';
    Map<String, dynamic> properties = {
      'Name_of_POI': nameOfPOI,
      'Name_of_Category': nameOfCategory,
      'POI_ID': poiID
    };
}

  void poiShared(String nameOfPoi, String nameOfCategory, String poiId) {
    String eventName = prefix + 'POI_Shared';
    Map<String, dynamic> properties = {
      'Name_of_POI': nameOfPoi,
      'Name_of_Category': nameOfCategory,
      'POI_ID': poiId,
    };
    // send event to analytics
  }
  
  void poiNavigationStarted(String nameOfPoi, String nameOfCategory, String poiId) {
    String eventName = prefix + 'POI_Navigation_Started';
    Map<String, dynamic> properties = {
      'Name_of_POI': nameOfPoi,
      'Name_of_Category': nameOfCategory,
      'POI_ID': poiId,
    };
    // send event to analytics
  }
}