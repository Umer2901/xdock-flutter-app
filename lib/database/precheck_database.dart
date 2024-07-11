import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';

class PreCheckDatabase {
  final Database _database;
  final String? accessToken;
  late StreamController<List<Map<String, dynamic>>> _streamController;
  Timer? _timer;

  Stream<List<Map<String, dynamic>>> get stream => _streamController.stream;

  PreCheckDatabase(this._database, {this.accessToken}) {
    _streamController =
        StreamController<List<Map<String, dynamic>>>.broadcast();
    _startListeningToChanges();
  }

  Future<void> create(Map<String, dynamic> data) async {
    await _database.insert('precheck_status', data);
    _refreshStream();
  }

  Future<List<Map<String, dynamic>>> read() async {
    try {
      final result = await _database.query(
        'precheck_status',
        where: 'access_token = ? AND datetime = ?',
        whereArgs: [
          accessToken,
          DateFormat('dd/MM/yyyy').format(DateTime.now())
        ],
      );
      return result;
    } catch (e) {
      return [];
    }
  }

  Future<void> update(Map<String, dynamic> data) async {
    await _database.update(
      'precheck_status',
      data,
      where: 'access_token = ? AND datetime = ?',
      whereArgs: [accessToken, DateFormat('dd/MM/yyyy').format(DateTime.now())],
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
    _timer?.cancel();
    _streamController.close();
  }
}
