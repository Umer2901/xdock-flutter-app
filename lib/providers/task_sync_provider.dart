import 'dart:convert';

import 'package:coldxpress/export.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

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

  // Start syncing data from TaskSyncDatabase
  void startSync(Database database) {
    taskDatabase = TaskSyncDatabase(database);

    taskDatabase?.stream.listen((event) async {
      // print('Received data from TaskSyncDatabase: $event');

      // Check if the event is not empty
      if (event.isNotEmpty) {
        for (var data in event) {
          try {
            // Print the type of "data['data']" to ensure it is a JSON object (Map) not a list
            // print("Type of data['data']: ${data['data'].runtimeType}");

            // Attempt to decode "data['data']" into a Map
            Map<String, dynamic> taskData;
            if (data['data'] is String) {
              taskData = json.decode(data['data']);
            } else if (data['data'] is Map) {
              taskData = data['data'];
            } else {
              print("Error: Unsupported data type");
              continue;
            }

            taskData.forEach((key, value) {
              debugPrint('$key: $value');
            });

            // Check if critical keys are null
            if (data['task_name'] == null) {
              //print("task_name is null");
              continue;
            }
            if (data['id'] == null) {
              //print("id is null");
              continue;
            }
            if (taskData['access_token'] == null) {
              // print("access_token is null");
              continue;
            }

            // Print task_name and task_type for debugging
            //print("Task Name: ${data['task_name']}, Task Type: ${data['task_type']}");

            if (data['task_name'] == 'delivery') {
              //await postDataToApi(data['id'], taskData['access_token'], taskData);
            } else if (data['task_name'] == 'update time') {
              await timeUpdateToApi(
                  data['id'], taskData['access_token'], taskData);
            } else if (data['task_type'] == 'reorder') {
              await reorder(data['id'], taskData['access_token'], taskData);
            } else {
              print('Unknown task type or name, skipping...');
            }
          } catch (e) {
            print('Error processing task: $e');
          }
        }
      } else {
        print('No data in TaskSyncDatabase to process.');
      }
    });
  }

  // Stop syncing data
  void stopSync(Database database) {
    taskDatabase?.dispose();
  }

  // Handle reorder API call
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

      //print('Reorder API response code: ${response.statusCode}');

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        String status = responseData['status'];
        //print('Reorder API response: $responseData');

        if (status == 'success') {
          //print('Reorder successful, deleting task from local database.');
          taskDatabase?.delete(taskId);
        } else {
          print(
              'Reorder failed with status: $status, Message: ${responseData['msg']}');
        }
      } else {
        print(
            'Reorder API failed with status code: ${response.statusCode} and response: ${response.body}');
      }
    } catch (e) {
      print('Error during reorder API call: $e');
    }
  }

  // Handle time update API call
  Future<void> timeUpdateToApi(int taskId, String accessToken, var data) async {
    try {
      final response = await http.post(
        Uri.parse(AppHost.updatetime),
        body: jsonEncode(data),
        headers: <String, String>{
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        String status = responseData['status'];

        if (status == 'success') {
          taskDatabase?.delete(taskId);
        } else {
          // print('Time update failed with status: $status, Message: ${responseData['msg']}');
        }
      } else {
        print(
            'Time update API failed with status code: ${response.statusCode} and response: ${response.body}');
      }
    } catch (e) {
      print('Error during time update API call: $e');
    }
  }

  // Future<void> postDataToApi(
  //     int taskId, String accessToken, var requesttaskBody) async {
  //   try {
  //     final int podType =
  //         requesttaskBody['pod_type'] ?? -1; // Default to -1 if null
  //     final String consignmentId =
  //         requesttaskBody['consignment_id']?.toString() ??
  //             ''; // Convert to String, provide fallback if null
  //     final accesToken = requesttaskBody['access_token'];
  //     if (consignmentId.isEmpty) {
  //       throw Exception('Invalid consignment ID');
  //     }
  //
  //     String url = '';
  //
  //     // URL generation based on pod_type
  //     switch (podType) {
  //       case 0:
  //         url = '${AppHost.podfull}$consignmentId';
  //         break;
  //       case 2:
  //         url = AppHost.group;
  //         break;
  //       case 5:
  //         url = AppHost.grouppop;
  //         break;
  //       case 4:
  //         url = '${AppHost.singlepop}$consignmentId';
  //         break;
  //       case 1:
  //         url = '${AppHost.podpartial}$consignmentId';
  //         break;
  //       case 3:
  //         List<String> rejectionReasons =
  //             requesttaskBody['rejectionReasons'] ?? [];
  //         for (String rejectionReason in rejectionReasons) {
  //           switch (rejectionReason) {
  //             case "Temperature issue":
  //               url = '${AppHost.temperateissue}$consignmentId';
  //               break;
  //             case "Wrong Address":
  //               url = '${AppHost.wrongaddress}$consignmentId';
  //               break;
  //             case "Damaged Goods":
  //               url = '${AppHost.damagegoods}$consignmentId';
  //               break;
  //             case "Receiver Not Open":
  //               url = '${AppHost.notopen}$consignmentId';
  //               break;
  //             case "Other Rejection":
  //               url = '${AppHost.otherrejection}$consignmentId';
  //               break;
  //             default:
  //               throw Exception('Invalid rejection reason: $rejectionReason');
  //           }
  //         }
  //         break;
  //       default:
  //         throw Exception('Invalid pod_type: $podType');
  //     }
  //
  //     // Request body construction with null safety
  //     final requestBody = {
  //       "carton": requesttaskBody['carton'],
  //       "pallet": requesttaskBody['pallet'],
  //       "space": requesttaskBody['space'],
  //       "weigth": requesttaskBody['weight'],
  //       "first_name": requesttaskBody['first_name'],
  //       "last_name": requesttaskBody['last_name'],
  //       "temperature": requesttaskBody['temperature'],
  //       "signature": requesttaskBody['signature'],
  //       "comments": requesttaskBody['comments'],
  //       "service_window": requesttaskBody['service_window'],
  //       "service_time_start": requesttaskBody['service_time_start'],
  //       "service_time_end": requesttaskBody['service_time_end'],
  //       "address_id": requesttaskBody['address_id'],
  //       "pod_type": podType,
  //       "customer_reference": requesttaskBody['customer_reference'],
  //       "pictures": [requesttaskBody['pictures']],
  //       "pictureSources": jsonDecode(requesttaskBody['pictureSources']),
  //       "latitude": requesttaskBody['latitude'],
  //       "longitude": requesttaskBody['longitude'],
  //       "consignments": jsonDecode(requesttaskBody['consignments']),
  //       "device": jsonDecode(requesttaskBody['device']),
  //       "app_version": requesttaskBody['app_version'],
  //       "driver_id": requesttaskBody['driver_id'],
  //       "date_delivered": requesttaskBody['date_delivered'],
  //       "platforms": jsonDecode(requesttaskBody['platforms']),
  //       "current_app_version": requesttaskBody['current_app_version'],
  //     };
  //
  //     final response = await http.post(
  //       Uri.parse(url),
  //       body: jsonEncode(requestBody),
  //       headers: <String, String>{
  //         'Authorization': 'Bearer $accesToken',
  //         'Content-Type': 'application/json',
  //         'Accept': 'application/json',
  //       },
  //     );
  //
  //     // Log the response
  //     print("Response status code: ${response.statusCode}");
  //     print("Response body: ${response.body}");
  //
  //     if (response.statusCode == 200) {
  //       var responseData = json.decode(response.body);
  //       if (responseData['status'] == 'success') {
  //         taskDatabase?.delete(taskId);
  //         print("Task deleted from local database.");
  //       } else {
  //         print("API responded with failure: ${responseData['msg']}");
  //       }
  //     } else {
  //       print(
  //           "Failed to post data to API. Status code: ${response.statusCode}, Response: ${response.body}");
  //     }
  //   } catch (e) {
  //     print("Error posting data to API: $e");
  //   }
  // }
}
