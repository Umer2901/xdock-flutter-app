import 'dart:convert';
import 'package:coldxpress/providers/pof_services_provider.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:coldxpress/export.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TaskSyncProvider with ChangeNotifier {
  TaskSyncDatabase? taskDatabase;

  void checkInternetConnectivity(Database database, BuildContext context) async {
    Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      if (results.contains(ConnectivityResult.mobile) ||
          results.contains(ConnectivityResult.wifi)) {
        startSync(database, context);
        syncTasksWithApi(database, context);
      } else {
        stopSync(database);
      }
    });
  }

  startSync(Database database, BuildContext context) {
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

  syncTasksWithApi(Database database, BuildContext context) async {
    try {
      final taskDatabase = TaskSyncDatabase(database);
      final tasks = await taskDatabase.read();
      print("Data from sync: ${tasks}");

      if (tasks.isEmpty) {
        print('No tasks to sync');
        return;
      }

      print('Syncing ${tasks.length} tasks with API...');
      await Provider.of<TaskSyncpofProvider>(context, listen: false).postDataToApi(tasks);

      for (var task in tasks) {
        await taskDatabase.delete(task['id']);
        await ConsignmentDatabase(database).update(task['id'], {'is_complete': 1});
      }
    } catch (e) {
      print('Error syncing tasks: $e');
    }
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
