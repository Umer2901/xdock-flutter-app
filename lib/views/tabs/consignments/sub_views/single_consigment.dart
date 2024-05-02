// ignore_for_file: deprecated_member_use

import 'package:coldxpress/export.dart';
import 'package:flutter/material.dart';

class SingleConsigmentView extends StatelessWidget {
  const SingleConsigmentView({super.key});

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
                  AppBar(
                    backgroundColor: Colors.transparent,
                    surfaceTintColor: Colors.transparent,
                    centerTitle: true,
                    leading: const SizedBox.shrink(),
                    title: IntrinsicHeight(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'ID: 123456',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          VerticalDivider(
                            color: AppColors.black.withOpacity(0.5),
                            thickness: 2,
                          ),
                          Text(
                            'REF: 1234',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ],
                      ),
                    ),
                    actions: [
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
                                child: Image.asset(AppImages.cardboard))),
                      ),
                      SizedBox(
                        width: 54.w,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ritchies IGA',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            Text(
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              'Recipient: Drew Moran 830 Wellington road, Rowville',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
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
                      type: AppText.chilled,
                      time: '10.00 - 12.00',
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
                        const CustomOrderTracking(
                            title: "Supplier",
                            subText: 'Acme Corporation',
                            isLastStep: false,
                            currentStep: 3,
                            stepIndex: 1),
                        const CustomOrderTracking(
                          title: "Pickup",
                          isLastStep: false,
                          currentStep: 3,
                          stepIndex: 2,
                          subText:
                              'ColdXpress Transport 2071 portarlinton road, Drysdale',
                        ),
                        const CustomOrderTracking(
                          title: "Out for Delivery",
                          isLastStep: false,
                          currentStep: 3,
                          stepIndex: 3,
                          subText: 'Driver: Abram Vetrovs',
                        ),
                        const CustomOrderTracking(
                          title: "Drop off",
                          isLastStep: true,
                          currentStep: 3,
                          stepIndex: 4,
                          subText:
                              'Pronto Fine Food 830 wellington road, Rowville',
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
                            counts: '5',
                            svgIcon: SvgPicture.asset(AppSvgs.carton),
                          ),
                          CustomDeliveryDetailsContainer(
                            type: AppText.pallets,
                            counts: '5',
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
                            counts: '5',
                            countType: 'sqft',
                            svgIcon: SvgPicture.asset(AppSvgs.space),
                          ),
                          CustomDeliveryDetailsContainer(
                            type: AppText.weight,
                            counts: '5',
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
                    AppText.specialInstructionsDetail,
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
