import 'package:coldxpress/export.dart';

class CustomProductTypeAndTime extends StatelessWidget {
  const CustomProductTypeAndTime(
      {super.key,
      required this.type,
      required this.time,
      required this.svgImage});
  final String type;
  final String time;
  final SvgPicture svgImage;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 1.h,
        horizontal: 2.w,
      ),
      width: double.maxFinite,
      decoration: BoxDecoration(
        color: type == '1' ? AppColors.lightBlue : AppColors.newBlue,
        borderRadius: BorderRadius.circular(15.sp),
      ),
      child: IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
                flex: 1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      height: 5.h,
                      width: 9.w,
                      child: svgImage,
                    ),
                    Container(
                      height: 3.5.h,
                      width: 18.w,
                      decoration: BoxDecoration(
                        color: type == '1'
                            ? AppColors.white
                            : AppColors.darkBlueOne,
                        borderRadius: BorderRadius.circular(8.sp),
                      ),
                      child: Center(
                        child: Text(
                          type == '1'
                              ? AppText.chilled.toUpperCase()
                              : AppText.frozen.toUpperCase(),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: type == '1'
                                        ? AppColors.lightNavyBlue
                                        : AppColors.white,
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                      ),
                    ),
                  ],
                )),
            const VerticalDivider(
              color: AppColors.midGrey,
            ),
            Expanded(
                child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppText.time,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    Text(
                      time,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ],
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.white,
                  opticalSize: 0.01,
                  size: 2.h,
                )
              ],
            ))
          ],
        ),
      ),
    );
  }
}
