import 'package:coldxpress/export.dart';

class InboundProvider with ChangeNotifier {
  int _index = 0;
  Map _data = {};
  List<XFile> _images = [];
  Map<String, String> _base64Images = {};
  Map<String, String> _pictureSources = {};

  int get index => _index;
  Map get data => _data;
  List<XFile> get images => _images;
  Map<String, String> get base64Images => _base64Images;
  Map<String, String> get pictureSources => _pictureSources;

  setIndex(int value) {
    _index = value;
    notifyListeners();
  }

  addEntities(dynamic entries) {
    _data.addEntries(entries);
    notifyListeners();
  }

  setEntities(Map value) {
    _data = value;
    notifyListeners();
  }

  addImage({
    required XFile image,
    required String base64String,
    required String source,
  }) {
    _images.add(image);
    _base64Images
        .addEntries({'picture${_images.length}': base64String}.entries);
    _pictureSources.addEntries({'picture${_images.length}': source}.entries);
    notifyListeners();
  }

  removeImage({
    required XFile image,
  }) {
    _images.remove(image);
    int index = _images.indexOf(image);
    _base64Images.remove('picture${index + 1}');
    _pictureSources.remove('picture${index + 1}');
    notifyListeners();
  }

  restoreToDefault() {
    _index = 0;
    _data = {};
    _images = [];
    _base64Images = {};
    _pictureSources = {};
  }
}
