
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:coldxpress/export.dart';

// class TaskSyncProvider with ChangeNotifier {
//   TaskSyncDatabase? taskDatabase;

//   void checkInternetConnectivity(Database database) async {
//     Connectivity()
//         .onConnectivityChanged
//         .listen((List<ConnectivityResult> results) {
//       if (results.contains(ConnectivityResult.mobile) ||
//           results.contains(ConnectivityResult.wifi)) {
//         startSync(database);
//       } else {
//         stopSync(database);
//       }
//     });
//   }

//   // Start syncing data from TaskSyncDatabase
// void startSync(Database database) {
//   print('Starting sync...');
//   taskDatabase = TaskSyncDatabase(database);

//   taskDatabase?.stream.listen((event) async {
//     print('Received data from TaskSyncDatabase: $event');

//     // Check if the event is not empty
//     if (event.isNotEmpty) {
//       for (var data in event) {
//         print('Processing data: $data');
//         try {
//           // Print the type of "data['data']" to ensure it is a JSON object (Map) not a list
//           print("Type of data['data']: ${data['data'].runtimeType}");
          
//           // Attempt to decode "data['data']" into a Map
//           Map<String, dynamic> taskData;
//           if (data['data'] is String) {
//             taskData = json.decode(data['data']);
//           } else if (data['data'] is Map) {
//             taskData = data['data'];
//           } else {
//             print("Error: Unsupported data type");
//             continue;
//           }

//           taskData.forEach((key, value) {
//             debugPrint('$key: $value');
//           });

//           // Check if critical keys are null
//           if (data['task_name'] == null) {
//             print("task_name is null");
//             continue;
//           }
//           if (data['id'] == null) {
//             print("id is null");
//             continue;
//           }
//           if (taskData['access_token'] == null) {
//             print("access_token is null");
//             continue;
//           }

//           // Print task_name and task_type for debugging
//           print("Task Name: ${data['task_name']}, Task Type: ${data['task_type']}");

//           if (data['task_name'] == 'delivery') {
//             await postDataToApi(data['id'], taskData['access_token'], taskData);
//           } else if (data['task_name'] == 'update time') {
//             await timeUpdateToApi(data['id'], taskData['access_token'], taskData);
//           } else if (data['task_type'] == 'reorder') {
//             await reorder(data['id'], taskData['access_token'], taskData);
//           } else {
//             print('Unknown task type or name, skipping...');
//           }

//         } catch (e) {
//           print('Error processing task: $e');
//         }
//       }
//     } else {
//     //  print('No data in TaskSyncDatabase to process.');
//     }
//   });
// }

//   // Stop syncing data
//   void stopSync(Database database) {
//     print('Stopping sync...');
//     taskDatabase?.dispose();
//   }

//   // Handle reorder API call
//   Future<void> reorder(int taskId, String accessToken, var data) async {
//     try {
//       print('Attempting reorder API call with data: $data');
      
//       final response = await http.post(
//         Uri.parse(AppHost.reorderConsignments),
//         body: jsonEncode(data),
//         headers: <String, String>{
//           'Authorization': 'Bearer $accessToken',
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//         },
//       );

//       print('Reorder API response code: ${response.statusCode}');
      
//       if (response.statusCode == 200) {
//         var responseData = json.decode(response.body);
//         String status = responseData['status'];
//         print('Reorder API response: $responseData');
        
//         if (status == 'success') {
//           print('Reorder successful, deleting task from local database.');
//           taskDatabase?.delete(taskId);
//         } else {
//           print('Reorder failed with status: $status, Message: ${responseData['msg']}');
//         }
//       } else {
//         print('Reorder API failed with status code: ${response.statusCode} and response: ${response.body}');
//       }
//     } catch (e) {
//       print('Error during reorder API call: $e');
//     }
//   }

//   // Handle time update API call
//   Future<void> timeUpdateToApi(int taskId, String accessToken, var data) async {
//     try {
//       print('Attempting timeUpdate API call with data: $data');
      
//       final response = await http.post(
//         Uri.parse(AppHost.updatetime),
//         body: jsonEncode(data),
//         headers: <String, String>{
//           'Authorization': 'Bearer $accessToken',
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//         },
//       );

//       print('Time update API response code: ${response.statusCode}');
      
//       if (response.statusCode == 200) {
//         var responseData = json.decode(response.body);
//         String status = responseData['status'];
//         print('Time update API response: $responseData');
        
//         if (status == 'success') {
//           print('Time update successful, deleting task from local database.');
//           taskDatabase?.delete(taskId);
//         } else {
//           print('Time update failed with status: $status, Message: ${responseData['msg']}');
//         }
//       } else {
//         print('Time update API failed with status code: ${response.statusCode} and response: ${response.body}');
//       }
//     } catch (e) {
//       print('Error during time update API call: $e');
//     }
//   }
// Future<void> postDataToApi(int taskId, String accessToken, var requesttaskBody) async {
//   try {
//     print("Starting to process data for API call...");

//     final int podType = int.tryParse(requesttaskBody['pod_type'].toString()) ?? -1; // Ensure podType is int
//     final String consignmentId = requesttaskBody['consignment_id']?.toString() ?? ''; // Ensure consignmentId is a String
//     final accesToken = requesttaskBody['access_token'];
//     print("i am podtype which is listed: ${podType}");

//     if (consignmentId.isEmpty) {
//       throw Exception('Invalid consignment ID');
//     }

//     String url = '';

//     // URL generation based on pod_type and rejection reason when podType == 3
//     if (podType == 3) {
//       // Ensure rejectionReasons exists and is a list
//       String rejectionReasons = requesttaskBody['rejection_reason'];
      
//      switch (rejectionReasons) {
//         case "Temperature issue":
//           url = '${AppHost.temperateissue}$consignmentId';
//           break;
//         case "Wrong Address":
//           url = '${AppHost.wrongaddress}$consignmentId';
//           break;
//         case "Damaged Goods":
//           url = '${AppHost.damagegoods}$consignmentId';
//           break;
//         case "Receiver Not Open":
//           url = '${AppHost.notopen}$consignmentId';
//           break;
//         case "Other Rejection":
//           url = '${AppHost.otherrejection}$consignmentId';
//           break;
//         default:
//           // If no valid rejection reason is provided, handle it with a default or skip
//           print('Unknown or missing rejection reason: $rejectionReasons. Using default rejection reason.');
//           url = '${AppHost.otherrejection}$consignmentId';
//           break;
//       }
//     }   else {
//       switch (podType) {
//         case 0:
//           url = '${AppHost.podfull}$consignmentId';
//           break;
//         case 2:
//           url = AppHost.group;
//           break;
//         case 5:
//           url = AppHost.grouppop;
//           break;
//         case 4:
//           url = '${AppHost.singlepop}$consignmentId';
//           break;
//         case 1:
//           url = '${AppHost.podpartial}$consignmentId';
//           break;
//         default:
//           throw Exception('Invalid pod_type: $podType');
//       }
//     }
//      final requestBody = {
//        "carton": requesttaskBody['carton'],
//           "pallet": requesttaskBody['pallet'],
//           "space": requesttaskBody['space'],
//           "weigth": requesttaskBody['weight'],
//           "first_name": requesttaskBody['first_name'],
//           "last_name": requesttaskBody['last_name'],
//           "temperature": requesttaskBody['temperature'],
//           "signature": requesttaskBody['signature'],
//           "comments":requesttaskBody['comments'],
//           "service_window": requesttaskBody['service_window'],
//           "service_time_start": requesttaskBody['service_time_start'],
//           "service_time_end":requesttaskBody['service_time_end'],
//           "address_id":requesttaskBody['address_id'],
//           "pod_type": podType,
//           "customer_reference": requesttaskBody['customer_reference'],
//           "pictures": [requesttaskBody['pictures']],
//           "pictureSources": jsonDecode(requesttaskBody['pictureSources']),
//           "latitude": requesttaskBody['latitude'],
//           "longitude": requesttaskBody['longitude'],
//           "consignments": jsonDecode(requesttaskBody['consignments']),
//           "device": jsonDecode(requesttaskBody['device']),
//           "app_version": requesttaskBody['app_version'],
//           "driver_id": requesttaskBody['driver_id'],
//           "date_delivered": requesttaskBody['date_delivered'],
//           "platforms": jsonDecode(requesttaskBody['platforms']),
//           "current_app_version": requesttaskBody['current_app_version'],
//     };
//     final requestBody2 = {
//       "error_type": int.tryParse(requesttaskBody['error_type']?.toString() ?? '') ?? 0,
//       "rejection_reason": requesttaskBody['rejection_reason'] ?? '',
//       "comments": requesttaskBody['comments'] ?? '',
//       "record_error": true, 
//       "adhoc_charges": false,
//       "pod_type": podType, 
//       "customer_reference":  requesttaskBody['customer_reference'] ?? '',
//       "space": int.tryParse(requesttaskBody['space']?.toString() ?? '') ?? 0, 
//       "weight": int.tryParse(requesttaskBody['weight']?.toString() ?? '') ?? 0, 
//       "consignment_id": consignmentId, 
//       "device": jsonDecode(requesttaskBody['device']), 
//       "date_delivered": DateTime.now().toIso8601String(), 
//       "driver_id": int.tryParse(requesttaskBody['driver_id']?.toString() ?? '') ?? 0,
//       "first_name": requesttaskBody['first_name'] ?? "", 
//       "last_name": requesttaskBody['last_name'] ?? "",
//       "customer_probe_temp": int.tryParse(requesttaskBody['customer_probe_temp']?.toString() ?? '') ?? 0, 
//       "driver_probe_temp": int.tryParse(requesttaskBody['driver_probe_temp']?.toString() ?? '') ?? 0,
//       "driver_infrared_temp": int.tryParse(requesttaskBody['driver_infrared_temp']?.toString() ?? '') ?? 0, 
//       "where_temp_checked": requesttaskBody['where_temp_checked'] ?? "",
//       "customer_probe_checked": requesttaskBody['customer_probe_checked'] ?? '', 
//       "customer_probe_why": requesttaskBody['customer_probe_why'] ?? '', 
//       "pictures": jsonDecode(requesttaskBody['pictures'] ?? [],),  
//       "pictureSources":jsonDecode(requesttaskBody['pictureSources'] ?? [],), 
//       "app_version": int.tryParse(requesttaskBody['app_version']?.toString() ?? '') ?? 0, 
//       "current_app_version": int.tryParse(requesttaskBody['current_app_version']?.toString() ?? '') ?? 0, 
//       "platforms": jsonDecode(requesttaskBody['platforms'] ?? [],),  
//     };

//     // Debugging: Print the constructed request body to verify its content
//     print("Request body: ${jsonEncode(requestBody)}");
// final body = podType == 3 ? jsonEncode(requestBody2) : jsonEncode(requestBody);
//     // Perform the API call
//     final response = await http.post(
//       Uri.parse(url),
//         body: body,
//       headers: <String, String>{
//         'Authorization': 'Bearer $accesToken',
//         'Content-Type': 'application/json',
//         'Accept': 'application/json',
//       },
//     );

//     // Log the response
//     print("Response status code: ${response.statusCode}");
//     print("Response body: ${response.body}");

//     if (response.statusCode == 200) {
//       var responseData = json.decode(response.body);
//       if (responseData['status'] == 'success') {
//         taskDatabase?.delete(taskId);
//         print("Task deleted from local database.");
        
//       } else {
//         print("API responded with failure: ${responseData['msg']}");
//       }
//     } else {
//       print("Failed to post data to API. Status code: ${response.statusCode}, Response: ${response.body}");
//     }
//   } catch (e) {
//     print("Error posting data to API: $e");
//   }
// }

// }


import 'dart:convert';
import 'package:coldxpress/providers/proof-of-delivery-provider.dart';
import 'package:coldxpress/views/tabs/consignments/sub_views/proof_of_delivery_photos.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:coldxpress/export.dart';
import 'package:path/path.dart';

class TaskSyncProvider with ChangeNotifier {
  TaskSyncDatabase? taskDatabase;

  void checkInternetConnectivity(Database database, BuildContext context) async {
    Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      if (results.contains(ConnectivityResult.mobile) ||
          results.contains(ConnectivityResult.wifi)) {
        startSync(database,context);
      } else {
        stopSync(database);
      }
    });
  }

  // Start syncing data from TaskSyncDatabase
 void startSync(Database database, BuildContext context) {
    print('Starting sync...');
    taskDatabase = TaskSyncDatabase(database);

    taskDatabase?.stream.listen((event) async {
     // print('Received data from TaskSyncDatabase: $event');

      // Check if the event is not empty
      if (event.isNotEmpty) {
        for (var data in event) {
       //   print('Processing data: $data');
          try {
            // Ensure the data['data'] is a valid JSON object (Map)
           // print("Type of data['data']: ${data['data'].runtimeType}");

            Map<String, dynamic> taskData;
            if (data['data'] is String) {
              taskData = json.decode(data['data']);
            } else if (data['data'] is Map) {
              taskData = data['data'];
            } else {
              print("Error: Unsupported data type");
              continue;
            }

            // taskData.forEach((key, value) {
            //   debugPrint('$key: $value');
            // });

            // Check if critical keys are null
            if (data['task_name'] == null || data['id'] == null || taskData['access_token'] == null) {
              print("Missing critical data: task_name, id, or access_token is null.");
              continue;
            }

            // Only post if is_sync is false
            if (data['is_sync'] == 'false') {
          //    print("Task Name: ${data['task_name']}, Task Type: ${data['task_type']}");
              if (data['task_name'] == 'delivery') {
               await postDataToApi(data['id'], taskData['access_token'], taskData, context);
              } else {
                print('Unknown task type or name, skipping...');
              }
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
    print('Stopping sync...');
    taskDatabase?.dispose();
  }




  Future<void> postDataToApi(int taskId, String accessToken, var requesttaskBody,BuildContext context) async {
  try {
    print("Starting to process data for API call...");

    final int podType = int.tryParse(requesttaskBody['pod_type'].toString()) ?? -1; // Ensure podType is int
    final String consignmentId = requesttaskBody['consignment_id']?.toString() ?? ''; // Ensure consignmentId is a String
    final accesToken = requesttaskBody['access_token'];
     final isGroup = requesttaskBody['is_group'];
    print("i am podtype which is listed: ${podType}");

    if (consignmentId.isEmpty) {
      throw Exception('Invalid consignment ID');
    }

    String url = '';

    // URL generation based on pod_type and rejection reason when podType == 3
    if (podType == 3) {
      // Ensure rejectionReasons exists and is a list
      String rejectionReasons = requesttaskBody['rejection_reason'];
      
     switch (rejectionReasons) {
        case "Temperature issue":
          url = '${AppHost.temperateissue}$consignmentId';
          break;
        case "Wrong Address":
          url = '${AppHost.wrongaddress}$consignmentId';
          break;
        case "Damaged Goods":
          url = '${AppHost.damagegoods}$consignmentId';
          break;
        case "Receiver Not Open":
          url = '${AppHost.notopen}$consignmentId';
          break;
        case "Other Rejection":
          url = '${AppHost.otherrejection}$consignmentId';
          break;
        default:
          // If no valid rejection reason is provided, handle it with a default or skip
          print('Unknown or missing rejection reason: $rejectionReasons. Using default rejection reason.');
          url = '${AppHost.otherrejection}$consignmentId';
          break;
      }
    }   else {
      switch (podType) {
        case 0:
          url = '${AppHost.podfull}$consignmentId';
          break;
        case 2:
          url = AppHost.group;
          break;
        case 5:
          url = AppHost.grouppop;
          break;
        case 4:
          url = '${AppHost.singlepop}$consignmentId';
          break;
        case 1:
          url = '${AppHost.podpartial}$consignmentId';
          break;
        default:
          throw Exception('Invalid pod_type: $podType');
      }
    }
     final requestBody = {
       "carton": requesttaskBody['carton'],
          "pallet": requesttaskBody['pallet'],
          "space": requesttaskBody['space'],
          "weigth": requesttaskBody['weight'],
          "first_name": requesttaskBody['first_name'],
          "last_name": requesttaskBody['last_name'],
          "temperature": requesttaskBody['temperature'],
          "signature": requesttaskBody['signature'],
          "comments":requesttaskBody['comments'],
          "service_window": requesttaskBody['service_window'],
          "service_time_start": requesttaskBody['service_time_start'],
          "service_time_end":requesttaskBody['service_time_end'],
          "address_id":requesttaskBody['address_id'],
          "pod_type": podType,
          "customer_reference": requesttaskBody['customer_reference'],
          "pictures": [requesttaskBody['pictures']],
          "pictureSources": jsonDecode(requesttaskBody['pictureSources']),
          "latitude": requesttaskBody['latitude'],
          "longitude": requesttaskBody['longitude'],
          "consignments": jsonDecode(requesttaskBody['consignments']),
          "device": jsonDecode(requesttaskBody['device']),
          "app_version": requesttaskBody['app_version'],
          "driver_id": requesttaskBody['driver_id'],
          "date_delivered": requesttaskBody['date_delivered'],
          "platforms": jsonDecode(requesttaskBody['platforms']),
          "current_app_version": requesttaskBody['current_app_version'],
    };
    final requestBody2 = {
      "error_type": int.tryParse(requesttaskBody['error_type']?.toString() ?? '') ?? 0,
      "rejection_reason": requesttaskBody['rejection_reason'] ?? '',
      "comments": requesttaskBody['comments'] ?? '',
      "record_error": true, 
      "adhoc_charges": false,
      "pod_type": podType, 
      "customer_reference":  requesttaskBody['customer_reference'] ?? '',
      "space": int.tryParse(requesttaskBody['space']?.toString() ?? '') ?? 0, 
      "weight": int.tryParse(requesttaskBody['weight']?.toString() ?? '') ?? 0, 
      "consignment_id": consignmentId, 
      "device": jsonDecode(requesttaskBody['device']), 
      "date_delivered": DateTime.now().toIso8601String(), 
      "driver_id": int.tryParse(requesttaskBody['driver_id']?.toString() ?? '') ?? 0,
      "first_name": requesttaskBody['first_name'] ?? "", 
      "last_name": requesttaskBody['last_name'] ?? "",
      "customer_probe_temp": int.tryParse(requesttaskBody['customer_probe_temp']?.toString() ?? '') ?? 0, 
      "driver_probe_temp": int.tryParse(requesttaskBody['driver_probe_temp']?.toString() ?? '') ?? 0,
      "driver_infrared_temp": int.tryParse(requesttaskBody['driver_infrared_temp']?.toString() ?? '') ?? 0, 
      "where_temp_checked": requesttaskBody['where_temp_checked'] ?? "",
      "customer_probe_checked": requesttaskBody['customer_probe_checked'] ?? '', 
      "customer_probe_why": requesttaskBody['customer_probe_why'] ?? '', 
      "pictures": jsonDecode(requesttaskBody['pictures'] ?? [],),  
      "pictureSources":jsonDecode(requesttaskBody['pictureSources'] ?? [],), 
      "app_version": int.tryParse(requesttaskBody['app_version']?.toString() ?? '') ?? 0, 
      "current_app_version": int.tryParse(requesttaskBody['current_app_version']?.toString() ?? '') ?? 0, 
      "platforms": jsonDecode(requesttaskBody['platforms'] ?? [],),  
    };

    // Debugging: Print the constructed request body to verify its content
   // print("Request body: ${jsonEncode(requestBody)}");
final body = podType == 3 ? jsonEncode(requestBody2) : jsonEncode(requestBody);
    // Perform the API call
    final response = await http.post(
      Uri.parse(url),
        body: body,
      headers: <String, String>{
        'Authorization': 'Bearer $accesToken',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    // Log the response
    print("Response status code: ${response.statusCode}");
    print("Response body: ${response.body}");

    if (response.statusCode == 200) {
      var responseData = json.decode(response.body);
      if (responseData['status'] == 'success') {
         await taskDatabase?.update(taskId, {'is_sync': 'true'});
        print("Task deleted from local database.");
           if (isGroup != null && isGroup != 'parent') {
            await submitGroupAsIndividual(int.parse(isGroup),context);
            await addNewConsignment(Get.arguments,context);
          }
      } else {
        print("API responded with failure: ${responseData['msg']}");
      }
    } else {
      print("Failed to post data to API. Status code: ${response.statusCode}, Response: ${response.body}");
    }
  } catch (e) {
    print("Error posting data to API: $e");
  }
}
  Future<void> submitGroupAsIndividual(int id,BuildContext context) async {
    List<Map<String, dynamic>> individualConsignments = [];
    int carton = 0;
    int pallet = 0;
    int space = 0;
    double weight = 0.0;

    await ConsignmentDatabase(context.read<DatabaseProvider>().database)
        .readById(id)
        .then((value) async {
      Map<String, dynamic> consignment = value.first;
      if (consignment['grouped_consignments'] != null) {
        groupedConsignments = json.decode(consignment['grouped_consignments']);
      }

      await Future.forEach(groupedConsignments, (element) async {
        await ConsignmentDatabase(context.read<DatabaseProvider>().database)
            .readById(element['id'])
            .then((value) {
          individualConsignments.add(value.first);
        });
      });

      for (var element in individualConsignments) {
        element['quantity'] = consignment['quantity'];
        element['status'] = 3;
        element['weight'] = consignment['weight'];
        element['comment'] = consignment['comment'];
        element['carton'] = consignment['carton'];
        element['pallet'] = consignment['pallet'];
        element['space'] = consignment['space'];
        element['pod_type'] = consignment['pod_type'];
        await ConsignmentDatabase(context.read<DatabaseProvider>().database)
            .update(element['id'], element);
      }
    });

    final updatedConsignment = {
      'id': id,
      'carton': carton,
      'pallet': pallet,
      'space': space,
      'weight': weight,
      'grouped_consignments': '',
      'status': 3,
    };
    await ConsignmentDatabase(context.read<DatabaseProvider>().database)
        .update(id, updatedConsignment);
  }

  Future<void> addNewConsignment(Map consignmentDetails,BuildContext context) async {
    final provider = context.read<ProofOfDeliveryProvider>();
    final newConsignment = {
      'id': consignmentDetails['id'],
      'carton': 0,
      'pallet': 0,
      'space': 0,
      'weight': 0,
      'grouped_consignments': '',
      'status': 1,
      'comment': '',
      'signature': '',
      'pod_type': provider.selectedDeliveryType.toString().split('.').last,
      'date': DateFormat('dd/MM/yyyy').format(DateTime.now()),
    };
    await ConsignmentDatabase(context.read<DatabaseProvider>().database)
        .create(newConsignment);
  }

}