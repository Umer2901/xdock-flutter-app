import 'dart:io';
import 'package:coldxpress/export.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PrecheckStatusService {
  final Database _database;

  PrecheckStatusService(this._database);

  Future<void> fetchAndStore(String accessToken) async {
    try {
      final response = await http.get(
        Uri.parse(AppHost.checkSubmissions),
        headers: <String, String>{
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        if (data['status'] == 'success') {
          Map<String, dynamic> submissionData = data;
          submissionData.addAll({
            'access_token': accessToken,
            'datetime': DateFormat('dd/MM/yyyy').format(
              DateTime.now(),
            ),
          });
          submissionData.remove('status');
          await PreCheckDatabase(_database).create(submissionData);
        } else {
          throw Exception(
            'Unsuccessful to fetch submission data! (Error: ${data['message']})',
          );
        }
      } else {
        throw Exception(
            'Unsuccessful to fetch submission data! (Error Code: ${response.statusCode})');
      }
    } on SocketException catch (e) {
      throw Exception('No Internet ($e)');
    } catch (e) {
      throw Exception('Unsuccessful to fetch submission data!');
    }
  }

  Future<dynamic> fetchPreChecklistQA(String accessToken) async {
    try {
      final response = await http.get(
        Uri.parse(AppHost.indexPreChecklist),
        headers: <String, String>{
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        return data;
      } else {
        throw Exception('Failed to fetch data');
      }
    } catch (e) {
      throw Exception(
        e.toString(),
      );
    }
  }
}
