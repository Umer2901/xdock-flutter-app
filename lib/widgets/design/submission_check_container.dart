import 'package:coldxpress/export.dart';

class SubmissionCheckContainer extends StatelessWidget {
  final String leadingSVG;
  final String title;
  final String subtitle;
  final LinearGradient backgroundColor;
  final bool isLoading;
  final VoidCallback onPressed;
  const SubmissionCheckContainer({
    super.key,
    required this.leadingSVG,
    required this.title,
    required this.subtitle,
    required this.backgroundColor,
    this.isLoading = false,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        height: 16.h,
        width: double.maxFinite,
        decoration: BoxDecoration(
          gradient: backgroundColor,
          borderRadius: BorderRadius.circular(10.sp),
        ),
        padding: isLoading
            ? const EdgeInsets.all(0)
            : EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
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
            : Column(
                children: [
                  Row(
                    children: [
                      Container(
                        height: 5.h,
                        width: 5.h,
                        padding: EdgeInsets.all(2.5.w),
                        decoration: BoxDecoration(
                          color: AppColors.grey.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(10.sp),
                        ),
                        child: SvgPicture.asset(
                          leadingSVG,
                          // ignore: deprecated_member_use
                          color: AppColors.white,
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Text(
                        title,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(color: AppColors.white),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.h),
                  Row(
                    children: [
                      SizedBox(
                        width: 14.w,
                      ),
                      Expanded(
                        child: Text(
                          subtitle,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.white,
                                    fontSize: 10.sp,
                                  ),
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: AppColors.white,
                        size: 15.sp,
                      ),
                    ],
                  )
                ],
              ),
      ),
    );
  }
}
