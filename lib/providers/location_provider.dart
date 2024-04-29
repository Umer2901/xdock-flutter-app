import 'package:coldxpress/export.dart';
import 'package:geolocator/geolocator.dart';

class LocationProvider with ChangeNotifier {
  Position? _current;

  Position? get current => _current;

  final GeolocatorPlatform _geolocator = GeolocatorPlatform.instance;

  void getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        const Text('Please allow the location');
        return;
      }
      if (permission == LocationPermission.denied) {
        const Text('Location Needed');
        return;
      }
    }
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      _geolocator.getPositionStream().listen((Position position) {
        _current = position;
        notifyListeners();
      });
    }
  }
}
