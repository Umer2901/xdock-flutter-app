import 'package:coldxpress/export.dart';

class CustomConsignmentContainer extends StatelessWidget {
  final bool isLoading;
  final Map? consignment;
  const CustomConsignmentContainer(
      {super.key, this.isLoading = false, this.consignment});

  @override
  Widget build(BuildContext context) {
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
                      color: consignment!['product_types']['id'] == 1
                          ? AppColors.skyBlue
                          : AppColors.darkBlue,
                      borderRadius: BorderRadius.circular(15.sp),
                    ),
                    child: Center(
                      child: Text(
                        (consignment!['product_types']['name'])
                            .toString()
                            .toUpperCase(),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: consignment!['product_types']['id'] == 1
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
                      child: Icon(Icons.drag_handle),
                    ),
                    // CircleAvatar(
                    //   backgroundColor: AppColors.darkGrey.withOpacity(0.16),
                    //   radius: 7.5.w,
                    //   child: SizedBox(
                    //     height: 15.h,
                    //     width: 15.w,
                    //     child: Image(
                    //       image: consignment!['product_types']['id'] == 1
                    //           ? const AssetImage(AppImages.chilled)
                    //           : const AssetImage(AppImages.frozen),
                    //     ),
                    //   ),
                    // ),
                    SizedBox(width: 2.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (consignment!['consignment_type'] == 'delivery'
                                  ? consignment!['delivery_addresses']
                                      ['customer_name']
                                  : consignment!['pickup_addresses']
                                      ['customer_name']) ??
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
