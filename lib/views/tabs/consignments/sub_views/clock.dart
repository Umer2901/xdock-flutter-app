import 'dart:convert';
import 'package:coldxpress/export.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class EditTime extends StatefulWidget {
  const EditTime({super.key});

  @override
  State<EditTime> createState() => _EditTimeState();
}

class _EditTimeState extends State<EditTime> {
  late PickedTime _startTime;
  late PickedTime _endTime;
  late Map consignment;

  DateTime? startTime;
  DateTime? endTime;

  late Map deliveryAddresses;
  late Map pickupAddresses;

  @override
  void initState() {
    super.initState();
    consignment = Get.arguments;
    deliveryAddresses = consignment['delivery_addresses'].runtimeType == String
        ? json.decode(consignment['delivery_addresses'])
        : consignment['delivery_addresses'];
    pickupAddresses = consignment['pickup_addresses'].runtimeType == String
        ? json.decode(consignment['pickup_addresses'])
        : consignment['pickup_addresses'];

    startTime = consignment['consignment_type'] == 'delivery'
        ? deliveryAddresses['service_time_start'] != null
            ? DateTime.parse(deliveryAddresses['service_time_start'])
            : null
        : pickupAddresses['service_time_start'] != null
            ? DateTime.parse(pickupAddresses['service_time_start'])
            : null;
    endTime = consignment['consignment_type'] == 'delivery'
        ? deliveryAddresses['service_time_end'] != null
            ? DateTime.parse(deliveryAddresses['service_time_end'])
            : null
        : pickupAddresses['service_time_end'] != null
            ? DateTime.parse(pickupAddresses['service_time_end'])
            : null;

    _startTime = startTime == null
        ? PickedTime(h: 6, m: 30)
        : PickedTime(h: startTime!.hour, m: startTime!.minute);
    _endTime = endTime == null
        ? PickedTime(h: 15, m: 30)
        : PickedTime(h: endTime!.hour, m: endTime!.minute);
  }

  Future<void> saveTimeUpdateToTaskSync(
      DatabaseProvider dbProvider, String accessToken, int addressId, PickedTime startTime, PickedTime endTime) async {
    // Prepare the data to be saved in the TaskSyncDatabase
    final requestBody = {
      "addressId": addressId,
      "startTime": "${startTime.h.toString().padLeft(2, '0')}:${startTime.m.toString().padLeft(2, '0')}",
      "endTime": "${endTime.h.toString().padLeft(2, '0')}:${endTime.m.toString().padLeft(2, '0')}"
    };

    // Save the data in TaskSyncDatabase
    final taskData = {
      "task_name": "update time", // Task name for the update time task
      "task_type": "update_time", // Task type to indicate this is a time update
      "data": jsonEncode(requestBody), // Store the requestBody as JSON string
      "access_token": accessToken // Store the access token for future API calls
    };

    try {
      await dbProvider.database.insert('sync_task', taskData);
    } catch (e) {
      debugPrint('Error saving task to TaskSyncDatabase: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final address_id = (Get.arguments['consignment_type'] == 'pickup')
        ? pickupAddresses['id']
        : deliveryAddresses['id'];

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
                  SizedBox(height: 2.h),
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
                                style: Theme.of(context).textTheme.headlineMedium,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 1.h),
                        InkWell(
                          onTap: () async {
                            final Uri launchUri = Uri(
                              scheme: 'tel',
                              path: consignment['consignment_type'] == 'delivery'
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
                  SizedBox(height: 2.h),
                  const Divider(),
                  SizedBox(height: 2.h),
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
                              SizedBox(width: 1.w),
                              Text(
                                "Start Time",
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.black),
                              ),
                            ],
                          ),
                          Text(
                            "${_startTime.h}:${_startTime.m}",
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: const Color(0xFFE29400)),
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
                              SizedBox(width: 1.w),
                              Text(
                                "End Time",
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.black),
                              ),
                            ],
                          ),
                          Text(
                            "${_endTime.h}:${_endTime.m}",
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.blue),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 1.h),
                  SizedBox(height: 2.h),
                  Center(
                    child: Text(
                      "*24 HR CLOCK",
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppColors.grey),
                    ),
                  ),
                  SizedBox(height: 1.h),
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
                                baseColor: const Color.fromARGB(255, 200, 198, 198),
                                initHandlerDecoration: TimePickerHandlerDecoration(
                                  color: AppColors.grey,
                                  shape: BoxShape.circle,
                                  radius: 12.0,
                                  icon: const Icon(
                                    Icons.circle,
                                    size: 20.0,
                                    color: AppColors.yellow,
                                  ),
                                ),
                                endHandlerDecoration: TimePickerHandlerDecoration(
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
                  SizedBox(height: 2.h),
                  Center(
                    child: Text(
                      "*Changing these hours may impact drop order",
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppColors.grey),
                    ),
                  ),
                  SizedBox(height: 3.h),
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
                            // Get the user's token from the authentication state
                            AuthenticationState state = BlocProvider.of<AuthenticationCubit>(context).state;
                            if (state is Authenticated) {
                              String accessToken = state.token;

                              // Save the time update task to TaskSyncDatabase
                              await saveTimeUpdateToTaskSync(
                                  context.read<DatabaseProvider>(),
                                  accessToken,
                                  address_id,
                                  _startTime,
                                  _endTime);

                              // Now, update the consignment data in the local database
                              await ConsignmentDatabase(context.read<DatabaseProvider>().database)
                                  .readById(consignment['id'])
                                  .then((value) {
                                if (value.isNotEmpty) {
                                  // Update consignment delivery or pickup data
                                  if (consignment['consignment_type'] == 'delivery') {
                                    deliveryAddresses['service_time_start'] =
                                        startTime != null
                                            ? startTime!
                                                .copyWith(hour: _startTime.h, minute: _startTime.m)
                                                .toString()
                                                .split('.')
                                                .first
                                            : parseDate(consignment['date'])
                                                .copyWith(hour: _startTime.h, minute: _startTime.m)
                                                .toString()
                                                .split('.')
                                                .first;

                                    deliveryAddresses['service_time_end'] =
                                        endTime != null
                                            ? endTime!.copyWith(hour: _endTime.h, minute: _endTime.m)
                                                .toString()
                                                .split('.')
                                                .first
                                            : parseDate(consignment['date'])
                                                .copyWith(hour: _endTime.h, minute: _endTime.m)
                                                .toString()
                                                .split('.')
                                                .first;

                                    // Save the updated delivery addresses
                                    String temp = json.encode(deliveryAddresses);
                                    ConsignmentDatabase(context.read<DatabaseProvider>().database)
                                        .update(consignment['id'], {'delivery_addresses': temp});
                                  } else {
                                    pickupAddresses['service_time_start'] =
                                        startTime != null
                                            ? startTime!
                                                .copyWith(hour: _startTime.h, minute: _startTime.m)
                                                .toString()
                                                .split('.')
                                                .first
                                            : parseDate(consignment['date'])
                                                .copyWith(hour: _startTime.h, minute: _startTime.m)
                                                .toString()
                                                .split('.')
                                                .first;

                                    pickupAddresses['service_time_end'] =
                                        endTime != null
                                            ? endTime!.copyWith(hour: _endTime.h, minute: _endTime.m)
                                                .toString()
                                                .split('.')
                                                .first
                                            : parseDate(consignment['date'])
                                                .copyWith(hour: _endTime.h, minute: _endTime.m)
                                                .toString()
                                                .split('.')
                                                .first;

                                    // Save the updated pickup addresses
                                    String temp = json.encode(pickupAddresses);
                                    ConsignmentDatabase(context.read<DatabaseProvider>().database)
                                        .update(consignment['id'], {'pickup_addresses': temp});
                                  }
                                }

                                // Update the time in TimeProvider
                                var timeProvider = Provider.of<TimeProvider>(context, listen: false);
                                timeProvider.updateTimes(
                                  DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, _startTime.h, _startTime.m),
                                  DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, _endTime.h, _endTime.m)
                                );

                                // Go back to the previous screen
                                Navigator.pop(context);
                              });
                            }
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

  DateTime parseDate(String? date) {
    if (date == null) {
      return DateTime.now();
    }
    List<String> value = date.split('/');
    return DateTime(int.parse(value[2]), int.parse(value[1]), int.parse(value[0]));
  }
}

class TimeProvider extends ChangeNotifier {
  DateTime _startTime = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 6, 30);
  DateTime _endTime = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 19, 30);

  DateTime get startTime => _startTime;
  DateTime get endTime => _endTime;

  void updateTimes(DateTime startTime, DateTime endTime) {
    _startTime = startTime;
    _endTime = endTime;
    notifyListeners();
  }

  String getFormattedTime(DateTime time) {
    final hours = time.hour.toString().padLeft(2, '0');
    final minutes = time.minute.toString().padLeft(2, '0');
    return '$hours:$minutes';
  }

  String get formattedStartTime => getFormattedTime(_startTime);
  String get formattedEndTime => getFormattedTime(_endTime);
}
