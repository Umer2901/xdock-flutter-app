import 'dart:convert';
import 'package:coldxpress/export.dart';
import 'package:url_launcher/url_launcher.dart';

class ConsignmentMapTab extends StatefulWidget {
  const ConsignmentMapTab({super.key});

  @override
  State<ConsignmentMapTab> createState() => _ConsignmentMapTabState();
}

class _ConsignmentMapTabState extends State<ConsignmentMapTab> {
  late GoogleMapController mapController;
  late ConsignmentDatabase consignment;
  Set<Marker> markers = {};
  bool isBottomSheetVisible = false;

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Map? selectedConsignment;

  @override
  void initState() {
    super.initState();
    AuthenticationState state =
        BlocProvider.of<AuthenticationCubit>(context).state;
    if (state is Authenticated) {
      consignment = ConsignmentDatabase(
        context.read<DatabaseProvider>().database,
        accessToken: state.token,
      );
    }
  }

  void addMarkerOnMap(List consignments) {
    BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(
        size: Size(24, 0.5),
      ),
      AppImages.customMarker,
    ).then(
      (customIcon) {
        for (Map consignment in consignments) {
          Map deliveryAddresses =
              json.decode(consignment['delivery_addresses']);
          Map pickupAddresses = json.decode(consignment['pickup_addresses']);
          markers.add(
            Marker(
              markerId: MarkerId('${consignment["id"]}'),
              position: consignment['consignment_type'] == 'delivery'
                  ? LatLng(
                      deliveryAddresses['latitude'],
                      deliveryAddresses['longitude'],
                    )
                  : LatLng(
                      pickupAddresses['latitude'],
                      pickupAddresses['longitude'],
                    ),
              icon: customIcon,
              onTap: () {
                setState(() {
                  selectedConsignment = consignment;
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
  void dispose() {
    super.dispose();
    consignment.dispose();
    mapController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: consignment.stream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!.isNotEmpty) {
              addMarkerOnMap(snapshot.data!);
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
                if (isBottomSheetVisible && selectedConsignment != null)
                  Positioned(
                      bottom: 0,
                      left: 0.h,
                      right: 0.h,
                      child: consignmentPopupContainer(selectedConsignment!)),
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

  Widget consignmentPopupContainer(Map consignmentDetail) {
    Map productTypes = json.decode(consignmentDetail['product_types']);
    Map deliveryAddresses =
        json.decode(consignmentDetail['delivery_addresses']);
    Map pickupAddresses = json.decode(consignmentDetail['pickup_addresses']);
    return Container(
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
                        borderRadius: BorderRadius.circular(5.sp),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        (consignmentDetail['sort'] ?? 0).toString(),
                        style: Theme.of(context)
                            .textTheme
                            .headlineLarge
                            ?.copyWith(color: AppColors.white),
                      ),
                    ),
                    title: Text(
                      (consignmentDetail['consignment_type'] == 'delivery'
                              ? deliveryAddresses['company_name']
                              : pickupAddresses['company_name']) ??
                          'Not Provided',
                      style: Theme.of(context).textTheme.headlineMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Recipient: ${(consignmentDetail['consignment_type'] == 'delivery' ? deliveryAddresses['customer_name'] : pickupAddresses['customer_name']) ?? 'Not Provided'}',
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          consignmentDetail['consignment_type'] == 'delivery'
                              ? '${deliveryAddresses['street_address']}, ${deliveryAddresses['suburb']}'
                              : '${pickupAddresses['street_address']}, ${pickupAddresses['suburb']}',
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )
                      ],
                    ),
                    trailing: Container(
                      height: 12.w,
                      width: 12.w,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.black),
                        borderRadius: BorderRadius.circular(20.sp),
                      ),
                      alignment: Alignment.center,
                      child: IconButton(
                        icon: const Icon(Icons.phone),
                        onPressed: () async {
                          final Uri launchUri = Uri(
                            scheme: 'tel',
                            path: consignmentDetail['consignment_type'] ==
                                    'delivery'
                                ? deliveryAddresses['telephone']
                                : pickupAddresses['telephone'],
                          );
                          await launchUrl(launchUri);
                        },
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isBottomSheetVisible = false;
                      });
                      Get.toNamed(
                        AppRoutes.Stopwatch,
                        arguments: consignmentDetail,
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 2.h,
                        horizontal: 4.w,
                      ),
                      margin: EdgeInsets.symmetric(horizontal: 4.w),
                      decoration: BoxDecoration(
                        color: AppColors.lightBlue,
                        borderRadius: BorderRadius.circular(10.sp),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Image(
                                  image: AssetImage(AppImages.cartons),
                                ),
                                SizedBox(width: 2.w),
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.sp),
                                    color: AppColors.white,
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    vertical: 0.5.h,
                                    horizontal: 2.w,
                                  ),
                                  child: Text(
                                    (productTypes['name'])
                                        .toString()
                                        .toUpperCase(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.navyBlue,
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
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10.0,
                              ),
                              title: Text(
                                AppText.time,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: AppColors.white),
                              ),
                              subtitle: Text(
                                consignmentDetail['consignment_type'] ==
                                        'delivery'
                                    ? '${deliveryAddresses['service_time_start'].toString().split(' ').last.split(':')[0]}.${deliveryAddresses['service_time_start'].toString().split(' ').last.split(':')[1]} - ${deliveryAddresses['service_time_end'].toString().split(' ').last.split(':')[0]}.${deliveryAddresses['service_time_end'].toString().split(' ').last.split(':')[1]}'
                                    : '${pickupAddresses['service_time_start'].toString().split(' ').last.split(':')[0]}.${pickupAddresses['service_time_start'].toString().split(' ').last.split(':')[1]} - ${pickupAddresses['service_time_end'].toString().split(' ').last.split(':')[0]}.${pickupAddresses['service_time_end'].toString().split(' ').last.split(':')[1]}',
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
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      CustomValueField(
                        title: AppText.id.toUpperCase(),
                        value: consignmentDetail['id'].toString(),
                      ),
                      CustomValueField(
                        title: AppText.ref.toUpperCase(),
                        value:
                            consignmentDetail['customer_reference'].toString(),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      CustomValueField(
                        title: AppText.supplier,
                        value:
                            pickupAddresses['customer_name'] ?? 'Not Provided',
                      ),
                      CustomValueField(
                        title: AppText.cartons,
                        value: (consignmentDetail['cartons'] ?? 0).toString(),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      CustomValueField(
                        title: AppText.receiver,
                        value: deliveryAddresses['customer_name'] ??
                            'Not Provided',
                      ),
                      CustomValueField(
                        title: AppText.pallets,
                        value: (consignmentDetail['pallets'] ?? 0).toString(),
                      ),
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
