// import 'package:coldxpress/export.dart';

// class PalletContainer extends StatelessWidget {
//   final String name;
//   final String heading;
//   final Widget? icon;
//   final String? hintText;
//   final String? Function(String?)? validator;
//   final TextInputAction textInputAction;
//   final int? initialValue;
//   final int? totalPallet;
//   final Color? fillColor;
//   final TextInputType keyboardType;
//   final EdgeInsets? contentPadding;
//   final bool isErrorState;
//   const PalletContainer({
//     super.key,
//     required this.name,
//     required this.heading,
//     this.hintText,
//     this.validator,
//     this.initialValue,
//     this.totalPallet,
//     this.textInputAction = TextInputAction.done,
//     this.fillColor = AppColors.white,
//     this.keyboardType = TextInputType.number,
//     this.contentPadding,
//     this.isErrorState = false,
//     this.icon,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 43.w,
//       decoration: BoxDecoration(
//         color: AppColors.greyWhite,
//         borderRadius: BorderRadius.circular(10.sp),
//       ),
//       padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
//       margin: EdgeInsets.symmetric(horizontal: 1.w, vertical: 0.5.h),
//       child: Column(
//         children: [
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               SizedBox(
//                 height: 20.sp,
//                 width: 20.sp,
//                 child: icon ??
//                     Image(
//                       image: AssetImage(AppImages.pallet),
//                     ),
//               ),
//               SizedBox(width: 2.w),
//               Text(
//                 heading,
//                 style: Theme.of(context).textTheme.headlineSmall,
//               ),
//             ],
//           ),
//           SizedBox(
//             height: 1.h,
//           ),
//           Row(
//             children: [
//               SizedBox(
//                 width: 17.w,
//                 height: 6.h,
//                 child: FormBuilderTextField(
//                   textInputAction: textInputAction,
//                   validator: validator,
//                   name: name,
//                   initialValue: initialValue.toString(),
//                   style: Theme.of(context).textTheme.bodyLarge,
//                   cursorColor: AppColors.black,
//                   keyboardType: keyboardType,
//                   decoration: InputDecoration(
//                     contentPadding: contentPadding,
//                     hintText: hintText,
//                     hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                           letterSpacing: 1,
//                           color: AppColors.black.withOpacity(0.5),
//                         ),
//                     fillColor: fillColor,
//                     filled: true,
//                     enabled: true,
//                     enabledBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10.sp),
//                       borderSide: BorderSide(
//                         color:
//                             isErrorState ? AppColors.red : AppColors.lightGrey,
//                       ),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10.sp),
//                       borderSide: BorderSide(
//                         color: isErrorState ? AppColors.red : AppColors.black,
//                       ),
//                     ),
//                     errorBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10.sp),
//                       borderSide: const BorderSide(
//                         color: AppColors.red,
//                       ),
//                     ),
//                     focusedErrorBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10.sp),
//                       borderSide: const BorderSide(
//                         color: AppColors.red,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               if (totalPallet != null)
//                 Text(
//                   '  of $totalPallet',
//                   style: Theme.of(context)
//                       .textTheme
//                       .bodyLarge
//                       ?.copyWith(color: AppColors.midGrey),
//                 ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:coldxpress/export.dart';

class PalletContainer extends StatelessWidget {
  final String name;
  final String heading;
  final Widget? icon;
  final String? hintText;
  final String? Function(String?)? validator;
  final TextInputAction textInputAction;
  final int? initialValue;
  final int? totalPallet;
  final Color? fillColor;
  final TextInputType keyboardType;
  final EdgeInsets? contentPadding;
  final bool isErrorState;
  final Function(int)? onValueChanged;
  const PalletContainer({
    super.key,
    required this.name,
    required this.heading,
    this.hintText,
    this.validator,
    this.initialValue,
    this.totalPallet,
    this.textInputAction = TextInputAction.done,
    this.fillColor = AppColors.white,
    this.keyboardType = TextInputType.number,
    this.contentPadding,
    this.isErrorState = false,
    this.icon,
    this.onValueChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 43.w,
      decoration: BoxDecoration(
        color: AppColors.greyWhite,
        borderRadius: BorderRadius.circular(10.sp),
      ),
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
      margin: EdgeInsets.symmetric(horizontal: 1.w, vertical: 0.5.h),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 20.sp,
                width: 20.sp,
                child: icon ??
                    const Image(
                      image: AssetImage(AppImages.pallet),
                    ),
              ),
              SizedBox(width: 2.w),
              Text(
                heading,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ],
          ),
          SizedBox(
            height: 1.h,
          ),
          Row(
            children: [
              SizedBox(
                width: 17.w,
                height: 6.h,
                child: FormBuilderTextField(
                  textInputAction: textInputAction,
                  validator: validator,
                  name: name,
                  initialValue: initialValue.toString(),
                  onChanged: (value) {
                    if (onValueChanged != null) {
                      onValueChanged!(int.tryParse(value!) ?? 0);
                    }
                  },
                  style: Theme.of(context).textTheme.bodyLarge,
                  cursorColor: AppColors.black,
                  keyboardType: keyboardType,
                  decoration: InputDecoration(
                    contentPadding: contentPadding,
                    hintText: hintText,
                    hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          letterSpacing: 1,
                          color: AppColors.black.withOpacity(0.5),
                        ),
                    fillColor: fillColor,
                    filled: true,
                    enabled: true,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.sp),
                      borderSide: BorderSide(
                        color:
                            isErrorState ? AppColors.red : AppColors.lightGrey,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.sp),
                      borderSide: BorderSide(
                        color: isErrorState ? AppColors.red : AppColors.black,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.sp),
                      borderSide: const BorderSide(
                        color: AppColors.red,
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.sp),
                      borderSide: const BorderSide(
                        color: AppColors.red,
                      ),
                    ),
                  ),
                ),
              ),
              if (totalPallet != null)
                Text(
                  '  of $totalPallet',
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(color: AppColors.midGrey),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
