import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:coldxpress/providers/pof_services_provider.dart';
import 'package:coldxpress/export.dart';
import 'package:coldxpress/providers/proof-of-delivery-provider.dart';

class ProofOfDeliveryPhotos extends StatefulWidget {
  const ProofOfDeliveryPhotos({super.key, required arguments});

  @override
  State<ProofOfDeliveryPhotos> createState() => _ProofOfDeliveryPhotosState();
}
String selectedTempCheck = ""; 
bool isLoading = false;
late Map productTypes;
late Map deliveryAddresses;
late Map pickupAddresses;
List groupedConsignments = [];
String probeChecked = ""; 
//final _formKey = GlobalKey<FormBuilderState>();

late Map<String, dynamic> arguments;

class _ProofOfDeliveryPhotosState extends State<ProofOfDeliveryPhotos> {
   late GlobalKey<FormBuilderState> _formKey;
  @override
  void initState() {
    super.initState();
      _formKey = GlobalKey<FormBuilderState>();
    productTypes = Get.arguments['product_types'].runtimeType == String
        ? json.decode(Get.arguments['product_types'])
        : Get.arguments['product_types'];
    deliveryAddresses =
        Get.arguments['delivery_addresses'].runtimeType == String
            ? json.decode(Get.arguments['delivery_addresses'])
            : Get.arguments['delivery_addresses'];
    pickupAddresses = Get.arguments['pickup_addresses'].runtimeType == String
        ? json.decode(Get.arguments['pickup_addresses'])
        : Get.arguments['pickup_addresses'];
    if (Get.arguments?['grouped_consignments'] != null) {
      groupedConsignments = json.decode(
        Get.arguments?['grouped_consignments'],
      );
    }
    arguments = (Get.arguments != null)
        ? Map<String, dynamic>.from(Get.arguments)
        : {};
    debugPrint("our group data: ${Get.arguments['is_group']}");
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<ProofOfDeliveryProvider>(context);
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
    final String? rejectionReason = provider.data['rejection_reason'];
    bool isNoDelivery = provider.selectedDeliveryType == DeliveryType.none;
    bool isPickup = arguments['consignment_type'] == 'pickup';
    String appBarTitle = isPickup ? 'Pickup' : 'Delivery';

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          //  provider.backToDefault();
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
          )
        ],
        centerTitle: true,
        title:  Text(
          appBarTitle,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: SingleChildScrollView(
            child: Center(
              child: FormBuilder(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IntrinsicHeight(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'ID: ${Get.arguments?['id'] ?? 'Not Provided'}',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          VerticalDivider(
                            color: AppColors.black.withOpacity(0.5),
                            thickness: 2,
                          ),
                          Text(
                            'REF: ${Get.arguments?['customer_reference'] ?? 'Not Provided'}',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          InkWell(
                            onTap: () {},
                            child: Container(
                              width: 13.5.w,
                              height: 6.h,
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(50.sp),
                                border: Border.all(),
                              ),
                              child: Image.asset(
                                AppImages.map,
                                color: AppColors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 2.h),
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
                                (Get.arguments?['consignment_type'] == 'delivery'
                                        ? deliveryAddresses['company_name']
                                        : pickupAddresses['company_name']) ??
                                    'Not Provided',
                                style: Theme.of(context).textTheme.headlineMedium,
                              ),
                              Text(
                                'Recipient: ${(Get.arguments?['consignment_type'] == 'delivery' ? deliveryAddresses['customer_name'] : pickupAddresses['customer_name']) ?? 'Not Provided'}',
                                style: Theme.of(context).textTheme.bodySmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                Get.arguments?['consignment_type'] == 'delivery'
                                    ? '${deliveryAddresses['street_address']}, ${deliveryAddresses['suburb']}'
                                    : '${pickupAddresses['street_address']}, ${pickupAddresses['suburb']}',
                                style: Theme.of(context).textTheme.bodySmall,
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
                    SizedBox(height: 2.h),
                    const Divider(
                      height: 1,
                      thickness: 2,
                      color: AppColors.grey,
                    ),
                    SizedBox(height: 1.h),
                     if (rejectionReason == 'Damaged Goods')
                    Column(
                      children: [
                        Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  PalletContainer(
                                    name: 'nocartons',
                                    heading: AppText.cartons,
                                    icon: SvgPicture.asset(AppSvgs.boundpallets),
                                    hintText: '0',
                                    initialValue: int.tryParse(context
                                                .read<ProofOfDeliveryProvider>()
                                                .data['carton']
                                                ?.toString() ??
                                            '0') ??
                                        0,
                                    totalPallet: int.tryParse(Get
                                                .arguments?['carton']
                                                ?.toString() ??
                                            '0') ??
                                        0,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 4.w,
                                      vertical: 0,
                                    ),
                                  ),
                                  
                                  Row(
                                    children: [
                                      PalletContainer(
                                    name: 'nopallet',
                                    heading: AppText.pallets,
                                    hintText: '0',
                                    initialValue: int.tryParse(context
                                                .read<ProofOfDeliveryProvider>()
                                                .data['pallet']
                                                ?.toString() ??
                                            '0') ??
                                        0,
                                    totalPallet: int.tryParse(Get
                                                .arguments?['pallet']
                                                ?.toString() ??
                                            '0') ??
                                        0,
                                  ),
                                    ],
                                  )
                                ],
                              ),
                              PalletContainer(
                                    name: 'nopspace',
                                    heading: AppText.space,
                                    hintText: '0',
                                    initialValue: int.tryParse(context
                                                .read<ProofOfDeliveryProvider>()
                                                .data['space']
                                                ?.toString() ??
                                            '0') ??
                                        0,
                                    totalPallet: int.tryParse(Get
                                                .arguments?['space']
                                                ?.toString() ??
                                            '0') ??
                                        0,
                                  ),
                    
                      ],
                    ),
                     if (rejectionReason == 'Temperature issue')
                     Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(
                          "Customer Probe Checked?",
                          style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        SizedBox(height: 1.h),
                        
                       Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text("Yes"),
                            value: "Yes",
                            groupValue: provider.probeChecked,
                            onChanged: (value) {
                provider.setProbeChecked(value!);
                print('Customer Probe Checked: ${provider.probeChecked}');
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text("No"),
                            value: "No",
                            groupValue: provider.probeChecked,
                            onChanged: (value) {
                provider.setProbeChecked(value!);
                print('Customer Probe Checked: ${provider.probeChecked}');
                            },
                          ),
                        ),
                      ],
                       ),
                        
                        SizedBox(height: 1.h),
                
                        // If "No" is selected, show the text field for further details
                        if (provider.probeChecked == "No")
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                Text(
                  "Why? Please provide details:",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                SizedBox(height: 1.h),
                Container(
                  height: 10.h,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.navyBlue),
                    borderRadius: BorderRadius.all(
                      Radius.circular(5.sp),
                    ),
                  ),
                  padding: EdgeInsets.symmetric(
                    vertical: 1.h, horizontal: 2.w),
                  child: CustomTextField(
                    borderColor: AppColors.white,
                    name: 'why',
                    hintText: "Provide reason for not checking the customer probe",
                    onChanged: (value) {
                      context
                          .read<ProofOfDeliveryProvider>()
                          .data['customer_probe_why'] = value;
                      print('Reason: $value'); 
                    },
                  ),
                ),
                            ],
                          ),
                
                        SizedBox(height: 1.h),
                  SizedBox(height: 1.h,),
                     Row(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                          "Custumer Probe Temp",
                            style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                            
                        ),
                           Row(
                            children: [
                              Container(
                              height: 5.h,
                              width: 12.w,
                               child: Center(
                                 child: CustomTextField(
                                        name: 'CustumerProbeTemp',
                                        hintText: "2",
                                         textInputAction: TextInputAction.done,
                                          keyboardType: TextInputType.number,
                                        validator: (value) {
                                        if (value == null || value.isEmpty) {
                                         return 'First Name is required! Also fill last name again'; 
                                           }
                                            return null;
                                             },
                                        onChanged: (value) {
                                         context.read<ProofOfDeliveryProvider>().updateField('customer_probe_temp', value);
                                               
                                        },
                                      ),
                               ),
                                                     ),
                                                     SizedBox(width: 1.w,),
                                                    Text("°C"),
                            ],
                          ),
                  ],
                ),
                  SizedBox(height: 1.h,),   
                     Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       children: [
                         Text(
                          "Driver Probe Temp",
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                                           ),
                                  Row(
                            children: [
                              Container(
                              height: 5.h,
                              width: 12.w,
                               child: Center(
                                 child: CustomTextField(
                                        name: 'Driverprobetemp',
                                        hintText: "2",
                                         textInputAction: TextInputAction.done,
                                          keyboardType: TextInputType.number,
                                        validator: (value) {
                                        if (value == null || value.isEmpty) {
                                         return 'First Name is required! Also fill last name again'; 
                                           }
                                            return null;
                                             },
                                        onChanged: (value) {
                                         context.read<ProofOfDeliveryProvider>().updateField('driver_probe_temp', value);
                                               
                                        },
                                      ),
                               ),
                                                     ),
                                                     SizedBox(width: 1.w,),
                                                    Text("°C"),
                            ],
                          ),
                       ],
                     ),
                  SizedBox(height: 1.h,),
                     Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Driver infrared Temp",
                            style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                        ),
                          Row(
                            children: [
                              Container(
                              height: 5.h,
                              width: 12.w,
                               child: Center(
                                 child: CustomTextField(
                                        name: 'driverinfraredtemp',
                                        hintText: "2",
                                         textInputAction: TextInputAction.done,
                                          keyboardType: TextInputType.number,
                                        validator: (value) {
                                        if (value == null || value.isEmpty) {
                                         return 'First Name is required! Also fill last name again'; 
                                           }
                                            return null;
                                             },
                                        onChanged: (value) {
                                         context.read<ProofOfDeliveryProvider>().updateField('driver_infrared_temp', value);
                                               
                                        },
                                      ),
                               ),
                                                     ),
                                                     SizedBox(width: 1.w,),
                                                    Text("°C"),
                            ],
                          ),
                      ],
                    ),
                     SizedBox(height: 1.h),
                    CustomDropdown(
                      name: "tempcheck",
                      fillColor: AppColors.white,
                       hintWidget:Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.green,
                                    radius: 3.sp,
                                  ),
                                  SizedBox(
                                    width: 2.w,
                                  ),
                                  const Text('Vehicle',style: TextStyle(
                                    color: AppColors.black
                                  ),),
                                ],
                              ),
                      items: [
                        DropdownMenuItem(
                          value: "Vehicle",
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.green,
                                radius: 3.sp,
                              ),
                              SizedBox(
                                width: 2.w,
                              ),
                              const Text('Vehicle'),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: "Freezer",
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.green,
                                radius: 3.sp,
                              ),
                              SizedBox(
                                width: 2.w,
                              ),
                              const Text('Freezer'),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: "Other",
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.green,
                                radius: 3.sp,
                              ),
                              SizedBox(
                                width: 2.w,
                              ),
                              const Text('Other'),
                            ],
                          ),
                        ),
                      ],
                      onChanged: (value) {
                     
                          selectedTempCheck = value!;
                          print('Selected: $selectedTempCheck'); 
                       
                      },
                    
                    ),
                      ],
                     ),
                    
                    
                              
                    SizedBox(height: 3.h),
                    Text(
                      "Photo Evidence",
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: 1.h),
                    GestureDetector(
                      onTap: () {
                        _takePhoto();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.navyBlue),
                          borderRadius: BorderRadius.all(
                            Radius.circular(10.sp),
                          ),
                        ),
                        child: SizedBox(
                          width: 92.w,
                          height: 18.h,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 6.5.w,
                                backgroundColor: AppColors.greyWhite,
                                child: Icon(
                                  Icons.camera_alt_rounded,
                                  color: AppColors.blue,
                                  size: 24.sp,
                                ),
                              ),
                              SizedBox(height: 0.5.h),
                              Text(
                                AppText.takePhoto,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: AppColors.blue,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Row(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: context
                                  .read<ProofOfDeliveryProvider>()
                                  .images
                                  .map(
                                    (image) => Padding(
                                      padding: EdgeInsets.only(right: 2.w),
                                      child: Container(
                                        height: 13.h,
                                        width: 28.w,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5.sp),
                                          image: DecorationImage(
                                            image: FileImage(File(image.path)),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              context
                                                  .read<ProofOfDeliveryProvider>()
                                                  .removeImage(image: image);
                                            });
                                          },
                                          child: const Align(
                                            alignment: Alignment.topRight,
                                            child: Icon(
                                              Icons.cancel,
                                              color: AppColors.blue,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 3.h),
                    // Ensure that delivery type is not 'none'
                if (provider.selectedDeliveryType != DeliveryType.none)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Other Information",
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      Stack(
                        children: [
                          Container(
                            height: 15.h,
                            decoration: BoxDecoration(
                border: Border.all(color: AppColors.navyBlue),
                borderRadius: BorderRadius.all(
                  Radius.circular(5.sp),
                ),
                            ),
                            padding: EdgeInsets.symmetric(
                  vertical: 1.h, horizontal: 2.w),
                            child: CustomTextField(
                borderColor: AppColors.white,
                name: 'commentspho',
                hintText: "Enter Text",
                onChanged: (value) {
                  context
                      .read<ProofOfDeliveryProvider>()
                      .data['comments'] = value;
                },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                
                    SizedBox(height: 1.h),
                
                    // Conditionally show rejection reason text and TextField
                    if (isNoDelivery && rejectionReason != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Text(
                          //   "Rejection Reason: $rejectionReason",
                          //   style: Theme.of(context)
                          //       .textTheme
                          //       .headlineSmall
                          //       ?.copyWith(fontWeight: FontWeight.bold),
                          // ),
                          SizedBox(height: 1.h),
                          if (rejectionReason == 'Other Rejection' ||
                              rejectionReason == 'Wrong Address' ||
                              rejectionReason == 'Receiver Not Open')
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Please provide more details:",
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                SizedBox(height: 1.h),
                                Stack(
                                  children: [
                                    Container(
                                      height: 15.h,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: AppColors.navyBlue),
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(5.sp),
                                        ),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        vertical: 1.h, horizontal: 2.w),
                                      child: CustomTextField(
                                        borderColor: AppColors.white,
                                        name: 'rejection_details',
                                        hintText: "Enter details for $rejectionReason",
                                        onChanged: (value) {
                                          provider.data['rejection_details'] = value;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                        ],
                      ),
                 SizedBox(height: 1.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(
                          width: 50.w,
                          child: 
                         CustomButton(
  label: "Submit POD",
  onPressed: provider.images.isNotEmpty
    ? () {
        if (_formKey.currentState!.saveAndValidate()) {
          // Create the temp map that will hold all the fields that need to be sent
          final Map<String, dynamic> temp = {
            "pictures": jsonEncode(provider.base64Images),
            "pictureSources": jsonEncode(provider.pictureSources),
            "comments": _formKey.currentState!.fields['commentspho']?.value?.toString(),
          };

          if (provider.selectedDeliveryType == DeliveryType.none || provider.data['rejection_reason'] == 'Temperature issue') {
  temp.addAll({
    "customer_probe_checked": provider.probeChecked,
    "customer_probe_temp": _formKey.currentState!.fields['CustumerProbeTemp']?.value != null
        ? int.tryParse(_formKey.currentState!.fields['CustumerProbeTemp']!.value.toString()) ?? 0
        : 0, 
    "driver_probe_temp": _formKey.currentState!.fields['Driverprobetemp']?.value != null
        ? int.tryParse(_formKey.currentState!.fields['Driverprobetemp']!.value.toString()) ?? 0
        : 0, 
    "driver_infrared_temp": _formKey.currentState!.fields['driverinfraredtemp']?.value != null
        ? int.tryParse(_formKey.currentState!.fields['driverinfraredtemp']!.value.toString()) ?? 0
        : 0, 
    "customer_probe_why": _formKey.currentState!.fields['why']?.value?.toString(),
    "where_temp_checked": selectedTempCheck,
  });
}


          if (provider.selectedDeliveryType == DeliveryType.none || provider.data['rejection_reason'] == 'Damaged Goods') {
            temp.addAll({
              "customer_probe_checked": "",  
              "customer_probe_temp": null,   
              "driver_probe_temp": null,    
              "driver_infrared_temp": null,  
              "customer_probe_why": "",      
              "where_temp_checked": "",
              "carton": int.tryParse(_formKey.currentState!.fields['nocartons']?.value ?? '0') ?? 0,
              "pallet": int.tryParse(_formKey.currentState!.fields['nopallet']?.value ?? '0') ?? 0,
              "space": int.tryParse(_formKey.currentState!.fields['nospace']?.value ?? '0') ?? 0,
            });
          }
            if (provider.selectedDeliveryType == DeliveryType.none || provider.data['rejection_reason'] == 'Wrong Address'|| provider.data['rejection_reason'] == 'Other Rejection'|| provider.data['rejection_reason'] == 'Receiver Not Open') {
            temp.addAll({
              "customer_probe_checked": "",  
              "customer_probe_temp": null,   
              "driver_probe_temp": null,     
              "driver_infrared_temp": null,  
              "customer_probe_why": "",     
              "where_temp_checked": "",
              "comments": _formKey.currentState!.fields['rejection_details']?.value?.toString(),
            });
          }
          

          provider.addEntities(temp.entries);

          Provider.of<TaskSyncpofProvider>(context, listen: false).submitData(context);
        } else {
          print("Form is not valid");
        }
      }
    : () {
        print("Submit POD button pressed but no images are available.");
      },
  backgroundColor: provider.images.isNotEmpty ? AppColors.blue : AppColors.grey,
  borderColor: provider.images.isNotEmpty ? AppColors.blue : AppColors.grey,
),

                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      endDrawer: const CustomDrawer(),
    );
  }

  Future<void> _takePhoto() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(
        imageQuality: 10,
        source: ImageSource.camera,
      );

      if (image != null) {
        debugPrint('Picked Image: ${image.path}');
        Uint8List bytes = await image.readAsBytes();
        String base64String = 'data:image/jpeg;base64,${base64Encode(bytes)}';
        debugPrint('Base64 Image: $base64String');

        setState(() {
          context.read<ProofOfDeliveryProvider>().addImage(
            image: image,
            base64String: base64String,
            source: 'By Camera',
          );
        });
      }
    } catch (e) {
      debugPrint('Error picking image from camera: $e');
    }
  }
}
