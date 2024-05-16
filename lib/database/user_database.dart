import 'package:coldxpress/export.dart';

class UserDatabase {
  final Database _database;

  UserDatabase(this._database);

  Future<void> create(Map<String, dynamic> data) async {
    await _database.insert('users', data);
  }

  Future<List<Map<String, dynamic>>> read(String accessToken) async {
    return _database.query(
      'users',
      where: 'access_token = ?',
      whereArgs: [accessToken],
    );
  }
}
