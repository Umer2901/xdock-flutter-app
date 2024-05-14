// ignore_for_file: deprecated_member_use

import 'package:coldxpress/export.dart';

class CustomMyConsigmentContainer extends StatefulWidget {
  const CustomMyConsigmentContainer({
    super.key,
    required this.isLoading,
    this.consignment,
    this.index,
  });
  final bool isLoading;
  final Map? consignment;
  final int? index;
  @override
  State<CustomMyConsigmentContainer> createState() =>
      _CustomMyConsigmentContainerState();
}

class _CustomMyConsigmentContainerState
    extends State<CustomMyConsigmentContainer> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 2.h),
      child: widget.isLoading
          ? Shimmer.fromColors(
              baseColor: AppColors.greyWhite,
              highlightColor: AppColors.lightGrey,
              child: Container(
                width: double.maxFinite,
                height: 40.h,
                decoration: BoxDecoration(
                  color: AppColors.greyWhite,
                  borderRadius: BorderRadius.circular(8.sp),
                ),
              ),
            )
          : Container(
              decoration: BoxDecoration(
                color: AppColors.greyWhite,
                borderRadius: BorderRadius.circular(8.sp),
              ),
              padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.5.h),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.darkGrey,
                          borderRadius: BorderRadius.circular(8.sp),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 1.8.h,
                          ),
                          child: Text(
                            // widget.consignment!['data']?.containsKey('2024-04-04') ==
                            //         false
                            //     ? '0'
                            //     : widget
                            //         .consignment!['data']['2024-04-04']
                            //             ['consignments']
                            //         .length
                            //         .toString(),
                            widget.index.toString(),
                            style: Theme.of(context)
                                .textTheme
                                .headlineLarge
                                ?.copyWith(
                                  color: AppColors.white,
                                ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 46.w,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              (widget.consignment!['consignment_type'] ==
                                          'delivery'
                                      ? widget.consignment![
                                          'delivery_addresses']['customer_name']
                                      : widget.consignment!['pickup_addresses']
                                          ['customer_name']) ??
                                  'Not Provided',
                              maxLines: 1,
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            Text(
                              maxLines: 1,
                              'Recipient: ${(widget.consignment!['consignment_type'] == 'delivery' ? widget.consignment!['delivery_addresses']['customer_name'] : widget.consignment!['pickup_addresses']['customer_name']) ?? 'Not Provided'}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            Text(
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              '${(widget.consignment!['consignment_type'] == 'delivery' ? widget.consignment!['delivery_addresses']['street_address'] : widget.consignment!['pickup_addresses']['street_address']) ?? 'Not Provided'}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Get.toNamed(AppRoutes.consignmentMap);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 2.w,
                            vertical: 0.5.h,
                          ),
                          width: 11.5.w,
                          height: 5.h,
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
                      SizedBox(
                        width: 1.w,
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
                      type:
                          widget.consignment!['product_types']['id'].toString(),
                      time:
                          '${(widget.consignment!['consignment_type'] == 'delivery' ? DateFormat('hh.mm').format(DateTime.parse(widget.consignment!['delivery_addresses']['service_time_start'])) : DateFormat('hh.mm').format(DateTime.parse(widget.consignment!['pickup_addresses']['service_time_start'])))} - ${(widget.consignment!['consignment_type'] == 'delivery' ? DateFormat('hh.mm').format(DateTime.parse(widget.consignment!['delivery_addresses']['service_time_end'])) : DateFormat('hh.mm').format(DateTime.parse(widget.consignment!['pickup_addresses']['service_time_end'])))}',
                      svgImage: widget.consignment!['product_types']['id'] == 1
                          ? SvgPicture.asset(AppSvgs.chilled)
                          : SvgPicture.asset(AppSvgs.frozen),
                    ),
                  ),
                  SizedBox(height: 1.h),
                  IntrinsicHeight(
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: EdgeInsets.only(left: 6.w),
                            child: Column(
                              children: [
                                CustomValueField(
                                  title: AppText.id.toUpperCase(),
                                  value: widget.consignment!['id'].toString(),
                                ),
                                SizedBox(
                                  height: 1.5.h,
                                ),
                                CustomValueField(
                                  title: AppText.supplier,
                                  value: (widget.consignment![
                                                  'consignment_type'] ==
                                              'delivery'
                                          ? widget.consignment![
                                              'delivery_addresses']['suburb']
                                          : widget.consignment![
                                              'pickup_addresses']['suburb']) ??
                                      'Not Provided',
                                ),
                                SizedBox(
                                  height: 1.5.h,
                                ),
                                CustomValueField(
                                  title: AppText.receiver,
                                  value: (widget.consignment![
                                                  'consignment_type'] ==
                                              'delivery'
                                          ? widget.consignment![
                                                  'delivery_addresses']
                                              ['customer_name']
                                          : widget.consignment![
                                                  'pickup_addresses']
                                              ['customer_name']) ??
                                      'Not Provided',
                                ),
                                SizedBox(
                                  height: 1.5.h,
                                ),
                                CustomValueField(
                                  title: AppText.group,
                                  value:
                                      widget.consignment!['is_group'] != 'null'
                                          ? widget.consignment!['is_group']
                                              .toString()
                                          : '-',
                                  svgImage: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          isExpanded == false &&
                                                  widget.consignment![
                                                          'is_group'] !=
                                                      'null'
                                              ? isExpanded = true
                                              : isExpanded = false;
                                        });
                                      },
                                      child: SvgPicture.asset(
                                        widget.consignment!['is_group']
                                                    .toString() !=
                                                'null'
                                            ? AppSvgs.expand
                                            : AppSvgs.expandInactive,
                                        color: widget.consignment!['is_group']
                                                    .toString() !=
                                                'null'
                                            ? AppColors.lightBlue
                                            : AppColors.grey,
                                      )),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const VerticalDivider(
                          color: AppColors.belowMidGreyTwo,
                        ),
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: EdgeInsets.only(left: 3.w),
                            child: Column(
                              children: [
                                CustomValueField(
                                  title: AppText.ref.toUpperCase(),
                                  value: widget
                                      .consignment!['customer_reference']
                                      .toString(),
                                ),
                                SizedBox(
                                  height: 1.5.h,
                                ),
                                CustomValueField(
                                  title: AppText.cartons,
                                  value:
                                      widget.consignment!['carton'].toString(),
                                ),
                                SizedBox(
                                  height: 1.5.h,
                                ),
                                CustomValueField(
                                  title: AppText.pallets,
                                  value:
                                      widget.consignment!['pallet'].toString(),
                                ),
                                SizedBox(
                                  height: 1.5.h,
                                ),
                                CustomValueField(
                                  title: AppText.spc,
                                  value:
                                      '${widget.consignment!['space'].toString()} sqm',
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  isExpanded
                      ? Column(
                          children: [
                            SizedBox(height: 1.5.h),
                            const Divider(
                              color: AppColors.belowMidGreyTwo,
                            ),
                            ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppColors.belowMidGreyTwo,
                                radius: 8.w,
                                child: SvgPicture.asset(
                                  AppSvgs.pallet,
                                  height: 3.h,
                                ),
                              ),
                              title: Text(
                                '${AppText.supplier}: ',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${AppText.id.toUpperCase()}: 123456',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.black
                                                  .withOpacity(0.5),
                                            ),
                                      ),
                                      Text(
                                        '${AppText.ref.toUpperCase()}: 123456',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.black
                                                  .withOpacity(0.5),
                                            ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${AppText.ctn.toUpperCase()}: 1',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.black,
                                            ),
                                      ),
                                      Text(
                                        '${AppText.plt.toUpperCase()}: 1',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.black,
                                            ),
                                      ),
                                      Text(
                                        '${AppText.spc.toUpperCase()}: 1',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.black,
                                            ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : const SizedBox.shrink(),
                ],
              ),
            ),
    );
  }
}
