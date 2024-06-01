// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'package:coldxpress/export.dart';

class SingleConsigmentView extends StatefulWidget {
  const SingleConsigmentView({super.key});

  @override
  State<SingleConsigmentView> createState() => _SingleConsigmentViewState();
}

class _SingleConsigmentViewState extends State<SingleConsigmentView> {
  late Map productTypes;
  late Map deliveryAddresses;
  late Map pickupAddresses;

  @override
  void initState() {
    super.initState();
    productTypes = json.decode(Get.arguments['product_types']);
    deliveryAddresses = json.decode(Get.arguments['delivery_addresses']);
    pickupAddresses = json.decode(Get.arguments['pickup_addresses']);
  }

  @override
  Widget build(BuildContext context) {
    print({Get.arguments});
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
                  GestureDetector(
                    onTap: () {
                      Get.toNamed(AppRoutes.Stopwatch);
                    },
                    child: CustomProductTypeAndTime(
                      type: (productTypes['id']) == 1 ? '1' : '2',
                      time: Get.arguments['consignment_type'] == 'delivery'
                          ? '${deliveryAddresses['service_time_start'].toString().split(' ').last.split(':')[0]}.${deliveryAddresses['service_time_start'].toString().split(' ').last.split(':')[1]} - ${deliveryAddresses['service_time_end'].toString().split(' ').last.split(':')[0]}.${deliveryAddresses['service_time_end'].toString().split(' ').last.split(':')[1]}'
                          : '${pickupAddresses['service_time_start'].toString().split(' ').last.split(':')[0]}.${pickupAddresses['service_time_start'].toString().split(' ').last.split(':')[1]} - ${pickupAddresses['service_time_end'].toString().split(' ').last.split(':')[0]}.${pickupAddresses['service_time_end'].toString().split(' ').last.split(':')[1]}',
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
                        CustomOrderTracking(
                            title: "Supplier",
                            subText: 'Acme Corporation',
                            isLastStep: false,
                            currentStep:
                                Get.arguments['consignment_type'] == 'delivery'
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
                  Text(
                    AppText.specialInstructions,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.black.withOpacity(0.5),
                        ),
                  ),
                  Text(
                    Get.arguments['special_instruction'] == ''
                        ? 'Not Provided'
                        : Get.arguments['special_instruction'],
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.black,
                        ),
                  ),
                  SizedBox(
                    height: 4.h,
                  ),
                  CustomElevatedButton(
                      label: AppText.podCapture,
                      onPressed: () {
                        Get.toNamed(AppRoutes.proofOfDelivery);
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
