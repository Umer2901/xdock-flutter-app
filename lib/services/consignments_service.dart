import 'dart:io';
import 'package:coldxpress/export.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ConsignmentService {
  final Database _database;

  ConsignmentService(this._database);

  Future<void> fetchAndStore(String accessToken) async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        final response = await http.get(
          Uri.parse(AppHost.consignments),
          headers: <String, String>{
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          final dynamic data = json.decode(response.body);
          try {
            if (data['status'] == 'success') {
              // List<dynamic> submissionData = data['data']
              //         [DateFormat('yyyy-MM-dd').format(DateTime.now())]
              //     ['consignments'];
              List<dynamic> submissionData =
                  data['data']['2024-07-02']['consignments'];
              for (var dataIteration in submissionData) {
                dataIteration['delivery_addresses'] = json.encode(
                  dataIteration['delivery_addresses'],
                );
                dataIteration['pickup_addresses'] = json.encode(
                  dataIteration['pickup_addresses'],
                );
                dataIteration['delivery_runs'] = json.encode(
                  dataIteration['delivery_runs'],
                );
                dataIteration['customers'] = json.encode(
                  dataIteration['customers'],
                );
                dataIteration['product_types'] = json.encode(
                  dataIteration['product_types'],
                );
                dataIteration['run_sheets'] = json.encode(
                  dataIteration['run_sheets'],
                );
                dataIteration['consignment_pallets'] = json.encode(
                  dataIteration['consignment_pallets'],
                );
                dataIteration['grouped_consignments'] =
                    dataIteration.containsKey('grouped_consignments')
                        ? json.encode(
                            dataIteration['grouped_consignments'],
                          )
                        : null;
                dataIteration.addAll({
                  'access_token': accessToken,
                  'datetime': DateFormat('dd/MM/yyyy').format(DateTime.now()),
                  'is_complete': 0,
                });
                List consignment = await ConsignmentDatabase(_database)
                    .readById(dataIteration['id']);
                if (consignment.isEmpty) {
                  await ConsignmentDatabase(_database).create(dataIteration);
                }
              }
            } else {
              throw Exception(
                'Unsuccessful to fetch submission data! (Error: ${data['message']})',
              );
            }
          } catch (e) {
            print('Data Error: $e');
          }
        } else {
          throw Exception(
              'Unsuccessful to fetch submission data! (Error Code: ${response.statusCode})');
        }
      }
    } on SocketException catch (e) {
      throw Exception('No Internet ($e)');
    } catch (e) {
      debugPrint('Unsuccessful to fetch submission data! $e');
    }
  }

  void reorderConsignments(List consignmentIds, String accessToken) async {
    for (int id in consignmentIds) {
      await ConsignmentDatabase(_database).update(
        id,
        {'sort': consignmentIds.indexOf(id) + 1},
      );
    }
    await TaskSyncDatabase(_database).create({
      'task_name': 'Re-order Consignments',
      'task_type': 'reorder',
      'data': json.encode(
        {DateFormat('yyyy-MM-dd').format(DateTime.now()): consignmentIds},
      ),
      'access_token': accessToken,
    });
  }
}
