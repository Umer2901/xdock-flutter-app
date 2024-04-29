import 'package:coldxpress/export.dart';

class PreStartProvider with ChangeNotifier {
  int _index = 0;
  Map _data = {};
  XFile? _image;
  bool _ischeck = false;

  int get index => _index;
  Map get data => _data;
  XFile? get image => _image;
  bool? get ischeck => _ischeck;

  setIndex(int value) {
    _index = value;
    notifyListeners();
  }

  setImage({required XFile image}) {
    _image = image;
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

  void clearImage() {
    _image = null;
    notifyListeners();
  }

  setIsCheck({required bool isCheck}) {
    _ischeck = isCheck;
    notifyListeners();
  }
}
