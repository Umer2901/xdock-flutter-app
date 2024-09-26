import 'dart:convert';

import 'package:coldxpress/export.dart';

import 'custom_text.dart';

class CustomPodHistoryContainer extends StatefulWidget {
  final Function()? ontab;
  // final ConsignmentDatabase? consignment;
  final Map? consignment;

  const CustomPodHistoryContainer({
    super.key,
    this.ontab,
    this.consignment,
  });

  @override
  State<CustomPodHistoryContainer> createState() =>
      _CustomPodHistoryContainerState();
}

class _CustomPodHistoryContainerState extends State<CustomPodHistoryContainer> {
  late UserDatabase staff;
  Map<String, dynamic>? userData;

  @override
  void initState() {
    Future<void> fetchAndPrintUserData() async {
      try {
        List<Map<String, dynamic>> userDataList = await staff.read();

        if (userDataList.isNotEmpty) {
          setState(() {
            userData = userDataList.first;
          });
          debugPrint("User Data: ${json.encode(userData)}");
        } else {
          debugPrint('No user data found.');
        }
      } catch (e) {
        debugPrint('Error fetching user data: $e');
      }
    }

    super.initState();
    AuthenticationState state =
        BlocProvider.of<AuthenticationCubit>(context).state;
    if (state is Authenticated) {
      staff = UserDatabase(
        context.read<DatabaseProvider>().database,
        accessToken: state.token,
      );
      fetchAndPrintUserData();
    }
  }

  @override
  Widget build(BuildContext context) {
    //String productId = widget.consignment?['id'] ?? 'N/A';
    //String customerReference = widget.consignment?['customer_reference'] ?? 'N/A';
    // int carton = widget.consignment?['carton'];
    // int pallet = widget.consignment?['pallet'];
    // int space = widget.consignment?['space'];
    // Ensure that data is decoded correctly
    Map<String, dynamic> data;
    try {
      data = json.decode(widget.consignment?['data']);
    } catch (e) {
      debugPrint('Error decoding data: $e');
      data = {}; // fallback to empty map in case of error
    }

    int carton = data['carton'] ?? 0;
    int pallet = data['pallet'] ?? 0;
    int space = data['space'] ?? 0;
    //var podType = data['pod_type'];
    final int podType = int.tryParse(data['pod_type'].toString()) ?? -1;
    int referenceId = data['consignment_id'] ?? 0;
    String customerReference = data['customer_reference'] ?? 'N/A';
    String serviceTime = data['service_time_start'] ?? 'N/A';
    String companyName = data['company_name'] ?? 'N/A';

    // print('data : $')

    Color containerColor;
    String displayText;

    switch (podType) {
      case 0:
        containerColor = AppColors.yellow;
        displayText = "Full Delivery";
        break;
      case 1:
        containerColor = AppColors.green;
        displayText = "Partial Delivery";
        break;
      case 2:
        containerColor = AppColors.blue;
        displayText = "Group POD Delivery";
        break;
      case 3:
        containerColor = AppColors.red;
        displayText = "No Delivery";
        break;
      case 4:
        containerColor = Colors.orange;
        displayText = "Single POP";
        break;
      case 5:
        containerColor = Colors.purple;
        displayText = "Group POP Delivery";
        break;
      default:
        containerColor = AppColors.grey;
        displayText = "hello";
    }
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: Container(
          height: 18.3.h,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xffF4F4F4),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 10.0, left: 15, right: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  // (widget.consignment!['consignment_type'] == 'delivery'
                  //         ? deliveryAddresses['company_name']
                  //         : pickupAddresses['company_name']) ??
                  //     'Not Provided',
                  // 'Hello',
                  companyName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    CustomTextDisplay(text: "Cartons: $carton"),
                    SizedBox(width: 1.5.w),
                    const CustomTextDisplay(text: "|"),
                    SizedBox(width: 1.5.w),
                    CustomTextDisplay(text: "Pallets: $pallet"),
                    SizedBox(width: 1.5.w),
                    const CustomTextDisplay(text: "|"),
                    SizedBox(width: 1.5.w),
                    CustomTextDisplay(text: "Space: $space"),
                  ],
                ),
                SizedBox(height: 0.5.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    //CustomTextDisplay(text: "${widget.consignment!['id']}: 239183"),
                    CustomTextDisplay(text: "ID: $referenceId"),
                    // CustomTextDisplay(text: "ID: $productId"),
                    SizedBox(width: 1.5.w),
                    const CustomTextDisplay(text: "|"),
                    SizedBox(width: 1.5.w),
                    Expanded(
                        child: CustomTextDisplay(
                            text: "Reference: $customerReference")),
                  ],
                ),
                SizedBox(height: 0.5.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    CustomTextDisplay(text: "Driver id: ${userData?['id']}"),
                    SizedBox(width: 1.5.w),
                    const CustomTextDisplay(text: "|"),
                    SizedBox(width: 1.5.w),
                    Expanded(
                      child: CustomTextDisplay(text: "Time: $serviceTime"),
                    ),
                    // CustomTextDisplay(
                    //   text:
                    //       '${(widget.consignment!['consignment_type'] == 'delivery' ? deliveryAddresses['service_time_start'] == null ? '--.--' : DateFormat('HH.mm').format(DateTime.parse(deliveryAddresses['service_time_start'])) : pickupAddresses['service_time_start'] == null ? '--.--' : DateFormat('HH.mm').format(DateTime.parse(pickupAddresses['service_time_start'])))} - ${(widget.consignment!['consignment_type'] == 'delivery' ? deliveryAddresses['service_time_end'] == null ? '--.--' : DateFormat('HH.mm').format(DateTime.parse(deliveryAddresses['service_time_end'])) : pickupAddresses['service_time_end'] == null ? '--.--' : DateFormat('HH.mm').format(DateTime.parse(pickupAddresses['service_time_end'])))}',
                    // ),
                  ],
                ),
                SizedBox(height: 0.5.h),
                InkWell(
                  onTap: widget.ontab,
                  child: Container(
                    height: 4.h,
                    width: 24.w,
                    decoration: BoxDecoration(
                      color: containerColor,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Center(
                      child: Text(
                        textAlign: TextAlign.center,
                        displayText,
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}