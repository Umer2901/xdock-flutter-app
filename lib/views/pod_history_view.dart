import 'dart:convert';
import 'dart:typed_data';

import 'package:coldxpress/export.dart';
import 'package:coldxpress/widgets/core/custom-widget.dart';
import 'package:coldxpress/widgets/core/custom_text.dart';

class PodHistoryView extends StatefulWidget {
  const PodHistoryView({super.key});

  @override
  State<PodHistoryView> createState() => _PodHistoryViewState();
}

class _PodHistoryViewState extends State<PodHistoryView> {
  final SignatureController _controller = SignatureController(
    penStrokeWidth: 3,
    penColor: AppColors.black,
    exportBackgroundColor: AppColors.white,
  );

  bool isLoading = false;
  late UserDatabase staff;
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {});
    });
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
    Map<String, dynamic> task = Get.arguments;

    Map<String, dynamic> taskData = jsonDecode(task['data']);
    //print('Task POD HISTORY : $task');

    // Assuming you have signatureBase64 from taskData
    String signatureBase64 = taskData['signature'];

// Remove extra quotes from the signature if present
    if (signatureBase64.startsWith('"') && signatureBase64.endsWith('"')) {
      signatureBase64 =
          signatureBase64.substring(1, signatureBase64.length - 1);
    }

// Remove 'data:image/png;base64,' prefix if present
    if (signatureBase64.contains(',')) {
      signatureBase64 = signatureBase64.split(',')[1];
    }
    signatureBase64 = signatureBase64.trim();

    //print('Signature after cleaning: $signatureBase64');

// Now decode the base64 string
    Uint8List decodedSignature = base64Decode(signatureBase64);
    //print('Decoded signature: $decodedSignature');

    // Display the signature image using Image.memory()
    Image signatureImage = Image.memory(decodedSignature);

    // Extract the 'data' field from the task
    Map<String, dynamic> data = {};
    try {
      data = jsonDecode(task['data']);
    } catch (e) {
      debugPrint('Error decoding data: $e');
      data = {};
    }

    // Extract fields from the parsed data
    int carton = data['carton'] ?? 0;
    int pallet = data['pallet'] ?? 0;
    int space = data['space'] ?? 0;
    String companyName = data['company_name'] ?? 'N/A';
    int referenceId = data['address_id'] ?? 0;

    String picturesString = data['pictures'] ?? null;

    print('PictureString : $picturesString');

    String customerReference = data['customer_reference'] ?? 'N/A';
    String serviceTime = data['service_time_start'] ?? 'N/A';
    final int podType = int.tryParse(data['pod_type'].toString()) ?? -1;

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

    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () {
            //context.read<BottomNavProvider>().changeTabView(1);
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_ios,
            size: 15.sp,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              //  _scaffoldKey.currentState?.openEndDrawer();
            },
            icon: Icon(
              Icons.more_horiz,
              size: 20.sp,
            ),
          ),
        ],
        centerTitle: true,
        title: Text(
          AppText.podhistoryview,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 15.0, left: 14, right: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 18.3.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xffF4F4F4),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.only(top: 10.0, left: 15, right: 10),
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
                          CustomTextDisplay(
                              text: "Driver id: ${userData?['id']}"),
                          SizedBox(width: 1.5.w),
                          const CustomTextDisplay(text: "|"),
                          SizedBox(width: 1.5.w),
                          Expanded(
                            child:
                                CustomTextDisplay(text: "Time: $serviceTime"),
                          ),
                          // CustomTextDisplay(
                          //   text:
                          //       '${(widget.consignment!['consignment_type'] == 'delivery' ? deliveryAddresses['service_time_start'] == null ? '--.--' : DateFormat('HH.mm').format(DateTime.parse(deliveryAddresses['service_time_start'])) : pickupAddresses['service_time_start'] == null ? '--.--' : DateFormat('HH.mm').format(DateTime.parse(pickupAddresses['service_time_start'])))} - ${(widget.consignment!['consignment_type'] == 'delivery' ? deliveryAddresses['service_time_end'] == null ? '--.--' : DateFormat('HH.mm').format(DateTime.parse(deliveryAddresses['service_time_end'])) : pickupAddresses['service_time_end'] == null ? '--.--' : DateFormat('HH.mm').format(DateTime.parse(pickupAddresses['service_time_end'])))}',
                          // ),
                        ],
                      ),
                      SizedBox(height: 0.5.h),
                      InkWell(
                        onTap: () {},
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
              SizedBox(
                height: 1.h,
              ),
              Container(
                height: 27.3.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Color(0xffF4F4F4),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.only(top: 10.0, left: 15, right: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomWidget(text: "POD Histories view", onTap: () {}),
                      SizedBox(
                        height: 2.h,
                      ),
                      Container(
                          height: 15.h,
                          width: 27.w,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Image.asset(
                            picturesString,
                            fit: BoxFit.contain,
                          )),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 1.h,
              ),
              Container(
                height: 27.3.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xffF4F4F4),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.only(top: 10.0, left: 15, right: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                          child: CustomWidget(text: "Signature", onTap: () {})),
                      SizedBox(
                        height: 2.h,
                      ),
                      // Container(
                      //   height: 15.h,
                      //   width: 27.w,
                      //   decoration: BoxDecoration(
                      //     borderRadius: BorderRadius.circular(20),
                      //   ),
                      //   padding: EdgeInsets.symmetric(
                      //       vertical: 1.h, horizontal: 2.w),
                      //   child: Signature(
                      //     controller: _controller,
                      //     width: 90.w,
                      //     height: 20.h,
                      //     backgroundColor: Colors.transparent,
                      //   ),
                      //   //child: Image.asset(AppImages.simplePic,fit: BoxFit.contain,),
                      // ),
                      Container(
                        height: 15.h,
                        width: 27.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: signatureImage,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 1.5.h,
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Container(
                  height: 47.3.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Color(0xffF4F4F4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.only(top: 10.0, left: 15, right: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 1.h,
                        ),
                        CustomWidget(text: "Payload", onTap: () {}),
                        SizedBox(
                          height: 2.h,
                        ),
                        // Container(
                        //   height: 35.h,
                        //   width: 85.w,
                        //   decoration: BoxDecoration(
                        //     borderRadius: BorderRadius.circular(20),
                        //   ),
                        //   child: Container(
                        //     height: 20.h,
                        //     width: 20.w,
                        //     decoration: BoxDecoration(
                        //       borderRadius: BorderRadius.circular(5),
                        //       color: AppColors.white,
                        //     ),
                        //     child: Padding(
                        //       padding: const EdgeInsets.only(
                        //           top: 8.0, left: 10, right: 10, bottom: 8),
                        //       child: CustomTextDisplay(
                        //         text: "sksnksnksn",
                        //       ),
                        //     ),
                        //   ),
                        // ),
                        Container(
                          height: 35.h,
                          width: 85.w,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Container(
                            height: 20.h,
                            width: 20.w,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: AppColors.white,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  top: 8.0, left: 10, right: 10, bottom: 8),
                              child: CustomTextDisplay(
                                text: "{${task}, },", maxLine: 12,
                                // "Temperature: ${taskData['temperature']}°C\n"
                                // "Service Window: ${taskData['service_window']} minutes\n"
                                // "Delivered on: ${taskData['date_delivered']}",
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
