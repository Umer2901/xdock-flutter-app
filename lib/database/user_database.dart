import 'dart:async';
import 'package:coldxpress/export.dart';

class UserDatabase {
  final Database _database;
  final String? accessToken;
  late StreamController<List<Map<String, dynamic>>> _streamController;

  StreamController get controller => _streamController;

  UserDatabase(this._database, {this.accessToken}) {
    _streamController =
        StreamController<List<Map<String, dynamic>>>.broadcast();
    _startListeningToChanges();
  }

  Future<void> create(Map<String, dynamic> data) async {
    await _database.insert('users', data);
  }

  Future<List<Map<String, dynamic>>> read() async {
    return _database.query(
      'users',
      where: 'access_token = ?',
      whereArgs: [accessToken],
    );
  }

  void _startListeningToChanges() {
    _database.transaction((txn) async {
      await txn.query(
        'users',
        where: 'access_token = ?',
        whereArgs: [accessToken],
      ).then((result) {
        _streamController.add(result);
      });
    });
  }

  void dispose() {
    _streamController.close();
  }
}
