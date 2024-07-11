import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:coldxpress/database/delivery_database.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:coldxpress/export.dart';
import 'package:coldxpress/providers/proof-of-delivery-provider.dart';

class ProofOfDeliveryPhotos extends StatefulWidget {
  const ProofOfDeliveryPhotos({super.key, required arguments});

  @override
  State<ProofOfDeliveryPhotos> createState() => _ProofOfDeliveryPhotosState();
}

bool isLoading = false;
late Map productTypes;
late Map deliveryAddresses;
late Map pickupAddresses;
late final Database _database;
DatabaseProvider? databaseProvider;
late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
List groupedConsignments = [];

class _ProofOfDeliveryPhotosState extends State<ProofOfDeliveryPhotos> {
  @override
  void initState() {
    super.initState();
    productTypes = Get.arguments['product_types'].runtimeType == String
        ? json.decode(Get.arguments['product_types'])
        : Get.arguments['product_types'];
    deliveryAddresses =
        Get.arguments['delivery_addresses'].runtimeType == String
            ? json.decode(Get.arguments['delivery_addresses'])
            : Get.arguments['delivery_addresses'];
    pickupAddresses = Get.arguments['pickup_addresses'].runtimeType == String
        ? json.decode(Get.arguments['pickup_addresses'])
        : Get.arguments['pickup_addresses'];
    if (Get.arguments?['grouped_consignments'] != null) {
      groupedConsignments = json.decode(
        Get.arguments?['grouped_consignments'],
      );
    }
    databaseProvider = Provider.of<DatabaseProvider>(context, listen: false);

    print("our group data: ${Get.arguments['is_group']}");
    // _initializeDatabase();
    _subscribeToConnectivityChanges();
  }

  void _subscribeToConnectivityChanges() {
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      final hasInternet = results.contains(ConnectivityResult.mobile) ||
          results.contains(ConnectivityResult.wifi);
      if (hasInternet) {
        postDataToApi();
      }
    });
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  // Future<void> _initializeDatabase() async {
  //   databaseProvider = context.read<DatabaseProvider>();
  //   await databaseProvider?.initDatabase();
  //   setState(() {
  //     _database = databaseProvider!.database;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<ProofOfDeliveryProvider>(context);
    var databaseProvider = Provider.of<DatabaseProvider>(context);

    Future<void> saveDataToDatabase(Map postData) async {
      try {
        final ProofOfDeliveryProvider provider =
            context.read<ProofOfDeliveryProvider>();
        final DeliveryDatabase fullDeliveryDatabase =
            DeliveryDatabase(_database);

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
        final podType =
            provider.selectedDeliveryType.toString().split('.').last;
        final Map<String, dynamic> taskToSave = {
          'task_name': 'delivery',
          'task_type': podType,
          'data': json.encode(taskData),
        };

        print('Saving the following data to TaskSyncDatabase: $taskToSave');

        TaskSyncDatabase(_database).create(taskToSave);
        //  await   ConsignmentDatabase(_database).update(taskToSave['id'], {'sort': 1});
      } catch (e) {
        print('Error saving data to database: $e');
      }
    }

    Future<void> submitData() async {
      setState(() {
        isLoading = true;
      });

      try {
        final Map postData = context.read<ProofOfDeliveryProvider>().data;
        await saveDataToDatabase(postData);

        final connectivityResult = await (Connectivity().checkConnectivity());
        if (connectivityResult != ConnectivityResult.none) {
          await postDataToApi();
        }

        setState(() {
          isLoading = false;
        });

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
        setState(() {
          isLoading = false;
        });
        print('Error submitting data: $e');
      }
    }

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
            provider.backToDefault();
          },
          icon: Icon(
            Icons.arrow_back_ios,
            size: 15.sp,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.more_horiz,
              size: 20.sp,
            ),
          )
        ],
        centerTitle: true,
        title: Text(
          AppText.proofOfDelivery,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IntrinsicHeight(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'ID: ${Get.arguments?['id'] ?? 'Not Provided'}',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        VerticalDivider(
                          color: AppColors.black.withOpacity(0.5),
                          thickness: 2,
                        ),
                        Text(
                          'REF: ${Get.arguments?['customer_reference'] ?? 'Not Provided'}',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        InkWell(
                          onTap: () {},
                          child: Container(
                            width: 13.5.w,
                            height: 6.h,
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(50.sp),
                              border: Border.all(),
                            ),
                            child: SvgPicture.asset(
                              AppSvgs.mapMarker,
                              color: AppColors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: 8.h,
                        width: 18.w,
                        decoration: BoxDecoration(
                          color: AppColors.darkGrey,
                          borderRadius: BorderRadius.circular(8.sp),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 2.w,
                            vertical: 1.h,
                          ),
                          child: SizedBox(
                            width: 16.w,
                            height: 7.h,
                            child: Image.asset(AppImages.cardboard),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 54.w,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              (Get.arguments?['consignment_type'] == 'delivery'
                                      ? deliveryAddresses['company_name']
                                      : pickupAddresses['company_name']) ??
                                  'Not Provided',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            Text(
                              'Recipient: ${(Get.arguments?['consignment_type'] == 'delivery' ? deliveryAddresses['customer_name'] : pickupAddresses['customer_name']) ?? 'Not Provided'}',
                              style: Theme.of(context).textTheme.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              Get.arguments?['consignment_type'] == 'delivery'
                                  ? '${deliveryAddresses['street_address']}, ${deliveryAddresses['suburb']}'
                                  : '${pickupAddresses['street_address']}, ${pickupAddresses['suburb']}',
                              style: Theme.of(context).textTheme.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            )
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () {},
                        child: Container(
                          width: 13.5.w,
                          height: 6.h,
                          decoration: BoxDecoration(
                            color: AppColors.black.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(50.sp),
                          ),
                          child: Icon(
                            Icons.call,
                            color: AppColors.white,
                            size: 4.h,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  const Divider(
                    height: 1,
                    thickness: 2,
                    color: AppColors.grey,
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    "Photo Evidence",
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 1.h),
                  GestureDetector(
                    onTap: () async {
                      _takePhoto();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.navyBlue),
                        borderRadius: BorderRadius.all(
                          Radius.circular(10.sp),
                        ),
                      ),
                      child: SizedBox(
                        width: 92.w,
                        height: 18.h,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 6.5.w,
                              backgroundColor: AppColors.greyWhite,
                              child: Icon(
                                Icons.camera_alt_rounded,
                                color: AppColors.blue,
                                size: 24.sp,
                              ),
                            ),
                            SizedBox(height: 0.5.h),
                            Text(
                              AppText.takePhoto,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: AppColors.blue,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Row(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: context
                                .read<ProofOfDeliveryProvider>()
                                .images
                                .map(
                                  (image) => Padding(
                                    padding: EdgeInsets.only(right: 2.w),
                                    child: Container(
                                      height: 13.h,
                                      width: 28.w,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(5.sp),
                                        image: DecorationImage(
                                          image: FileImage(File(image.path)),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            context
                                                .read<ProofOfDeliveryProvider>()
                                                .removeImage(image: image);
                                          });
                                        },
                                        child: const Align(
                                          alignment: Alignment.topRight,
                                          child: Icon(
                                            Icons.cancel,
                                            color: AppColors.blue,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    "Other Information",
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  Stack(
                    children: [
                      Container(
                        height: 15.h,
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.navyBlue),
                          borderRadius: BorderRadius.all(
                            Radius.circular(5.sp),
                          ),
                        ),
                        padding: EdgeInsets.symmetric(
                            vertical: 1.h, horizontal: 2.w),
                        child: CustomTextField(
                          borderColor: AppColors.white,
                          name: 'commentspho',
                          hintText: "Enter Text",
                          onChanged: (value) {
                            context
                                .read<ProofOfDeliveryProvider>()
                                .data['comments'] = value;
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: 50.w,
                        child: CustomButton(
                          label: "Submit POD",
                          onPressed: context
                                  .watch<ProofOfDeliveryProvider>()
                                  .images
                                  .isNotEmpty
                              ? () {
                                  submitData();
                                }
                              : () {},
                          backgroundColor: context
                                  .watch<ProofOfDeliveryProvider>()
                                  .images
                                  .isNotEmpty
                              ? AppColors.blue
                              : AppColors.grey,
                          borderColor: context
                                  .watch<ProofOfDeliveryProvider>()
                                  .images
                                  .isNotEmpty
                              ? AppColors.blue
                              : AppColors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
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
        groupedConsignments = json.decode(
          consignment['grouped_consignments'],
        );
        for (var temp in groupedConsignments) {
          if (temp['id'] != id) {
            individualConsignments.add(temp);
            carton = carton + int.parse(temp['carton'].toString());
            pallet = pallet + int.parse(temp['pallet'].toString());
            space = space + int.parse(temp['space'].toString());
            weight = weight + double.parse(temp['weight'].toString());
          }
        }
        await ConsignmentDatabase(context.read<DatabaseProvider>().database)
            .update(id, {
          'grouped_consignments': json.encode(individualConsignments),
          'total_grouped_consignments': individualConsignments.length,
          'carton': carton,
          'pallet': pallet,
          'space': space,
          'weight': weight,
        });
      }
    });
  }

  Future<void> addNewConsignment(Map<String, dynamic> myConsignment) async {
    AuthenticationState state =
        BlocProvider.of<AuthenticationCubit>(context).state;
    if (state is Authenticated) {
      Map<String, dynamic> dataIteration = myConsignment;
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
        'access_token': state.token,
        'datetime': DateFormat('dd/MM/yyyy').format(DateTime.now()),
        'is_complete': 1,
      });
      List consignment =
          await ConsignmentDatabase(_database).readById(dataIteration['id']);
      if (consignment.isEmpty) {
        await ConsignmentDatabase(_database).create(dataIteration);
      }
    }
  }

  Future<void> _takePhoto() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(
        imageQuality: 10,
        source: ImageSource.camera,
      );

      if (image != null) {
        Uint8List bytes = await image.readAsBytes();
        setState(() {
          context.read<ProofOfDeliveryProvider>().addImage(
                image: image,
                base64String:
                    'data:image/jpeg;base64,${base64Encode(bytes).toString()}',
                source: 'By Camera',
              );
        });
      }
    } catch (e) {
      debugPrint('Error picking image from camera: $e');
      // Handle error, e.g., show an error dialog or log the error
    }
  }

  Future<void> postDataToApi() async {
    var provider = Provider.of<ProofOfDeliveryProvider>(context, listen: false);
    var databaseProvider =
        Provider.of<DatabaseProvider>(context, listen: false);
    AuthenticationState state =
        BlocProvider.of<AuthenticationCubit>(context).state;

    if (state is Authenticated) {
      try {
        final taskDatabase = TaskSyncDatabase(_database!);

        final tasks = await taskDatabase.read();
        print(tasks);

        if (tasks.isEmpty) {
          print('No tasks to send');
          return;
        }

        final Map postData = context.read<ProofOfDeliveryProvider>().data;
        String url = '';
        final consignmentId = Get.arguments?['id'];
        final consignmentType =
            Get.arguments?['consignment_type'] ?? 'delivery';
        if (groupedConsignments.isNotEmpty) {
          if (consignmentType == 'delivery') {
            url = '${AppHost.group}';
          } else {
            url = '${AppHost.grouppop}';
          }
        } else {
          switch (provider.selectedDeliveryType) {
            case DeliveryType.full:
              final consignmentType =
                  Get.arguments?['consignment_type'] ?? 'delivery';
              if (consignmentType == 'delivery') {
                url = '${AppHost.podfull}$consignmentId';
              } else {
                url = '${AppHost.singlepop}$consignmentId';
              }
              break;
            case DeliveryType.partial:
              url = '${AppHost.podpartial}$consignmentId';
              break;
            case DeliveryType.none:
              List<String> rejectionReasons =
                  provider.selectedOrderRejectionReasons as List<String>;
              for (String rejectionReason in rejectionReasons) {
                print('Rejection Reason: $rejectionReason');
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
                    throw Exception(
                        'Invalid rejection reason: $rejectionReason');
                }
              }
              break;
          }
        }

        final podType =
            provider.selectedDeliveryType.toString().split('.').last;
        final combinedData = {
          'pod_type': podType,
          'tasks': tasks,
        };

        final response = await http.post(
          Uri.parse(url),
          headers: <String, String>{
            'Authorization': 'Bearer ${state.token}',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode(combinedData),
        );

        if (response.statusCode == 200) {
          print('Data posted successfully to URL: $url');
          print('Response body: ${response.body}');
          debugPrint('Response body: ${response.body}');
          for (var task in tasks) {
            await taskDatabase.delete(task['id']);
            print(task['id']);
            await ConsignmentDatabase(_database)
                .update(task['id'], {'is_complete': 1});
          }
          if (Get.arguments['is_group'] != null) {
            if (Get.arguments['is_group'] != 'parent') {
              await submitGroupAsIndividual(
                int.parse(
                  Get.arguments['is_group'],
                ),
              );
              await addNewConsignment(Get.arguments);
            }
          }
        } else {
          print('Failed to post data to URL: $url');
          print('Response status: ${response.statusCode}');
          print('Response body: ${response.body}');
        }
        ;
      } catch (e) {
        print('Error posting data to API: $e');
      }
    }
  }

//   Future<void> postDataToApi() async {
//   var provider = Provider.of<ProofOfDeliveryProvider>(context, listen: false);
//   var databaseProvider = Provider.of<DatabaseProvider>(context, listen: false);
//   AuthenticationState state = BlocProvider.of<AuthenticationCubit>(context).state;

//   if (state is Authenticated) {
//     try {
//       final taskDatabase = TaskSyncDatabase(_database!);

//       final tasks = await taskDatabase.read();
//       print(tasks);

//       if (tasks.isEmpty) {
//         print('No tasks to send');
//         return;
//       }

//       final Map postData = context.read<ProofOfDeliveryProvider>().data;

//        String url = '';
//       final consignmentId = Get.arguments?['id'];
//  final consignmentType = Get.arguments?['consignment_type'] ?? '';
//      if (provider.selectedDeliveryType == DeliveryType.full) {
//   if (groupedConsignments.isNotEmpty) {
//     if (consignmentType == 'delivery') {
//       url = '${AppHost.group}';
//     } else {
//       url = '${AppHost.grouppop}';
//     }
//   } else {
//     if (consignmentType == 'delivery') {
//       url = '${AppHost.podfull}$consignmentId';
//     } else {
//       url = '${AppHost.singlepop}';
//     }
//   }
// } else if (provider.selectedDeliveryType == DeliveryType.partial) {
//   url = '${AppHost.podpartial}$consignmentId';
// } else {
//   List<String> rejectionReasons = provider.selectedOrderRejectionReasons as List<String>;
//   for (String rejectionReason in rejectionReasons) {
//     print('Rejection Reason: $rejectionReason');
//     switch (rejectionReason) {
  // case "Temperature issue":
  //   url = '${AppHost.temperateissue}$consignmentId';
  //   break;
  // case "Wrong Address":
  //   url = '${AppHost.wrongaddress}$consignmentId';
  //   break;
  // case "Damaged Goods":
  //   url = '${AppHost.damagegoods}$consignmentId';
  //   break;
  // case "Receiver Not Open":
  //   url = '${AppHost.notopen}$consignmentId';
  //   break;
  // case "Other Rejection":
  //   url = '${AppHost.otherrejection}$consignmentId';
  //   break;
//       default:
//         throw Exception('Invalid rejection reason: $rejectionReason');
//     }
//   }
// }

//       final podType = provider.selectedDeliveryType.toString().split('.').last;
//       final combinedData = {
//         'pod_type': podType,
//         'tasks': tasks,
//       };

//       final response = await http.post(
//         Uri.parse(url),
//         headers: <String, String>{
//           'Authorization': 'Bearer ${state.token}',
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//         },
//         body: jsonEncode(combinedData),
//       );

//       if (response.statusCode == 200) {
//         print('Data posted successfully to URL: $url');
//         print('Response body: ${response.body}');

//         for (var task in tasks) {
//           await taskDatabase.delete(task['id']);
//           print(task['id']);
//           await ConsignmentDatabase(_database).update(task['id'], {'sort': 1});
//         }
//       } else  {
//         print('Failed to post data to URL: $url');
//         print('Response status: ${response.statusCode}');
//         print('Response body: ${response.body}');
//       };
//     } catch (e) {
//       print('Error posting data to API: $e');
//     }
//   }
// }

// Future<void> postDataToApi() async {
//   var provider = Provider.of<ProofOfDeliveryProvider>(context, listen: false);
//   var databaseProvider = Provider.of<DatabaseProvider>(context, listen: false);
//   AuthenticationState state = BlocProvider.of<AuthenticationCubit>(context).state;

//   if (state is Authenticated) {
//     try {
//       final TaskDatabase = TaskSyncDatabase(_database);
//       final tasks = await TaskDatabase.read();
//       print(tasks);

//       if (tasks.isEmpty) {
//         print('No tasks to send');
//         return;
//       }

//       bool hasGroupTask = false;

//       for (var task in tasks) {
//         var taskData = jsonDecode(task['data']);
//         if (taskData['is_group'] != null) {
//           hasGroupTask = true;
//           print('is_group: ${taskData['is_group']}');
//         }
//       }

//       final consignmentType = Get.arguments?['consignment_type'] ?? '';
//       final groupedConsignments = [];
//       String url = '';
//       final consignmentId = Get.arguments?['id'];
//  if (groupedConsignments.isNotEmpty) {
//         url = AppHost.group;
//       } else {
//         switch (provider.selectedDeliveryType) {
//           case DeliveryType.full:
//             if (groupedConsignments.isEmpty && consignmentType == 'delivery') {
//           url = '${AppHost.podfull}$consignmentId';
//         } else if (groupedConsignments.isNotEmpty && consignmentType == 'delivery') {
//           url = '${AppHost.group}$consignmentId';
//         } else if (groupedConsignments.isNotEmpty && consignmentType == 'pickup') {
//           url = '${AppHost.grouppop}$consignmentId';
//         } else if (groupedConsignments.isEmpty && consignmentType == 'pickup') {
//           url = '${AppHost.singlepop}$consignmentId';
//         }
//             break;
//           case DeliveryType.partial:
//              url = '${AppHost.podpartial}$consignmentId';
//             break;
//           case DeliveryType.none:
//             List<String> rejectionReasons = provider.selectedOrderRejectionReasons as List<String>;
//             for (String rejectionReason in rejectionReasons) {
//               print('Rejection Reason: $rejectionReason');
//               switch (rejectionReason) {
//                  case "Temperature issue":
//                  url = '${AppHost.temperateissue}$consignmentId';
//                   break;
//                 case "Wrong Address":
//                   url = '${AppHost.wrongaddress}$consignmentId';
//                   break;
//                 case "Damaged Goods":
//                   url = '${AppHost.damagegoods}$consignmentId';
//                   break;
//                 case "Receiver Not Open":
//                   url = '${AppHost.notopen}$consignmentId';
//                   break;
//                 case "Other Rejection":
//                   url = '${AppHost.otherrejection}$consignmentId';
//                   break;
//                 default:
//                   throw Exception('Invalid rejection reason: $rejectionReason');
//               }
//             }
//             break;
//         }
//       }

//       // if (provider.selectedDeliveryType == DeliveryType.full) {
//       //   if (groupedConsignments.isEmpty && consignmentType == 'delivery') {
//       //     url = '${AppHost.podfull}$consignmentId';
//       //   } else if (groupedConsignments.isNotEmpty && consignmentType == 'delivery') {
//       //     url = '${AppHost.group}$consignmentId';
//       //   } else if (groupedConsignments.isNotEmpty && consignmentType == 'pickup') {
//       //     url = '${AppHost.grouppop}$consignmentId';
//       //   } else if (groupedConsignments.isEmpty && consignmentType == 'pickup') {
//       //     url = '${AppHost.singlepop}$consignmentId';
//       //   }
//       // } else {
//       //   switch (provider.selectedDeliveryType) {
//       //     case DeliveryType.partial:
//       //       url = '${AppHost.podpartial}$consignmentId';
//       //       break;
//       //     case DeliveryType.none:
//       //       List<String> rejectionReasons =
//       //           provider.selectedOrderRejectionReasons as List<String>;
//       //       for (String rejectionReason in rejectionReasons) {
//       //         print('Rejection Reason: $rejectionReason');
//       //         switch (rejectionReason) {
//       //           case "Temperature issue":
//       //            url = '${AppHost.temperateissue}$consignmentId';
//       //             break;
//       //           case "Wrong Address":
//       //             url = '${AppHost.wrongaddress}$consignmentId';
//       //             break;
//       //           case "Damaged Goods":
//       //             url = '${AppHost.damagegoods}$consignmentId';
//       //             break;
//       //           case "Receiver Not Open":
//       //             url = '${AppHost.notopen}$consignmentId';
//       //             break;
//       //           case "Other Rejection":
//       //             url = '${AppHost.otherrejection}$consignmentId';
//       //             break;
//       //           default:
//       //             throw Exception('Invalid rejection reason: $rejectionReason');
//       //         }
//       //       }
//       //       break;
//       //     case DeliveryType.full:
//       //       if (groupedConsignments.isEmpty && consignmentType == 'delivery') {
//       //     url = '${AppHost.podfull}$consignmentId';
//       //   } else if (groupedConsignments.isNotEmpty && consignmentType == 'delivery') {
//       //     url = '${AppHost.group}';
//       //   } else if (groupedConsignments.isNotEmpty && consignmentType == 'pickup') {
//       //     url = '${AppHost.grouppop}';
//       //   } else if (groupedConsignments.isEmpty && consignmentType == 'pickup') {
//       //     url = '${AppHost.singlepop}$consignmentId';
//       //   }
//       //   }
//       // }

//       final podType = provider.selectedDeliveryType.toString().split('.').last;
//       final combinedData = {
//         'pod_type': podType,
//         'tasks': tasks,
//         "message": {},
//       };

//       final response = await http.post(
//         Uri.parse(url),
//         headers: <String, String>{
//           'Authorization': 'Bearer ${state.token}',
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//         },
//         body: jsonEncode(combinedData),
//       );

//       if (response.statusCode == 200) {
//         print('Data posted successfully to URL: $url');
//         print('Response body: ${response.body}');

//         for (var task in tasks) {
//           await TaskDatabase.delete(task['id']);
//           print(task['id']);
//           await ConsignmentDatabase(_database).update(task['id'], {'sort': 1});
//         }
//       } else {
//         print('Failed to post data to URL: $url');
//         print('Response status: ${response.statusCode}');
//         print('Response body: ${response.body}');
//       }
//     } catch (e) {
//       print('Error posting data to API: $e');
//     }
//   }
// }
}
