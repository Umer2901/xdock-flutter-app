import 'package:coldxpress/export.dart';
import 'package:flutter/material.dart';

import '../widgets/core/custom-container.dart';

class PendingView extends StatelessWidget {
  const PendingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            backgroundColor: AppColors.yellow,
            shape: CircleBorder(),
            onPressed: () {

            },
            child:Image.asset(AppImages.refreshicon,height: 30,width: 30,),
          ),
          SizedBox(height: 1.7.h,)
          ,FloatingActionButton(
            backgroundColor: AppColors.blue,
            shape: CircleBorder(),
            onPressed: () {

            },
            child:Image.asset(AppImages.upload,height: 30,width: 30,),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () {
            //context.read<BottomNavProvider>().changeTabView(1);
            Navigator.pop();
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
          AppText.pending,
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
              CustomContainer(podStatus: 'single pod',ontab: () {
                Get.toNamed(AppRoutes.pending);
              },),

            ],
          ),
        ),
      ),
    );
  }
}
