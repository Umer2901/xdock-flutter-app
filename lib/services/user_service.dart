import 'package:coldxpress/export.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserService {
  final Database _database;

  UserService(this._database);

  Future<void> fetchAndStore(String accessToken) async {
    try {
      final response = await http.get(
        Uri.parse(AppHost.loginStaffData),
        headers: <String, String>{
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        if (data['status'] == 'success') {
          Map<String, dynamic> staffData = data['data'];
          staffData.addAll({'access_token': accessToken});
          await UserDatabase(_database).create(staffData);
        } else {
          throw Exception(
              'Unsuccessful to fetch staff data! (Error: ${data['message']})');
        }
      } else {
        throw Exception(
            'Unsuccessful to fetch staff data! (Error Code: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Unsuccessful to fetch staff data!');
    }
  }
}
