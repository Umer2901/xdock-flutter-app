import 'package:coldxpress/export.dart';
import 'package:flutter/material.dart';
import '../../constants/colors.dart';

class CustomWidget extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  CustomWidget({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 4.5.h,
          width: 65.w,
          decoration: BoxDecoration(
            color: AppColors.blue,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: AppColors.white,
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
