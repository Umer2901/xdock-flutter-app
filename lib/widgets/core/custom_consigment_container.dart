import 'dart:convert';

import 'package:coldxpress/export.dart';

class CustomConsignmentContainer extends StatelessWidget {
  final bool isLoading;
  final bool? isSelected;
  final Widget? icon;
  final Function? onTap;
  final Map? consignment;
  const CustomConsignmentContainer({
    super.key,
    this.isLoading = false,
    this.consignment,
    this.icon,
    this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Map? productTypes;
    Map? deliveryAddresses;
    Map? pickupAddresses;
    if (consignment != null) {
      productTypes = json.decode(consignment!['product_types']);
      deliveryAddresses = json.decode(consignment!['delivery_addresses']);
      pickupAddresses = json.decode(consignment!['pickup_addresses']);
    }
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.lightGrey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: isLoading
          ? const EdgeInsets.all(0)
          : EdgeInsets.symmetric(horizontal: 2.w, vertical: 2.h),
      margin: EdgeInsets.only(bottom: 1.h),
      child: isLoading
          ? Shimmer.fromColors(
              baseColor: AppColors.greyWhite,
              highlightColor: AppColors.lightGrey,
              child: Container(
                width: double.maxFinite,
                height: 10.h,
                color: AppColors.greyWhite,
              ),
            )
          : Stack(
              children: [
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    height: 3.5.h,
                    width: 18.w,
                    decoration: BoxDecoration(
                      color: productTypes!['id'] == 1
                          ? AppColors.skyBlue
                          : AppColors.darkBlue,
                      borderRadius: BorderRadius.circular(15.sp),
                    ),
                    child: Center(
                      child: Text(
                        (productTypes['name']).toString().toUpperCase(),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: productTypes['id'] == 1
                                ? AppColors.black
                                : AppColors.white,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 4.w,
                      ),
                      child: isSelected != null
                          ? (isSelected == true
                              ? const Icon(Icons.check_box)
                              : const Icon(Icons.check_box_outline_blank))
                          : icon,
                    ),
                    SizedBox(width: 2.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (consignment!['consignment_type'] == 'delivery'
                                  ? deliveryAddresses!['customer_name']
                                  : pickupAddresses!['customer_name']) ??
                              'Not Provided',
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'ID: ${consignment!['id']}'.toUpperCase(),
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.black.withOpacity(0.5),
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                        SizedBox(
                          width: 45.w,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${AppText.drop}: ${consignment!['sort'] ?? 0}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              Text(
                                '${AppText.ctn}: ${consignment!['cartons'] ?? 0}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              Text(
                                '${AppText.plt}: ${consignment!['pallets'] ?? 0}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}
