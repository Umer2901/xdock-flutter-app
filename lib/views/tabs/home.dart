import 'dart:convert';
import 'package:coldxpress/export.dart';


class HomeTab extends StatefulWidget {
  const HomeTab({Key? key}) : super(key: key);

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  late UserDatabase staff;
  late PreCheckDatabase precheck;
  late ConsignmentDatabase consignment;

  int consignmentCount = 0;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    AuthenticationState state =
        BlocProvider.of<AuthenticationCubit>(context).state;
    if (state is Authenticated) {
      staff = UserDatabase(
        context.read<DatabaseProvider>().database,
        accessToken: state.token,
      );
      precheck = PreCheckDatabase(
        context.read<DatabaseProvider>().database,
        accessToken: state.token,
      );
      consignment = ConsignmentDatabase(
        context.read<DatabaseProvider>().database,
        accessToken: state.token,
      );
      config(state.token,);
  
    }
  }

 

  config(token) async {
    await PreCheckDatabase(context.read<DatabaseProvider>().database,
            accessToken: token)
        .read();
  }

  @override
  void dispose() {
    staff.dispose();
    precheck.dispose();
    consignment.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
      

    return StreamBuilder<dynamic>(
        stream: staff.controller.stream,
        builder: (context, staffSnapshot) {
          return Scaffold(
            key: _scaffoldKey,
            body: SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  4.w,
                  2.h,
                  4.w,
                  0,
                ),
                child: Column(
                  children: [
                    if (staffSnapshot.hasData) ...{
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 80.w,
                                child: Text(
                                  '${AppText.goodMorning} ${staffSnapshot.data[0]['name']}!',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(color: AppColors.darkGrey),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                AppText.letStartYourday,
                                style:
                                    Theme.of(context).textTheme.headlineMedium,
                              )
                            ],
                          ),
                          InkWell(
                            onTap: () {
                              _scaffoldKey.currentState?.openEndDrawer();
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
                      stream: precheck.stream,
                      builder: (context, precheckSnapshot) {
                        if (precheckSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const SizedBox();
                        } else if (!precheckSnapshot.hasData ||
                            precheckSnapshot.data!.isEmpty) {
                          return const Text('No data available');
                        } else {
                          final data = precheckSnapshot.data!;
                          return Column(
                            children: [
                              if (data[0]['checklist'] == 0)
                                SubmissionCheckContainer(
                                  leadingSVG: AppSvgs.checkList,
                                  title: AppText.preStartCheckReq,
                                  subtitle: AppText.preStartSubtext,
                                  onPressed: () {
                                    Get.toNamed(AppRoutes.preStartChecklist);
                                  },
                                  backgroundColor: AppColors.twoBlueGradient,
                                  isLoading: false,
                                ),
                              if (data[0]['outbound'] == 0)
                                SubmissionCheckContainer(
                                  leadingSVG: AppSvgs.boundpallets,
                                  title: AppText.outboundPalletsReq,
                                  subtitle: AppText.outboundPalletSubtext,
                                  onPressed: () {
                                    Get.toNamed(AppRoutes.outboundPallet);
                                  },
                                  backgroundColor: AppColors.twoBlackGradient,
                                  isLoading: false,
                                ),
                              if (data[0]['inbound'] == 0)
                                SubmissionCheckContainer(
                                  leadingSVG: AppSvgs.boundpallets,
                                  title: AppText.inboundPalletsReq,
                                  subtitle: AppText.inboundPalletSubtext,
                                  onPressed: () {
                                    Get.toNamed(AppRoutes.inboundPallet);
                                  },
                                  backgroundColor: AppColors.twoBlackGradient,
                                  isLoading: false,
                                ),
                            ],
                          );
                        }
                      },
                    ),
                    SizedBox(height: 2.h),
                    StreamBuilder(
                      stream: consignment.stream,
                      builder: (context, consignmentSnapshot) {
                        if (consignmentSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const SizedBox();
                        } else if (consignmentSnapshot.hasData) {
                          consignmentCount =
                              consignmentSnapshot.data?.length ?? 0;
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
                                    GestureDetector(
                                      onTap: () {
                                        context
                                            .read<BottomNavProvider>()
                                            .changeTabView(0);
                                      },
                                      child: Text(
                                        AppText.seeAll,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color: AppColors.midBlue,
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      consignmentSnapshot.data!.length
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
                                    child: consignmentSnapshot.data!.isEmpty
                                        ? Padding(
                                            padding: EdgeInsets.symmetric(
                                              vertical: 4.h,
                                            ),
                                            child: SizedBox(
                                              width: 60.w,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
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
                                                    textAlign: TextAlign.center,
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
                                                    textAlign: TextAlign.center,
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
                                        : Column(
                                            children: [
                                              for (var consignment
                                                  in consignmentSnapshot
                                                      .data!) ...{
                                                ConsignmentContainer(
                                                  consignment: consignment,
                                                ),
                                              },
                                              SizedBox(
                                                height: 2.h,
                                              ),
                                              GestureDetector(
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
                                                height: 4.h,
                                              ),
                                            ],
                                          ),
                                  ),
                                )
                              ],
                            ),
                          );
                        } else if (consignmentSnapshot.hasError) {
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
                                      consignmentSnapshot.error.toString(),
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
                          return Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 4.h,
                            ),
                            child: SizedBox(
                              width: 60.w,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
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
                                    'No Consignment!',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                  Text(
                                    'Get back safe, and remember to return your pallets.',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            endDrawer: staffSnapshot.hasData
                ? CustomDrawer(
                    name: staffSnapshot.data[0]['name'],
                    consignmentCount: consignmentCount,
                  )
                : const SizedBox(),
          );
        });
  }
}

class ConsignmentContainer extends StatelessWidget {
  final bool isLoading;
  final Map? consignment;
  const ConsignmentContainer(
      {super.key, this.isLoading = false, this.consignment});

  @override
  Widget build(BuildContext context) {
    Map productTypes = json.decode(consignment?['product_types']);
    Map deliveryAddresses = json.decode(consignment?['delivery_addresses']);
    Map pickupAddresses = json.decode(consignment?['pickup_addresses']);
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
                      color: productTypes['id'] == 1
                          ? AppColors.skyBlue
                          : AppColors.darkBlue,
                      borderRadius: BorderRadius.circular(15.sp),
                    ),
                    child: Center(
                      child: Text(
                        (productTypes['name']).toString().toUpperCase(),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: productTypes['id'] == 1
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
                          image: productTypes['id'] == 1
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
                          (consignment?['consignment_type'] == 'delivery'
                                  ? deliveryAddresses['customer_name']
                                  : pickupAddresses['customer_name']) ??
                              'Not Provided',
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'ID: ${consignment?['id']}'.toUpperCase(),
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
                                '${AppText.drop}: ${consignment?['sort'] ?? 0}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              Text(
                                '${AppText.ctn}: ${consignment?['cartons'] ?? 0}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              Text(
                                '${AppText.plt}: ${consignment?['pallets'] ?? 0}',
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
