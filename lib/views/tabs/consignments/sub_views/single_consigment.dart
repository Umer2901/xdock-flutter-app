// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'package:coldxpress/export.dart';
import 'package:url_launcher/url_launcher.dart';

class SingleConsigmentView extends StatefulWidget {
  const SingleConsigmentView({super.key});

  @override
  State<SingleConsigmentView> createState() => _SingleConsigmentViewState();
}

class _SingleConsigmentViewState extends State<SingleConsigmentView> {
  late Map productTypes;
  late Map deliveryAddresses;
  late Map pickupAddresses;
  List groupedConsignments = [];

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () {
            Get.back();
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
          AppText.delivery,
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
                  if (groupedConsignments.isEmpty)
                    IntrinsicHeight(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'ID: ${Get.arguments['id']}',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          VerticalDivider(
                            color: AppColors.black.withOpacity(0.5),
                            thickness: 2,
                          ),
                          Text(
                            'REF: ${Get.arguments['customer_reference']}',
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
                              (Get.arguments['consignment_type'] == 'delivery'
                                      ? deliveryAddresses['company_name']
                                      : pickupAddresses['company_name']) ??
                                  'Not Provided',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            Text(
                              'Recipient: ${(Get.arguments['consignment_type'] == 'delivery' ? deliveryAddresses['customer_name'] : pickupAddresses['customer_name']) ?? 'Not Provided'}',
                              style: Theme.of(context).textTheme.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              Get.arguments['consignment_type'] == 'delivery'
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
                        onTap: () async {
                          final Uri launchUri = Uri(
                            scheme: 'tel',
                            path:
                                Get.arguments['consignment_type'] == 'delivery'
                                    ? deliveryAddresses['telephone']
                                    : pickupAddresses['telephone'],
                          );
                          await launchUrl(launchUri);
                        },
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
                  GestureDetector(
                    onTap: () {
                      Get.offAndToNamed(
                        AppRoutes.Stopwatch,
                        arguments: Get.arguments,
                      );
                    },
                    child: CustomProductTypeAndTime(
                      type: (productTypes['id']) == 1 ? '1' : '2',
                      time:
                          '${(Get.arguments!['consignment_type'] == 'delivery' ? deliveryAddresses['service_time_start'] == null ? '--.--' : DateFormat('HH.mm').format(DateTime.parse(deliveryAddresses['service_time_start'])) : pickupAddresses['service_time_start'] == null ? '--.--' : DateFormat('HH.mm').format(DateTime.parse(pickupAddresses['service_time_start'])))} - ${(Get.arguments!['consignment_type'] == 'delivery' ? deliveryAddresses['service_time_end'] == null ? '--.--' : DateFormat('HH.mm').format(DateTime.parse(deliveryAddresses['service_time_end'])) : pickupAddresses['service_time_end'] == null ? '--.--' : DateFormat('HH.mm').format(DateTime.parse(pickupAddresses['service_time_end'])))}',
                      svgImage: SvgPicture.asset(AppSvgs.frozen),
                    ),
                  ),
                  SizedBox(
                    height: 2.h,
                  ),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                    // height: 3.5.h,
                    width: double.maxFinite,
                    decoration: BoxDecoration(
                      color: AppColors.greyWhite,
                      borderRadius: BorderRadius.circular(8.sp),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 3.5.h,
                          width: 19.w,
                          decoration: BoxDecoration(
                            color: AppColors.darkGrey,
                            borderRadius: BorderRadius.circular(20.sp),
                          ),
                          child: Center(
                            child: Text(
                              'En Route',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: AppColors.white,
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 2.h,
                        ),
                        if (groupedConsignments.isEmpty)
                          CustomOrderTracking(
                              title: "Supplier",
                              subText: 'Acme Corporation',
                              isLastStep: false,
                              currentStep: Get.arguments['consignment_type'] ==
                                      'delivery'
                                  ? 3
                                  : 1,
                              stepIndex: 1),
                        CustomOrderTracking(
                          title: "Pickup",
                          isLastStep: false,
                          currentStep:
                              Get.arguments['consignment_type'] == 'delivery'
                                  ? 3
                                  : 1,
                          stepIndex: 2,
                          subText: pickupAddresses['full_address'],
                        ),
                        CustomOrderTracking(
                          title: "Out for Delivery",
                          isLastStep: false,
                          currentStep:
                              Get.arguments['consignment_type'] == 'delivery'
                                  ? 3
                                  : 1,
                          stepIndex: 3,
                          subText: 'Driver: Abram Vetrovs',
                        ),
                        CustomOrderTracking(
                          title: "Drop off",
                          isLastStep: true,
                          currentStep:
                              Get.arguments['consignment_type'] == 'delivery'
                                  ? 3
                                  : 1,
                          stepIndex: 4,
                          subText: deliveryAddresses['full_address'],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 3.h,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (groupedConsignments.isNotEmpty != 0) ...{
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            AppText.totalDelivery.toUpperCase(),
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                          ),
                        ),
                        SizedBox(height: 1.h),
                      },
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomDeliveryDetailsContainer(
                            type: AppText.cartons,
                            counts: '${Get.arguments['carton']}',
                            svgIcon: SvgPicture.asset(AppSvgs.carton),
                          ),
                          CustomDeliveryDetailsContainer(
                            type: AppText.pallets,
                            counts: '${Get.arguments['pallet']}',
                            svgIcon: SvgPicture.asset(AppSvgs.palletBlue),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 2.h,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomDeliveryDetailsContainer(
                            type: AppText.space,
                            counts: '${Get.arguments['space']}',
                            countType: 'sqft',
                            svgIcon: SvgPicture.asset(AppSvgs.space),
                          ),
                          CustomDeliveryDetailsContainer(
                            type: AppText.weight,
                            counts: '${Get.arguments['weight']}',
                            countType: 'KG',
                            svgIcon: SvgPicture.asset(AppSvgs.weight),
                          )
                        ],
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 4.h,
                  ),
                  if (groupedConsignments.isNotEmpty) ...{
                    const Divider(),
                    SizedBox(
                      height: 2.h,
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        AppText.suppliers.toUpperCase(),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                    SizedBox(height: 1.h),
                    for (var subConsignment in groupedConsignments) ...{
                      Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 2.h,
                          horizontal: 4.w,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.greyWhite,
                          borderRadius: BorderRadius.circular(10.sp),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '${(subConsignment!['consignment_type'] == 'delivery' ? deliveryAddresses['customer_name'] : pickupAddresses['customer_name']) ?? 'Not Provided'}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w800,
                                        ),
                                  ),
                                ),
                                SizedBox(width: 2.w),
                                SizedBox(
                                  height: 2.5.h,
                                  child: VerticalDivider(
                                    thickness: 0.5.w,
                                    color: AppColors.black,
                                  ),
                                ),
                                SizedBox(width: 2.w),
                                Expanded(
                                  child: Text(
                                    'ID: ${subConsignment['id']}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w800,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 0.5.h),
                            Text(
                              '${(subConsignment!['consignment_type'] == 'delivery' ? deliveryAddresses['full_address'] : pickupAddresses['full_address']) ?? 'Not Provided'}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: AppColors.grey,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            SizedBox(height: 1.h),
                            Container(
                              padding: EdgeInsets.symmetric(
                                vertical: 2.h,
                                horizontal: 4.w,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(10.sp),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    children: [
                                      Text(
                                        AppText.cartons,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                      SizedBox(height: 1.h),
                                      Text(
                                        '${subConsignment['carton']}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 8.h,
                                    child: VerticalDivider(
                                      thickness: 0.5.w,
                                      color: AppColors.greyWhite,
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        AppText.pallets,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                      SizedBox(height: 1.h),
                                      Text(
                                        '${subConsignment['pallet']}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 8.h,
                                    child: VerticalDivider(
                                      thickness: 0.5.w,
                                      color: AppColors.greyWhite,
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        AppText.space,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                      SizedBox(height: 1.h),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${subConsignment['space']}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w700,
                                                ),
                                          ),
                                          SizedBox(
                                            width: 1.w,
                                          ),
                                          Text(
                                            'sqft',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 10.sp),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 8.h,
                                    child: VerticalDivider(
                                      thickness: 0.5.w,
                                      color: AppColors.greyWhite,
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        AppText.weight,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                      SizedBox(height: 1.h),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${subConsignment['weight']}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w700,
                                                ),
                                          ),
                                          SizedBox(
                                            width: 1.w,
                                          ),
                                          Text(
                                            'KG',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 10.sp),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 1.h),
                            Container(
                              width: 100.w,
                              padding: EdgeInsets.symmetric(
                                vertical: 2.h,
                                horizontal: 4.w,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(10.sp),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppText.specialInstructions,
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                  SizedBox(height: 1.h),
                                  Text(
                                    '${subConsignment['special_instruction']}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w500,
                                        ),
                                    textAlign: TextAlign.justify,
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(height: 2.h),
                    }
                  } else ...{
                    Text(
                      AppText.specialInstructions,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.black.withOpacity(0.5),
                          ),
                    ),
                    Text(
                      (Get.arguments['special_instruction'] ?? '') == ''
                          ? 'Not Provided'
                          : Get.arguments['special_instruction'],
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.black,
                          ),
                    ),
                  },
                  SizedBox(
                    height: 4.h,
                  ),
                  CustomElevatedButton(
                      label: AppText.podCapture,
                      onPressed: () {
                        Get.toNamed(AppRoutes.proofOfDelivery,
                            arguments: Get.arguments);
                      }),
                  SizedBox(
                    height: 8.h,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
