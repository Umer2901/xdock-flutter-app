import 'package:coldxpress/export.dart';
import 'package:coldxpress/providers/proof-of-delivery-provider.dart';
import 'package:coldxpress/views/tabs/consignments/sub_views/proof_of_delivery.dart';

class CustomDropdown extends StatelessWidget {
  final String name;
  final String hintText;
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
    required this.hintText,
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
    this.isErrorState = false, required DeliveryType value,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width * 0.9,
      child: FormBuilderDropdown(
        iconDisabledColor: AppColors.lightGrey,
        iconEnabledColor: AppColors.darkGrey,
        validator: validator,
        onTap: onTap,
        name: name,
        initialValue: initialValue,
        style: Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(color: AppColors.black),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 4.w),
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          hintText: hintText,
          hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                letterSpacing: 1,
                color: AppColors.darkGrey,
              ),
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
        onChanged: onChanged,
        items: items,
      ),
    );
  }
}
