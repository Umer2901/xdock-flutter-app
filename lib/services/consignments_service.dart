// import 'dart:io';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:sqflite/sqflite.dart';
// import 'package:intl/intl.dart';
// import 'package:coldxpress/constants/host.dart';

// class ConsignmentService {
//   final Database _database;

//   ConsignmentService(this._database);

//   Future<void> fetchAndStore(String accessToken) async {
//     var connectivityResult = await InternetAddress.lookup('google.com');
//     if (connectivityResult.isEmpty || connectivityResult[0].rawAddress.isEmpty) {
//       throw Exception('No Internet Connection');
//     }

//     final response = await http.get(
//       Uri.parse(AppHost.consignments),
//       headers: {
//         'Authorization': 'Bearer $accessToken',
//         'Content-Type': 'application/json',
//         'Accept': 'application/json',
//       },
//     );

//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       if (data['status'] == 'success') {
//         await _database.transaction((txn) async {
//           await _processData(txn, data['data'], accessToken);
//         });
//       } else {
//         throw Exception('Failed to fetch data: ${data['message']}');
//       }
//     } else {
//       throw Exception('Failed to fetch data with status code: ${response.statusCode}');
//     }
//   }

//   Future<void> _processData(Transaction txn, Map<String, dynamic> dataByDate, String accessToken) async {
//     for (var date in dataByDate.keys) {
//       var submissionData = dataByDate[date]['consignments'];
//       for (var dataIteration in submissionData) {
//         dataIteration['delivery_addresses'] = json.encode(dataIteration['delivery_addresses']);
//         dataIteration['pickup_addresses'] = json.encode(dataIteration['pickup_addresses']);
//         dataIteration['delivery_runs'] = json.encode(dataIteration['delivery_runs']);
//         dataIteration['customers'] = json.encode(dataIteration['customers']);
//         dataIteration['product_types'] = json.encode(dataIteration['product_types']);
//         dataIteration['run_sheets'] = json.encode(dataIteration['run_sheets']);
//         dataIteration['consignment_pallets'] = json.encode(dataIteration['consignment_pallets']);
//         dataIteration['grouped_consignments'] = dataIteration.containsKey('grouped_consignments') ?
//                                                json.encode(dataIteration['grouped_consignments']) : null;
//         dataIteration['datetime'] = DateFormat('dd/MM/yyyy').format(DateTime.now());
//         dataIteration['is_complete'] = 0;
//         dataIteration['access_token'] = accessToken;

//         List consignment = await txn.query(
//           'consignments',
//           where: 'id = ?',
//           whereArgs: [dataIteration['id']]
//         );

//         if (consignment.isEmpty) {
//           await txn.insert('consignments', dataIteration);
//         } else {
//           await txn.update(
//             'consignments',
//             dataIteration,
//             where: 'id = ?',
//             whereArgs: [dataIteration['id']]
//           );
//         }
//       }
//     }
//   }
//  Future<void> reorderConsignments(List<int> consignmentIds, String accessToken) async {
//     await _database.transaction((txn) async {
//       List<Map> tables = await txn.rawQuery("SELECT name FROM sqlite_master WHERE type='table' AND name='sync_task'");
//       print("Checking table existence: $tables");
      
//       if (tables.isNotEmpty) {
//         for (var id in consignmentIds) {
//           await txn.update(
//             'consignments',
//             {'sort': consignmentIds.indexOf(id) + 1},
//             where: 'id = ?',
//             whereArgs: [id]
//           );
//         }

//         await txn.insert('sync_task', {
//           'task_name': 'Re-order Consignments',
//           'task_type': 'reorder',
//           'data': json.encode({DateFormat('yyyy-MM-dd').format(DateTime.now()): consignmentIds}),
//           'access_token': accessToken
//         });
//         print('Reorder saved to sync_task');
//          List<Map> syncTaskData = await txn.rawQuery('SELECT * FROM sync_task');
//       print('Data in sync_task table: $syncTaskData');
//       } else {
//         print("Table sync_task does not exist. Check your database initialization.");
//       }
//     });
//   }
// }
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';
import 'package:coldxpress/constants/host.dart';

class ConsignmentService {
  final Database _database;

  ConsignmentService(this._database);
  final List<String> allowedFields = [
    'id',
    'invoice_id',
    'driver_invoice_id',
    'removed_from_driver_invoice',
    'sale_order_id',
    'customer_reference',
    'barcode',
    'consignment_type',
    'multi_leg',
    'carton',
    'pallet',
    'space',
    'weight',
    'hand_unload_fee_applied',
    'invoice_value',
    'comment',
    'status',
    'date_delivered',
    'manifest_id',
    'rate_zone_id',
    'manually_assigned_rate_zone',
    'cash_on_delivery',
    'complete_cod',
    'cod_value',
    'cod_requirement',
    'delivery_date',
    'required_delivery_date',
    'special_instruction',
    'save_special_instruction',
    'confirm',
    'finalize',
    'end_date',
    'next_date',
    'repeat_every',
    'repeat_count',
    'is_repeat',
    'no_charge',
    'parent_repeat_id',
    'created_at',
    'is_group',
    'sort_arrival',
    'delivery_address_string_id',
    'pickup_address_string_id',
    'cc_consignment_id',
    'is_printed',
    'signature',
    'temperature',
    'recevied_by_name',
    'runsheet_id',
    'sort',
    'osrm_sort',
    'osrm_eta',
    'original_carton',
    'original_pallet',
    'original_space',
    'original_weight',
    'validated',
    'grouping_flag',
    'pop_temperature',
    'pop_recevied_by_name',
    'pop_signature',
    'date_picked',
    'is_unassigned',
    'deleted_at',
    'loadsheet_pallet_id',
    'delivery_addresses',
    'pickup_addresses',
    'delivery_runs',
    'customers',
    'product_types',
    'run_sheets',
    'consignment_pallets',
    'grouped_consignments',
    'total_grouped_consignments',
    'customer_id',
    'product_type_id',
    'delivery_run_id',
    'pickup_address',
    'delivery_address',
    'datetime',
    'access_token',
    'address_grouping',
    'required_delivery_time',
    'is_complete'
  ];

  // Helper method to filter data fields
  Map<String, dynamic> filterFields(Map<String, dynamic> data) {
    return Map.fromEntries(data.entries.where((entry) {
      return allowedFields.contains(entry.key);
    }));
  }

  // Method to fetch and store consignments from the API
  Future<void> fetchAndStore(String accessToken) async {
    var connectivityResult = await InternetAddress.lookup('google.com');
    if (connectivityResult.isEmpty || connectivityResult[0].rawAddress.isEmpty) {
      throw Exception('No Internet Connection');
    }

    final response = await http.get(
      Uri.parse(AppHost.consignments),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'success') {
        await _database.transaction((txn) async {
          await _processData(txn, data['data'], accessToken);
        });
      } else {
        throw Exception('Failed to fetch data: ${data['message']}');
      }
    } else {
      throw Exception('Failed to fetch data with status code: ${response.statusCode}');
    }
  }

  Future<void> _processData(Transaction txn, Map<String, dynamic> dataByDate, String accessToken) async {
    for (var date in dataByDate.keys) {
      var submissionData = dataByDate[date]['consignments'];
      for (var dataIteration in submissionData) {
        var filteredData = filterFields(dataIteration);
        filteredData['delivery_addresses'] = json.encode(filteredData['delivery_addresses']);
        filteredData['pickup_addresses'] = json.encode(filteredData['pickup_addresses']);
        filteredData['delivery_runs'] = json.encode(filteredData['delivery_runs']);
        filteredData['customers'] = json.encode(filteredData['customers']);
        filteredData['product_types'] = json.encode(filteredData['product_types']);
        filteredData['run_sheets'] = json.encode(filteredData['run_sheets']);
        filteredData['consignment_pallets'] = json.encode(filteredData['consignment_pallets']);
        filteredData['grouped_consignments'] = filteredData.containsKey('grouped_consignments')
            ? json.encode(filteredData['grouped_consignments'])
            : null;
        filteredData['datetime'] = DateFormat('dd/MM/yyyy').format(DateTime.now());
        filteredData['is_complete'] = 0;
        filteredData['access_token'] = accessToken;

        List consignment = await txn.query(
          'consignments',
          where: 'id = ?',
          whereArgs: [filteredData['id']]
        );

        if (consignment.isEmpty) {
          await txn.insert('consignments', filteredData);
        } else {
          await txn.update(
            'consignments',
            filteredData,
            where: 'id = ?',
            whereArgs: [filteredData['id']]
          );
        }
      }
    }
  }

Future<void> sendReorderedConsignments(
      Map<String, List<int>> finalConsignments, String accessToken) async {
    try {
      print('Sending reorder API request with data: $finalConsignments');

      final response = await http.post(
        Uri.parse(AppHost.reorderConsignments), // Use the correct API endpoint
        body: jsonEncode(finalConsignments),
        headers: <String, String>{
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('Reorder API response code: ${response.statusCode}');

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        String status = responseData['status'];
        print('Reorder API response: $responseData');

        if (status == 'success') {
          print('Reorder successful.');
        } else {
          print('Reorder failed with status: $status, Message: ${responseData['msg']}');
        }
      } else {
        print('Reorder API failed with status code: ${response.statusCode} and response: ${response.body}');
      }
    } catch (e) {
      print('Error during reorder API call: $e');
    }
  }

}