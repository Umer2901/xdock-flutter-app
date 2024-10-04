// import 'dart:io';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:sqflite/sqflite.dart';
// import 'package:intl/intl.dart';
// import 'package:coldxpress/constants/host.dart';

// class ConsignmentService {
//   final Database _database;

//   ConsignmentService(this._database);

//   final List<String> allowedFields = [
//     'id',
//     'invoice_id',
//     'driver_invoice_id',
//     'removed_from_driver_invoice',
//     'sale_order_id',
//     'customer_reference',
//     'barcode',
//     'consignment_type',
//     'multi_leg',
//     'carton',
//     'pallet',
//     'space',
//     'weight',
//     'hand_unload_fee_applied',
//     'invoice_value',
//     'comment',
//     'status',
//     'date_delivered',
//     'manifest_id',
//     'rate_zone_id',
//     'manually_assigned_rate_zone',
//     'cash_on_delivery',
//     'complete_cod',
//     'cod_value',
//     'cod_requirement',
//     'delivery_date',
//     'required_delivery_date',
//     'special_instruction',
//     'save_special_instruction',
//     'confirm',
//     'finalize',
//     'end_date',
//     'next_date',
//     'repeat_every',
//     'repeat_count',
//     'is_repeat',
//     'no_charge',
//     'parent_repeat_id',
//     'created_at',
//     'is_group',
//     'sort_arrival',
//     'delivery_address_string_id',
//     'pickup_address_string_id',
//     'cc_consignment_id',
//     'is_printed',
//     'signature',
//     'temperature',
//     'recevied_by_name',
//     'runsheet_id',
//     'sort',
//     'osrm_sort',
//     'osrm_eta',
//     'original_carton',
//     'original_pallet',
//     'original_space',
//     'original_weight',
//     'validated',
//     'grouping_flag',
//     'pop_temperature',
//     'pop_recevied_by_name',
//     'pop_signature',
//     'date_picked',
//     'is_unassigned',
//     'deleted_at',
//     'loadsheet_pallet_id',
//     'delivery_addresses',
//     'pickup_addresses',
//     'delivery_runs',
//     'customers',
//     'product_types',
//     'run_sheets',
//     'consignment_pallets',
//     'grouped_consignments',
//     'total_grouped_consignments',
//     'customer_id',
//     'product_type_id',
//     'delivery_run_id',
//     'pickup_address',
//     'delivery_address',
//     'datetime',
//     'access_token',
//     'address_grouping',
//     'required_delivery_time',
//     'is_complete'
//   ];

//   // Helper method to filter data fields
//   Map<String, dynamic> filterFields(Map<String, dynamic> data) {
//     return Map.fromEntries(data.entries.where((entry) {
//       return allowedFields.contains(entry.key);
//     }));
//   }

//   // Method to fetch and store consignments from the API
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

//   // Method to process and store the data into the database
// Future<void> _processData(Transaction txn, Map<String, dynamic> dataByDate, String accessToken) async {
//   Map<String, List<int>> apiConsignmentIds = {};     // To store consignment IDs grouped by date from API
//   Map<String, List<int>> dbConsignmentIds = {};      // To store consignment IDs grouped by date from DB

//   // Group consignment IDs from the API by date
//   dataByDate.forEach((date, value) {
//     if (value['consignments'] != null) {
//       // Ensure IDs are cast to integer type before adding to the list
//       apiConsignmentIds[date] = value['consignments'].map<int>((item) => item['id'] as int).toList();
//     }
//   });

//   // Extract the list of consignments to process them one by one
//   List<dynamic> submissionData = _extractConsignments(dataByDate);

//   for (var dataIteration in submissionData) {
//     // Encode nested objects if needed
//     dataIteration['delivery_addresses'] = json.encode(dataIteration['delivery_addresses']);
//     dataIteration['pickup_addresses'] = json.encode(dataIteration['pickup_addresses']);
//     dataIteration['delivery_runs'] = json.encode(dataIteration['delivery_runs']);
//     dataIteration['customers'] = json.encode(dataIteration['customers']);
//     dataIteration['product_types'] = json.encode(dataIteration['product_types']);
//     dataIteration['run_sheets'] = json.encode(dataIteration['run_sheets']);
//     dataIteration['consignment_pallets'] = json.encode(dataIteration['consignment_pallets']);
//     dataIteration['grouped_consignments'] = dataIteration.containsKey('grouped_consignments')
//         ? json.encode(dataIteration['grouped_consignments'])
//         : null;
//     dataIteration['datetime'] = DateFormat('dd/MM/yyyy').format(DateTime.now());
//     dataIteration['is_complete'] = 0;
//     dataIteration['access_token'] = accessToken;

//     // Check if the consignment already exists in the database
//     List consignment = await txn.query(
//       'consignments',
//       where: 'id = ?',
//       whereArgs: [dataIteration['id']],
//     );

//     // Insert or update the consignment in the database
//     if (consignment.isEmpty) {
//       await txn.insert('consignments', dataIteration);
//     } else {
//       await txn.update(
//         'consignments',
//         dataIteration,
//         where: 'id = ?',
//         whereArgs: [dataIteration['id']],
//       );
//     }

//     // Group stored consignment IDs by date
//     String date = DateFormat('dd-MM-yyyy').format(DateTime.parse(dataIteration['delivery_date']));
//     if (dbConsignmentIds.containsKey(date)) {
//       dbConsignmentIds[date]?.add(dataIteration['id']);
//     } else {
//       dbConsignmentIds[date] = [dataIteration['id']];
//     }
//   }

//   // Print API consignment IDs grouped by date
//   print("Consignment IDs from API: $apiConsignmentIds");

//   // Print DB consignment IDs grouped by date
//   print("Consignment IDs stored in DB: $dbConsignmentIds");
// }

//   // Helper method to extract consignments from the nested data structure
//   List<dynamic> _extractConsignments(Map<String, dynamic> dataByDate) {
//     List<dynamic> consignments = [];
//     // Iterate through each date key and gather consignments
//     dataByDate.forEach((date, value) {
//       if (value['consignments'] != null) {
//         consignments.addAll(value['consignments']);
//       }
//     });
//     return consignments;
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
    'is_complete',
    'sort_app' // New field added to allowedFields list
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

      // Print the list of fetched IDs from the API
      List<String> fetchedIds = [];
      data['data'].forEach((key, value) {
        value['consignments'].forEach((consignment) {
          fetchedIds.add(consignment['id'].toString());
        });
      });
      print('Fetched Consignment IDs from API: $fetchedIds');

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

  // Updated _processData method to add sort_app field
  Future<void> _processData(Transaction txn, Map<String, dynamic> dataByDate, String accessToken) async {
    List<String> savedIds = []; // List to store saved consignment IDs
    int sortAppCounter = 1; // Counter to generate unique sort_app values

    for (var date in dataByDate.keys) {
      var submissionData = dataByDate[date]['consignments'];
      for (var dataIteration in submissionData) {
        var filteredData = filterFields(dataIteration);

        // Adding the sort_app field with a unique value
        filteredData['sort_app'] = sortAppCounter++;

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
          whereArgs: [filteredData['id']],
        );

        if (consignment.isEmpty) {
          await txn.insert('consignments', filteredData);
          savedIds.add(filteredData['id'].toString()); // Add ID to saved list
        } else {
          await txn.update(
            'consignments',
            filteredData,
            where: 'id = ?',
            whereArgs: [filteredData['id']],
          );
          savedIds.add(filteredData['id'].toString()); // Add ID to saved list
        }
      }
    }

    // Print the list of saved IDs in the database
    print('Saved Consignment IDs in Database: $savedIds');
  }
}
