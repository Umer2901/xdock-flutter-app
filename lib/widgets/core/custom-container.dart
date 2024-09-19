import 'package:coldxpress/export.dart';
import 'package:flutter/material.dart';

import '../../constants/colors.dart';
import '../../constants/text.dart';
import 'custom_text.dart';
class CustomContainer extends StatelessWidget {
  final String podStatus;
  final Function()? ontab;

  CustomContainer({required this.podStatus,this.ontab});

  @override
  Widget build(BuildContext context) {

    Color containerColor;
    String displayText;


    switch (podStatus.toLowerCase()) {
      case 'single pod':
        containerColor = AppColors.yellow;
        displayText = "Single POD";
        break;
      case 'grouped pod':
        containerColor = AppColors.green;
        displayText = "Grouped POD";
        break;
      case 'partial pod':
        containerColor = AppColors.blue;
        displayText = "Partial POD";
        break;
      default:
        containerColor = AppColors.grey;
        displayText = "Unknown POD";
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Container(
        height: 18.3.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Color(0xffF4F4F4),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 10.0, left: 15, right: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppText.name,
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16.sp),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CustomTextDisplay(text: AppText.cartons + ": 1"),
                  SizedBox(width: 1.5.w),
                  CustomTextDisplay(text: "|"),
                  SizedBox(width: 1.5.w),
                  CustomTextDisplay(text: AppText.pallets + ": 0"),
                  SizedBox(width: 1.5.w),
                  CustomTextDisplay(text: "|"),
                  SizedBox(width: 1.5.w),
                  CustomTextDisplay(text: AppText.space + ": 0"),
                ],
              ),
              SizedBox(height: 0.5.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CustomTextDisplay(text: AppText.ID + ": 239183"),
                  SizedBox(width: 1.5.w),
                  CustomTextDisplay(text: "|"),
                  SizedBox(width: 1.5.w),
                  CustomTextDisplay(text: AppText.reference + ": 0"),
                ],
              ),
              SizedBox(height: 0.5.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CustomTextDisplay(text: AppText.driverid + ": 1"),
                  SizedBox(width: 1.5.w),
                  CustomTextDisplay(text: "|"),
                  SizedBox(width: 1.5.w),
                  CustomTextDisplay(text: AppText.time + ": 09--02-2024 15:15:15"),
                ],
              ),
              SizedBox(height: 0.5.h),
              InkWell(
                onTap:ontab,
                child: Container(
                  height: 3.h,
                  width: 24.w,
                  decoration: BoxDecoration(
                    color: containerColor,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Center(
                    child: Text(
                      displayText,
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
