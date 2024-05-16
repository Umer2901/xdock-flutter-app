import 'package:coldxpress/export.dart';

class PreCheckDatabase {
  final Database _database;

  PreCheckDatabase(this._database);

  Future<void> create(Map<String, dynamic> data) async {
    await _database.insert('precheck_status', data);
  }

  Future<List<Map<String, dynamic>>> read(String accessToken) async {
    return _database.query(
      'precheck_status',
      where: 'access_token = ? AND datetime = ?',
      whereArgs: [accessToken, DateFormat('dd/MM/yyyy').format(DateTime.now())],
    );
  }
}
