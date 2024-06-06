import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:coldxpress/database/delivery_database.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:http/http.dart' as http;
import 'package:coldxpress/export.dart';
import 'package:coldxpress/providers/proof-of-delivery-provider.dart';
import 'package:coldxpress/views/tabs/consignments/sub_views/clock.dart';

class ProofOfDeliveryView extends StatefulWidget {

  const ProofOfDeliveryView({super.key, required arguments});
  
  @override
  State<ProofOfDeliveryView> createState() => _ProofOfDeliveryViewState();
}
class _ProofOfDeliveryViewState extends State<ProofOfDeliveryView> {
  final SignatureController controller = SignatureController(
    penStrokeWidth: 3,
    penColor: AppColors.black,
    exportBackgroundColor: AppColors.white,
  );

  final TextEditingController serviceTimeController = TextEditingController();
  bool showSignature =false;
  final _formKey = GlobalKey<FormBuilderState>();
  bool isLoading = false;
  Map<String, dynamic> deviceinfo = {};
  late Map productTypes;
  late Map deliveryAddresses;
  late Map pickupAddresses;
  Database? _database;
  final dateDeliveredTimestamp = DateTime.now().millisecondsSinceEpoch;
  late final DatabaseProvider databaseProvider;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;


  @override
  void initState() {
    super.initState();
   _setDeviceInfo();
    config();
     productTypes = json.decode(Get.arguments['product_types']);
    deliveryAddresses = json.decode(Get.arguments['delivery_addresses']);
    pickupAddresses = json.decode(Get.arguments['pickup_addresses']);
    _initializeDatabase();
    _subscribeToConnectivityChanges();
  }
   config() async {
    context.read<LocationProvider>().getCurrentLocation();
  }
  void _subscribeToConnectivityChanges() {
  _connectivitySubscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
    final hasInternet = results.contains(ConnectivityResult.mobile) || results.contains(ConnectivityResult.wifi);
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
   Future<void> _initializeDatabase() async {
    databaseProvider = context.read<DatabaseProvider>();
    await databaseProvider.initDatabase();
    setState(() {
      _database = databaseProvider.database;
    });
  }


void _setDeviceInfo() async {
  final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

  try {
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;
      deviceinfo = {
        "isVirtual": androidInfo.isPhysicalDevice,
        "manufacturer": androidInfo.manufacturer,
        "model": androidInfo.model,
        "platform": "Android",
        "serial": androidInfo.id,
        "uuid": androidInfo.id,
        "version": androidInfo.version.sdkInt.toString(),
      };
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfoPlugin.iosInfo;
      deviceinfo = {
        "isVirtual": iosInfo.isPhysicalDevice,
        "manufacturer": 'Apple',
        "model": iosInfo.model,
        "platform": "iOS",
        "serial": iosInfo.identifierForVendor,
        "uuid": iosInfo.identifierForVendor,
        "version": iosInfo.systemVersion,
      };
    }
    print("Device Info: $deviceinfo");
  } catch (e) {
    print("Error fetching device info: $e");
  }

  if (deviceinfo.isNotEmpty) {
    context.read<ProofOfDeliveryProvider>().setDeviceInfo(deviceinfo);
    print("Device info set in provider: $deviceinfo");
  } else {
    print("Device info is empty. Cannot set in the provider.");
  }
}
 
  @override
  Widget build(BuildContext context) {
      var provider = Provider.of<ProofOfDeliveryProvider>(context);
    //  var databaseProvider = Provider.of<DatabaseProvider>(context);
  //  print({Get.arguments});
  //  print("2 ${pickupAddresses}");
  //  print(productTypes);
  //  print("3${deliveryAddresses}");

      bool _isValid() {
  final cartons = _formKey.currentState!.fields['cartons']!.value;
  final pallets = _formKey.currentState!.fields['pallets']!.value;
  final temperature = _formKey.currentState!.fields['temp']!.value;
  final lengthofDelivery = _formKey.currentState!.fields['length']!.value;
  final receiverFirstName = _formKey.currentState!.fields['receiverFirstName']!.value;
  final receiverLastName = _formKey.currentState!.fields['receiverLastName']!.value;
  final signature = provider.signature;
  return cartons != null &&
         pallets != null &&
         temperature != null &&
         lengthofDelivery != null &&
         receiverFirstName != null &&
         receiverLastName != null &&
         signature != null;
        
}

 Future<void> saveDataToDatabase(Map postData) async {
    try {
      final ProofOfDeliveryProvider provider = context.read<ProofOfDeliveryProvider>();
      final DeliveryDatabase fullDeliveryDatabase = DeliveryDatabase(_database!);

      Map<String, dynamic> taskData = {};

      switch (provider.selectedDeliveryType) {
        case DeliveryType.full:
          await fullDeliveryDatabase.fullcreate(postData.cast<String, dynamic>());
          taskData = postData.cast<String, dynamic>();
          break;
        case DeliveryType.partial:
          await fullDeliveryDatabase.partialcreate(postData.cast<String, dynamic>());
          taskData = postData.cast<String, dynamic>();
          break;
        case DeliveryType.none:
          await fullDeliveryDatabase.nonecreate(postData.cast<String, dynamic>());
          taskData = postData.cast<String, dynamic>();
          break;
      }
 final podType = provider.selectedDeliveryType.toString().split('.').last;
      final Map<String, dynamic> taskToSave = {
        'task_name': 'delivery',
        'task_type': podType,
        'data': json.encode(taskData),
      };

      print('Saving the following data to TaskDatabase: $taskToSave');

      TaskDatabase(_database!).create(taskToSave);
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
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomButton(
                      height: 5.h,
                      width: 30.w,
                      label: 'Edit',
                      backgroundColor: AppColors.white,
                      borderColor: AppColors.black,
                      foregroundColor: AppColors.black,
                      onPressed: () async {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                    ),
                    CustomButton(
                      height: 5.h,
                      width: 30.w,
                      label: 'CLOSE',
                      backgroundColor: AppColors.blue,
                      borderColor: AppColors.blue,
                      foregroundColor: AppColors.white,
                      onPressed: () async {
                        context.read<ProofOfDeliveryProvider>().restoreToDefault();
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
    }}
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
            provider.restoreToDefault();
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
              child: FormBuilder(
                      key: _formKey,
                     
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
                                border: Border.all()),
                            child: SvgPicture.asset(
                              AppSvgs.mapMarker,
                              color: AppColors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 2.h,
                  ),
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
                        SizedBox(
                          height: 2.h,
                        ),
                        const Divider(),
                        SizedBox(
                          height: 2.h,
                        ),
                        Text(
                          AppText.selectDeliveryType,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        SizedBox(
                          height: 1.h,
                        ),
                     CustomDropdown(
                    name: 'deliveryType',
                    hintText: 'Please Select',
                    fillColor: AppColors.white,
                
                    onChanged: (newValue) {
                      
                      context.read<ProofOfDeliveryProvider>().updateSelectedDeliveryType(newValue!);
                      provider.lpc(context, controller);
                       
                    },
                    items: [
                      DropdownMenuItem(
                        value: DeliveryType.full,
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.green,
                              radius: 3.sp,
                            ),
                            SizedBox(
                              width: 2.w,
                            ),
                            const Text('Full Delivery'),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: DeliveryType.partial,
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: AppColors.yellow,
                              radius: 3.sp,
                            ),
                            SizedBox(
                              width: 2.w,
                            ),
                            const Text('Partial Delivery'),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: DeliveryType.none,
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: AppColors.red,
                              radius: 3.sp,
                            ),
                            SizedBox(
                              width: 2.w,
                            ),
                            const Text('No Delivery'),
                          ],
                        ),
                      ),
                    ],
                  ),

                   
                    SizedBox(
                      height: 2.h,
                    ),
                    
                        if (Provider.of<ProofOfDeliveryProvider>(context).selectedDeliveryType == DeliveryType.full)
                         Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppText.howManyDelivered,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          SizedBox(
                            height: 1.h,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              PalletContainer(
                                name: 'cartons',
                                heading: AppText.cartons,
                                  icon: SvgPicture.asset(AppSvgs.boundpallets),
                                hintText: '0',
                                 initialValue: context
                                        .read<ProofOfDeliveryProvider>()
                                        .data
                                        .containsKey('cartons')
                                    ? int.parse(context
                                        .read<ProofOfDeliveryProvider>()
                                        .data['cartons'])
                                    : 0,
                                 totalPallet: int.tryParse(Get.arguments?['carton']?.toString() ?? '0') ?? 0,
                                  
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 4.w,
                                vertical: 0,
                              ),
                              ),
                              PalletContainer(
                                name: 'pallets',
                                heading: AppText.pallets,
                                hintText: '0',
                                initialValue: context
                                        .read<ProofOfDeliveryProvider>()
                                        .data
                                        .containsKey('pallet')
                                    ? int.parse(context
                                        .read<ProofOfDeliveryProvider>()
                                        .data['pallet'])
                                    : 0,
                                    
                              
                                totalPallet: int.tryParse(Get.arguments?['pallet']?.toString() ?? '0') ?? 0,
                              ),
                            
                        
                            ],
                          ),
                          SizedBox(
                            height: 3.h,
                          ),
                          Text(
                            AppText.deliveryTemperature,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          SizedBox(
                            height: 1.h,
                          ),
                       CustomTextField(
  name: 'temp',
  hintText: AppText.temperature,
  keyboardType: TextInputType.number,
  suffixIcon: Padding(
    padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 2.w),
    child: Text(
      AppText.celsius,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
    ),
  ),
 
  onChanged: (value) {
    context.read<ProofOfDeliveryProvider>().data['temperature'] = value;
  },
),
                
                          SizedBox(
                            height: 3.h,
                          ),
                          Text(
                            AppText.serviceTime,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          SizedBox(
                            height: 1.h,
                          ),
                         CustomTextField(
                      name: 'service',
                      keyboardType: TextInputType.number,
                      readOnly: true,
                      hintText:  serviceTimeController.text =
                          '${Provider.of<TimeProvider>(context).startTime.h}:${Provider.of<TimeProvider>(context).startTime.m} - ${Provider.of<TimeProvider>(context).endTime.h}:${Provider.of<TimeProvider>(context).endTime.m}',
                             controller:  serviceTimeController,
                      onTap: () {
                        Get.toNamed(AppRoutes.Stopwatch);
                       
                      },
                      suffixIcon: Padding(
                        padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 2.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                             Text(
                              AppText.editHours,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.black.withOpacity(0.5),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                           
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 2.h,
                              color: AppColors.black.withOpacity(0.5),
                            )
                          ],
                        ),
                      ),
                    
                                    onChanged: (value) {
                  
                  context.read<ProofOfDeliveryProvider>().data['serviceStart'] = value;
                  context.read<ProofOfDeliveryProvider>().data['serviceEnd'] = value;
                  },
                    ),
                    
                          SizedBox(
                            height: 1.h,
                          ),
                          CustomTextField(
                            name: 'length',
                            hintText: AppText.lengthOfDelivery,
                            keyboardType: TextInputType.number,
                            suffixIcon: Padding(
                              padding:
                    EdgeInsets.symmetric(vertical: 2.h, horizontal: 2.w),
                              child: Text(
                                AppText.minutes,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                              ),
                            ),
                    
                                    onChanged: (value) {
                    context.read<ProofOfDeliveryProvider>().data['lengthOfDelivery'] = value;
                  },
                          ),
                          SizedBox(
                            height: 3.h,
                          ),
                          Text(
                            AppText.receiverConfirmation,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          SizedBox(
                            height: 1.h,
                          ),
                           CustomTextField(
                            name: 'receiverFirstName',
                            hintText: AppText.receiverFirstName,
                              
                                   onChanged: (value) {
                    context.read<ProofOfDeliveryProvider>().data['first_name'] = value;
                  },
                                  
                          ),
                          SizedBox(
                            height: 1.h,
                          ),
                           CustomTextField(
                            name: 'receiverLastName',
                            hintText: AppText.receiverLastName,
                           
                                  onChanged: (value) {
                    context.read<ProofOfDeliveryProvider>().data['last_name'] = value;
                  },
                          ),
                          SizedBox(
                            height: 1.h,
                          ),
Consumer<ProofOfDeliveryProvider>(
        builder: (context, provider, _) {
          return SizedBox(
            width: 90.w,
            child: GestureDetector(
              onTap: () async{
                
           if (!provider.showSignature) {
      provider.setShowSignature(true);
      provider.showSignaturePopup(context, controller);
      final bytes = await controller.toPngBytes();
      if (bytes != null) {
        provider.updateSignatureData(bytes);
        provider.addEntities({
          "signature": 'data:image/png;base64, ${base64Encode(bytes)}',
        });
      }
                }
              },
                          child: Stack(
                            children: [
                              if (controller.isEmpty && !provider.showSignature)
                  Container(
                    height: 25.h,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.navyBlue),
                      borderRadius: BorderRadius.all(
                        Radius.circular(5.sp),
                      ),
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: 1.h,
                      horizontal: 2.w,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 50.sp,
                          height: 50.sp,
                          child: Image.asset(
                            AppImages.handWithPen,
                          ),
                        ),
                        Text(
                          AppText.tapHereToSign,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        )
                      ],
                    ),
                  ),
                              if (provider.showSignature)
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.navyBlue),
                      borderRadius: BorderRadius.all(
                        Radius.circular(5.sp),
                      ),
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: 1.h,
                      horizontal: 2.w,
                    ),
                    child: Column(
                      children: [
                        IgnorePointer(
                      child: Signature(
                        dynamicPressureSupported: false,
                        controller: controller,
                        width: 90.w,
                        height: 20.h,
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                        const Divider(
                          height: 1,
                          thickness: 2,
                          color: AppColors.grey,
                        ),
                        CupertinoButton(
                          child: const Text(
                            "Redo",
                            style: TextStyle(color: Colors.blue),
                          ),
                          onPressed: () {
                          provider.clearSignatureAndShowPopup(context, controller);
                         
                          },
                        ),
                      ],
                    ),
                  ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                        
                          SizedBox(
                            height: 1.h,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                             SizedBox(
                              width: 50.w,
                              child: Consumer<ProofOfDeliveryProvider>(
                                      builder: (context, provider, _) =>
                                       CustomButton(
                                        label: "Next",
                                      onPressed: () {
        if (int.parse(_formKey.currentState!.fields['cartons']!.value.toString()) < Get.arguments['carton'] ||
            int.parse(_formKey.currentState!.fields['pallets']!.value.toString()) < Get.arguments['pallet']) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.sp),
                ),
                backgroundColor: AppColors.white,
                titlePadding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 2.w),
                contentPadding: EdgeInsets.zero,
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 20.w,
                      width: 20.w,
                      child: Image.asset(
                        AppImages.brakeWarning,
                        fit: BoxFit.contain,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 2.w),
                      child: Text(
                        "You are missing cartons or pallets. Please fix this mistake.",
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                actions: <Widget>[
                  SizedBox(height: 2.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      CustomButton(
                        height: 5.h,
                        width: 30.w,
                        label: 'OK',
                        backgroundColor: AppColors.white,
                        borderColor: AppColors.yellow,
                        foregroundColor: AppColors.black,
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ],
              );
            },
          );
        } else {
          if (_formKey.currentState != null) {
        final temperature = _formKey.currentState!.fields['temp']!.value.toString();
        final first_name = _formKey.currentState!.fields['receiverFirstName']!.value.toString();
        final last_name = _formKey.currentState!.fields['receiverLastName']!.value.toString();
        final comments = _formKey.currentState!.fields['commentspho']?.value.toString();
        final serviceTimeProvider = Provider.of<TimeProvider>(context, listen: false); 
        final service_time_start = '${serviceTimeProvider.startTime.h}:${serviceTimeProvider.startTime.m}';
        final service_time_end = '${serviceTimeProvider.endTime.h}:${serviceTimeProvider.endTime.m}';
        final lengthofDelivery = _formKey.currentState!.fields['length']!.value.toString();
        final cartons = _formKey.currentState!.fields['cartons']!.value.toString();
        final pallets = _formKey.currentState!.fields['pallets']!.value.toString();
        final signature = jsonEncode('data:image/png;base64, ${base64Encode(provider.signature!)}');
        final pictureSources = jsonEncode(context.read<ProofOfDeliveryProvider>().pictureSources);
        final latitude = context.read<LocationProvider>().current!.latitude;
        final longitude = context.read<LocationProvider>().current!.longitude;
        final images = jsonEncode(context.read<ProofOfDeliveryProvider>().base64Images);
        final consignments =  Get.arguments['id'];
        final driver_id =  Get.arguments['runsheet_id'];
        final address_id =   pickupAddresses['id'];
        final space =  Get.arguments['space'];
        final weight = Get.arguments['weight'];
        final customer_reference = Get.arguments['customer_reference'];
        final service_window = pickupAddresses['service_window'];
        final platforms = jsonEncode(["android", "cordova", "mobile", "hybrid"]);
        //  final date_delivered =  Get.arguments['date_delivered'];
        // final device = jsonEncode(Provider.of<ProofOfDeliveryProvider>(context, listen: false).data['device']); 

        final temp = {
          "temperature": temperature,
          "first_name": first_name,
          "last_name": last_name,
          "lengthOfDelivery": lengthofDelivery,
          "pod_type": "full",
          "device":  jsonEncode(deviceinfo),
          "cartons": cartons,
          "pallets": pallets,
          "service_window": service_window,
          "service_time_start": service_time_start,
          "service_time_end": service_time_end,
          "signature": signature,
           "pictureSources": pictureSources,
          "latitude": latitude,
          "longitude": longitude,
          "current_app_version": "3.15.2",
          "app_version": "3.15.2",
          "consignments": consignments,
          "driver_id": driver_id,
          "date_delivered": DateTime.now().toIso8601String(),
          "space": space,
          "weight": weight,
          "customer_reference": customer_reference,
          "comments": comments,
          "address_id": address_id,
          "pictures": images,
          "platforms": platforms,
        };

            context.read<ProofOfDeliveryProvider>().addEntities(temp.entries);
            Get.toNamed(AppRoutes.podphotos, arguments: Get.arguments);
          }
        }
      },
      borderColor: _isValid() ? AppColors.blue : AppColors.grey,
      backgroundColor: _isValid() ? AppColors.blue : AppColors.grey, 
      enabled: _isValid(), 
    ),
),
                    
                    
                           
                            )  ],
                          ),
                        
                        ],
                      ),
                    
                     if (Provider.of<ProofOfDeliveryProvider>(context).selectedDeliveryType == DeliveryType.partial)
                   
                        Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppText.howManyDelivered,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          SizedBox(
                            height: 1.h,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                                PalletContainer(
                                name: 'cartons',
                                heading: AppText.cartons,
                                  icon: SvgPicture.asset(AppSvgs.boundpallets),
                                hintText: '0',
                                 initialValue: context
                                        .read<ProofOfDeliveryProvider>()
                                        .data
                                        .containsKey('cartons')
                                    ? int.parse(context
                                        .read<ProofOfDeliveryProvider>()
                                        .data['cartons'])
                                    : 0,
                                 totalPallet: int.tryParse(Get.arguments?['carton']?.toString() ?? '0') ?? 0,
                                  
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 4.w,
                                vertical: 0,
                              ),
                              ),
                              PalletContainer(
                                name: 'pallets',
                                heading: AppText.pallets,
                                hintText: '0',
                                initialValue: context
                                        .read<ProofOfDeliveryProvider>()
                                        .data
                                        .containsKey('pallet')
                                    ? int.parse(context
                                        .read<ProofOfDeliveryProvider>()
                                        .data['pallet'])
                                    : 0,
                                    
                              
                                totalPallet: int.tryParse(Get.arguments?['pallet']?.toString() ?? '0') ?? 0,
                              ),
                            ],
                          ),
                             SizedBox(
                            height: 3.h,
                          ),
                          Text(
                            "Reason for partial delivery",
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                    
                          SizedBox(
                            height: 1.h,
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
                                child:
                                 CustomTextField(
                            name: 'Reasonpartial',
                            hintText:"Lorem ipsum dolor sit amet consectetur. Leo laoreet malesuada eget ipsum.",
                           borderColor: AppColors.white,
                      
                                  onChanged: (value) {
                    context.read<ProofOfDeliveryProvider>().data['reason'] = value;
                  },
                          ),
                                
                                
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 3.h,
                          ),
                          Text(
                            AppText.deliveryTemperature,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          SizedBox(
                            height: 1.h,
                          ),
                          CustomTextField(
  name: 'temp',
  hintText: AppText.temperature,
  keyboardType: TextInputType.number,
  suffixIcon: Padding(
    padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 2.w),
    child: Text(
      AppText.celsius,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
    ),
  ),
   onChanged: (value) {
    context.read<ProofOfDeliveryProvider>().data['temperature'] = value;
  },
),
                
                          SizedBox(
                            height: 3.h,
                          ),
                          Text(
                            AppText.serviceTime,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          SizedBox(
                            height: 1.h,
                          ),
                         CustomTextField(
                      name: 'service',
                      keyboardType: TextInputType.number,
                      readOnly: true,
                      hintText:  serviceTimeController.text =
                          '${Provider.of<TimeProvider>(context).startTime.h}:${Provider.of<TimeProvider>(context).startTime.m} - ${Provider.of<TimeProvider>(context).endTime.h}:${Provider.of<TimeProvider>(context).endTime.m}',
                             controller:  serviceTimeController,
                      onTap: () {
                        Get.toNamed(AppRoutes.Stopwatch);
                       
                      },
                      suffixIcon: Padding(
                        padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 2.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                             Text(
                              AppText.editHours,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.black.withOpacity(0.5),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                           
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 2.h,
                              color: AppColors.black.withOpacity(0.5),
                            )
                          ],
                        ),
                      ),
                        onChanged: (value) {
                      context.read<ProofOfDeliveryProvider>().data['serviceStart'] = value;
                  context.read<ProofOfDeliveryProvider>().data['serviceEnd'] = value;
                  },
                    ),
                    
                          SizedBox(
                            height: 1.h,
                          ),
                          CustomTextField(
                            name: 'length',
                            hintText: AppText.lengthOfDelivery,
                            keyboardType: TextInputType.number,
                            suffixIcon: Padding(
                              padding:
                    EdgeInsets.symmetric(vertical: 2.h, horizontal: 2.w),
                              child: Text(
                                AppText.minutes,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                              ),
                            ),
                             
                                    onChanged: (value) {
                    context.read<ProofOfDeliveryProvider>().data['lengthOfDelivery'] = value;
                  },
                          ),
                          SizedBox(
                            height: 3.h,
                          ),
                          Text(
                            AppText.receiverConfirmation,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          SizedBox(
                            height: 1.h,
                          ),
                           CustomTextField(
                            name: 'receiverFirstName',
                            hintText: AppText.receiverFirstName,
                           
                                onChanged: (value) {
                    context.read<ProofOfDeliveryProvider>().data['first_name'] = value;
                  },
                                  
                          ),
                          SizedBox(
                            height: 1.h,
                          ),
                           CustomTextField(
                            name: 'receiverLastName',
                            hintText: AppText.receiverLastName,
                          
                                  onChanged: (value) {
                    context.read<ProofOfDeliveryProvider>().data['last_name'] = value;
                  },
                          ),
                          SizedBox(
                            height: 1.h,
                          ),
Consumer<ProofOfDeliveryProvider>(
  builder: (context, provider, _) {
    return SizedBox(
      width: 90.w,
      child: GestureDetector(
        onTap: () async {
          // Check if the signature is not empty and showSignature is false
          if (controller.isEmpty && !provider.showSignature) {
            provider.setShowSignature(true);
            provider.showSignaturePopup(context, controller);
            final bytes = await controller.toPngBytes();
            if (bytes != null) {
              provider.updateSignatureData(bytes);
              provider.addEntities({
                "signature": 'data:image/png;base64, ${base64Encode(bytes)}',
              });
            }
          }
        },
        child: Stack(
          children: [
            if (controller.isEmpty && !provider.showSignature)
              Container(
                height: 25.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.navyBlue),
                  borderRadius: BorderRadius.all(
                    Radius.circular(5.sp),
                  ),
                ),
                padding: EdgeInsets.symmetric(
                  vertical: 1.h,
                  horizontal: 2.w,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 50.sp,
                      height: 50.sp,
                      child: Image.asset(
                        AppImages.handWithPen,
                      ),
                    ),
                    Text(
                      AppText.tapHereToSign,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    )
                  ],
                ),
              ),
            if (provider.showSignature)
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.navyBlue),
                  borderRadius: BorderRadius.all(
                    Radius.circular(5.sp),
                  ),
                ),
                padding: EdgeInsets.symmetric(
                  vertical: 1.h,
                  horizontal: 2.w,
                ),
                child: Column(
                  children: [
                    IgnorePointer(
                      child: Signature(
                        dynamicPressureSupported: false,
                        controller: controller,
                        width: 90.w,
                        height: 20.h,
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                    const Divider(
                      height: 1,
                      thickness: 2,
                      color: AppColors.grey,
                    ),
                    CupertinoButton(
                      child: const Text(
                        "Redo",
                        style: TextStyle(color: Colors.blue),
                      ),
                      onPressed: () {
                        provider.clearSignatureAndShowPopup(context, controller);
                      },
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  },
),

                        
                         SizedBox(
  height: 1.h,
),
Row(
  mainAxisAlignment: MainAxisAlignment.end,
  children: [
    SizedBox(
      width: 50.w,
      child: Consumer<ProofOfDeliveryProvider>(
  builder: (context, provider, _) => CustomButton(
    label: "Next",
    onPressed: () {
      if (_formKey.currentState != null) {
        final temperature = _formKey.currentState!.fields['temp']!.value.toString();
        final first_name = _formKey.currentState!.fields['receiverFirstName']!.value.toString();
        final last_name = _formKey.currentState!.fields['receiverLastName']!.value.toString();
        final comments = _formKey.currentState!.fields['commentspho']?.value.toString();
        final serviceTimeProvider = Provider.of<TimeProvider>(context, listen: false); 
        final service_time_start = '${serviceTimeProvider.startTime.h}:${serviceTimeProvider.startTime.m}';
        final service_time_end = '${serviceTimeProvider.endTime.h}:${serviceTimeProvider.endTime.m}';
        final lengthofDelivery = _formKey.currentState!.fields['length']!.value.toString();
        final cartons = _formKey.currentState!.fields['cartons']!.value.toString();
        final pallets = _formKey.currentState!.fields['pallets']!.value.toString();
        final signature = jsonEncode('data:image/png;base64, ${base64Encode(provider.signature!)}');
        final reason = _formKey.currentState!.fields['Reasonpartial']!.value.toString();
        final pictureSources = jsonEncode(context.read<ProofOfDeliveryProvider>().pictureSources);
        final latitude = context.read<LocationProvider>().current!.latitude;
        final longitude = context.read<LocationProvider>().current!.longitude;
        final images = jsonEncode(context.read<ProofOfDeliveryProvider>().base64Images);
        final consignments =  Get.arguments['id'];
        final driver_id =  Get.arguments['runsheet_id'];
        final address_id =  pickupAddresses['id'];
        final space =  Get.arguments['space'];
        final weight = Get.arguments['weight'];
        final customer_reference = Get.arguments['customer_reference'];
        final service_window = pickupAddresses['service_window'];
        final platforms = jsonEncode(["android", "cordova", "mobile", "hybrid"]);
        //final device = context.read<ProofOfDeliveryProvider>().data['device'];
        //final date_delivered =  Get.arguments['date_delivered'];

        final temp = {
          "pod_type": "partial",
          "temperature": temperature,
          "first_name": first_name,
          "last_name": last_name,
          "device":  jsonEncode(deviceinfo),
          "lengthofDelivery": lengthofDelivery,
          "cartons": cartons,
          "pallets": pallets,
          "service_window":service_window,
          "service_time_start": service_time_start,
          "service_time_end": service_time_end,
          "signature": signature,
          "reason": reason,
          "pictureSources": pictureSources,
          "latitude": latitude,
          "longitude": longitude,
          "current_app_version": "3.15.2",
          "app_version": "3.15.2",
          "consignments":  consignments,
          "driver_id":  driver_id,
          "date_delivered": DateTime.now().toIso8601String(),
          "space": space,
          "weight": weight,
          "customer_reference": customer_reference,
          "comments": comments,
          "address_id": address_id,
          "pictures": images,       
        "lodgeError": jsonEncode({ "comments":  comments, "errorPictures":   images, "errorPictureSources":  pictureSources,  }),
        // "lodgeError": comments,
          "platforms": platforms,
           
        };

        context.read<ProofOfDeliveryProvider>().addEntities(temp.entries);
       Get.toNamed(AppRoutes.podphotos, arguments: Get.arguments);
      
      } else {
        print("Form key is null.");
      }
       },
       borderColor: _isValid() ? AppColors.blue : AppColors.grey,
      backgroundColor: _isValid() ? AppColors.blue : AppColors.grey, 
      enabled: _isValid(), 
  ),
),

    ),
  
  ],
),

                        ],
                      ),
                      
                       if (provider.selectedDeliveryType == DeliveryType.none)
                         Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppText.howManyDelivered,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          SizedBox(
                            height: 1.h,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              PalletContainer(
                                name: 'cartons',
                                heading: AppText.cartons,
                                 icon: SvgPicture.asset(AppSvgs.boundpallets),
                                hintText: '0',
                                initialValue: 0,
                                totalPallet: 5,
                                isErrorState: true,
                              ),
                              const PalletContainer(
                                name: 'pallets',
                                heading: AppText.pallets,
                                hintText: '0',
                                initialValue: 0,
                                totalPallet: 5,
                                isErrorState: true,
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 3.h,
                          ),
                          Text(
                            "Reason for non delivery",
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          SizedBox(
                            height: 1.h,
                          ),
                           Text(
                            "Select a reason the delivery could not be completed. If you are unsure if you can complete the delivery please open the chat and message our admin staff.",
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          SizedBox(
                            height: 3.h,
                          ),
                      Consumer<ProofOfDeliveryProvider>(
                            builder: (context, provider, _) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                    
                               
                    const CustomContainer(
                      title: 'Wrong Address',
                      description: 'Address is wrong or the location has closed',
                    ),
                    SizedBox(
                          height: 3.h,
                        ),
                    const CustomContainer(
                      title: 'Receiver Not Open',
                      description: 'The receiver is unable to receive goods',
                    ),
                    SizedBox(
                          height: 3.h,
                        ),
                    const CustomContainer(
                         title: 'Temperature issue',
                      description: 'The stock is not the correct temperature',
                        ),
                        SizedBox(
                          height: 3.h,
                        ),
                        const CustomContainer(
                         title: 'Damaged Goods',
                      description: 'The packaging or goods have been damaged',
                        ),
                        SizedBox(
                          height: 3.h,
                        ),
                         const CustomContainer(
                          title: 'Other Rejection',
                          description: 'The customer refused the goods ',
                        )
                    
                                ]);}),
                    
                    
                     
                        
                    
                          SizedBox(
                            height: 1.h,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              SizedBox(
                                width: 50.w,
                                child: CustomButton(label: "Submit POD",backgroundColor: AppColors.red,borderColor: AppColors.red,
                     onPressed: () {
  if (_formKey.currentState != null) {
    final provider = context.read<ProofOfDeliveryProvider>();
    final rejection_reason = provider.data['rejection_reason']; 
    final consignments =  Get.arguments['consignments'];
    final driver_id =  Get.arguments['driver_id'];
    final address_id =  Get.arguments['address_id'];
    final date_delivered =  Get.arguments['date_delivered'];
    final space =  Get.arguments['space'];
    final weight = Get.arguments['weight'];
    final customer_reference = Get.arguments['customer_reference'];
    final service_window = Get.arguments['service_window'];
    final pictureSources = jsonEncode(provider.pictureSources);
    final images = jsonEncode(provider.base64Images);
    final device = jsonEncode(provider.data['device']);
 final commentss = _formKey.currentState!.fields['Order rejection']?.value.toString();
  final platforms = jsonEncode(["android", "cordova", "mobile", "hybrid"]);
 
      String? comments = '';
    int error_type = 1;

   
    if (rejection_reason == 'Temperature issue') {
      comments = 'The stock is not the correct temperature';
      error_type = 13;
    } else if (rejection_reason == 'Wrong Address') {
      comments = 'Address is wrong or the location has closed';
      error_type = 1; 
    } else if (rejection_reason == 'Receiver Not Open') {
     comments = 'The receiver is unable to receive goods';
      error_type = 2; 
    } else if (rejection_reason == 'Damaged Goods') {
      comments = 'The packaging or goods have been damaged';
      error_type = 3; //
    } else if (rejection_reason == 'Other Rejection') {
     comments = commentss;
      error_type = 6; 
    }

    final temp = {
      "pod_type": "none",
      "error_type": error_type,
      "rejection_reason": rejection_reason,
      "comments": comments,
      "record_error": true,
      "adhoc_charges": false,
      "space": space,
      "weight": weight,
      "consignments": consignments,
      "device":  jsonEncode(deviceinfo),
      "date_delivered": DateTime.now().toIso8601String(),
      "driver_id": driver_id,
      "first_name": "",
      "last_name": "",
      "customer_probe_temp": "",
      "driver_probe_temp": "",
      "driver_infrared_temp": "",
      "where_temp_checked": "",
      "customer_probe_checked": null,
      "customer_probe_why": null,
      "pictures": images,
      "pictureSources": pictureSources,
      "app_version": "3.15.2",
      "current_app_version": "3.15.2",
      "platforms":  platforms,
    };

    provider.addEntities(temp.entries);
    submitData();
   //postData();
  } else {
    print("Form key is null");
  }
},


                      
                      )),
                            ],
                          ),
                        ],
                      ),
                       
                                 SizedBox(
                            height: 1.h,
                          ),   ],
                    
                  
                  
                 
                             
                    
              ),
            ),
          ),
        ),
      ),
     ) );
  }
   Future<void> postDataToApi() async {
  var provider = Provider.of<ProofOfDeliveryProvider>(context, listen: false);
  var databaseProvider = Provider.of<DatabaseProvider>(context, listen: false);
  AuthenticationState state = BlocProvider.of<AuthenticationCubit>(context).state;
  
  if (state is Authenticated) {
    try {
      final taskDatabase = TaskDatabase(_database!);
      final tasks = await taskDatabase.read();
      print(tasks);

      if (tasks.isEmpty) {
        print('No tasks to send');
        return;
      }

      final Map postData = context.read<ProofOfDeliveryProvider>().data;

      String url = '';

      switch (provider.selectedDeliveryType) {
        case DeliveryType.full:
          url = AppHost.podfull;
          break;
        case DeliveryType.partial:
          url = AppHost.podpartial;
          break;
        case DeliveryType.none:
          List<String> rejectionReasons = provider.selectedOrderRejectionReasons as List<String>;
          for (String rejectionReason in rejectionReasons) {
            print('Rejection Reason: $rejectionReason');
            switch (rejectionReason) {
              case "Temperature issue":
                url = AppHost.temperateissue;
                break;
              case "Wrong Address":
                url = AppHost.wrongaddress;
                break;
              case "Damaged Goods":
                url = AppHost.damagegoods;
                break;
              case "Receiver Not Open":
                url = AppHost.notopen;
                break;
              case "Other Rejection":
                url = AppHost.otherrejection;
                break;
              default:
                throw Exception('Invalid rejection reason: $rejectionReason');
            }
          }
          break;
      }

     final podType = provider.selectedDeliveryType.toString().split('.').last;
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
        print('Data posted successfully: ${response.body}');
        await taskDatabase.deleteAll();
      } else {
        print('Failed to post data: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error posting data to API: $e');
    }
  }
}
   
}
class CustomContainer extends StatefulWidget {
  final String title;
  final String description;

  const CustomContainer({
    Key? key,
    required this.title,
    required this.description,
  }) : super(key: key);

  @override
  _CustomContainerState createState() => _CustomContainerState();
}

class _CustomContainerState extends State<CustomContainer> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProofOfDeliveryProvider>(context);
    bool isChecked = provider.selectedOrderRejectionReasons.contains(widget.title);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (!isChecked) {
            provider.clearOrderRejectionReasons();
            provider.updateOrderRejectionReason(widget.title);
          } else {
            provider.clearOrderRejectionReasons();
          }
        });
      },
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.sp),
            decoration: BoxDecoration(
              color: AppColors.grey,
              borderRadius: BorderRadius.circular(10.sp),
              border: Border.all(
                color: isChecked ? AppColors.blue : Colors.transparent,
                width: 2.0,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                SizedBox(height: 1.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.description,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (isChecked)
                      CircleAvatar(
                        radius: 8.sp,
                        backgroundColor: AppColors.blue,
                        child: Center(
                          child: Icon(
                            Icons.check,
                            color: AppColors.white,
                            size: 8.sp,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          if (isChecked && widget.title == 'Other Rejection')
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 3.h,
                ),
                Text(
                  "Order Rejection",
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                Text(
                  "Please provide more detail",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                SizedBox(
                  height: 1.h,
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
                        name: 'Order rejection',
                        hintText:
                            "Lorem ipsum dolor sit amet consectetur. Leo laoreet malesuada eget ipsum.",
                        onChanged: (value) {
                          context
                              .read<ProofOfDeliveryProvider>()
                              .data['comments'] = value;
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }
}
