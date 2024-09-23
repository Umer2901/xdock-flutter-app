import 'package:coldxpress/export.dart';
import 'package:coldxpress/widgets/core/custom-widget.dart';
import 'package:coldxpress/widgets/core/custom_text.dart';

import '../widgets/core/custom-container.dart';

class PodHistoryView extends StatefulWidget {
  const PodHistoryView({super.key});

  @override
  State<PodHistoryView> createState() => _PodHistoryViewState();
}

class _PodHistoryViewState extends State<PodHistoryView> {
  final SignatureController _controller = SignatureController(
    penStrokeWidth: 3,
    penColor: AppColors.black,
    exportBackgroundColor: AppColors.white,
  );

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          AppText.podhistoryview,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 15.0, left: 14, right: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomContainer(
                podStatus: 'single pod',
                //   ontab: () {
                //   Get.toNamed(AppRoutes.pending);
                // },
              ),
              SizedBox(
                height: 1.h,
              ),
              Container(
                height: 27.3.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Color(0xffF4F4F4),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.only(top: 10.0, left: 15, right: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomWidget(text: "POD Histories view", onTap: () {}),
                      SizedBox(
                        height: 2.h,
                      ),
                      Container(
                        height: 15.h,
                        width: 27.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Image.asset(
                          AppImages.simplePic,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 1.h,
              ),
              Container(
                height: 27.3.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Color(0xffF4F4F4),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.only(top: 10.0, left: 15, right: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                          child: CustomWidget(text: "Signature", onTap: () {})),
                      SizedBox(
                        height: 2.h,
                      ),
                      Container(
                        height: 15.h,
                        width: 27.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: EdgeInsets.symmetric(
                            vertical: 1.h, horizontal: 2.w),
                        child: Signature(
                          controller: _controller,
                          width: 90.w,
                          height: 20.h,
                          backgroundColor: Colors.transparent,
                        ),
                        //child: Image.asset(AppImages.simplePic,fit: BoxFit.contain,),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 1.5.h,
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Container(
                  height: 47.3.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Color(0xffF4F4F4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.only(top: 10.0, left: 15, right: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 1.h,
                        ),
                        CustomWidget(text: "Payload", onTap: () {}),
                        SizedBox(
                          height: 2.h,
                        ),
                        Container(
                          height: 35.h,
                          width: 85.w,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Container(
                            height: 20.h,
                            width: 20.w,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: AppColors.white,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  top: 8.0, left: 10, right: 10, bottom: 8),
                              child: CustomTextDisplay(
                                text: "sksnksnksn",
                              ),
                            ),
                          ),
                        ),
                      ],
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
