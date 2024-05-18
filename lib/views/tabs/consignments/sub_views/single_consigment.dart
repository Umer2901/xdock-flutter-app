// ignore_for_file: deprecated_member_use
import 'dart:async';
import 'dart:convert';
import 'package:coldxpress/export.dart';
import 'package:coldxpress/views/tabs/consignments/sub_views/proof_of_delivery.dart';
import 'package:http/http.dart' as http;

class SingleConsigmentView extends StatefulWidget {
  const SingleConsigmentView({super.key});

  @override
  State<SingleConsigmentView> createState() => _SingleConsigmentViewState();
}

class _SingleConsigmentViewState extends State<SingleConsigmentView> {
  final StreamController<dynamic> _consignmentStreamController =
      StreamController<dynamic>();

  late Timer _timer;

  @override
  void initState() {
    super.initState();
    fetchData();
    _timer = Timer.periodic(
      const Duration(seconds: 30),
      (timer) {
        fetchData();
      },
    );
  }

  @override
  void dispose() {
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
          Uri.parse('${AppHost.consignmentDetail}${Get.arguments}'),
          headers: <String, String>{
            'Authorization': 'Bearer ${state.token}',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          final dynamic data = json.decode(response.body);
          _consignmentStreamController.add(data);
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
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
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
          AppText.delivery,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: SingleChildScrollView(
            child: Center(
              child: StreamBuilder(
                  stream: _consignmentStreamController.stream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppBar(
                            backgroundColor: Colors.transparent,
                            surfaceTintColor: Colors.transparent,
                            centerTitle: true,
                            leading: const SizedBox.shrink(),
                            title: IntrinsicHeight(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'ID: ${snapshot.data['data']['id']}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall,
                                  ),
                                  VerticalDivider(
                                    color: AppColors.black.withOpacity(0.5),
                                    thickness: 2,
                                  ),
                                  Text(
                                    'REF: ${snapshot.data['data']['customer_reference']}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall,
                                  ),
                                ],
                              ),
                            ),
                            actions: [
                              InkWell(
                                onTap: () {},
                                child: Container(
                                  width: 13.5.w,
                                  height: 6.h,
                                  decoration: BoxDecoration(
                                      color: AppColors.white,
                                      borderRadius:
                                          BorderRadius.circular(50.sp),
                                      border: Border.all()),
                                  child: SvgPicture.asset(
                                    AppSvgs.mapMarker,
                                    color: AppColors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 2.h,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                height: 8.h,
                                width: 18.w,
                                decoration: BoxDecoration(
                                  color: AppColors.darkGrey,
                                  borderRadius: BorderRadius.circular(8.sp),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 2.w,
                                    vertical: 1.h,
                                  ),
                                  child: SizedBox(
                                    width: 16.w,
                                    height: 7.h,
                                    child: Image.asset(AppImages.cardboard),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 54.w,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      (snapshot.data['data']
                                                      ['consignment_type'] ==
                                                  'delivery'
                                              ? snapshot.data['data']
                                                      ['delivery_addresses']
                                                  ['company_name']
                                              : snapshot.data['data']
                                                      ['pickup_addresses']
                                                  ['company_name']) ??
                                          'Not Provided',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineMedium,
                                    ),
                                    Text(
                                      'Recipient: ${(snapshot.data['data']['consignment_type'] == 'delivery' ? snapshot.data['data']['delivery_addresses']['customer_name'] : snapshot.data['data']['pickup_addresses']['customer_name']) ?? 'Not Provided'}',
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      snapshot.data['data']
                                                  ['consignment_type'] ==
                                              'delivery'
                                          ? '${snapshot.data['data']['delivery_addresses']['street_address']}, ${snapshot.data['data']['delivery_addresses']['suburb']}'
                                          : '${snapshot.data['data']['pickup_addresses']['street_address']}, ${snapshot.data['data']['pickup_addresses']['suburb']}',
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    )
                                  ],
                                ),
                              ),
                              InkWell(
                                onTap: () {},
                                child: Container(
                                  width: 13.5.w,
                                  height: 6.h,
                                  decoration: BoxDecoration(
                                    color: AppColors.black.withOpacity(0.8),
                                    borderRadius: BorderRadius.circular(50.sp),
                                  ),
                                  child: Icon(
                                    Icons.call,
                                    color: AppColors.white,
                                    size: 4.h,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 2.h,
                          ),
                          GestureDetector(
                            onTap: () {
                              Get.toNamed(AppRoutes.Stopwatch);
                            },
                            child: CustomProductTypeAndTime(
                              type: (snapshot.data['data']['product_types']
                                          ['id']) ==
                                      1
                                  ? '1'
                                  : '2',
                              time: snapshot.data['data']['consignment_type'] ==
                                      'delivery'
                                  ? '${snapshot.data['data']['delivery_addresses']['service_time_start'].toString().split(' ').last.split(':')[0]}.${snapshot.data['data']['delivery_addresses']['service_time_start'].toString().split(' ').last.split(':')[1]} - ${snapshot.data['data']['delivery_addresses']['service_time_end'].toString().split(' ').last.split(':')[0]}.${snapshot.data['data']['delivery_addresses']['service_time_end'].toString().split(' ').last.split(':')[1]}'
                                  : '${snapshot.data['data']['pickup_addresses']['service_time_start'].toString().split(' ').last.split(':')[0]}.${snapshot.data['data']['pickup_addresses']['service_time_start'].toString().split(' ').last.split(':')[1]} - ${snapshot.data['data']['pickup_addresses']['service_time_end'].toString().split(' ').last.split(':')[0]}.${snapshot.data['data']['pickup_addresses']['service_time_end'].toString().split(' ').last.split(':')[1]}',
                              svgImage: SvgPicture.asset(AppSvgs.frozen),
                            ),
                          ),
                          SizedBox(
                            height: 2.h,
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 6.w, vertical: 2.h),
                            // height: 3.5.h,
                            width: double.maxFinite,
                            decoration: BoxDecoration(
                              color: AppColors.greyWhite,
                              borderRadius: BorderRadius.circular(8.sp),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 3.5.h,
                                  width: 19.w,
                                  decoration: BoxDecoration(
                                    color: AppColors.darkGrey,
                                    borderRadius: BorderRadius.circular(20.sp),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'En Route',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: AppColors.white,
                                            fontSize: 10.sp,
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 2.h,
                                ),
                                const CustomOrderTracking(
                                    title: "Supplier",
                                    subText: 'Acme Corporation',
                                    isLastStep: false,
                                    currentStep: 3,
                                    stepIndex: 1),
                                const CustomOrderTracking(
                                  title: "Pickup",
                                  isLastStep: false,
                                  currentStep: 3,
                                  stepIndex: 2,
                                  subText:
                                      'ColdXpress Transport 2071 portarlinton road, Drysdale',
                                ),
                                const CustomOrderTracking(
                                  title: "Out for Delivery",
                                  isLastStep: false,
                                  currentStep: 3,
                                  stepIndex: 3,
                                  subText: 'Driver: Abram Vetrovs',
                                ),
                                const CustomOrderTracking(
                                  title: "Drop off",
                                  isLastStep: true,
                                  currentStep: 3,
                                  stepIndex: 4,
                                  subText:
                                      'Pronto Fine Food 830 wellington road, Rowville',
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 3.h,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  CustomDeliveryDetailsContainer(
                                    type: AppText.cartons,
                                    counts:
                                        '${snapshot.data['data']['carton']}',
                                    svgIcon: SvgPicture.asset(AppSvgs.carton),
                                  ),
                                  CustomDeliveryDetailsContainer(
                                    type: AppText.pallets,
                                    counts:
                                        '${snapshot.data['data']['pallet']}',
                                    svgIcon:
                                        SvgPicture.asset(AppSvgs.palletBlue),
                                  )
                                ],
                              ),
                              SizedBox(
                                height: 2.h,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  CustomDeliveryDetailsContainer(
                                    type: AppText.space,
                                    counts: '${snapshot.data['data']['space']}',
                                    countType: 'sqft',
                                    svgIcon: SvgPicture.asset(AppSvgs.space),
                                  ),
                                  CustomDeliveryDetailsContainer(
                                    type: AppText.weight,
                                    counts:
                                        '${snapshot.data['data']['weight']}',
                                    countType: 'KG',
                                    svgIcon: SvgPicture.asset(AppSvgs.weight),
                                  )
                                ],
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 4.h,
                          ),
                          Text(
                            AppText.specialInstructions,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.black.withOpacity(0.5),
                                    ),
                          ),
                          Text(
                            snapshot.data['data']['special_instruction'] == ''
                                ? 'Not Provided'
                                : snapshot.data['data']['special_instruction'],
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: AppColors.black,
                                ),
                          ),
                          SizedBox(
                            height: 4.h,
                          ),
                          CustomElevatedButton(
                              label: AppText.podCapture,
                              onPressed: () {
                              Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ProofOfDeliveryView(data: snapshot.data),
    ),);
                              }),
                          SizedBox(
                            height: 8.h,
                          ),
                        ],
                      );
                    } else {
                      return const CircularProgressIndicator();
                    }
                  }),
            ),
          ),
        ),
      ),
    );
  }
}
