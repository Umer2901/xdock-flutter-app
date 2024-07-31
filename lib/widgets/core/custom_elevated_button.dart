// ignore_for_file: deprecated_member_use
import 'package:coldxpress/export.dart';

class CustomElevatedButton extends StatelessWidget {
  final double? height;
  final double? width;
  final double? borderRadius;
  final Color borderColor;
  final IconData? icon;
  final Color? iconColor;
  final String label;
  final double? labelFontSize;
  final VoidCallback onPressed;
  final Color? foregroundColor;
  final Color? backgroundColor;
  final bool isLoading;
  const CustomElevatedButton({
    super.key,
    this.height,
    this.width,
    this.borderRadius,
    this.borderColor = AppColors.blue,
    this.icon,
    this.iconColor,
    required this.label,
    this.labelFontSize,
    this.foregroundColor = AppColors.white,
    this.backgroundColor = AppColors.blue,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height ?? 6.5.h,
      width: width ?? 90.w,
      child: Stack(
        children: [
          SizedBox(
            height: height ?? 6.5.h,
            width: width ?? 90.w,
            child: ElevatedButton(
              onPressed: isLoading ? null : onPressed,
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(backgroundColor!),
                foregroundColor:
                    MaterialStateProperty.all<Color>(foregroundColor!),
                shape: MaterialStateProperty.all<OutlinedBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(borderRadius ?? 10.sp),
                    side: BorderSide(color: borderColor),
                  ),
                ),
                elevation: MaterialStateProperty.all<double>(10),
                shadowColor: MaterialStateProperty.all<Color>(
                    AppColors.black.withOpacity(0.5)),
              ),
              child: isLoading
                  ? LoadingIndicator(
                      indicatorType: Indicator.ballBeat,
                      colors: [foregroundColor ?? AppColors.white],
                      strokeWidth: 2.w,
                    )
                  : icon != null
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Icon(icon, color: iconColor),
                            Text(
                              label,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: labelFontSize,
                                    color: foregroundColor,
                                  ),
                            ),
                          ],
                        )
                      : Text(
                          label,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: labelFontSize,
                                    color: foregroundColor,
                                  ),
                        ),
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 0,
            height: 10,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(55.sp),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withOpacity(0.1),
                    spreadRadius: 0,
                    blurRadius: 5,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
            ),
          ),
          // Right shadow
          Positioned(
            top: 0,
            right: 0,
            bottom: 5,
            width: 10,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(55.sp),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withOpacity(0.1),
                    spreadRadius: 0,
                    blurRadius: 5,
                    offset: const Offset(5, 0),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
