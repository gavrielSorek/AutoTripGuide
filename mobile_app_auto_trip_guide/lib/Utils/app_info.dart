import 'package:journ_ai/Map/server_communication.dart';
import 'package:package_info_plus/package_info_plus.dart';

enum UpdateStatus {
  notRequired,
  available,
  requiredImmediately,
}

class AppInfo {

  static Future<String> getCurrentAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  static Future<UpdateStatus> getUpdateStatus() async {
    Map statusToUpdateStatus = {0: UpdateStatus.notRequired, 1: UpdateStatus.available, 2: UpdateStatus.requiredImmediately};
    int status = await ServerCommunication.checkForUpdates(await getCurrentAppVersion());
    return statusToUpdateStatus[status] ?? UpdateStatus.notRequired;
  }
}