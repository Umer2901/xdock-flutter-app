import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:coldxpress/export.dart';

class TaskSyncProvider with ChangeNotifier {
  TaskSyncDatabase? taskDatabase;

  void checkInternetConnectivity(Database database) async {
    Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      if (results.contains(ConnectivityResult.mobile) ||
          results.contains(ConnectivityResult.wifi)) {
        startSync(database);
      } else {
        stopSync(database);
      }
    });
  }

  startSync(database) {
    taskDatabase = TaskSyncDatabase(database);
    taskDatabase?.stream.listen((event) async {
      if (event.isNotEmpty) {
        for (var data in event) {
          if (data['task_type'] == 'reorder') {
            Map consignmentsIds = json.decode(data['data']);
            reorder(data['id'], data['access_token'], consignmentsIds);
          }
        }
      }
    });
  }

  stopSync(database) {
    taskDatabase?.dispose();
  }

  Future<void> reorder(int taskId, String accessToken, var data) async {
    try {
      final response = await http.post(
        Uri.parse(AppHost.reorderConsignments),
        body: jsonEncode(data),
        headers: <String, String>{
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        String status = json.decode(response.body)['status'];
        if (status == 'success') {
          taskDatabase?.delete(taskId);
        }
      }
    } catch (e) {
      debugPrint('Error Reorder: $e');
    }
  }
}
