// ignore_for_file: deprecated_member_use
import 'dart:convert';
import 'package:coldxpress/services/map_helper.dart';
import 'package:coldxpress/export.dart';

class CustomMyConsigmentContainer extends StatefulWidget {
  const CustomMyConsigmentContainer({
    super.key,
    required this.isLoading,
    this.consignment,
    this.index,
    required this.isPrecheckDone,
  });
  final bool isLoading;
  final Map? consignment;
  final int? index;
  final bool isPrecheckDone;
  @override
  State<CustomMyConsigmentContainer> createState() =>
      _CustomMyConsigmentContainerState();
}

class _CustomMyConsigmentContainerState
    extends State<CustomMyConsigmentContainer> {
  bool isExpanded = false;
  Map<String, dynamic> _decodeIfString(dynamic data) {
    if (data is String) {
      return json.decode(data) as Map<String, dynamic>;
    } else if (data is Map<String, dynamic>) {
      return data;
    } else {
      throw TypeError();
    }
  }
  @override
  Widget build(BuildContext context) {
    Map productTypes = json.decode(widget.consignment?['product_types']);
    Map deliveryAddresses = json.decode(
      widget.consignment?['delivery_addresses'],
    );
    Map pickupAddresses = json.decode(widget.consignment?['pickup_addresses']);
    List groupedConsignments = [];
    if (widget.consignment?['grouped_consignments'] != null) {
      groupedConsignments = json.decode(
        widget.consignment?['grouped_consignments'],
      );
    }
final Map runSheets = jsonDecode(widget.consignment?['run_sheets']);
    final date = runSheets['date'] ?? 'Not Provided';
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
                                      ? deliveryAddresses['company_name']
                                      : pickupAddresses['company_name']) ??
                                  'Not Provided',
                              maxLines: 1,
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                          //   Padding(
                          //   padding: EdgeInsets.symmetric(vertical: 1.h),
                          //   child: Text(
                          //     date,
                          //     style: Theme.of(context).textTheme.headlineSmall,
                          //   ),
                          // ),
                            Text(
                              maxLines: 1,
                              'Recipient: ${(widget.consignment!['consignment_type'] == 'delivery' ? deliveryAddresses['customer_name'] : pickupAddresses['customer_name']) ?? 'Not Provided'}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            Text(
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              '${(widget.consignment!['consignment_type'] == 'delivery' ? deliveryAddresses['street_address'] : pickupAddresses['street_address']) ?? 'Not Provided'}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          MapHelper.openDirections(
                            originLatitude: context
                                .read<LocationProvider>()
                                .current!
                                .latitude
                                .toString(),
                            originLongitude: context
                                .read<LocationProvider>()
                                .current!
                                .longitude
                                .toString(),
                            destinationLatitude:
                                (widget.consignment!['consignment_type'] ==
                                            'delivery'
                                        ? deliveryAddresses['latitude']
                                        : pickupAddresses['latitude'])
                                    .toString(),
                            destinationLongitude:
                                (widget.consignment!['consignment_type'] ==
                                            'delivery'
                                        ? deliveryAddresses['longitude']
                                        : pickupAddresses['longitude'])
                                    .toString(),
                          );
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
                          child: Image.asset(
                            AppImages.map,
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
                      Get.toNamed(
                        AppRoutes.stopwatch,
                        arguments: widget.consignment,
                      );
                    },
                    child: CustomProductTypeAndTime(
                      type: productTypes['id'].toString(),
                      time:
                          '${(widget.consignment!['consignment_type'] == 'delivery' ? deliveryAddresses['service_time_start'] == null ? '--.--' : DateFormat('HH.mm').format(DateTime.parse(deliveryAddresses['service_time_start'])) : pickupAddresses['service_time_start'] == null ? '--.--' : DateFormat('HH.mm').format(DateTime.parse(pickupAddresses['service_time_start'])))} - ${(widget.consignment!['consignment_type'] == 'delivery' ? deliveryAddresses['service_time_end'] == null ? '--.--' : DateFormat('HH.mm').format(DateTime.parse(deliveryAddresses['service_time_end'])) : pickupAddresses['service_time_end'] == null ? '--.--' : DateFormat('HH.mm').format(DateTime.parse(pickupAddresses['service_time_end'])))}',
                      svgImage: productTypes['id'] == 1
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
                                          ? deliveryAddresses['suburb']
                                          : pickupAddresses['suburb']) ??
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
                                          ? deliveryAddresses['customer_name']
                                          : pickupAddresses['customer_name']) ??
                                      'Not Provided',
                                ),
                                SizedBox(
                                  height: 1.5.h,
                                ),
                                CustomValueField(
                                  title: AppText.group,
                                  value: widget.consignment![
                                          'total_grouped_consignments']
                                      .toString(),
                                  svgImage: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          isExpanded == false &&
                                                  widget.consignment![
                                                          'total_grouped_consignments'] !=
                                                      0
                                              ? isExpanded = true
                                              : isExpanded = false;
                                        });
                                      },
                                      child: Image.asset(
                                        widget.consignment!['is_group']
                                                    .toString() !=
                                                'null'
                                            ? AppImages.zoom
                                            : AppImages.zoomclose,
                                        
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
                           if (groupedConsignments.isNotEmpty) ...[],
                  ...groupedConsignments.map<Widget>((subConsignment) {
                    final deliveryAddresses = _decodeIfString(subConsignment['delivery_addresses']);
                    final pickupAddresses = _decodeIfString(subConsignment['pickup_addresses']);

                    final companyName = subConsignment['consignment_type'] == 'delivery'
                        ? (deliveryAddresses['company_name'] ?? 'No Company Name')
                        : (pickupAddresses['company_name'] ?? 'No Company Name');
                    
                    final address = subConsignment['consignment_type'] == 'delivery'
                        ? deliveryAddresses['full_address']
                        : pickupAddresses['full_address'];

                    return Padding(
                      padding: EdgeInsets.only(bottom: 2.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (groupedConsignments.indexOf(subConsignment) == 0) ...[
                     
                          ],
                               SizedBox(height: 1.5.h),
                              const Divider(
                                color: AppColors.belowMidGreyTwo,
                              ),
                              ListTile(
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                leading: CircleAvatar(
                                  backgroundColor: AppColors.belowMidGreyTwo,
                                  radius: 8.w,
                                  child: SvgPicture.asset(
                                    AppSvgs.boundpallets,
                                    height: 3.h,
                                  ),
                                ),
                                onTap: () {
                                  if (widget.isPrecheckDone) {
                                    Get.toNamed(
                                      AppRoutes.singleConsigment,
                                      arguments: subConsignment,
                                    );
                                  }
                                },
                                title: Text(
                                  '${AppText.supplier}: ${companyName}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
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
                                          '${AppText.id.toUpperCase()}: ${subConsignment['id']}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.black
                                                    .withOpacity(0.5),
                                              ),
                                        ),
                                        Text(
                                          '${AppText.ref.toUpperCase()}: ${subConsignment['customer_reference']}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
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
                                          '${AppText.ctn.toUpperCase()}: ${subConsignment['carton']}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.black,
                                              ),
                                        ),
                                        Text(
                                          '${AppText.plt.toUpperCase()}: ${subConsignment['pallet']}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.black,
                                              ),
                                        ),
                                        Text(
                                          '${AppText.spc.toUpperCase()}: ${subConsignment['space']}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
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
                      ),
                    );
                  }).toList(),
                    SizedBox(
                    height: 2.h,
                  ),
                 ] )
                      : const SizedBox.shrink(),
                ],
              ),
            ),
    );
  }
}

