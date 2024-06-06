import 'dart:async';
import 'package:coldxpress/export.dart';

class TaskDatabase {
  final Database _database;
  final String? accessToken;
  late StreamController<List<Map<String, dynamic>>> _streamController;

  TaskDatabase(this._database, {this.accessToken}) {
    _streamController = StreamController<List<Map<String, dynamic>>>.broadcast();
    _startListeningToChanges();
  }

  Stream<List<Map<String, dynamic>>> get taskStream => _streamController.stream;

  Future<void> create(Map<String, dynamic> data) async {
    try {
      await _database.insert('sync_task', data);
      _notifyChanges();
    } catch (e) {
      print('Error inserting data: $e');
    }
  }

  Future<List<Map<String, dynamic>>> read() async {
    try {
      return await _database.query('sync_task');
    } catch (e) {
      print('Error reading data: $e');
      return [];
    }
  }

  Future<void> delete(int id) async {
    try {
      await _database.delete(
        'sync_task',
        where: 'id = ?',
        whereArgs: [id],
      );
      _notifyChanges();
    } catch (e) {
      print('Error deleting data: $e');
    }
  }

  Future<void> deleteAll() async {
    try {
      await _database.delete('sync_task');
      _notifyChanges();
    } catch (e) {
      print('Error deleting all data: $e');
    }
  }

  void _startListeningToChanges() {
    _database.transaction((txn) async {
      final result = await txn.query('sync_task');
      _streamController.add(result);
    });
  }

  void _notifyChanges() async {
    final result = await _database.query('sync_task');
    _streamController.add(result);
  }

  void dispose() {
    _streamController.close();
  }
}
