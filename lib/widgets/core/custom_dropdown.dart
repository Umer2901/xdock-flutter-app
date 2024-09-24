// import 'package:coldxpress/export.dart';

// class CustomDropdown extends StatelessWidget {
//   final String name;
//   final Widget? hintWidget; // Changed to hintWidget to clarify it's a widget
//   final Icon? prefixIcon;
//   final Widget? suffixIcon;
//   final bool obscureText;
//   final InputBorder? enableBorder;
//   final String? Function(dynamic)? validator;
//   final TextInputAction textInputAction;
//   final Function()? onTap;
//   final String? initialValue;
//   final bool readOnly;
//   final Color fillColor;
//   final void Function(dynamic)? onChanged;
//   final TextInputType keyboardType;
//   final List<DropdownMenuItem> items;
//   final bool isErrorState;
//   final dynamic value; // Added value property to track the selected value

//   const CustomDropdown({
//     super.key,
//     required this.name,
//     this.hintWidget, // Now accepts a widget for the hint
//     this.prefixIcon,
//     this.suffixIcon,
//     this.obscureText = false,
//     this.enableBorder,
//     this.validator,
//     this.initialValue,
//     this.textInputAction = TextInputAction.done,
//     this.onTap,
//     required this.fillColor,
//     this.readOnly = false,
//     this.keyboardType = TextInputType.name,
//     this.onChanged,
//     required this.items,
//     this.isErrorState = false,
//     this.value, // Added value
//   });

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: MediaQuery.sizeOf(context).width * 0.9,
//       child: DropdownButtonFormField(
//         iconDisabledColor: AppColors.lightGrey,
//         iconEnabledColor: AppColors.darkGrey,
//         validator: validator,
//         onTap: onTap,
//         value: value, // Set the dropdown's value to the selected value
//         style: Theme.of(context)
//             .textTheme
//             .bodyMedium
//             ?.copyWith(color: AppColors.black),
//         decoration: InputDecoration(
//           contentPadding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 4.w),
//           prefixIcon: prefixIcon,
//           suffixIcon: suffixIcon,
//           fillColor: fillColor,
//           filled: true,
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(10.sp),
//             borderSide: BorderSide(
//               color: isErrorState ? AppColors.red : AppColors.border,
//             ),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(10.sp),
//             borderSide: BorderSide(
//               color: isErrorState ? AppColors.red : AppColors.black,
//             ),
//           ),
//           errorBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(10.sp),
//             borderSide: const BorderSide(
//               color: AppColors.red,
//             ),
//           ),
//           focusedErrorBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(10.sp),
//             borderSide: const BorderSide(
//               color: AppColors.red,
//             ),
//           ),
//         ),
//         hint: hintWidget, // Using hintWidget directly in DropdownButtonFormField
//         onChanged: onChanged,
//         items: items,
//       ),
//     );
//   }
// }

import 'package:coldxpress/export.dart';

class CustomDropdown extends StatelessWidget {
  final String name;
  final Widget? hintWidget; // Changed to hintWidget to clarify it's a widget
  final Icon? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final InputBorder? enableBorder;
  final String? Function(dynamic)? validator;
  final TextInputAction textInputAction;
  final Function()? onTap;
  final String? initialValue;
  final bool readOnly;
  final Color fillColor;
  final void Function(dynamic)? onChanged;
  final TextInputType keyboardType;
  final List<DropdownMenuItem> items;
  final bool isErrorState;

  const CustomDropdown({
    super.key,
    required this.name,
    this.hintWidget, // Now accepts a widget for the hint
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.enableBorder,
    this.validator,
    this.initialValue,
    this.textInputAction = TextInputAction.done,
    this.onTap,
    required this.fillColor,
    this.readOnly = false,
    this.keyboardType = TextInputType.name,
    this.onChanged,
    required this.items,
    this.isErrorState = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width * 0.9,
      child: DropdownButtonFormField(
        iconDisabledColor: AppColors.lightGrey,
        iconEnabledColor: AppColors.darkGrey,
        validator: validator,
        onTap: onTap,
        value: initialValue,
        style: Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(color: AppColors.black),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 4.w),
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          fillColor: fillColor,
          filled: true,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.sp),
            borderSide: BorderSide(
              color: isErrorState ? AppColors.red : AppColors.border,
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
        hint: hintWidget, // Using hintWidget directly in DropdownButtonFormField
        onChanged: onChanged,
        items: items,
      ),
    );
  }
}
