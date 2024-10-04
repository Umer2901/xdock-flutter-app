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
  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> task = Get.arguments;
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

    Map<String, dynamic> taskData = jsonDecode(task['data']);
    //print('Task POD HISTORY : $task');

    Map<String, dynamic> data = {};
    try {
      data = jsonDecode(task['data']);
    } catch (e) {
      debugPrint('Error decoding data: $e');
      data = {};
    }

    String signatureBase64 = '';

if (data['signature'] != null && data['signature'] is String) {
  signatureBase64 = jsonDecode(data['signature']) 
      .replaceAll(RegExp(r'\s+'), '')
      .replaceAll(RegExp(r'data:image\/[a-zA-Z]+;base64,'), '');
}

    Uint8List? signatureBytes;
    if (signatureBase64.isNotEmpty) {
      try {
        signatureBytes = Base64Decoder().convert(signatureBase64);
      } catch (e) {
        debugPrint('Error decoding signature base64: $e');
        signatureBytes = null;
      }
    } else {
      debugPrint('Signature data is either null or empty');
      signatureBytes = null;
    }

    Map<String, dynamic>? pictures;
    if (data['pictures'] is Map<String, dynamic>) {
      pictures = data['pictures'] as Map<String, dynamic>;
    } else if (data['pictures'] is String) {
      try {
        pictures = jsonDecode(data['pictures']) as Map<String, dynamic>?;
      } catch (e) {
        debugPrint('Error decoding pictures string: $e');
        pictures = null;
      }
    }

    List<Uint8List> imageBytesList = [];

    if (pictures != null) {
      pictures.forEach((key, value) {
        String base64String = value
            .toString()
            .replaceAll(RegExp(r'data:image\/[a-zA-Z]+;base64,'), '');
        if (base64String.isNotEmpty) {
          imageBytesList.add(Base64Decoder().convert(base64String));
        }
      });
    }

    int carton = data['carton'] ?? 0;
    int pallet = data['pallet'] ?? 0;
    int space = data['space'] ?? 0;
    int driver = data['driver_id'] ?? 0;
    String companyName = data['company_name'] ?? 'N/A';
    int referenceId = data['address_id'] ?? 0;
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
      key: _scaffoldKey,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () {
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
              _scaffoldKey.currentState?.openEndDrawer();
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
                          SizedBox(width: 1.5.w),
                          const CustomTextDisplay(text: "|"),
                          SizedBox(width: 1.5.w),
                          Expanded(
                            child: CustomTextDisplay(
                                text: "Reference: $customerReference"),
                          ),
                        ],
                      ),
                      SizedBox(height: 0.5.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          CustomTextDisplay(text: "Driver id: $driver"),
                          SizedBox(width: 1.5.w),
                          const CustomTextDisplay(text: "|"),
                          SizedBox(width: 1.5.w),
                          Expanded(
                            child:
                                CustomTextDisplay(text: "Time: $serviceTime"),
                          ),
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
              SizedBox(height: 1.h),
              Container(
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
                      SizedBox(height: 2.h),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: imageBytesList.map((bytes) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              height: 15.h,
                              width: 27.w,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Image.memory(bytes),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 1.h),
       
if (podType != 3 && signatureBytes != null && signatureBytes.isNotEmpty)
  Container(
    width: double.infinity,
    decoration: BoxDecoration(
      color: const Color(0xffF4F4F4),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Padding(
      padding: const EdgeInsets.only(top: 10.0, left: 15, right: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: CustomWidget(text: "Signature", onTap: () {}),
          ),
          SizedBox(height: 2.h),
          Container(
            height: 15.h,
            width: 50.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Image.memory(
                signatureBytes!,
                fit: BoxFit.fill,
              ),
            ),
          ),
        ],
      ),
    ),
  ),


              SizedBox(height: 1.5.h),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Container(
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
                        SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: taskData.entries.map((entry) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 4.0),
                                child: CustomTextDisplay(
                                  text: "${entry.key}: ${entry.value}",
                                ),
                              );
                            }).toList(),
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
      endDrawer: const CustomDrawer(),
    );
  }
}
