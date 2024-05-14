import 'package:coldxpress/export.dart';

class BottomNavProvider with ChangeNotifier {
  int _index = 1;

  int get index => _index;

  changeTabView(int index) {
    _index = index;
    notifyListeners();
  }
}
