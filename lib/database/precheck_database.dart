import 'dart:async';
import 'package:coldxpress/export.dart';

class PreCheckDatabase {
  final Database _database;
  final String? accessToken;
  late StreamController<List<Map<String, dynamic>>> _streamController;

  StreamController get controller => _streamController;

  PreCheckDatabase(this._database, {this.accessToken}) {
    _streamController =
        StreamController<List<Map<String, dynamic>>>.broadcast();
    _startListeningToChanges();
  }

  Future<void> create(Map<String, dynamic> data) async {
    await _database.insert('precheck_status', data);
  }

  Future<List<Map<String, dynamic>>> read() async {
    return _database.query(
      'precheck_status',
      where: 'access_token = ? AND datetime = ?',
      whereArgs: [accessToken, DateFormat('dd/MM/yyyy').format(DateTime.now())],
    );
  }

  void _startListeningToChanges() {
    _database.transaction((txn) async {
      await txn.query(
        'precheck_status',
        where: 'access_token = ? AND datetime = ?',
        whereArgs: [
          accessToken,
          DateFormat('dd/MM/yyyy').format(DateTime.now())
        ],
      ).then((result) {
        _streamController.add(result);
      });
    });
  }

  void dispose() {
    _streamController.close();
  }
}
