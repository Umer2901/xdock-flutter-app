import 'dart:async';
import 'dart:convert';
import 'package:coldxpress/export.dart';

import 'package:http/http.dart' as http;

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final StreamController<dynamic> _dataStreamController =
      StreamController<dynamic>();
  final StreamController<dynamic> _requireStreamController =
      StreamController<dynamic>();
  final StreamController<dynamic> _consignmentStreamController =
      StreamController<dynamic>();

  late Timer _timer;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchData();
    checkRequires();
    fetchConsignment();
    _timer = Timer.periodic(
      const Duration(seconds: 30),
      (timer) {
        fetchData();
        checkRequires();
        fetchConsignment();
      },
    );
  }

  @override
  void dispose() {
    _dataStreamController.close();
    _requireStreamController.close();
    _consignmentStreamController.close();
    _timer.cancel();
    super.dispose();
  }

  Future<void> fetchData() async {
    AuthenticationState state =
        BlocProvider.of<AuthenticationCubit>(context).state;
    if (state is Authenticated) {
      try {
        final response = await http.get(
          Uri.parse(AppHost.loginStaffData),
          headers: <String, String>{
            'Authorization': 'Bearer ${state.token}',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          final dynamic data = json.decode(response.body);
          _dataStreamController.add(data);
        } else {
          _dataStreamController.addError('Failed to fetch data');
        }
      } catch (e) {
        if (!_dataStreamController.isClosed) {
          _dataStreamController.addError(e.toString());
        }
      }
    }
  }

  Future<void> checkRequires() async {
    AuthenticationState state =
        BlocProvider.of<AuthenticationCubit>(context).state;
    if (state is Authenticated) {
      try {
        final response = await http.get(
          Uri.parse(AppHost.checkSubmissions),
          headers: <String, String>{
            'Authorization': 'Bearer ${state.token}',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          final dynamic data = json.decode(response.body);
          _requireStreamController.add(data);
        } else {
          _requireStreamController.addError('Failed to fetch data');
        }
      } catch (e) {
        if (!_requireStreamController.isClosed) {
          _requireStreamController.addError(e.toString());
        }
      }
    }
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
        print(response.body);
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
    return StreamBuilder<dynamic>(
      stream: _dataStreamController.stream,
      builder: (context, snapshot) {
        return Scaffold(
          body: Builder(builder: (BuildContext context) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  4.w,
                  2.h,
                  4.w,
                  0,
                ),
                child: Column(
                  children: [
                    if (snapshot.hasData) ...{
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 80.w,
                                child: Text(
                                  '${AppText.goodMorning} ${snapshot.data['data']['name']}!',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(color: AppColors.darkGrey),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                snapshot.data['data'].containsKey(
                                            DateFormat('yyyy-MM-dd')
                                                .format(DateTime.now())) ==
                                        false
                                    ? AppText.letFinishYourday
                                    : AppText.letStartYourday,
                                style:
                                    Theme.of(context).textTheme.headlineMedium,
                              )
                            ],
                          ),
                          InkWell(
                            onTap: () {
                              Scaffold.of(context).openEndDrawer();
                            },
                            child: Stack(
                              children: [
                                CircleAvatar(
                                  backgroundColor: AppColors.greyWhite,
                                  radius: 5.w,
                                  child: const Icon(Icons.more_horiz),
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: Container(
                                    height: 2.w,
                                    width: 2.w,
                                    decoration: BoxDecoration(
                                        color: AppColors.lightRed,
                                        border: Border.all(
                                            color: AppColors.white,
                                            width: 2.sp,
                                            strokeAlign:
                                                BorderSide.strokeAlignOutside),
                                        borderRadius:
                                            BorderRadius.circular(10.sp)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    } else ...{
                      SizedBox(
                        width: double.maxFinite,
                        height: 10.h,
                        child: Shimmer.fromColors(
                          baseColor: AppColors.greyWhite,
                          highlightColor: AppColors.lightGrey,
                          child: Container(
                            width: double.maxFinite,
                            height: 10.h,
                            color: AppColors.greyWhite,
                          ),
                        ),
                      ),
                    },
                    SizedBox(height: 2.h),
                    StreamBuilder(
                      stream: _requireStreamController.stream,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Column(children: [
                            // if (snapshot.data['checklist'] == 0)
                            DetailContainer(
                              title: AppText.preStartCheckReq,
                              subtitle: AppText.preStartSubtext,
                              isSelected: true,
                              onPressed: () {
                                Get.toNamed(AppRoutes.preStartChecklist);
                              },
                              isLoading: false,
                            ),
                            // if (snapshot.data['outbound'] == 0)
                            DetailContainer(
                              title: AppText.outboundPalletsReq,
                              subtitle: AppText.outboundPalletSubtext,
                              isSelected: false,
                              onPressed: () {
                                Get.toNamed(AppRoutes.outboundPallet);
                              },
                              isLoading: false,
                            ),
                            // if (snapshot.data['inbound'] == 0)
                            DetailContainer(
                              title: AppText.inboundPalletsReq,
                              subtitle: AppText.inboundPalletSubtext,
                              isSelected: false,
                              onPressed: () {
                                Get.toNamed(AppRoutes.inboundPallet);
                              },
                              isLoading: false,
                            ),
                          ]);
                        } else {
                          return Column(children: [
                            DetailContainer(
                              title: AppText.preStartCheckReq,
                              subtitle: AppText.preStartSubtext,
                              isSelected: true,
                              onPressed: () {},
                              isLoading: true,
                            ),
                            DetailContainer(
                              title: AppText.outboundPalletsReq,
                              subtitle: AppText.outboundPalletSubtext,
                              isSelected: false,
                              onPressed: () {},
                              isLoading: true,
                            ),
                            DetailContainer(
                              title: AppText.inboundPalletsReq,
                              subtitle: AppText.inboundPalletSubtext,
                              isSelected: false,
                              onPressed: () {},
                              isLoading: true,
                            ),
                          ]);
                        }
                      },
                    ),
                    SizedBox(height: 2.h),
                    StreamBuilder(
                      stream: _consignmentStreamController.stream,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Expanded(
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      AppText.todayConsignments.toUpperCase(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall,
                                    ),
                                    SizedBox(width: 2.w),
                                    // if (snapshot.hasData)
                                    //   CircleAvatar(
                                    //     radius: 12,
                                    //     backgroundColor: AppColors.blue,
                                    //     child: Text(
                                    //       (snapshot.data['data']?[DateFormat(
                                    //                           'yyyy-MM-dd')
                                    //                       .format(DateTime
                                    //                           .now())] ==
                                    //                   null
                                    //               ? []
                                    //               : snapshot.data[
                                    //                       'data'][DateFormat(
                                    //                           'yyyy-MM-dd')
                                    //                       .format(DateTime.now())]
                                    //                   ['consignments'])
                                    //           .length
                                    //           .toString(),
                                    //       style: Theme.of(context)
                                    //           .textTheme
                                    //           .bodySmall
                                    //           ?.copyWith(
                                    //               color: AppColors.white),
                                    //     ),
                                    //   ),
                                    const Spacer(),
                                    Text(
                                      AppText.seeAll,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: AppColors.midBlue,
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      snapshot.data['data'].containsKey(
                                                  DateFormat('yyyy-MM-dd')
                                                      .format(
                                                          DateTime.now())) ==
                                              false
                                          ? '0'
                                          : snapshot
                                              .data['data'][
                                                  DateFormat('yyyy-MM-dd')
                                                      .format(DateTime.now())]
                                                  ['consignments']
                                              .length
                                              .toString(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                    Text(
                                      AppText.consignmentRemaining,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                    ),
                                    SizedBox(
                                      width: 2.w,
                                    ),
                                    CircleAvatar(
                                      backgroundColor: AppColors.black,
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
                                          .bodyMedium,
                                    ),
                                  ],
                                ),
                                SizedBox(height: 2.h),
                                Expanded(
                                  child: SingleChildScrollView(
                                    controller: _scrollController,
                                    child: Column(
                                      children: [
                                        for (var consignment in snapshot
                                                    .data['data'][DateFormat(
                                                        'yyyy-MM-dd')
                                                    .format(DateTime.now())] ==
                                                null
                                            ? []
                                            : snapshot.data['data'][
                                                    DateFormat('yyyy-MM-dd')
                                                        .format(DateTime.now())]
                                                ['consignments']) ...{
                                          ConsignmentContainer(
                                            consignment: consignment,
                                          ),
                                        },
                                        snapshot.data['data'].containsKey(
                                                    DateFormat('yyyy-MM-dd')
                                                        .format(
                                                            DateTime.now())) ==
                                                false
                                            ? Padding(
                                                padding: EdgeInsets.symmetric(
                                                  vertical: 4.h,
                                                ),
                                                child: SizedBox(
                                                  width: 60.w,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      const Image(
                                                        image: AssetImage(
                                                          AppImages.cardboard,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 3.h,
                                                      ),
                                                      Text(
                                                        'Consignment Completed!',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .headlineSmall
                                                            ?.copyWith(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700),
                                                      ),
                                                      Text(
                                                        'Get back safe, and remember to return your pallets.',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodyMedium
                                                            ?.copyWith(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              )
                                            : GestureDetector(
                                                onTap: () {
                                                  _scrollController.animateTo(
                                                    0.0,
                                                    duration: const Duration(
                                                        milliseconds: 500),
                                                    curve: Curves.easeInOut,
                                                  );
                                                },
                                                child: Text(
                                                  AppText.returnToTop,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.copyWith(
                                                        color:
                                                            AppColors.midBlue,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                ),
                                              ),
                                        SizedBox(
                                          height: 6.h,
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          );
                        }
                        if (snapshot.hasError) {
                          return Expanded(
                            child: SizedBox(
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        AppText.todayConsignments.toUpperCase(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineSmall,
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
                            ),
                          );
                        } else {
                          return Expanded(
                            child: SizedBox(
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          AppText.todayConsignments
                                              .toUpperCase(),
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineSmall,
                                        ),
                                        const Spacer(),
                                        Text(
                                          AppText.seeAll,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                  color: AppColors.midBlue),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 2.h),
                                    for (int i = 0; i < 4; i++) ...{
                                      const ConsignmentContainer(
                                        isLoading: true,
                                      ),
                                    }
                                  ],
                                ),
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          }),
          endDrawer: snapshot.hasData
              ? CustomDrawer(
                  name: snapshot.data['data']['name'],
                )
              : const SizedBox(),
        );
      },
    );
  }
}

class DetailContainer extends StatelessWidget {
  const DetailContainer({
    super.key,
    required this.title,
    required this.subtitle,
    this.isSelected = false,
    required this.onPressed,
    required this.isLoading,
  });
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        height: 16.h,
        width: double.maxFinite,
        decoration: BoxDecoration(
          gradient: isSelected
              ? AppColors.preStartGradient
              : AppColors.outInBoundGradient,
          borderRadius: BorderRadius.circular(10.sp),
        ),
        padding: isLoading
            ? const EdgeInsets.all(0)
            : EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        margin: EdgeInsets.only(bottom: 1.h),
        child: isLoading
            ? Shimmer.fromColors(
                baseColor: AppColors.greyWhite,
                highlightColor: AppColors.lightGrey,
                child: Container(
                  width: double.maxFinite,
                  height: 10.h,
                  color: AppColors.greyWhite,
                ),
              )
            : Column(
                children: [
                  Row(
                    children: [
                      Container(
                          height: 5.h,
                          width: 5.h,
                          padding: EdgeInsets.all(2.5.w),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.lightBlue
                                : AppColors.grey,
                            borderRadius: BorderRadius.circular(10.sp),
                          ),
                          child: isSelected
                              ? SvgPicture.asset(
                                  AppSvgs.checkList,
                                )
                              : SvgPicture.asset(
                                  AppSvgs.pallet,
                                )),
                      SizedBox(width: 3.w),
                      Text(
                        title,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(color: AppColors.white),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.h),
                  Row(
                    children: [
                      SizedBox(
                        width: 14.w,
                      ),
                      Expanded(
                        child: Text(
                          subtitle,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                  color: AppColors.white, fontSize: 10.sp),
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: AppColors.white,
                        size: 15.sp,
                      ),
                    ],
                  )
                ],
              ),
      ),
    );
  }
}

class ConsignmentContainer extends StatelessWidget {
  final bool isLoading;
  final Map? consignment;
  const ConsignmentContainer(
      {super.key, this.isLoading = false, this.consignment});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.lightGrey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: isLoading
          ? const EdgeInsets.all(0)
          : EdgeInsets.symmetric(horizontal: 2.w, vertical: 2.h),
      margin: EdgeInsets.only(bottom: 1.h),
      child: isLoading
          ? Shimmer.fromColors(
              baseColor: AppColors.greyWhite,
              highlightColor: AppColors.lightGrey,
              child: Container(
                width: double.maxFinite,
                height: 10.h,
                color: AppColors.greyWhite,
              ),
            )
          : Stack(
              children: [
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    height: 3.5.h,
                    width: 18.w,
                    decoration: BoxDecoration(
                      color: consignment!['product_types']['id'] == 1
                          ? AppColors.skyBlue
                          : AppColors.darkBlue,
                      borderRadius: BorderRadius.circular(15.sp),
                    ),
                    child: Center(
                      child: Text(
                        (consignment!['product_types']['name'])
                            .toString()
                            .toUpperCase(),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: consignment!['product_types']['id'] == 1
                                ? AppColors.black
                                : AppColors.white,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.darkGrey.withOpacity(0.16),
                      radius: 7.5.w,
                      child: SizedBox(
                        height: 15.h,
                        width: 15.w,
                        child: Image(
                          image: consignment!['product_types']['id'] == 1
                              ? const AssetImage(AppImages.chilled)
                              : const AssetImage(AppImages.frozen),
                        ),
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (consignment!['consignment_type'] == 'delivery'
                                  ? consignment!['delivery_addresses']
                                      ['customer_name']
                                  : consignment!['pickup_addresses']
                                      ['customer_name']) ??
                              'Not Provided',
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'ID: ${consignment!['id']}'.toUpperCase(),
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.black.withOpacity(0.5),
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                        SizedBox(
                          width: 45.w,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${AppText.drop}: ${consignment!['sort'] ?? 0}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              Text(
                                '${AppText.ctn}: ${consignment!['cartons'] ?? 0}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              Text(
                                '${AppText.plt}: ${consignment!['pallets'] ?? 0}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}
