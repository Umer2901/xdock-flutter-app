// ignore_for_file: non_constant_identifier_names, unused_local_variable

import 'dart:convert';
import 'dart:io';
import 'package:coldxpress/providers/pof_services_provider.dart';
import 'package:device_info_plus/device_info_plus.dart';
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
  bool showSignature = false;
  final _formKey = GlobalKey<FormBuilderState>();
  bool isLoading = false;
  Map<String, dynamic> deviceinfo = {};
  late Map productTypes;
  late Map deliveryAddresses;
  late Map pickupAddresses;
  List groupedConsignments = [];

  @override
  void initState() {
    super.initState();
    _setDeviceInfo();
    config();
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
    debugPrint("our group data: ${Get.arguments['is_group']}");
  }

  config() async {
    context.read<LocationProvider>().getCurrentLocation();
  }

  void showSignaturePopup(SignatureController controller) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          backgroundColor: Colors.white,
          child: Transform.rotate(
            angle: 90 * 3.14159 / 180,
            child: SizedBox(
              height: 47.h,
              width: 80.w,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CupertinoButton(
                        child: const Text(
                          "Cancel",
                          style: TextStyle(color: Colors.blue),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          controller.clear();
                          context
                              .read<ProofOfDeliveryProvider>()
                              .resetSignatureState();
                        },
                      ),
                      Text(
                        "Signature",
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      CupertinoButton(
                        child: const Text(
                          "Done",
                          style: TextStyle(color: Colors.blue),
                        ),
                        onPressed: () async {
                          await controller.toPngBytes().then(
                            (bytes) {
                              if (bytes != null) {
                                context
                                    .read<ProofOfDeliveryProvider>()
                                    .updateSignatureData(bytes);
                                Navigator.pop(context);
                              }
                            },
                          );
                        },
                      ),
                    ],
                  ),
                  Center(
                    child: Container(
                      height: 24.h,
                      width: 90.w,
                      alignment: Alignment.center,
                      child: Signature(
                        controller: controller,
                        width: 85.w,
                        height: 20.h,
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Center(
                        child: Divider(
                          height: 1,
                          thickness: 2,
                          color: AppColors.grey,
                        ),
                      ),
                      CupertinoButton(
                        child: const Text(
                          "Clear",
                          style: TextStyle(color: Colors.blue),
                        ),
                        onPressed: () {
                          controller.clear();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
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
//    print("Device Info: $deviceinfo");
    } catch (e) {
      //  print("Error fetching device info: $e");
    }

    if (deviceinfo.isNotEmpty) {
      // ignore: use_build_context_synchronously
      context.read<ProofOfDeliveryProvider>().setDeviceInfo(deviceinfo);
      debugPrint("Device info set in provider: $deviceinfo");
    } else {
      debugPrint("Device info is empty. Cannot set in the provider.");
    }
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<ProofOfDeliveryProvider>(context);
    debugPrint({Get.arguments}.toString());
    bool isGroupedConsignment = groupedConsignments.isNotEmpty;

    bool isValid() {
      final cartons = _formKey.currentState!.fields['cartons']!.value;
      final pallets = _formKey.currentState!.fields['pallets']!.value;
      final temperature = _formKey.currentState!.fields['temp']!.value;
      final lengthofDelivery = _formKey.currentState!.fields['length']!.value;
      final receiverFirstName =
          _formKey.currentState!.fields['receiverFirstName']!.value;
      final receiverLastName =
          _formKey.currentState!.fields['receiverLastName']!.value;
      final signature = provider.signature;
      return cartons != null &&
          pallets != null &&
          temperature != null &&
          lengthofDelivery != null &&
          receiverFirstName != null &&
          receiverLastName != null &&
          signature != null;
    }

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
                                  // ignore: deprecated_member_use
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
                                  (Get.arguments?['consignment_type'] ==
                                              'delivery'
                                          ? deliveryAddresses['company_name']
                                          : pickupAddresses['company_name']) ??
                                      'Not Provided',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium,
                                ),
                                Text(
                                  'Recipient: ${(Get.arguments?['consignment_type'] == 'delivery' ? deliveryAddresses['customer_name'] : pickupAddresses['customer_name']) ?? 'Not Provided'}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  Get.arguments?['consignment_type'] ==
                                          'delivery'
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
                          context
                              .read<ProofOfDeliveryProvider>()
                              .updateSelectedDeliveryType(newValue!);
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
                          if (!isGroupedConsignment)
                            if (Get.arguments?['consignment_type'] != 'pickup')
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
                          if (!isGroupedConsignment)
                            if (Get.arguments?['consignment_type'] != 'pickup')
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
                      if (Provider.of<ProofOfDeliveryProvider>(context)
                              .selectedDeliveryType ==
                          DeliveryType.full)
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
                                  //  initialValue: int.tryParse(context.read<ProofOfDeliveryProvider>().data['cartons']?.toString() ?? '0') ?? 0,
                                  initialValue: isGroupedConsignment
                                      ? (Get.arguments?['carton'] ?? 0)
                                      : (int.tryParse(context
                                                  .read<
                                                      ProofOfDeliveryProvider>()
                                                  .data['cartons']
                                                  ?.toString() ??
                                              '0') ??
                                          0),
                                  totalPallet: int.tryParse(Get
                                              .arguments?['carton']
                                              ?.toString() ??
                                          '0') ??
                                      0,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 4.w,
                                    vertical: 0,
                                  ),
                                ),
                                PalletContainer(
                                  name: 'pallets',
                                  heading: AppText.pallets,
                                  hintText: '0',
                                  //initialValue:int.tryParse(context.read<ProofOfDeliveryProvider>().data['pallet']?.toString() ?? '0') ?? 0,
                                  initialValue: isGroupedConsignment
                                      ? (Get.arguments?['pallet'] ?? 0)
                                      : (int.tryParse(context
                                                  .read<
                                                      ProofOfDeliveryProvider>()
                                                  .data['pallet']
                                                  ?.toString() ??
                                              '0') ??
                                          0),
                                  totalPallet: int.tryParse(Get
                                              .arguments?['pallet']
                                              ?.toString() ??
                                          '0') ??
                                      0,
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
                                padding: EdgeInsets.symmetric(
                                    vertical: 2.h, horizontal: 2.w),
                                child: Text(
                                  AppText.celsius,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                              ),
                              onChanged: (value) {
                                context
                                    .read<ProofOfDeliveryProvider>()
                                    .data['temperature'] = value;
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
                              hintText: serviceTimeController.text =
                                  '${Provider.of<TimeProvider>(context).formattedStartTime} - ${Provider.of<TimeProvider>(context).formattedEndTime}',
                              controller: serviceTimeController,
                              onTap: () {
                                Get.toNamed(
                                  AppRoutes.stopwatch,
                                  arguments: Get.arguments,
                                );
                              },
                              suffixIcon: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 2.h, horizontal: 2.w),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      AppText.editHours,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: AppColors.black
                                                .withOpacity(0.5),
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: 2.h,
                                      color: AppColors.black.withOpacity(0.5),
                                    ),
                                  ],
                                ),
                              ),
                              onChanged: (value) {
                                context
                                    .read<ProofOfDeliveryProvider>()
                                    .data['service_time_start'] = value;
                                context
                                    .read<ProofOfDeliveryProvider>()
                                    .data['service_time_end'] = value;
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
                                padding: EdgeInsets.symmetric(
                                    vertical: 2.h, horizontal: 2.w),
                                child: Text(
                                  AppText.minutes,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                              ),
                              onChanged: (value) {
                                context
                                    .read<ProofOfDeliveryProvider>()
                                    .data['lengthOfDelivery'] = value;
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
                                context
                                    .read<ProofOfDeliveryProvider>()
                                    .data['first_name'] = value;
                              },
                            ),
                            SizedBox(
                              height: 1.h,
                            ),
                            CustomTextField(
                              name: 'receiverLastName',
                              hintText: AppText.receiverLastName,
                              onChanged: (value) {
                                context
                                    .read<ProofOfDeliveryProvider>()
                                    .data['last_name'] = value;
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
                                      if (!provider.showSignature) {
                                        provider.setShowSignature(true);
                                        showSignaturePopup(controller);
                                        final bytes =
                                            await controller.toPngBytes();
                                        if (bytes != null) {
                                          provider.updateSignatureData(bytes);
                                          provider.addEntities({
                                            "signature":
                                                'data:image/png;base64, ${base64Encode(bytes)}',
                                          });
                                        }
                                      }
                                    },
                                    child: Stack(
                                      children: [
                                        if (controller.isEmpty &&
                                            !provider.showSignature)
                                          Container(
                                            height: 25.h,
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: AppColors.navyBlue),
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(5.sp),
                                              ),
                                            ),
                                            padding: EdgeInsets.symmetric(
                                              vertical: 1.h,
                                              horizontal: 2.w,
                                            ),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
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
                                                      ?.copyWith(
                                                          fontWeight:
                                                              FontWeight.w700),
                                                )
                                              ],
                                            ),
                                          ),
                                        if (provider.showSignature)
                                          Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: AppColors.navyBlue),
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
                                                    dynamicPressureSupported:
                                                        false,
                                                    controller: controller,
                                                    width: 90.w,
                                                    height: 20.h,
                                                    backgroundColor:
                                                        Colors.transparent,
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
                                                    style: TextStyle(
                                                        color: Colors.blue),
                                                  ),
                                                  onPressed: () {
                                                    provider
                                                        .clearSignatureAndShowPopup(
                                                            controller);
                                                    showSignaturePopup(
                                                        controller);
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
                                        if (int.parse(_formKey.currentState!
                                                    .fields['cartons']!.value
                                                    .toString()) <
                                                Get.arguments['carton'] ||
                                            int.parse(_formKey.currentState!
                                                    .fields['pallets']!.value
                                                    .toString()) <
                                                Get.arguments['pallet']) {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.sp),
                                                ),
                                                backgroundColor:
                                                    AppColors.white,
                                                titlePadding:
                                                    EdgeInsets.symmetric(
                                                  vertical: 1.h,
                                                  horizontal: 2.w,
                                                ),
                                                contentPadding: EdgeInsets.zero,
                                                content: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
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
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                        vertical: 1.h,
                                                        horizontal: 2.w,
                                                      ),
                                                      child: Text(
                                                        "You are missing cartons or pallets. Please fix this mistake.",
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodyLarge
                                                            ?.copyWith(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                            ),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                actions: <Widget>[
                                                  SizedBox(height: 2.h),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceAround,
                                                    children: [
                                                      CustomButton(
                                                        height: 5.h,
                                                        width: 30.w,
                                                        label: 'OK',
                                                        backgroundColor:
                                                            AppColors.white,
                                                        borderColor:
                                                            AppColors.yellow,
                                                        foregroundColor:
                                                            AppColors.black,
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
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
                                            final temperature = int.tryParse(
                                                    _formKey
                                                        .currentState!
                                                        .fields['temp']!
                                                        .value) ??
                                                0;
                                            final first_name = _formKey
                                                .currentState!
                                                .fields['receiverFirstName']!
                                                .value
                                                .toString();
                                            final last_name = _formKey
                                                .currentState!
                                                .fields['receiverLastName']!
                                                .value
                                                .toString();
                                            final comments = _formKey
                                                .currentState!
                                                .fields['commentspho']
                                                ?.value
                                                .toString();
                                            final serviceTimeProvider =
                                                Provider.of<TimeProvider>(
                                                    context,
                                                    listen: false);
                                            final service_time_start =
                                                '${serviceTimeProvider.startTime}';
                                            final service_time_end =
                                                '${serviceTimeProvider.endTime}';
                                            final lengthofDelivery =
                                                int.tryParse(_formKey
                                                        .currentState!
                                                        .fields['length']!
                                                        .value) ??
                                                    0;
                                            final cartons = int.tryParse(
                                                    _formKey
                                                        .currentState!
                                                        .fields['cartons']!
                                                        .value) ??
                                                0;
                                            final pallets = int.tryParse(
                                                    _formKey
                                                        .currentState!
                                                        .fields['pallets']!
                                                        .value) ??
                                                0;
                                            final signature = jsonEncode(
                                                'data:image/png;base64, ${base64Encode(provider.signature!)}');
                                            final pictureSources = jsonEncode(
                                                context
                                                    .read<
                                                        ProofOfDeliveryProvider>()
                                                    .pictureSources);
                                            final latitude = context
                                                .read<LocationProvider>()
                                                .current!
                                                .latitude;
                                            final longitude = context
                                                .read<LocationProvider>()
                                                .current!
                                                .longitude;
                                            final images = jsonEncode(context
                                                .read<ProofOfDeliveryProvider>()
                                                .base64Images);
                                            final consignments =
                                                Get.arguments['id'];
                                            final driver_id =
                                                Get.arguments['runsheet_id'];
                                            final address_id =
                                                pickupAddresses['id'];
                                            final space =
                                                Get.arguments['space'];
                                            final weight =
                                                Get.arguments['weight'];
                                            final customer_reference =
                                                Get.arguments[
                                                    'customer_reference'];
                                            final service_window =
                                                pickupAddresses[
                                                    'service_window'];
                                            final platforms = jsonEncode([
                                              "android",
                                              "cordova",
                                              "mobile",
                                              "hybrid"
                                            ]);

                                            final consignmentType =
                                                Get.arguments?[
                                                        'consignment_type'] ??
                                                    'delivery';
                                            if (groupedConsignments
                                                .isNotEmpty) {
                                              provider.data['pod_type'] =
                                                  consignmentType == 'delivery'
                                                      ? 2
                                                      : 5;
                                            } else {
                                              switch (provider
                                                  .selectedDeliveryType) {
                                                case DeliveryType.full:
                                                  provider.data['pod_type'] =
                                                      consignmentType ==
                                                              'delivery'
                                                          ? 0
                                                          : 4;
                                                  break;
                                                case DeliveryType.partial:
                                                case DeliveryType.none:
                                              }
                                            }

                                            final temp = {
                                              "temperature": temperature,
                                              "first_name": first_name,
                                              "last_name": last_name,
                                              "lengthOfDelivery":
                                                  lengthofDelivery,
                                              "pod_type":
                                                  provider.data['pod_type'],
                                              "device": jsonEncode(deviceinfo),
                                              "carton": cartons,
                                              "pallet": pallets,
                                              "service_window": service_window,
                                              "service_time_start":
                                                  service_time_start,
                                              "service_time_end":
                                                  service_time_end,
                                              "signature": signature,
                                              "pictureSources": pictureSources,
                                              "latitude": latitude,
                                              "longitude": longitude,
                                              "current_app_version": "3.15.2",
                                              "app_version": "3.15.2",
                                              "consignments":
                                                  jsonEncode([consignments]),
                                              "driver_id": driver_id,
                                              "date_delivered": DateTime.now()
                                                  .toIso8601String(),
                                              "space": space,
                                              "weight": weight,
                                              "customer_reference":
                                                  customer_reference,
                                              "comments": comments,
                                              "address_id": address_id,
                                              "pictures": images,
                                              "platforms": platforms,
                                            };

                                            context
                                                .read<ProofOfDeliveryProvider>()
                                                .addEntities(temp.entries);
                                            Get.toNamed(AppRoutes.podphotos,
                                                arguments: Get.arguments);
                                          }
                                        }
                                      },
                                      borderColor: isValid()
                                          ? AppColors.blue
                                          : AppColors.grey,
                                      backgroundColor: isValid()
                                          ? AppColors.blue
                                          : AppColors.grey,
                                      enabled: isValid(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      if (Provider.of<ProofOfDeliveryProvider>(context)
                              .selectedDeliveryType ==
                          DeliveryType.partial)
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
                                  initialValue: int.tryParse(context
                                              .read<ProofOfDeliveryProvider>()
                                              .data['cartons']
                                              ?.toString() ??
                                          '0') ??
                                      0,
                                  totalPallet: int.tryParse(Get
                                              .arguments?['carton']
                                              ?.toString() ??
                                          '0') ??
                                      0,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 4.w,
                                    vertical: 0,
                                  ),
                                ),
                                PalletContainer(
                                  name: 'pallets',
                                  heading: AppText.pallets,
                                  hintText: '0',
                                  initialValue: int.tryParse(context
                                              .read<ProofOfDeliveryProvider>()
                                              .data['pallet']
                                              ?.toString() ??
                                          '0') ??
                                      0,
                                  totalPallet: int.tryParse(Get
                                              .arguments?['pallet']
                                              ?.toString() ??
                                          '0') ??
                                      0,
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
                                    border:
                                        Border.all(color: AppColors.navyBlue),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(5.sp),
                                    ),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      vertical: 1.h, horizontal: 2.w),
                                  child: CustomTextField(
                                    name: 'Reasonpartial',
                                    hintText:
                                        "Lorem ipsum dolor sit amet consectetur. Leo laoreet malesuada eget ipsum.",
                                    borderColor: AppColors.white,
                                    onChanged: (value) {
                                      context
                                          .read<ProofOfDeliveryProvider>()
                                          .data['reason'] = value;
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
                                padding: EdgeInsets.symmetric(
                                    vertical: 2.h, horizontal: 2.w),
                                child: Text(
                                  AppText.celsius,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                              ),
                              onChanged: (value) {
                                context
                                    .read<ProofOfDeliveryProvider>()
                                    .data['temperature'] = value;
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
                              hintText: serviceTimeController.text =
                                  '${Provider.of<TimeProvider>(context).formattedStartTime} - ${Provider.of<TimeProvider>(context).formattedEndTime}',
                              controller: serviceTimeController,
                              onTap: () {
                                Get.toNamed(
                                  AppRoutes.stopwatch,
                                  arguments: Get.arguments,
                                );
                              },
                              suffixIcon: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 2.h, horizontal: 2.w),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      AppText.editHours,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: AppColors.black
                                                .withOpacity(0.5),
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: 2.h,
                                      color: AppColors.black.withOpacity(0.5),
                                    ),
                                  ],
                                ),
                              ),
                              onChanged: (value) {
                                context
                                    .read<ProofOfDeliveryProvider>()
                                    .data['service_time_start'] = value;
                                context
                                    .read<ProofOfDeliveryProvider>()
                                    .data['service_time_end'] = value;
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
                                padding: EdgeInsets.symmetric(
                                    vertical: 2.h, horizontal: 2.w),
                                child: Text(
                                  AppText.minutes,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                              ),
                              onChanged: (value) {
                                context
                                    .read<ProofOfDeliveryProvider>()
                                    .data['lengthOfDelivery'] = value;
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
                                context
                                    .read<ProofOfDeliveryProvider>()
                                    .data['first_name'] = value;
                              },
                            ),
                            SizedBox(
                              height: 1.h,
                            ),
                            CustomTextField(
                              name: 'receiverLastName',
                              hintText: AppText.receiverLastName,
                              onChanged: (value) {
                                context
                                    .read<ProofOfDeliveryProvider>()
                                    .data['last_name'] = value;
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
                                      if (controller.isEmpty &&
                                          !provider.showSignature) {
                                        provider.setShowSignature(true);
                                        showSignaturePopup(controller);
                                        final bytes =
                                            await controller.toPngBytes();
                                        if (bytes != null) {
                                          provider.updateSignatureData(bytes);
                                          provider.addEntities({
                                            "signature":
                                                'data:image/png;base64, ${base64Encode(bytes)}',
                                          });
                                        }
                                      }
                                    },
                                    child: Stack(
                                      children: [
                                        if (controller.isEmpty &&
                                            !provider.showSignature)
                                          Container(
                                            height: 25.h,
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: AppColors.navyBlue),
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(5.sp),
                                              ),
                                            ),
                                            padding: EdgeInsets.symmetric(
                                              vertical: 1.h,
                                              horizontal: 2.w,
                                            ),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
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
                                                      ?.copyWith(
                                                          fontWeight:
                                                              FontWeight.w700),
                                                )
                                              ],
                                            ),
                                          ),
                                        if (provider.showSignature)
                                          Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: AppColors.navyBlue),
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
                                                    dynamicPressureSupported:
                                                        false,
                                                    controller: controller,
                                                    width: 90.w,
                                                    height: 20.h,
                                                    backgroundColor:
                                                        Colors.transparent,
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
                                                    style: TextStyle(
                                                        color: Colors.blue),
                                                  ),
                                                  onPressed: () {
                                                    provider
                                                        .clearSignatureAndShowPopup(
                                                            controller);
                                                    showSignaturePopup(
                                                        controller);
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
                                        if (_formKey.currentState != null) {
                                          final temperature = int.tryParse(
                                                  _formKey.currentState!
                                                      .fields['temp']!.value) ??
                                              0;
                                          final first_name = _formKey
                                              .currentState!
                                              .fields['receiverFirstName']!
                                              .value
                                              .toString();
                                          final last_name = _formKey
                                              .currentState!
                                              .fields['receiverLastName']!
                                              .value
                                              .toString();
                                          final comments = _formKey
                                              .currentState!
                                              .fields['commentspho']
                                              ?.value
                                              .toString();
                                          final serviceTimeProvider =
                                              Provider.of<TimeProvider>(context,
                                                  listen: false);
                                          final service_time_start =
                                              '${serviceTimeProvider.startTime}:${serviceTimeProvider.startTime}';
                                          final service_time_end =
                                              '${serviceTimeProvider.endTime}:${serviceTimeProvider.endTime}';
                                          final lengthofDelivery = int.tryParse(
                                                  _formKey
                                                      .currentState!
                                                      .fields['length']!
                                                      .value) ??
                                              0;
                                          final cartons = int.tryParse(_formKey
                                                  .currentState!
                                                  .fields['cartons']!
                                                  .value) ??
                                              0;
                                          final pallets = int.tryParse(_formKey
                                                  .currentState!
                                                  .fields['pallets']!
                                                  .value) ??
                                              0;
                                          final signature = jsonEncode(
                                              'data:image/png;base64, ${base64Encode(provider.signature!)}');
                                          final reason = _formKey.currentState!
                                              .fields['Reasonpartial']!.value
                                              .toString();
                                          final pictureSources = jsonEncode(
                                              context
                                                  .read<
                                                      ProofOfDeliveryProvider>()
                                                  .pictureSources);
                                          final latitude = context
                                              .read<LocationProvider>()
                                              .current!
                                              .latitude;
                                          final longitude = context
                                              .read<LocationProvider>()
                                              .current!
                                              .longitude;
                                          final images = jsonEncode(context
                                              .read<ProofOfDeliveryProvider>()
                                              .base64Images);
                                          final consignments =
                                              Get.arguments['id'];
                                          final driver_id =
                                              Get.arguments['runsheet_id'];
                                          final address_id =
                                              pickupAddresses['id'];
                                          final space = Get.arguments['space'];
                                          final weight =
                                              Get.arguments['weight'];
                                          final customer_reference = Get
                                              .arguments['customer_reference'];
                                          final service_window =
                                              pickupAddresses['service_window'];
                                          final platforms = jsonEncode([
                                            "android",
                                            "cordova",
                                            "mobile",
                                            "hybrid"
                                          ]);

                                          final temp = {
                                            "pod_type": "1",
                                            "temperature": temperature,
                                            "first_name": first_name,
                                            "last_name": last_name,
                                            "device": jsonEncode(deviceinfo),
                                            "lengthofDelivery":
                                                lengthofDelivery,
                                            "carton": cartons,
                                            "pallet": pallets,
                                            "service_window": service_window,
                                            "service_time_start":
                                                service_time_start,
                                            "service_time_end":
                                                service_time_end,
                                            "signature": signature,
                                            "reason": reason,
                                            "pictureSources": pictureSources,
                                            "latitude": latitude,
                                            "longitude": longitude,
                                            "current_app_version": "3.15.2",
                                            "app_version": "3.15.2",
                                            "consignments":
                                                jsonEncode([consignments]),
                                            "driver_id": driver_id,
                                            "date_delivered": DateTime.now()
                                                .toIso8601String(),
                                            "space": space,
                                            "weight": weight,
                                            "customer_reference":
                                                customer_reference,
                                            "comments": comments,
                                            "address_id": address_id,
                                            "pictures": images,
                                            "lodgeError": jsonEncode({
                                              "comments": comments,
                                              "errorPictures": images,
                                              "errorPictureSources":
                                                  pictureSources,
                                            }),
                                            "platforms": platforms,
                                          };

                                          context
                                              .read<ProofOfDeliveryProvider>()
                                              .addEntities(temp.entries);
                                          Get.toNamed(AppRoutes.podphotos,
                                              arguments: Get.arguments);
                                        } else {
                                          debugPrint("Form key is null.");
                                        }
                                      },
                                      borderColor: isValid()
                                          ? AppColors.blue
                                          : AppColors.grey,
                                      backgroundColor: isValid()
                                          ? AppColors.blue
                                          : AppColors.grey,
                                      enabled: isValid(),
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
                                      description:
                                          'Address is wrong or the location has closed',
                                    ),
                                    SizedBox(
                                      height: 3.h,
                                    ),
                                    const CustomContainer(
                                      title: 'Receiver Not Open',
                                      description:
                                          'The receiver is unable to receive goods',
                                    ),
                                    SizedBox(
                                      height: 3.h,
                                    ),
                                    const CustomContainer(
                                      title: 'Temperature issue',
                                      description:
                                          'The stock is not the correct temperature',
                                    ),
                                    SizedBox(
                                      height: 3.h,
                                    ),
                                    const CustomContainer(
                                      title: 'Damaged Goods',
                                      description:
                                          'The packaging or goods have been damaged',
                                    ),
                                    SizedBox(
                                      height: 3.h,
                                    ),
                                    const CustomContainer(
                                      title: 'Other Rejection',
                                      description:
                                          'The customer refused the goods ',
                                    )
                                  ]);
                            }),
                            SizedBox(
                              height: 1.h,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                SizedBox(
                                    width: 50.w,
                                    child: CustomButton(
                                      label: "Submit POD",
                                      backgroundColor: AppColors.red,
                                      borderColor: AppColors.red,
                                      onPressed: () {
                                        if (_formKey.currentState != null) {
                                          final provider = context
                                              .read<ProofOfDeliveryProvider>();
                                          final rejection_reason =
                                              provider.data['rejection_reason'];
                                          final consignments =
                                              Get.arguments['id'];
                                          final driver_id =
                                              Get.arguments['driver_id'];
                                          final address_id =
                                              Get.arguments['address_id'];
                                          final date_delivered =
                                              Get.arguments['date_delivered'];
                                          final space = Get.arguments['space'];
                                          final weight =
                                              Get.arguments['weight'];
                                          final customer_reference = Get
                                              .arguments['customer_reference'];
                                          final service_window =
                                              Get.arguments['service_window'];
                                          final pictureSources = jsonEncode(
                                              provider.pictureSources);
                                          final images =
                                              jsonEncode(provider.base64Images);
                                          final device = jsonEncode(
                                              provider.data['device']);
                                          final commentss = _formKey
                                              .currentState!
                                              .fields['Order rejection']
                                              ?.value
                                              .toString();
                                          final platforms = jsonEncode([
                                            "android",
                                            "cordova",
                                            "mobile",
                                            "hybrid"
                                          ]);

                                          String? comments = '';
                                          int error_type = 1;

                                          if (rejection_reason ==
                                              'Temperature issue') {
                                            comments =
                                                'The stock is not the correct temperature';
                                            error_type = 13;
                                          } else if (rejection_reason ==
                                              'Wrong Address') {
                                            comments =
                                                'Address is wrong or the location has closed';
                                            error_type = 1;
                                          } else if (rejection_reason ==
                                              'Receiver Not Open') {
                                            comments =
                                                'The receiver is unable to receive goods';
                                            error_type = 2;
                                          } else if (rejection_reason ==
                                              'Damaged Goods') {
                                            comments =
                                                'The packaging or goods have been damaged';
                                            error_type = 3; //
                                          } else if (rejection_reason ==
                                              'Other Rejection') {
                                            comments = commentss;
                                            error_type = 6;
                                          }

                                          final temp = {
                                            "pod_type": "3",
                                            "error_type": error_type,
                                            "rejection_reason":
                                                rejection_reason,
                                            "comments": comments,
                                            "record_error": true,
                                            "adhoc_charges": false,
                                            "space": space,
                                            "weight": weight,
                                            "consignments":
                                                jsonEncode([consignments]),
                                            "device": jsonEncode(deviceinfo),
                                            "date_delivered": DateTime.now()
                                                .toIso8601String(),
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
                                            "platforms": platforms,
                                          };

                                          provider.addEntities(temp.entries);
                                          Provider.of<TaskSyncpofProvider>(
                                                  context,
                                                  listen: false)
                                              .submitData(context);
                                        } else {
                                          debugPrint("Form key is null");
                                        }
                                      },
                                    )),
                              ],
                            ),
                          ],
                        ),
                      SizedBox(
                        height: 1.h,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ));
  }
}

class CustomContainer extends StatefulWidget {
  final String title;
  final String description;

  const CustomContainer({
    super.key,
    required this.title,
    required this.description,
  });

  @override
  CustomContainerState createState() => CustomContainerState();
}

class CustomContainerState extends State<CustomContainer> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProofOfDeliveryProvider>(context);
    bool isChecked =
        provider.selectedOrderRejectionReasons.contains(widget.title);

    return GestureDetector(
      onTap: () {
        if (!isChecked) {
          provider.clearOrderRejectionReasons();
          provider.updateOrderRejectionReason(widget.title);
        } else {
          provider.clearOrderRejectionReasons();
        }
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
                      padding:
                          EdgeInsets.symmetric(vertical: 1.h, horizontal: 2.w),
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
