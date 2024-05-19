import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:coldxpress/export.dart';

class MyConsigmentTab extends StatefulWidget {
  const MyConsigmentTab({super.key});

  @override
  State<MyConsigmentTab> createState() => _MyConsigmentTabState();
}

class _MyConsigmentTabState extends State<MyConsigmentTab> {
  final StreamController<dynamic> _consignmentStreamController =
      StreamController<dynamic>();
  final ScrollController _scrollController = ScrollController();
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    fetchConsignment();
    _timer = Timer.periodic(
      const Duration(seconds: 30),
      (timer) {
        fetchConsignment();
      },
    );
  }

  @override
  void dispose() {
    _consignmentStreamController.close();
    _timer.cancel();
    super.dispose();
  }

  Future<void> fetchConsignment() async {
    AuthenticationState state =
        BlocProvider.of<AuthenticationCubit>(context).state;
    if (state is Authenticated) {
      try {
        final response = await http.get(
          Uri.parse(AppHost.consignments),
          headers: <String, String>{
            'Authorization': 'Bearer ${state.token}',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        );
        if (response.statusCode == 200) {
          final dynamic data = json.decode(response.body);
          
          if (data['status'] == 'success') {
            _consignmentStreamController.add(data);
          } else {
            _consignmentStreamController.addError(data['message']);
          }
        } else {
          _consignmentStreamController.addError('Failed to fetch data');
        }
      } catch (e) {
        if (!_consignmentStreamController.isClosed) {
          _consignmentStreamController.addError(e.toString());
        }
      }
    }
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
            context.read<BottomNavProvider>().changeTabView(1);
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
          AppText.myConsignment,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: SafeArea(
          child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        child: SingleChildScrollView(
          controller: _scrollController,
          child: StreamBuilder(
              stream: _consignmentStreamController.stream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Column(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 4.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: AppColors.blue,
                          borderRadius: BorderRadius.circular(8.sp),
                        ),
                        child: Column(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 0.5.h,
                                ),
                                Text(
                                  AppText.todayConsignment,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(color: AppColors.white),
                                ),
                                SizedBox(
                                  height: 1.5.h,
                                ),
                                Row(
                                  children: [
                                    Text(
                                      snapshot.data['data']
                                                  .containsKey('2024-04-04') ==
                                              false
                                          ? '0'
                                          : snapshot
                                              .data['data']['2024-04-04']
                                                  ['consignments']
                                              .length
                                              .toString(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.white,
                                          ),
                                    ),
                                    Text(
                                      AppText.consignmentRemaining,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: AppColors.white,
                                          ),
                                    ),
                                    SizedBox(
                                      width: 1.w,
                                    ),
                                    CircleAvatar(
                                      backgroundColor: AppColors.white,
                                      radius: 0.6.w,
                                    ),
                                    SizedBox(
                                      width: 1.w,
                                    ),
                                    Text(
                                      DateFormat('dd MMM,yyyy')
                                          .format(DateTime.now()),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: AppColors.white,
                                          ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 2.h,
                            ),
                            CustomTextField(
                              name: 'search',
                              borderColor: AppColors.white,
                              prefixIcon: Icon(
                                Icons.search,
                                color: AppColors.black.withOpacity(0.5),
                              ),
                              hintText: 'Search by ID, REF or Recipient',
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 1.5.h,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          for (int i = 0; i < 4; i++) ...{
                            Column(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    i == 0
                                        ? Get.toNamed(AppRoutes.consignmentMap)
                                        : i == 1
                                            ? Get.toNamed(
                                                AppRoutes.consigmentReorder)
                                            : i == 2
                                                ? Get.toNamed(
                                                    AppRoutes.consigmentGroup)
                                                : null;
                                  },
                                  child: CircleAvatar(
                                    radius: 9.w,
                                    backgroundColor: AppColors.greyWhite,
                                    child: i == 0
                                        ? SvgPicture.asset(
                                            AppSvgs.consignmentViewBlack,
                                            width: 10.w,
                                          )
                                        : i == 1
                                            ? SvgPicture.asset(
                                                AppSvgs.reorderBlack,
                                                width: 10.w,
                                              )
                                            : i == 2
                                                ? SvgPicture.asset(
                                                    AppSvgs.groupBlack,
                                                    width: 10.w,
                                                  )
                                                : SvgPicture.asset(
                                                    AppSvgs.reset,
                                                    width: 10.w,
                                                  ),
                                  ),
                                ),
                                Text(
                                  i == 0
                                      ? 'Map'
                                      : i == 1
                                          ? 'Re-order'
                                          : i == 2
                                              ? 'Group'
                                              : 'Refresh',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.darkGrey,
                                      ),
                                )
                              ],
                            )
                          },
                        ],
                      ),
                      for (var consignment
                          in snapshot.data['data']['2024-04-04'] == null
                              ? []
                              : snapshot.data['data']['2024-04-04']
                                  ['consignments']) ...{
                        GestureDetector(
                          onTap: () {
                            Get.toNamed(
                              AppRoutes.singleConsigment,
                              arguments: snapshot.data['data']['2024-04-04']
                                  ['consignments'][snapshot.data['data']
                                      ['2024-04-04']['consignments']
                                  .indexOf(consignment)]['id'],
                            );
                          },
                          child: CustomMyConsigmentContainer(
                            consignment: consignment,
                            isLoading: false,
                            index: snapshot.data['data']['2024-04-04']
                                ['consignments'][snapshot.data['data']
                                    ['2024-04-04']['consignments']
                                .indexOf(consignment)]['sort'],
                          ),
                        ),
                      },
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
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: AppColors.midBlue,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                      ),
                    ],
                  );
                }
                if (snapshot.hasError) {
                  return SizedBox(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              AppText.todayConsignments.toUpperCase(),
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                          ],
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          snapshot.error.toString(),
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(color: AppColors.red),
                        ),
                      ],
                    ),
                  );
                } else {
                  return SizedBox(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Shimmer.fromColors(
                            baseColor: AppColors.greyWhite,
                            highlightColor: AppColors.lightGrey,
                            child: Column(
                              children: [
                                Container(
                                  height: 20.h,
                                  width: double.maxFinite,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8.sp),
                                    color: AppColors.greyWhite,
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    for (int i = 0; i < 4; i++) ...{
                                      Column(
                                        children: [
                                          CircleAvatar(
                                            radius: 9.w,
                                            backgroundColor:
                                                AppColors.greyWhite,
                                            child: i == 0
                                                ? SvgPicture.asset(
                                                    AppSvgs.journey,
                                                    width: 10.w,
                                                  )
                                                : i == 1
                                                    ? SvgPicture.asset(
                                                        AppSvgs.pallet,
                                                        width: 10.w,
                                                      )
                                                    : i == 2
                                                        ? SvgPicture.asset(
                                                            AppSvgs.pallet,
                                                            width: 10.w,
                                                          )
                                                        : SvgPicture.asset(
                                                            AppSvgs.pallet,
                                                            width: 10.w,
                                                          ),
                                          ),
                                          Text(
                                            i == 0
                                                ? 'Map'
                                                : i == 1
                                                    ? 'Re-order'
                                                    : i == 2
                                                        ? 'Group'
                                                        : 'Refresh',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w700,
                                                  color: AppColors.darkGrey,
                                                ),
                                          )
                                        ],
                                      )
                                    },
                                  ],
                                ),
                                SizedBox(height: 2.h),
                                for (int i = 0; i < 4; i++) ...{
                                  const CustomMyConsigmentContainer(
                                    isLoading: true,
                                  ),
                                }
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
              }),
        ),
      )),
    );
  }
}
