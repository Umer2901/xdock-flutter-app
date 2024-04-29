import 'package:coldxpress/export.dart';

class CustomDeliveryDetailsContainer extends StatelessWidget {
  const CustomDeliveryDetailsContainer(
      {super.key,
      required this.type,
      required this.counts,
      required this.svgIcon,
      this.countType});
  final String type;
  final String counts;
  final String? countType;
  final SvgPicture svgIcon;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
      width: 44.w,
      decoration: BoxDecoration(
        color: AppColors.greyWhite,
        borderRadius: BorderRadius.circular(8.sp),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            height: 6.h,
            width: 13.5.w,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(8.sp),
            ),
            child: SizedBox(
              height: 4.h,
              width: 9.5.w,
              child: svgIcon,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 4.w,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      counts,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    SizedBox(
                      width: 1.w,
                    ),
                    Text(
                      countType ?? '',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w700, fontSize: 10.sp),
                    ),
                  ],
                ),
                Text(
                  type.toUpperCase(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.darkGrey.withOpacity(0.8),
                      ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
