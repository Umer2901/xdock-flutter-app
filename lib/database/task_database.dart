import 'dart:async';
import 'package:coldxpress/export.dart';

class TaskDatabase {
  final Database _database;
  final String? accessToken;
  late StreamController<List<Map<String, dynamic>>> _streamController;

  StreamController get controller => _streamController;

  TaskDatabase(this._database, {this.accessToken}) {
    _streamController =
        StreamController<List<Map<String, dynamic>>>.broadcast();
    _startListeningToChanges();
  }

  Future<void> create(Map<String, dynamic> data) async {
    await _database.insert('sync_task', data);
  }

  Future<List<Map<String, dynamic>>> read() async {
    return _database.query('sync_task');
  }

  Future<void> delete(int id) async {
    await _database.delete(
      'sync_task',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  void _startListeningToChanges() {
    _database.transaction((txn) async {
      await txn.query('sync_task').then((result) {
        _streamController.add(result);
      });
    });
  }

  void dispose() {
    _streamController.close();
  }
}
