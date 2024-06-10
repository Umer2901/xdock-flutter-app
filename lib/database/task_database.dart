import 'dart:async';
import 'package:sqflite/sqflite.dart';

class TaskSyncDatabase {
  final Database _database;

  late StreamController<List<Map<String, dynamic>>> _streamController;
  Timer? _timer;

  Stream<List<Map<String, dynamic>>> get stream => _streamController.stream;

  TaskSyncDatabase(this._database) {
    _streamController =
        StreamController<List<Map<String, dynamic>>>.broadcast();
    _startListeningToChanges();
  }

  Future<void> create(Map<String, dynamic> data) async {
    await _database.insert('sync_task', data);
  }

  Future<List<Map<String, dynamic>>> read() async {
    return _database.query(
      'sync_task',
      orderBy: 'id',
    );
  }

  Future<void> update(int id, Map<String, dynamic> data) async {
    await _database.update(
      'sync_task',
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> delete(int id) async {
    await _database.delete(
      'sync_task',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  void _startListeningToChanges() {
    _timer = Timer.periodic(const Duration(milliseconds: 800), (timer) async {
      _refreshStream();
    });
  }

  Future<void> _refreshStream() async {
    final result = await read();
    if (!_streamController.isClosed) {
      _streamController.add(result);
    }
  }

  void dispose() {
    _timer!.cancel();
    _streamController.close();
  }
}
