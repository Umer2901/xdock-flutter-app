// ignore_for_file: use_build_context_synchronously, unused_local_variable

import 'dart:async';
import 'dart:convert';
import 'package:coldxpress/database/delivery_database.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:coldxpress/providers/proof-of-delivery-provider.dart';
import 'package:coldxpress/views/tabs/consignments/sub_views/proof_of_delivery_photos.dart';
import 'package:coldxpress/export.dart';

class TaskSyncpofProvider extends ChangeNotifier {
  final BuildContext context;

  TaskSyncpofProvider(this.context);

  Future<void> submitData(BuildContext context) async {
    try {
      final Map postData = context.read<ProofOfDeliveryProvider>().data;
      saveDataToDatabase(postData);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            icon: SizedBox(
              height: 20.w,
              width: 20.w,
              child: const Image(
                image: AssetImage(AppImages.checkmark),
                color: Colors.green,
              ),
            ),
            title: Text(
              'Your Proof of Delivery has been submitted successfully.',
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            titlePadding: EdgeInsets.symmetric(
              vertical: 1.h,
              horizontal: 2.w,
            ),
            iconPadding: EdgeInsets.symmetric(vertical: 1.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.sp),
            ),
            backgroundColor: AppColors.white,
            actions: <Widget>[
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomButton(
                      height: 5.h,
                      width: 30.w,
                      label: 'CLOSE',
                      backgroundColor: AppColors.blue,
                      borderColor: AppColors.blue,
                      foregroundColor: AppColors.white,
                      onPressed: () async {
                        context
                            .read<ProofOfDeliveryProvider>()
                            .restoreToDefault();
                        Get.offAllNamed(AppRoutes.dashboard);
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      );
    } catch (e) {
      debugPrint('Error submitting data: $e');
    }
  }

  Future<void> saveDataToDatabase(Map postData) async {
    try {
      final ProofOfDeliveryProvider provider =
          context.read<ProofOfDeliveryProvider>();
      final DeliveryDatabase fullDeliveryDatabase =
          DeliveryDatabase(context.read<DatabaseProvider>().database);

      Map<String, dynamic> taskData = {};

      switch (provider.selectedDeliveryType) {
        case DeliveryType.full:
          await fullDeliveryDatabase
              .fullcreate(postData.cast<String, dynamic>());
          taskData = postData.cast<String, dynamic>();
          break;
        case DeliveryType.partial:
          await fullDeliveryDatabase
              .partialcreate(postData.cast<String, dynamic>());
          taskData = postData.cast<String, dynamic>();
          break;
        case DeliveryType.none:
          await fullDeliveryDatabase
              .nonecreate(postData.cast<String, dynamic>());
          taskData = postData.cast<String, dynamic>();
          break;
      }

      final podType = provider.selectedDeliveryType.toString().split('.').last;
      print("i am pod type ${podType}");
      final Map<String, dynamic> taskToSave = {
        'task_name': 'delivery',
        'task_type': podType,
        'data': json.encode(taskData),
      };

      debugPrint('Saving the following data to TaskSyncDatabase: $taskToSave');
 taskData.forEach((key, value) {
          debugPrint('$key: $value');
        });
      await TaskSyncDatabase(context.read<DatabaseProvider>().database)
          .create(taskToSave);

      final consignmentId = postData['consignment_id'];
      debugPrint(
          "i am your dad ${consignmentId.toString().replaceAll(RegExp(r'[\[\]]'), '')}");
      if (consignmentId != null) {
        final consignmentIdInt = int.tryParse(
            consignmentId.toString().replaceAll(RegExp(r'[\[\]]'), ''));
        if (consignmentIdInt != null) {
          await _updateConsignmentCompletion(consignmentIdInt);
        } else {
          debugPrint('Error: consignment_id is not a valid integer');
        }
      } else {
        debugPrint('Error: consignment_id is null');
      }

      final connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult.contains(ConnectivityResult.wifi) ||
          connectivityResult.contains(ConnectivityResult.mobile)) {
        final taskDatabase =
            TaskSyncDatabase(context.read<DatabaseProvider>().database);
        final tasks = await taskDatabase.read();
       // await postDataToApi(tasks);
      }
    } catch (e) {
      debugPrint('Error saving data to database: $e');
    }
  }

  Future<void> _updateConsignmentCompletion(int consignmentId) async {
    try {
      await context.read<DatabaseProvider>().database.update(
            'consignments',
            {'is_complete': 1},
            where: 'id = ?',
            whereArgs: [consignmentId],
          );
      debugPrint(
          'Updated consignment with id $consignmentId to is_complete = 1');
    } catch (e) {
      debugPrint('Error updating consignment completion: $e');
    }
  }

 Future<void> postDataToApi(List<Map<String, dynamic>> tasks) async {
  var provider = Provider.of<ProofOfDeliveryProvider>(context, listen: false);
  AuthenticationState state = BlocProvider.of<AuthenticationCubit>(context).state;

  if (state is Authenticated) {
    try {
      final Map postData = context.read<ProofOfDeliveryProvider>().data;
      for (var task in tasks) {
        final taskData = json.decode(task['data']);
        final consignmentId = taskData['consignment_id'];
        final isGroup = taskData['is_group'];
        final int podType = taskData['pod_type'];
        debugPrint("Consignment ID: $consignmentId");

        String url = '';

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
          case 3:
            List<String> rejectionReasons = provider.selectedOrderRejectionReasons;
            for (String rejectionReason in rejectionReasons) {
              switch (rejectionReason) {
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
                  throw Exception('Invalid rejection reason: $rejectionReason');
              }
            }
            break;
          default:
            throw Exception('Invalid pod_type: $podType');
        }

        final requestBody = {
          "carton": taskData['carton'],
          "pallet": taskData['pallet'],
          "space": taskData['space'],
          "weigth": taskData['weight'],
          "first_name": taskData['first_name'],
          "last_name": taskData['last_name'],
          "temperature": taskData['temperature'],
          "signature": taskData['signature'],
          "comments": taskData['comments'],
          "service_window": taskData['service_window'],
          "service_time_start": taskData['service_time_start'],
          "service_time_end": taskData['service_time_end'],
          "address_id": taskData['address_id'],
          "pod_type": podType,
          "customer_reference": taskData['customer_reference'],
          "pictures": [taskData['pictures']],
          "pictureSources": jsonDecode(taskData['pictureSources']),
          "latitude": taskData['latitude'],
          "longitude": taskData['longitude'],
          "consignments": jsonDecode(taskData['consignments']),
          "device": jsonDecode(taskData['device']),
          "app_version": taskData['app_version'],
          "driver_id": taskData['driver_id'],
          "date_delivered": taskData['date_delivered'],
          "platforms": jsonDecode(taskData['platforms']),
          "current_app_version": taskData['current_app_version'],
        };

        requestBody.forEach((key, value) {
          debugPrint('$key: $value');
        });

        final response = await http.post(
          Uri.parse(url),
          headers: <String, String>{
            'Authorization': 'Bearer ${state.token}',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode(requestBody),
        );

        if (response.statusCode == 200) {
          debugPrint('Data posted successfully to URL: $url');
          await TaskSyncDatabase(context.read<DatabaseProvider>().database)
              .delete(task['id']);
          await ConsignmentDatabase(context.read<DatabaseProvider>().database)
              .update(task['id'], {'is_complete': 1});

          if (isGroup != null && isGroup != 'parent') {
            await submitGroupAsIndividual(int.parse(isGroup));
            await addNewConsignment(Get.arguments);
          }
        } else {
          debugPrint('Failed to post data to URL: $url');
          debugPrint('Response status: ${response.statusCode}');
          debugPrint('Response body: ${response.body}');
        }
      }
    } catch (e) {
      debugPrint('Error posting data to API: $e');
    }
  }
}

  Future<void> submitGroupAsIndividual(int id) async {
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

  Future<void> addNewConsignment(Map consignmentDetails) async {
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