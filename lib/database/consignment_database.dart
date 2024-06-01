import 'dart:async';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';

class ConsignmentDatabase {
  final Database _database;
  final String? accessToken;
  late StreamController<List<Map<String, dynamic>>> _streamController;

  Stream<List<Map<String, dynamic>>> get stream => _streamController.stream;

  ConsignmentDatabase(this._database, {this.accessToken}) {
    _streamController =
        StreamController<List<Map<String, dynamic>>>.broadcast();
    _startListeningToChanges();
  }

 Future<void> create(Map<String, dynamic> data) async {
    try {
      await _database.insert('consignments', data);
      print('Data inserted into the database: $data');
      _refreshStream();
    } catch (e) {
      print('Error inserting data into the database: $e');
    }
  }

  Future<List<Map<String, dynamic>>> read() async {
    return _database.query(
      'consignments',
      where: 'access_token = ? ',
      whereArgs: [accessToken, ],
      orderBy: 'sort',
    );
  }

  Future<List<Map<String, dynamic>>> readById(int id) async {
    return _database.query(
      'consignments',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> update(int id, Map<String, dynamic> data) async {
    _database.update(
      'consignments',
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
    _refreshStream();
  }

  void _startListeningToChanges() async {
    final result = await read();
    if (!_streamController.isClosed) {
      _streamController.add(result);
    }
  }

  Future<void> _refreshStream() async {
    final result = await read();
    if (!_streamController.isClosed) {
      _streamController.add(result);
    }
  }

  void dispose() {
    _streamController.close();
  }
}
