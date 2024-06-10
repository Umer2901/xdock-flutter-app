// import 'package:coldxpress/export.dart';

// class CustomButton extends StatelessWidget {
//   final double? height;
//   final double? width;
//   final double? borderRadius;
//   final Color borderColor;
//   final IconData? icon;
//   final Color? iconColor;
//   final String label;
//   final double? labelFontSize;
//   final VoidCallback onPressed;
//   final Color? foregroundColor;
//   final Color? backgroundColor;
//   final bool isLoading;
//   const CustomButton(
//       {super.key,
//       this.height,
//       this.width,
//       this.borderRadius,
//       this.borderColor = AppColors.blue,
//       this.icon,
//       this.iconColor,
//       required this.label,
//       this.labelFontSize,
//       this.foregroundColor = AppColors.white,
//       this.backgroundColor = AppColors.blue,
//       required this.onPressed,
//       this.isLoading = false});

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onPressed,
//       child: Container(
//         height: height ?? 6.5.h,
//         width: width ?? 90.w,
//         alignment: Alignment.center,
//         padding: EdgeInsets.symmetric(
//           vertical: 1.h,
//           horizontal: 2.w,
//         ),
//         decoration: BoxDecoration(
//           color: backgroundColor,
//           borderRadius: BorderRadius.circular(
//             borderRadius ?? 10.sp,
//           ),
//           border: Border.all(
//             color: borderColor,
//           ),
//         ),
//         child: isLoading
//             ? LoadingIndicator(
//                 indicatorType: Indicator.ballBeat,
//                 colors: [
//                   foregroundColor ?? AppColors.white,
//                 ],
//                 strokeWidth: 2.w,
//               )
//             : icon != null
//                 ? Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                     children: [
//                       Expanded(
//                         child: Icon(
//                           icon,
//                         ),
//                       ),
//                       Expanded(
//                         flex: 4,
//                         child: Text(
//                           label,
//                           style:
//                               Theme.of(context).textTheme.bodyMedium?.copyWith(
//                                     color: foregroundColor,
//                                     fontWeight: FontWeight.w700,
//                                     fontSize: labelFontSize,
//                                   ),
//                         ),
//                       ),
//                     ],
//                   )
//                 : Text(
//                     label,
//                     style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                           color: foregroundColor,
//                           fontWeight: FontWeight.w700,
//                           fontSize: labelFontSize,
//                         ),
//                   ),
//       ),
//     );
//   }
// }

import 'package:coldxpress/export.dart';

class CustomButton extends StatelessWidget {
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
  final bool enabled;
  const CustomButton({
    Key? key,
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
    this.enabled = true, 
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onPressed : null, 
      child: Container(
        height: height ?? 6.5.h,
        width: width ?? 90.w,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(
          vertical: 1.h,
          horizontal: 2.w,
        ),
        decoration: BoxDecoration(
          color: enabled ? backgroundColor : AppColors.grey,
          borderRadius: BorderRadius.circular(
            borderRadius ?? 10.sp,
          ),
          border: Border.all(
            color: borderColor,
          ),
        ),
        child: isLoading
            ? LoadingIndicator(
                indicatorType: Indicator.ballBeat,
                colors: [
                  foregroundColor ?? AppColors.white,
                ],
                strokeWidth: 2.w,
              )
            : icon != null
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: Icon(
                          icon,
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Text(
                          label,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: foregroundColor,
                                    fontWeight: FontWeight.w700,
                                    fontSize: labelFontSize,
                                  ),
                        ),
                      ),
                    ],
                  )
                : Text(
                    label,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: foregroundColor,
                          fontWeight: FontWeight.w700,
                          fontSize: labelFontSize,
                        ),
                  ),
      ),
    );
  }
}
