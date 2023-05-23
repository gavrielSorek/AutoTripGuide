import 'package:url_launcher/url_launcher.dart';

class AppLauncher {
  void launchWaze(double lat, double lng) async {
    var url = Uri.parse('waze://?ll=${lat.toString()},${lng.toString()}');
    var fallbackUrl = Uri.parse('https://waze.com/ul?ll=${lat.toString()},${lng.toString()}&navigate=yes');
    try {
      bool launched =
          await launchUrl(url);
      if (!launched) {
        await launchUrl(fallbackUrl);
      }
    } catch (e) {
      await launchUrl(fallbackUrl);
    }
  }

  void launchGoogleMaps(double lat, double lng) async {
    var url = Uri.parse('google.navigation:q=${lat.toString()},${lng.toString()}');
    var fallbackUrl =
    Uri.parse('https://www.google.com/maps/search/?api=1&query=${lat.toString()},${lng.toString()}');
    try {
      bool launched =
          await launchUrl(url);
      if (!launched) {
        await launchUrl(fallbackUrl);
      }
    } catch (e) {
      await launchUrl(fallbackUrl);
    }
  }
}
