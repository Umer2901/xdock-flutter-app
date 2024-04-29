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
        horizontal: 4.w,
      ),
      width: double.maxFinite,
      height: 7.5.h,
      decoration: BoxDecoration(
        color: type == 'Chilled' ? AppColors.lightBlue : AppColors.newBlue,
        borderRadius: BorderRadius.circular(15.sp),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
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
              color:
                  type == 'Chilled' ? AppColors.white : AppColors.darkBlueOne,
              borderRadius: BorderRadius.circular(8.sp),
            ),
            child: Center(
              child: Text(
                type.toUpperCase(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: type == 'Chilled'
                          ? AppColors.lightNavyBlue
                          : AppColors.white,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          ),
          const VerticalDivider(
            color: AppColors.midGrey,
          ),
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
      ),
    );
  }
}
