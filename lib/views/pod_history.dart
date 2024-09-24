import 'package:coldxpress/export.dart';
import 'package:coldxpress/widgets/core/custom_text.dart';
import 'package:flutter/material.dart';

import '../widgets/core/custom-container.dart';

class PodHistory extends StatelessWidget {
  const PodHistory({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.blue,
        shape: CircleBorder(),
        onPressed: () {

        },
        child:Image.asset(AppImages.upload,height: 30,width: 30,),
        // Icon(Icons.file_upload_outlined,color: AppColors.white,size: 34,),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () {
            //context.read<BottomNavProvider>().changeTabView(1);
          },
          icon: Icon(
            Icons.arrow_back_ios,
            size: 15.sp,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
            //  _scaffoldKey.currentState?.openEndDrawer();
            },
            icon: Icon(
              Icons.more_horiz,
              size: 20.sp,
            ),
          ),
        ],
        centerTitle: true,
        title: Text(
          AppText.podHoistory,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 10.0,left: 14,right: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Container(
              height: 83,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Color(0xffF4F4F4),
                 shape: BoxShape.rectangle,
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 12.0,left: 15,right: 15,bottom: 12),
                  child: CustomTextField(
                    maxLines: 1,
                    hight: 6.h,
                    name: 'search',
                    borderColor: AppColors.white,
                    prefixIcon: Icon(
                      Icons.search,
                      color: AppColors.black.withOpacity(0.5),
                    ),
                    hintText:
                    'Search',
                    onChanged: (value) {
                      // setState(() {
                      //   query = value;
                      // });
                    },
                  ),
                ),
              ),
            ),
              SizedBox(height: 3.h,),
              CustomContainer(
                podStatus: 'single pod',ontab: () {
                Get.toNamed(AppRoutes.podhistoryview);
              },),
              CustomContainer(podStatus: 'grouped pod'),
              CustomContainer(podStatus: 'partial pod'),
              CustomContainer(podStatus: 'single pod'),  // for yellow container
              CustomContainer(podStatus: 'grouped pod'), // for green container
              CustomContainer(podStatus: 'partial pod'),
        
        
              // Container(
              //   height: 18.3.h,
              //   width: double.infinity,
              //   decoration: BoxDecoration(
              //     color: Color(0xffF4F4F4),
              //     borderRadius: BorderRadius.circular(10),
              //
              //   ),
              //   child: Padding(
              //     padding: const EdgeInsets.only(top: 10.0,left: 15,right: 10),
              //     child: Column(
              //        crossAxisAlignment: CrossAxisAlignment.start,
              //       children: [
              //         Text(AppText.name, style: TextStyle(fontWeight: FontWeight.w700,fontSize: 16.sp,),),
              //         Row(
              //          mainAxisAlignment: MainAxisAlignment.start,
              //          children: [
              //                CustomTextDisplay(text: AppText.cartons + ": 1"),
              //                SizedBox(width: 1.5.w,),
              //                CustomTextDisplay(text: "|",),
              //                SizedBox(width: 1.5.w,),
              //                CustomTextDisplay(text: AppText.pallets +": 0"),
              //                SizedBox(width: 1.5.w,),
              //                CustomTextDisplay(text: "|",),
              //                SizedBox(width: 1.5.w,),
              //               CustomTextDisplay(text: AppText.space + ": 0",),
              //          ],
              //        ),
              //         SizedBox(height: 0.5.h,),
              //         Row(
              //           mainAxisAlignment: MainAxisAlignment.start,
              //           children: [
              //             CustomTextDisplay(text: AppText.ID + ": 239183"),
              //             SizedBox(width: 1.5.w,),
              //             CustomTextDisplay(text: "|",),
              //             SizedBox(width: 1.5.w,),
              //             CustomTextDisplay(text: AppText.reference +": 0"),
              //
              //           ],
              //         ),
              //         SizedBox(height: 0.5.h,),
              //         Row(
              //           mainAxisAlignment: MainAxisAlignment.start,
              //           children: [
              //             CustomTextDisplay(text: AppText.driverid + ": 1"),
              //             SizedBox(width: 1.5.w,),
              //             CustomTextDisplay(text: "|",),
              //             SizedBox(width: 1.5.w,),
              //             CustomTextDisplay(text: AppText.time +": 09--02-2024 "+"15:15:15"),
              //           ],
              //         ),
              //         SizedBox(height: 0.5.h,),
              //         Container(
              //           height: 3.h,
              //           width: 24.w,
              //           decoration: BoxDecoration(
              //             color: AppColors.yellow,
              //             borderRadius: BorderRadius.circular(5),
              //           ),
              //           child: Center(
              //             child: Text(
              //               AppText.singlepod,
              //               style: TextStyle(
              //                   fontSize: 10.sp,
              //                   fontWeight: FontWeight.w700,
              //                 color: AppColors.white,
              //               ),),
              //           ),
              //         )
              //
              //       ],
              //     ),
              //   ),
              // )
        
        
        
            ],
          ),
        ),
      ),

    );
  }
}
