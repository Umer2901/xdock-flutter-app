import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';
import 'package:coldxpress/constants/host.dart';

class ConsignmentService {
  final Database _database;

  ConsignmentService(this._database);

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
        dataIteration['delivery_addresses'] = json.encode(dataIteration['delivery_addresses']);
        dataIteration['pickup_addresses'] = json.encode(dataIteration['pickup_addresses']);
        dataIteration['delivery_runs'] = json.encode(dataIteration['delivery_runs']);
        dataIteration['customers'] = json.encode(dataIteration['customers']);
        dataIteration['product_types'] = json.encode(dataIteration['product_types']);
        dataIteration['run_sheets'] = json.encode(dataIteration['run_sheets']);
        dataIteration['consignment_pallets'] = json.encode(dataIteration['consignment_pallets']);
        dataIteration['grouped_consignments'] = dataIteration.containsKey('grouped_consignments') ?
                                               json.encode(dataIteration['grouped_consignments']) : null;
        dataIteration['datetime'] = DateFormat('dd/MM/yyyy').format(DateTime.now());
        dataIteration['is_complete'] = 0;
        dataIteration['access_token'] = accessToken;

        List consignment = await txn.query(
          'consignments',
          where: 'id = ?',
          whereArgs: [dataIteration['id']]
        );

        if (consignment.isEmpty) {
          await txn.insert('consignments', dataIteration);
        } else {
          await txn.update(
            'consignments',
            dataIteration,
            where: 'id = ?',
            whereArgs: [dataIteration['id']]
          );
        }
      }
    }
  }
 Future<void> reorderConsignments(List<int> consignmentIds, String accessToken) async {
    await _database.transaction((txn) async {
      List<Map> tables = await txn.rawQuery("SELECT name FROM sqlite_master WHERE type='table' AND name='sync_task'");
      print("Checking table existence: $tables");
      
      if (tables.isNotEmpty) {
        for (var id in consignmentIds) {
          await txn.update(
            'consignments',
            {'sort': consignmentIds.indexOf(id) + 1},
            where: 'id = ?',
            whereArgs: [id]
          );
        }

        await txn.insert('sync_task', {
          'task_name': 'Re-order Consignments',
          'task_type': 'reorder',
          'data': json.encode({DateFormat('yyyy-MM-dd').format(DateTime.now()): consignmentIds}),
          'access_token': accessToken
        });
        print('Reorder saved to sync_task');
         List<Map> syncTaskData = await txn.rawQuery('SELECT * FROM sync_task');
      print('Data in sync_task table: $syncTaskData');
      } else {
        print("Table sync_task does not exist. Check your database initialization.");
      }
    });
  }
}