import 'dart:convert';
import 'package:coldxpress/export.dart';
import 'package:coldxpress/views/tabs/consignments/sub_views/proof_of_delivery_photos.dart';
import 'package:url_launcher/url_launcher.dart';

class EditTime extends StatefulWidget {
  const EditTime({super.key});

  @override
  State<EditTime> createState() => _EditTimeState();
}

class _EditTimeState extends State<EditTime> {
  late TimeProvider _timeProvider;
  late PickedTime _startTime;
  late PickedTime _endTime;
  late Map consignment;

  DateTime? startTime;
  DateTime? endTime;

  late Map deliveryAddresses;
  late Map pickupAddresses;

  @override
  void initState() {
    consignment = Get.arguments;
    deliveryAddresses = consignment['pickup_addresses'].runtimeType == String
        ? json.decode(consignment['pickup_addresses'])
        : consignment['pickup_addresses'];
    pickupAddresses = consignment['pickup_addresses'].runtimeType == String
        ? json.decode(consignment['pickup_addresses'])
        : consignment['pickup_addresses'];
    startTime = consignment['consignment_type'] == 'delivery'
        ? deliveryAddresses['service_time_start'] == null
            ? null
            : DateTime.parse(deliveryAddresses['service_time_start'])
        : pickupAddresses['service_time_start'] == null
            ? null
            : DateTime.parse(pickupAddresses['service_time_start']);
    endTime = consignment['consignment_type'] == 'delivery'
        ? deliveryAddresses['service_time_end'] == null
            ? null
            : DateTime.parse(deliveryAddresses['service_time_end'])
        : pickupAddresses['service_time_end'] == null
            ? null
            : DateTime.parse(pickupAddresses['service_time_end']);
    _startTime = startTime == null
        ? PickedTime(h: 6, m: 30)
        : PickedTime(h: startTime!.hour, m: startTime!.minute);
    _endTime = endTime == null
        ? PickedTime(h: 19, m: 30)
        : PickedTime(h: endTime!.hour, m: endTime!.minute);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _timeProvider = Provider.of<TimeProvider>(context);
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
          AppText.setdeliveryHours,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 2.h,
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                (consignment['consignment_type'] == 'delivery'
                                        ? deliveryAddresses['customer_name']
                                        : pickupAddresses['customer_name']) ??
                                    'Not Provided',
                                style:
                                    Theme.of(context).textTheme.headlineMedium,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 1.h,
                        ),
                        InkWell(
                          onTap: () async {
                            final Uri launchUri = Uri(
                              scheme: 'tel',
                              path:
                                  consignment['consignment_type'] == 'delivery'
                                      ? deliveryAddresses['telephone']
                                      : pickupAddresses['telephone'],
                            );
                            await launchUrl(launchUri);
                          },
                          child: Container(
                            width: 9.5.w,
                            height: 4.h,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50.sp),
                                border: Border.all(
                                  color: AppColors.black.withOpacity(0.8),
                                )),
                            child: Icon(
                              Icons.call,
                              color: AppColors.black,
                              size: 3.h,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 2.h,
                  ),
                  const Divider(),
                  SizedBox(
                    height: 2.h,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              const CircleAvatar(
                                backgroundColor: Color(0xFFE29400),
                                radius: 5,
                              ),
                              SizedBox(
                                width: 1.w,
                              ),
                              Text(
                                "Start Time",
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(color: AppColors.black),
                              ),
                            ],
                          ),
                          Text(
                            "${_startTime.h}:${_startTime.m}",
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(color: const Color(0xFFE29400)),
                          ),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              const CircleAvatar(
                                backgroundColor: AppColors.blue,
                                radius: 5,
                                child: CircleAvatar(
                                  backgroundColor: AppColors.white,
                                  radius: 2,
                                ),
                              ),
                              SizedBox(
                                width: 1.w,
                              ),
                              Text(
                                "End Time",
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(color: AppColors.black),
                              ),
                            ],
                          ),
                          Text(
                            "${_endTime.h}:${_endTime.m}",
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(color: AppColors.blue),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 1.h,
                  ),
                  SizedBox(
                    height: 2.h,
                  ),
                  Center(
                    child: Text(
                      "*24 HR CLOCK",
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(color: AppColors.grey),
                    ),
                  ),
                  SizedBox(
                    height: 1.h,
                  ),
                  Center(
                    child: SizedBox(
                      height: 31.h,
                      width: 75.w,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircleAvatar(
                            backgroundColor: AppColors.white,
                            backgroundImage: const AssetImage(AppImages.clock),
                            radius: 76.sp,
                          ),
                          Positioned(
                            right: 0,
                            left: 0,
                            child: TimePicker(
                              initTime: _startTime,
                              endTime: _endTime,
                              onSelectionChange: (start, end, isDisableRange) =>
                                  debugPrint(
                                'onSelectionChange => init : ${start.h}:${start.m}, end : ${end.h}:${end.m}, isDisableRangeRange: $isDisableRange',
                              ),
                              onSelectionEnd: (start, end, isDisableRange) {
                                setState(() {
                                  _startTime = start;
                                  _endTime = end;
                                });
                                debugPrint(
                                  'onSelectionEnd => init : ${start.h}:${start.m}, end : ${end.h}:${end.m}, isDisableRangeRange: $isDisableRange',
                                );
                              },
                              decoration: TimePickerDecoration(
                                sweepDecoration: TimePickerSweepDecoration(
                                  pickerStrokeWidth: 8,
                                  pickerGradient: const SweepGradient(
                                    colors: [
                                      Color.fromARGB(255, 9, 103, 198),
                                      Colors.blue,
                                    ],
                                    stops: [0.0, 1.0],
                                  ),
                                ),
                                baseColor:
                                    const Color.fromARGB(255, 200, 198, 198),
                                initHandlerDecoration:
                                    TimePickerHandlerDecoration(
                                  color: AppColors.grey,
                                  shape: BoxShape.circle,
                                  radius: 12.0,
                                  icon: const Icon(
                                    Icons.circle,
                                    size: 20.0,
                                    color: AppColors.yellow,
                                  ),
                                ),
                                endHandlerDecoration:
                                    TimePickerHandlerDecoration(
                                  color: AppColors.grey,
                                  shape: BoxShape.circle,
                                  radius: 12.0,
                                  icon: const Icon(
                                    Icons.circle,
                                    size: 20.0,
                                    color: AppColors.blue,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 2.h,
                  ),
                  Center(
                    child: Text(
                      "*Changing these hours may impact drop order",
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(color: AppColors.grey),
                    ),
                  ),
                  SizedBox(
                    height: 3.h,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 30.w,
                        child: CustomButton(
                          label: "Cancel",
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          backgroundColor: AppColors.white,
                          foregroundColor: AppColors.darkGrey,
                          borderColor: Colors.grey,
                        ),
                      ),
                      SizedBox(
                        width: 30.w,
                        child: CustomButton(
                          label: "Save",
                          onPressed: () async {
                            await ConsignmentDatabase(
                                    context.read<DatabaseProvider>().database)
                                .readById(consignment['id'])
                                .then((value) {
                              if (value.isNotEmpty) {
                                if (consignment['consignment_type'] ==
                                    'delivery') {
                                  deliveryAddresses['service_time_start'] =
                                      startTime != null
                                          ? startTime!
                                              .copyWith(
                                                hour: _startTime.h,
                                                minute: _startTime.m,
                                              )
                                              .toString()
                                              .split('.')
                                              .first
                                          : parseDate(consignment['date'])
                                              .copyWith(
                                                hour: _startTime.h,
                                                minute: _startTime.m,
                                              )
                                              .toString()
                                              .split('.')
                                              .first;
                                  deliveryAddresses['service_time_end'] =
                                      endTime != null
                                          ? endTime!
                                              .copyWith(
                                                hour: _endTime.h,
                                                minute: _endTime.m,
                                              )
                                              .toString()
                                              .split('.')
                                              .first
                                          : parseDate(consignment['date'])
                                              .copyWith(
                                                hour: _endTime.h,
                                                minute: _endTime.m,
                                              )
                                              .toString()
                                              .split('.')
                                              .first;

                                  String temp = json.encode(deliveryAddresses);

                                  ConsignmentDatabase(context
                                          .read<DatabaseProvider>()
                                          .database)
                                      .update(
                                    consignment['id'],
                                    {'delivery_addresses': temp},
                                  );
                                } else {
                                  pickupAddresses['service_time_start'] =
                                      startTime != null
                                          ? startTime!
                                              .copyWith(
                                                hour: _startTime.h,
                                                minute: _startTime.m,
                                              )
                                              .toString()
                                              .split('.')
                                              .first
                                          : parseDate(consignment['date'])
                                              .copyWith(
                                                hour: _startTime.h,
                                                minute: _startTime.m,
                                              )
                                              .toString()
                                              .split('.')
                                              .first;
                                  pickupAddresses['service_time_end'] =
                                      endTime != null
                                          ? endTime!
                                              .copyWith(
                                                hour: _endTime.h,
                                                minute: _endTime.m,
                                              )
                                              .toString()
                                              .split('.')
                                              .first
                                          : parseDate(consignment['date'])
                                              .copyWith(
                                                hour: _endTime.h,
                                                minute: _endTime.m,
                                              )
                                              .toString()
                                              .split('.')
                                              .first;

                                  String temp = json.encode(pickupAddresses);

                                  ConsignmentDatabase(context
                                          .read<DatabaseProvider>()
                                          .database)
                                      .update(
                                    consignment['id'],
                                    {'pickup_addresses': temp},
                                  );
                                }
                              }
                              var timeProvider = Provider.of<TimeProvider>(
                                context,
                                listen: false,
                              );
                              timeProvider.updateTimes(_startTime, _endTime);
                              Navigator.pop(context);
                            });
                          },
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  DateTime parseDate(String date) {
    List<String> value = date.split('/');
    return DateTime(
        int.parse(value[2]), int.parse(value[1]), int.parse(value[0]));
  }
}

class TimeProvider extends ChangeNotifier {
  PickedTime _startTime = PickedTime(h: 6, m: 30);
  PickedTime _endTime = PickedTime(h: 19, m: 30);

  PickedTime get startTime => _startTime;
  PickedTime get endTime => _endTime;

  void updateTimes(PickedTime startTime, PickedTime endTime) {
    _startTime = startTime;
    _endTime = endTime;
    notifyListeners();
  }
}
