// ignore_for_file: deprecated_member_use
import 'dart:convert';
import 'package:coldxpress/export.dart';

class MyConsigmentReorder extends StatefulWidget {
  const MyConsigmentReorder({super.key});

  @override
  State<MyConsigmentReorder> createState() => _MyConsigmentReorderState();
}

class _MyConsigmentReorderState extends State<MyConsigmentReorder> {
  final ScrollController _scrollController = ScrollController();
  final List<dynamic> _consignments = [];
  List<int> consignmentIds = [];

  @override
  void initState() {
    super.initState();
    _consignments.addAll(json.decode(json.encode(Get.arguments)));
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(
            Icons.arrow_back_ios,
            size: 15.sp,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.more_horiz,
              size: 20.sp,
            ),
          )
        ],
        centerTitle: true,
        title: Text(
          AppText.reorder,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: SafeArea(
          child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: [
              CircleAvatar(
                radius: 9.w,
                backgroundColor: AppColors.greyWhite,
                child: SvgPicture.asset(
                  AppSvgs.reorderBlack,
                  width: 10.w,
                  color: AppColors.blue,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 3.w,
                  vertical: 1.h,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomButton(
                      label: AppText.cancel.toUpperCase(),
                      borderColor: AppColors.belowMidGreyTwo,
                      backgroundColor: AppColors.white,
                      foregroundColor: AppColors.border.withOpacity(0.8),
                      width: 40.w,
                      height: 5.h,
                      onPressed: () {
                        Get.back();
                      },
                    ),
                    CustomButton(
                      width: 40.w,
                      height: 5.h,
                      label: AppText.save.toUpperCase(),
                      onPressed: () {
                        if (consignmentIds.isNotEmpty) {
                          AuthenticationState authState =
                              BlocProvider.of<AuthenticationCubit>(context)
                                  .state;
                          if (authState is Authenticated) {
                            ConsignmentService(
                                    context.read<DatabaseProvider>().database)
                                .reorderConsignments(
                              consignmentIds,
                              authState.token,
                            );
                            Get.back();
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  ReorderableListView(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    onReorder: (oldIndex, newIndex) {
                      setState(() {
                        if (newIndex > oldIndex) {
                          newIndex -= 1;
                        }
                        final item = _consignments.removeAt(oldIndex);
                        _consignments.insert(newIndex, item);
                        consignmentIds = [];
                        for (var consignment in _consignments) {
                          consignmentIds.add(consignment['id']);
                        }
                      });
                    },
                    children: List.generate(
                      _consignments.length,
                      (index) {
                        final consignment = _consignments[index];
                        return CustomConsignmentContainer(
                          key: ValueKey(consignment['id']),
                          consignment: consignment,
                          icon: const Icon(Icons.drag_handle),
                        );
                      },
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      _scrollController.animateTo(
                        0.0,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                      child: Text(
                        AppText.returnToTop,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.midBlue,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      )),
    );
  }
}
