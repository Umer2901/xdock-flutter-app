// ignore_for_file: deprecated_member_use
import 'package:url_launcher/url_launcher.dart';

class MapHelper {
  static Future<void> openDirections({
    required String originLatitude,
    required String originLongitude,
    required String destinationLatitude,
    required String destinationLongitude,
  }) async {
    final url =
        'https://www.google.com/maps/dir/?api=1&origin=$originLatitude,$originLongitude&destination=$destinationLatitude,$destinationLongitude';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
