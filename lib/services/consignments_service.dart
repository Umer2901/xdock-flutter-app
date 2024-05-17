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
          print(data);
          if (data['status'] == 'success') {
            // Map<String, dynamic> submissionData = data['data'][[DateFormat('yyyy-MM-dd').format(DateTime.now())]];
            List<dynamic> submissionData =
                data['data']['2024-04-04']['consignments'];
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
              dataIteration.addAll({
                'access_token': accessToken,
                'datetime': DateFormat('dd/MM/yyyy').format(DateTime.now()),
                'is_complete': 0,
              });
              try {
                List consignment = await ConsignmentDatabase(_database)
                    .readById(dataIteration['id']);
                if (consignment.isEmpty) {
                  await ConsignmentDatabase(_database).create(dataIteration);
                }
              } catch (e) {
                print('Old Error: $e');
              }
            }
          } else {
            throw Exception(
              'Unsuccessful to fetch submission data! (Error: ${data['message']})',
            );
          }
        } else {
          throw Exception(
              'Unsuccessful to fetch submission data! (Error Code: ${response.statusCode})');
        }
      }
    } on SocketException catch (e) {
      throw Exception('No Internet ($e)');
    } catch (e) {
      throw Exception('Unsuccessful to fetch submission data!');
    }
  }
}
