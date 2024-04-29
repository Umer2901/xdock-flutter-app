import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:coldxpress/export.dart';

class ConsignmentMapTab extends StatefulWidget {
  const ConsignmentMapTab({super.key});

  @override
  State<ConsignmentMapTab> createState() => _ConsignmentMapTabState();
}

class _ConsignmentMapTabState extends State<ConsignmentMapTab> {
  late GoogleMapController mapController;
  Set<Marker> markers = {};
  bool isBottomSheetVisible = false;
  final StreamController<dynamic> _consignmentStreamController =
      StreamController<dynamic>();

  Map? consignmentDetails;

  Future<void> fetchConsignment() async {
    AuthenticationState state =
        BlocProvider.of<AuthenticationCubit>(context).state;
    if (state is Authenticated) {
      try {
        const String apiUrl =
            'https://staging.xdock.com.au/api/driver/runSheet/v6/consignments';
        final String accessToken = state.token;

        final response = await http.get(
          Uri.parse(apiUrl),
          headers: <String, String>{
            'Authorization': 'Bearer $accessToken',
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

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  void initState() {
    super.initState();
    fetchConsignment();
  }

  void addMarkerOnMap(List consignments) {
    BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(
        size: Size(24, 0.5),
      ),
      AppImages.customMarker,
    ).then(
      (customIcon) {
        for (var consignment in consignments) {
          markers.add(
            Marker(
              markerId: MarkerId('${consignment["id"]}'),
              position: consignment['consignment_type'] == 'delivery'
                  ? LatLng(consignment['delivery_addresses']['latitude'],
                      consignment['delivery_addresses']['longitude'])
                  : LatLng(consignment['pickup_addresses']['latitude'],
                      consignment['pickup_addresses']['longitude']),
              icon: customIcon,
              onTap: () {
                setState(() {
                  consignmentDetails = consignment;
                  isBottomSheetVisible = true;
                });
              },
            ),
          );
        }
        setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: _consignmentStreamController.stream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data['data'].containsKey(
                    DateFormat('yyyy-MM-dd').format(DateTime.now()))
                ? snapshot.data['data']
                        [DateFormat('yyyy-MM-dd').format(DateTime.now())] !=
                    null
                : false) {
              addMarkerOnMap(snapshot.data['data']
                      [DateFormat('yyyy-MM-dd').format(DateTime.now())]
                  ['consignments']);
            }
          }
          return Scaffold(
            body: Stack(
              children: [
                Consumer<LocationProvider>(builder: (context, location, child) {
                  return GoogleMap(
                    onMapCreated: onMapCreated,
                    initialCameraPosition: CameraPosition(
                      target: LatLng(
                        location.current!.latitude,
                        location.current!.longitude,
                      ),
                      zoom: 15.0,
                    ),
                    markers: markers,
                  );
                }),
                if (isBottomSheetVisible)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isBottomSheetVisible = false;
                      });
                    },
                    child: Container(
                      height: double.maxFinite,
                      width: double.maxFinite,
                      color: Colors.transparent,
                    ),
                  ),
                if (isBottomSheetVisible)
                  Positioned(
                    bottom: 0,
                    left: 0.h,
                    right: 0.h,
                    child: Container(
                      height: 67.5.h,
                      width: double.maxFinite,
                      color: AppColors.white,
                      padding: EdgeInsets.symmetric(
                        vertical: 2.h,
                        horizontal: 2.w,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Container(
                              height: 0.5.h,
                              width: 40.w,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.sp),
                                color: AppColors.grey,
                              ),
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            AppText.locationInfo,
                            style: Theme.of(context).textTheme.headlineLarge,
                          ),
                          SizedBox(height: 1.h),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.greyWhite,
                                borderRadius: BorderRadius.circular(5.sp),
                              ),
                              child: Column(
                                children: [
                                  ListTile(
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 2.h,
                                      horizontal: 16.0,
                                    ),
                                    leading: Container(
                                      height: 15.w,
                                      width: 15.w,
                                      decoration: BoxDecoration(
                                        color: AppColors.navyBlue,
                                        borderRadius:
                                            BorderRadius.circular(5.sp),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        (consignmentDetails!['sort'] ?? 0)
                                            .toString(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineLarge
                                            ?.copyWith(color: AppColors.white),
                                      ),
                                    ),
                                    title: Text(
                                      (consignmentDetails![
                                                      'consignment_type'] ==
                                                  'delivery'
                                              ? consignmentDetails![
                                                      'delivery_addresses']
                                                  ['company_name']
                                              : consignmentDetails![
                                                      'pickup_addresses']
                                                  ['company_name']) ??
                                          'Not Provided',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineMedium,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Recipient: ${(consignmentDetails!['consignment_type'] == 'delivery' ? consignmentDetails!['delivery_addresses']['customer_name'] : consignmentDetails!['pickup_addresses']['customer_name']) ?? 'Not Provided'}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          consignmentDetails![
                                                      'consignment_type'] ==
                                                  'delivery'
                                              ? '${consignmentDetails!['delivery_addresses']['street_address']}, ${consignmentDetails!['delivery_addresses']['suburb']}'
                                              : '${consignmentDetails!['pickup_addresses']['street_address']}, ${consignmentDetails!['pickup_addresses']['suburb']}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        )
                                      ],
                                    ),
                                    trailing: Container(
                                      height: 12.w,
                                      width: 12.w,
                                      decoration: BoxDecoration(
                                        border:
                                            Border.all(color: AppColors.black),
                                        borderRadius:
                                            BorderRadius.circular(20.sp),
                                      ),
                                      alignment: Alignment.center,
                                      child: IconButton(
                                        icon: const Icon(Icons.phone),
                                        onPressed: () {},
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 2.h,
                                      horizontal: 4.w,
                                    ),
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 4.w),
                                    decoration: BoxDecoration(
                                      color: AppColors.lightBlue,
                                      borderRadius:
                                          BorderRadius.circular(10.sp),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Image(
                                                image: AssetImage(
                                                    AppImages.cartons),
                                              ),
                                              SizedBox(width: 2.w),
                                              Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.sp),
                                                  color: AppColors.white,
                                                ),
                                                padding: EdgeInsets.symmetric(
                                                  vertical: 0.5.h,
                                                  horizontal: 2.w,
                                                ),
                                                child: Text(
                                                  (consignmentDetails![
                                                              'product_types']
                                                          ['name'])
                                                      .toString()
                                                      .toUpperCase(),
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color:
                                                            AppColors.navyBlue,
                                                      ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          height: 8.h,
                                          child: const VerticalDivider(
                                            color: AppColors.darkGrey,
                                          ),
                                        ),
                                        Expanded(
                                          child: ListTile(
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                              horizontal: 10.0,
                                            ),
                                            title: Text(
                                              AppText.time,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                      color: AppColors.white),
                                            ),
                                            subtitle: Text(
                                              consignmentDetails![
                                                          'consignment_type'] ==
                                                      'delivery'
                                                  ? '${consignmentDetails!['delivery_addresses']['service_time_start'].toString().split(' ').last.split(':')[0]}.${consignmentDetails!['delivery_addresses']['service_time_start'].toString().split(' ').last.split(':')[1]} - ${consignmentDetails!['delivery_addresses']['service_time_end'].toString().split(' ').last.split(':')[0]}.${consignmentDetails!['delivery_addresses']['service_time_end'].toString().split(' ').last.split(':')[1]}'
                                                  : '${consignmentDetails!['pickup_addresses']['service_time_start'].toString().split(' ').last.split(':')[0]}.${consignmentDetails!['pickup_addresses']['service_time_start'].toString().split(' ').last.split(':')[1]} - ${consignmentDetails!['pickup_addresses']['service_time_end'].toString().split(' ').last.split(':')[0]}.${consignmentDetails!['pickup_addresses']['service_time_end'].toString().split(' ').last.split(':')[1]}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                    fontSize: 10.sp,
                                                    color: AppColors.white,
                                                  ),
                                            ),
                                            trailing: Icon(
                                              Icons.arrow_forward_ios,
                                              size: 10.sp,
                                              color: AppColors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 2.h),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      CustomValueField(
                                        title: AppText.id.toUpperCase(),
                                        value: consignmentDetails!['id']
                                            .toString(),
                                      ),
                                      CustomValueField(
                                        title: AppText.ref.toUpperCase(),
                                        value: consignmentDetails![
                                                'customer_reference']
                                            .toString(),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 1.h),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      CustomValueField(
                                        title: AppText.supplier,
                                        value: consignmentDetails![
                                                    'pickup_addresses']
                                                ['customer_name'] ??
                                            'Not Provided',
                                      ),
                                      CustomValueField(
                                        title: AppText.cartons,
                                        value:
                                            (consignmentDetails!['cartons'] ??
                                                    0)
                                                .toString(),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 1.h),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      CustomValueField(
                                        title: AppText.receiver,
                                        value: consignmentDetails![
                                                    'delivery_addresses']
                                                ['customer_name'] ??
                                            'Not Provided',
                                      ),
                                      CustomValueField(
                                        title: AppText.pallets,
                                        value:
                                            (consignmentDetails!['pallets'] ??
                                                    0)
                                                .toString(),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                Positioned(
                  top: 1.h,
                  left: 4.w,
                  child: SafeArea(
                    child: GestureDetector(
                      onTap: () {
                        Get.back();
                      },
                      child: CircleAvatar(
                        radius: 5.5.w,
                        backgroundColor: AppColors.white,
                        child: const Icon(Icons.arrow_back),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }
}
