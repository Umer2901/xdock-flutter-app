import 'dart:async';
import 'package:coldxpress/export.dart';

class ConsignmentDatabase {
  final Database _database;
  final String? accessToken;
  late StreamController<List<Map<String, dynamic>>> _streamController;

  StreamController get controller => _streamController;

  ConsignmentDatabase(this._database, {this.accessToken}) {
    _streamController =
        StreamController<List<Map<String, dynamic>>>.broadcast();
    _startListeningToChanges();
  }

  Future<void> create(Map<String, dynamic> data) async {
    await _database.insert('consignments', data);
  }

  Future<List<Map<String, dynamic>>> readById(int id) async {
    return _database.query(
      'consignments',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> read() async {
    return _database.query(
      'consignments',
      where: 'access_token = ? AND datetime = ?',
      whereArgs: [accessToken, DateFormat('dd/MM/yyyy').format(DateTime.now())],
    );
  }

  void _startListeningToChanges() {
    _database.transaction((txn) async {
      await txn
          .query(
        'consignments',
        where: 'access_token = ? AND datetime = ?',
        whereArgs: [
          accessToken,
          DateFormat('dd/MM/yyyy').format(
            DateTime.now().subtract(
              const Duration(days: 1),
            ),
          )
        ],
        orderBy: 'sort ASC',
      )
          .then((result) {
        _streamController.add(result);
      });
    });
  }

  void dispose() {
    _streamController.close();
  }
}
