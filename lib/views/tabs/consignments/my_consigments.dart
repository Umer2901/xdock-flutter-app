import 'package:coldxpress/export.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyConsigmentTab extends StatefulWidget {
  const MyConsigmentTab({super.key});

  @override
  State<MyConsigmentTab> createState() => _MyConsigmentTabState();
}

class _MyConsigmentTabState extends State<MyConsigmentTab> {
  final ScrollController _scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () {},
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
          AppText.myConsignment,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: SafeArea(
          child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: AppColors.blue,
                  borderRadius: BorderRadius.circular(8.sp),
                ),
                child: Column(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 0.5.h,
                        ),
                        Text(
                          AppText.todayConsignment,
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(color: AppColors.white),
                        ),
                        SizedBox(
                          height: 1.5.h,
                        ),
                        Row(
                          children: [
                            Text(
                              '32',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.white,
                                  ),
                            ),
                            Text(
                              AppText.consignmentRemaining,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: AppColors.white,
                                  ),
                            ),
                            SizedBox(
                              width: 1.w,
                            ),
                            CircleAvatar(
                              backgroundColor: AppColors.white,
                              radius: 0.6.w,
                            ),
                            SizedBox(
                              width: 1.w,
                            ),
                            Text(
                              DateFormat('dd MMM,yyyy').format(DateTime.now()),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: AppColors.white,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 2.h,
                    ),
                    CustomTextField(
                      name: 'search',
                      borderColor: AppColors.white,
                      prefixIcon: Icon(
                        Icons.search,
                        color: AppColors.black.withOpacity(0.5),
                      ),
                      hintText: 'Search by ID, REF or Recipient',
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 1.5.h,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (int i = 0; i < 4; i++) ...{
                    Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            i == 0
                                ? Get.toNamed(AppRoutes.consignmentMap)
                                : Get.toNamed(AppRoutes.consigmentReorder);
                          },
                          child: CircleAvatar(
                            radius: 9.w,
                            backgroundColor: AppColors.greyWhite,
                            child: SvgPicture.asset(
                              AppSvgs.pallet,
                              width: 10.w,
                            ),
                          ),
                        ),
                        Text(
                          i == 0
                              ? 'Map'
                              : i == 1
                                  ? 'Re-order'
                                  : i == 2
                                      ? 'Group'
                                      : 'Refresh',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.darkGrey,
                                  ),
                        )
                      ],
                    )
                  },
                ],
              ),
              GestureDetector(
                onTap: () {
                  Get.toNamed(AppRoutes.singleConsigment);
                },
                child: const CustomeMyConsigmentContainer(
                  count: 1,
                  recipientName: 'Ritchies IGA',
                  recipientAddress: 'Drew Moran 830 Wellington road, Rowville',
                  type: AppText.chilled,
                  time: '10.00 - 12.00',
                  id: 123456,
                  supplier: 'Ben’s Deli',
                  receiver: 'Drew Moran',
                  group: 3,
                  ref: 1234,
                  cartons: 1,
                  pallets: 1,
                  spc: 57,
                ),
              ),
              const CustomeMyConsigmentContainer(
                count: 2,
                recipientName: 'Ritchies IGA',
                recipientAddress: 'Drew Moran 830 Wellington road, Rowville',
                type: AppText.frozen,
                time: '10.00 - 12.00',
                id: 123456,
                supplier: 'Ben’s Deli',
                receiver: 'Drew Moran',
                // group: ,
                ref: 1234,
                cartons: 1,
                pallets: 1,
                spc: 57,
              ),
              GestureDetector(
                onTap: () {
                  _scrollController.animateTo(
                    0.0,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  child: Text(
                    AppText.returnToTop,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.midBlue,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ),
            ],
          ),
        ),
      )),
    );
  }
}
