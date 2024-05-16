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
  final StreamController<dynamic> _staffStreamController =
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
    staffData();
    checkRequires();
    fetchConsignment();
    _timer = Timer.periodic(
      const Duration(seconds: 30),
      (timer) {
        staffData();
        checkRequires();
        fetchConsignment();
      },
    );
  }

  @override
  void dispose() {
    _staffStreamController.close();
    _requireStreamController.close();
    _consignmentStreamController.close();
    _timer.cancel();
    super.dispose();
  }

  Future<void> staffData() async {
    AuthenticationState state =
        BlocProvider.of<AuthenticationCubit>(context).state;
    if (state is Authenticated) {
      List<Map<String, dynamic>> data =
          await UserDatabase(context.read<DatabaseProvider>().database)
              .read(state.token);
      _staffStreamController.add(data.first);
    }
  }

  Future<void> checkRequires() async {
    AuthenticationState state =
        BlocProvider.of<AuthenticationCubit>(context).state;
    if (state is Authenticated) {
      List<Map<String, dynamic>> data =
          await PreCheckDatabase(context.read<DatabaseProvider>().database)
              .read(state.token);
      _requireStreamController.add(data);
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
      stream: _staffStreamController.stream,
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
                                  '${AppText.goodMorning} ${snapshot.data['name']}!',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(color: AppColors.darkGrey),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                snapshot.data.containsKey(
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
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const SizedBox();
                        } else {
                          return Column(
                            children: [
                              if (snapshot.data[0]['checklist'] == 0)
                                SubmissionCheckContainer(
                                  leadingSVG: AppSvgs.checkList,
                                  title: AppText.preStartCheckReq,
                                  subtitle: AppText.preStartSubtext,
                                  onPressed: () {
                                    Get.toNamed(AppRoutes.preStartChecklist);
                                  },
                                  backgroundColor: AppColors.twoBlueGradient,
                                  isLoading: !snapshot.hasData,
                                ),
                              if (snapshot.data[0]['outbound'] == 0)
                                SubmissionCheckContainer(
                                  leadingSVG: AppSvgs.boundpallets,
                                  title: AppText.outboundPalletsReq,
                                  subtitle: AppText.outboundPalletSubtext,
                                  onPressed: () {
                                    Get.toNamed(AppRoutes.outboundPallet);
                                  },
                                  backgroundColor: AppColors.twoBlackGradient,
                                  isLoading: !snapshot.hasData,
                                ),
                              if (snapshot.data[0]['inbound'] == 0)
                                SubmissionCheckContainer(
                                  leadingSVG: AppSvgs.boundpallets,
                                  title: AppText.inboundPalletsReq,
                                  subtitle: AppText.inboundPalletSubtext,
                                  onPressed: () {
                                    Get.toNamed(AppRoutes.inboundPallet);
                                  },
                                  backgroundColor: AppColors.twoBlackGradient,
                                  isLoading: !snapshot.hasData,
                                )
                            ],
                          );
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
                                        for (var consignment
                                            in snapshot.data['data']
                                                        ['2024-04-04'] ==
                                                    null
                                                ? []
                                                : snapshot.data['data']
                                                        ['2024-04-04']
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
                          debugPrint('Error Print: ${snapshot.error}');
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
                  name: snapshot.data['name'],
                )
              : const SizedBox(),
        );
      },
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
