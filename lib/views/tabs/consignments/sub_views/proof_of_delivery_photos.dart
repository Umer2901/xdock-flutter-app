import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:coldxpress/providers/pof_services_provider.dart';
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

    debugPrint("our group data: ${Get.arguments['is_group']}");
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<ProofOfDeliveryProvider>(context);

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
                              // ignore: deprecated_member_use
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
                    onTap: () {
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
                                  Provider.of<TaskSyncpofProvider>(context,
                                          listen: false)
                                      .submitData(context);
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

  Future<void> _takePhoto() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(
        imageQuality: 10,
        source: ImageSource.camera,
      );

      if (image != null) {
        debugPrint('Testing Image Picker');
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
    }
  }
}
