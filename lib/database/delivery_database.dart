import 'dart:async';
import 'package:sqflite/sqflite.dart';

class DeliveryDatabase {
  final Database _database;
  late StreamController<List<Map<String, dynamic>>> _streamController;

  Stream<List<Map<String, dynamic>>> get stream => _streamController.stream;

 DeliveryDatabase(this._database) {
    _streamController =
        StreamController<List<Map<String, dynamic>>>.broadcast();
    _startListeningToChanges();
  }

  Future<void> fullcreate(Map<String, dynamic> data) async {
    try {
      await _database.insert('full_delivery', data);
      print('Data inserted into the database: $data');
      _refreshStream();
    } catch (e) {
      print('Error inserting data into the database: $e');
    }
  }
   Future<void> partialcreate(Map<String, dynamic> data) async {
    try {
      await _database.insert('partial_delivery', data);
      print('Data inserted into the database: $data');
      _refreshStream();
    } catch (e) {
      print('Error inserting data into the database: $e');
    }
  }
   Future<void> nonecreate(Map<String, dynamic> data) async {
    try {
      await _database.insert('none_delivery', data);
      print('Data inserted into the database: $data');
      _refreshStream();
    } catch (e) {
      print('Error inserting data into the database: $e');
    }
  }



  Future<List<Map<String, dynamic>>> read() async {
    return _database.query(
      'full_delivery',
      orderBy: 'date_delivered',
    );
  }

  Future<List<Map<String, dynamic>>> readById(int id) async {
    return _database.query(
      'full_delivery',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Future<void> update(int id, Map<String, dynamic> data) async {
  //   try {
  //     await _database.update(
  //       'full_delivery',
  //       data,
  //       where: 'id = ?',
  //       whereArgs: [id],
  //     );
  //     _refreshStream();
  //   } catch (e) {
  //     print('Error updating data in the database: $e');
  //   }
  // }

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
