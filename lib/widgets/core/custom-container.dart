import 'dart:convert';

import 'package:coldxpress/export.dart';

import 'custom_text.dart';

class CustomContainer extends StatefulWidget {
  //final String? podStatus;
  final Function()? ontab;
  // final ConsignmentDatabase? consignment;
  final Map? consignment;

  const CustomContainer({
    super.key,
    // required this.podStatus,
    this.ontab,
    this.consignment,
  });

  @override
  State<CustomContainer> createState() => _CustomContainerState();
}

class _CustomContainerState extends State<CustomContainer> {
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
    String productId = widget.consignment?['id']?.toString() ?? 'N/A';
    String customerReference =
        widget.consignment?['customer_reference']?.toString() ?? 'N/A';
    int carton = widget.consignment?['carton'];
    int pallet = widget.consignment?['pallet'];
    int space = widget.consignment?['space'];

    Map productTypes = json.decode(widget.consignment?['product_types']);
    Map deliveryAddresses = json.decode(
      widget.consignment?['delivery_addresses'],
    );
    Map pickupAddresses = json.decode(widget.consignment?['pickup_addresses']);
    List groupedConsignments = [];
    if (widget.consignment?['grouped_consignments'] != null) {
      groupedConsignments = json.decode(
        widget.consignment?['grouped_consignments'],
      );
    }

    Color containerColor;
    String displayText;

    switch (widget.consignment?['consignment_type']) {
      case 'delivery':
        containerColor = AppColors.yellow;
        displayText = "Delivery";
        break;
      case 'pickup':
        containerColor = AppColors.green;
        displayText = "Pickup";
        break;
      case 'return':
        containerColor = AppColors.green;
        displayText = "Return";
        break;
      // case 'partial pod':
      //   containerColor = AppColors.blue;
      //   displayText = "Partial POD";
      //   break;
      default:
        containerColor = AppColors.grey;
        displayText = "Unknown POD";
    }
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: Container(
          //height: 18.3.h,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Color(0xffF4F4F4),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 10.0, left: 15, right: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 15  digits and also check condition on Reference .......
                Text(
                  (widget.consignment!['consignment_type'] == 'delivery'
                          ? deliveryAddresses['company_name']
                          : pickupAddresses['company_name']) ??
                      'Not Provided',
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
                    // CustomTextDisplay(
                    //     text: "${widget.consignment!['id']}: 239183"),
                    CustomTextDisplay(text: "ID: $productId"),
                    SizedBox(width: 1.5.w),
                    const CustomTextDisplay(text: "|"),
                    SizedBox(width: 1.5.w),
                    Expanded(
                        child: CustomTextDisplay(
                            text: "Reference: $customerReference")),
                    //CustomTextDisplay(text: AppText.reference + ": 0"),
                  ],
                ),
                SizedBox(height: 0.5.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    CustomTextDisplay(text: "Driver id: ${userData?['id']}"),
                    SizedBox(width: 1.5.w),
                    CustomTextDisplay(text: "|"),
                    SizedBox(width: 1.5.w),
                    CustomTextDisplay(
                      text:
                          '${(widget.consignment!['consignment_type'] == 'delivery' ? deliveryAddresses['service_time_start'] == null ? '--.--' : DateFormat('HH.mm').format(DateTime.parse(deliveryAddresses['service_time_start'])) : pickupAddresses['service_time_start'] == null ? '--.--' : DateFormat('HH.mm').format(DateTime.parse(pickupAddresses['service_time_start'])))} - ${(widget.consignment!['consignment_type'] == 'delivery' ? deliveryAddresses['service_time_end'] == null ? '--.--' : DateFormat('HH.mm').format(DateTime.parse(deliveryAddresses['service_time_end'])) : pickupAddresses['service_time_end'] == null ? '--.--' : DateFormat('HH.mm').format(DateTime.parse(pickupAddresses['service_time_end'])))}',
                    ),
                  ],
                ),
                SizedBox(height: 0.5.h),
                InkWell(
                  onTap: widget.ontab,
                  child: Container(
                    height: 3.h,
                    width: 24.w,
                    decoration: BoxDecoration(
                      color: containerColor,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Center(
                      child: Text(
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
