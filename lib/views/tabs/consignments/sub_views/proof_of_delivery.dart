import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:coldxpress/export.dart';
import 'package:coldxpress/providers/proof-of-delivery-provider.dart';
import 'package:coldxpress/views/tabs/consignments/sub_views/clock.dart';


class ProofOfDeliveryView extends StatefulWidget {
  const ProofOfDeliveryView({Key? key}) : super(key: key);

  @override
  State<ProofOfDeliveryView> createState() => _ProofOfDeliveryViewState();
}

class _ProofOfDeliveryViewState extends State<ProofOfDeliveryView> {
  final SignatureController controller = SignatureController(
    penStrokeWidth: 3,
    penColor: AppColors.black,
    exportBackgroundColor: AppColors.white,
  );
  


final TextEditingController serviceTimeController = TextEditingController();

@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
   serviceTimeController.text = '${context.read<TimeProvider>().startTime.h}:${context.read<TimeProvider>().startTime.m} - ${context.read<TimeProvider>().endTime.h}:${context.read<TimeProvider>().endTime.m}';

  });
}


@override
void didChangeDependencies() {
  super.didChangeDependencies();
  serviceTimeController.text = '${context.read<TimeProvider>().startTime.h}:${context.read<TimeProvider>().startTime.m} - ${context.read<TimeProvider>().endTime.h}:${context.read<TimeProvider>().endTime.m}';
}
bool isLoading =false;
 



  @override
  Widget build(BuildContext context) {
      var provider = Provider.of<ProofOfDeliveryProvider>(context);

//only working for the no delivery---
 Future<void> postData() async {
  setState(() {
    isLoading = true;
  });
  AuthenticationState state =
      BlocProvider.of<AuthenticationCubit>(context).state;
  if (state is Authenticated) {
    try {
      Map<String, dynamic> requestBody = {};
      String url = ''; 

      switch (provider.selectedDeliveryType) {
        case DeliveryType.full:
          requestBody = {
            //'pod_type': provider.selectedDeliveryType.toString(),
            'pod_type': 'full',
            'palletValue': provider.palletValue,
            'cartonsValue': provider.cartonsValue,
            'showSignature': provider.showSignature,
            'temperature': provider.temperature,
            'serviceTime': provider.serviceTime,
            'lengthOfDelivery': provider.lengthOfDelivery,
            'receiverFirstName': provider.receiverFirstName,
            'receiverLastName': provider.receiverLastName,
            'images': provider.base64Images.values.toList(),
            "otherinfo": provider.otherinfo,
          };
          url = AppHost.podfull;
          break;
        case DeliveryType.partial:
          requestBody = {
            'pod_type': 'partial',
            'palletValue': provider.palletValue,
            'cartonsValue': provider.cartonsValue,
            'showSignature': provider.showSignature,
            'temperature': provider.temperature,
            'serviceTime': provider.serviceTime,
            'lengthOfDelivery': provider.lengthOfDelivery,
            'receiverFirstName': provider.receiverFirstName,
            'receiverLastName': provider.receiverLastName,
            'reasonpartialdelivery': provider.reasonpartialdelivery,
            'images': provider.base64Images.values.toList(),
            "otherinfo": provider.otherinfo,
          };
          url = AppHost.podpartial;
          break;
        case DeliveryType.none:
  List<String> rejectionReasons =
      provider.selectedOrderRejectionReasons as List<String>;
  for (String rejectionReason in rejectionReasons) {
    print('Rejection Reason: $rejectionReason');
    switch (rejectionReason) {
      case "Temperature issue":
        requestBody = {
          'pod_type': 'none',
          'temperature_issue': true,
        };
        url = AppHost.temperateissue;
        break;
      case "Wrong Address":
        requestBody = {
          'pod_type': 'none',
          'wrong_address': true,
        };
        url = AppHost.wrongaddress;
        break;
      case "Damaged Goods":
        requestBody = {
          'pod_type': 'none',
          'damage_goods': true,
        };
        url = AppHost.damagegoods;
        break;
      case "Receiver Not Open":
        requestBody = {
          'pod_type': 'none',
          'receiver_not': true,
        };
        url = AppHost.notopen;
        break;
      case "Other Rejection":
        requestBody = {
          'pod_type': 'none',
          'other_rejection': true,
          'reason': provider.orderRejectionReason,
        };
        url = AppHost.otherrejection;
        break;
      default:
        throw Exception('Invalid rejection reason: $rejectionReason');
    }
  }
  break;
      }
      print('Request Body: $requestBody');
      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Authorization': 'Bearer ${state.token}',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              icon: SizedBox(
                height: 20.w,
                width: 20.w,
                child: const Image(
                  image: AssetImage(AppImages.checkmark),
                  color: Colors.green,
                ),
              ),
              title: Text(
                'Your Outbound pallets have been submitted successfully',
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              titlePadding: EdgeInsets.symmetric(
                vertical: 1.h,
                horizontal: 2.w,
              ),
              iconPadding: EdgeInsets.symmetric(vertical: 1.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.sp),
              ),
              backgroundColor: AppColors.white,
              actions: <Widget>[
                Center(
                  child: CustomButton(
                    height: 5.h,
                    width: 30.w,
                    label: 'CLOSE',
                    backgroundColor: AppColors.blue,
                    borderColor: AppColors.blue,
                    foregroundColor: AppColors.white,
                    onPressed: () async {
                      context.read<ProofOfDeliveryProvider>().clearFormData();
                      Get.offAllNamed(AppRoutes.dashboard);
                    },
                  ),
                ),
              ],
            );
          },
        );
      } else {
        setState(() {
          isLoading = false;
        });
        final Map<String, dynamic> responseData =
            json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: AppColors.red,
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    responseData['message'].trim(),
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: AppColors.red),
                  ),
                ),
              ],
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0),
            ),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.lightRed,
            margin: EdgeInsets.only(bottom: 2.h),
          ),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint(e.toString());
    }
  }
}

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
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
          AppText.proofOfDelivery,
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
                            'ID: 123456',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          VerticalDivider(
                            color: AppColors.black.withOpacity(0.5),
                            thickness: 2,
                          ),
                          Text(
                            'REF: 1234',
                            style: Theme.of(context).textTheme.headlineSmall,
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
                              borderRadius: BorderRadius.circular(50.sp),
                              border: Border.all()),
                          child: SvgPicture.asset(
                            AppSvgs.journey,
                            color: AppColors.blue,
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
                                child: Image.asset(AppImages.cardboard))),
                      ),
                      SizedBox(
                        width: 54.w,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ritchies IGA',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            Text(
                              'Recipient: Drew Moran 830 Wellington road, Rowville',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
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
                  const Divider(),
                  SizedBox(
                    height: 2.h,
                  ),
                  Text(
                    AppText.selectDeliveryType,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  SizedBox(
                    height: 1.h,
                  ),
                 CustomDropdown(
  name: 'deliveryType',
  hintText: 'Please Select',
  fillColor: AppColors.white,
  value: Provider.of<ProofOfDeliveryProvider>(context).selectedDeliveryType,
  onChanged: (newValue) {
    context.read<ProofOfDeliveryProvider>().updateSelectedDeliveryType(newValue!);

  },
  items: [
    DropdownMenuItem(
      value: DeliveryType.full,
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.green,
            radius: 3.sp,
          ),
          SizedBox(
            width: 2.w,
          ),
          const Text('Full Delivery'),
        ],
      ),
    ),
    DropdownMenuItem(
      value: DeliveryType.partial,
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.yellow,
            radius: 3.sp,
          ),
          SizedBox(
            width: 2.w,
          ),
          const Text('Partial Delivery'),
        ],
      ),
    ),
    DropdownMenuItem(
      value: DeliveryType.none,
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.red,
            radius: 3.sp,
          ),
          SizedBox(
            width: 2.w,
          ),
          const Text('No Delivery'),
        ],
      ),
    ),
  ],
),
SizedBox(
  height: 2.h,
),

  if (Provider.of<ProofOfDeliveryProvider>(context).selectedDeliveryType == DeliveryType.full)
     Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        AppText.howManyDelivered,
        style: Theme.of(context).textTheme.headlineMedium,
      ),
      SizedBox(
        height: 1.h,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          PalletContainer(
            name: 'cartons',
            heading: AppText.cartons,
            icon: SvgPicture.asset(AppSvgs.pallet),
            hintText: '0',
            initialValue:
                Provider.of<ProofOfDeliveryProvider>(context).cartonsValue,
            totalPallet: 5,
            onValueChanged: (value) {
              Provider.of<ProofOfDeliveryProvider>(context, listen: false)
                  .updateCartonsValue(value);
            },
          ),
          PalletContainer(
            name: 'pallets',
            heading: AppText.pallets,
            hintText: '0',
            initialValue:
                Provider.of<ProofOfDeliveryProvider>(context).palletValue,
            totalPallet: 5,
            onValueChanged: (value) {
              Provider.of<ProofOfDeliveryProvider>(context, listen: false)
                  .updatePalletValue(value);
            },
          ),
        
    
        ],
      ),
      SizedBox(
        height: 3.h,
      ),
      Text(
        AppText.deliveryTemperature,
        style: Theme.of(context).textTheme.headlineMedium,
      ),
      SizedBox(
        height: 1.h,
      ),
      CustomTextField(
        name: 'temp',
        hintText: AppText.temperature,
        keyboardType: TextInputType.number,
        suffixIcon: Padding(
          padding:
              EdgeInsets.symmetric(vertical: 2.h, horizontal: 2.w),
          child: Text(
            AppText.celsius,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
        onChanged: (value) {
   Provider.of<ProofOfDeliveryProvider>(context, listen: false).updateTempValidity(value!.isNotEmpty);
    Provider.of<ProofOfDeliveryProvider>(context, listen: false)
      .updateDeliveryFormData(temperature: value);
  },
),
      SizedBox(
        height: 3.h,
      ),
      Text(
        AppText.serviceTime,
        style: Theme.of(context).textTheme.headlineMedium,
      ),
      SizedBox(
        height: 1.h,
      ),
     CustomTextField(
  name: 'serviceTime',
  keyboardType: TextInputType.number,
  readOnly: true,
  hintText:  '${Provider.of<TimeProvider>(context).startTime.h}:${Provider.of<TimeProvider>(context).startTime.m} - ${Provider.of<TimeProvider>(context).endTime.h}:${Provider.of<TimeProvider>(context).endTime.m}',
        controller:  serviceTimeController,
  onTap: () {
    Get.toNamed(AppRoutes.Stopwatch);
   
  },
  suffixIcon: Padding(
    padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 2.w),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
         Text(
          AppText.editHours,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.black.withOpacity(0.5),
            fontWeight: FontWeight.w500,
          ),
        ),
       
        Icon(
          Icons.arrow_forward_ios,
          size: 2.h,
          color: AppColors.black.withOpacity(0.5),
        )
      ],
    ),
  ),
     onChanged: (value) {
        Provider.of<ProofOfDeliveryProvider>(context, listen: false).updateServiceTimeValidity(value!.isNotEmpty);
   Provider.of<ProofOfDeliveryProvider>(context, listen: false)
    .updateDeliveryFormData(serviceTime: value);
  },
),

      SizedBox(
        height: 1.h,
      ),
      CustomTextField(
        name: 'lengthOfDelivery',
        hintText: AppText.lengthOfDelivery,
        keyboardType: TextInputType.number,
        suffixIcon: Padding(
          padding:
              EdgeInsets.symmetric(vertical: 2.h, horizontal: 2.w),
          child: Text(
            AppText.minutes,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
           onChanged: (value) {
             Provider.of<ProofOfDeliveryProvider>(context, listen: false).updateLengthOfDeliveryValidity(value!.isNotEmpty);
   Provider.of<ProofOfDeliveryProvider>(context, listen: false)
    .updateDeliveryFormData(lengthOfDelivery: value);
  },
      ),
      SizedBox(
        height: 3.h,
      ),
      Text(
        AppText.receiverConfirmation,
        style: Theme.of(context).textTheme.headlineMedium,
      ),
      SizedBox(
        height: 1.h,
      ),
       CustomTextField(
        name: 'receiverFirstName',
        hintText: AppText.receiverFirstName,
           onChanged: (value) {
             Provider.of<ProofOfDeliveryProvider>(context, listen: false).updateReceiverFirstNameValidity(value!.isNotEmpty);
   Provider.of<ProofOfDeliveryProvider>(context, listen: false)
    .updateDeliveryFormData(receiverFirstName: value);
  },
      ),
      SizedBox(
        height: 1.h,
      ),
       CustomTextField(
        name: 'receiverLastName',
        hintText: AppText.receiverLastName,
           onChanged: (value) {
           Provider.of<ProofOfDeliveryProvider>(context, listen: false).updateReceiverLastNameValidity(value!.isNotEmpty);
   Provider.of<ProofOfDeliveryProvider>(context, listen: false)
    .updateDeliveryFormData(receiverLastName: value);
  },
      ),
      SizedBox(
        height: 1.h,
      ),
Consumer<ProofOfDeliveryProvider>(
  builder: (context, provider, _) {
    return SizedBox(
      width: 90.w,
      child: GestureDetector(
        onTap: () {
          if (!provider.showSignature) {
            provider.setShowSignature(true);
            provider.showSignaturePopup(context, controller);
          }
        },
        child: Stack(
          children: [
            if (controller.isEmpty && !provider.showSignature)
              Container(
                height: 25.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.navyBlue),
                  borderRadius: BorderRadius.all(
                    Radius.circular(5.sp),
                  ),
                ),
                padding: EdgeInsets.symmetric(
                  vertical: 1.h,
                  horizontal: 2.w,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 50.sp,
                      height: 50.sp,
                      child: Image.asset(
                        AppImages.handWithPen,
                      ),
                    ),
                    Text(
                      AppText.tapHereToSign,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    )
                  ],
                ),
              ),
            if (provider.showSignature)
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.navyBlue),
                  borderRadius: BorderRadius.all(
                    Radius.circular(5.sp),
                  ),
                ),
                padding: EdgeInsets.symmetric(
                  vertical: 1.h,
                  horizontal: 2.w,
                ),
                child: Column(
                  children: [
                    Signature(
                      controller: controller,
                      width: 90.w,
                      height: 20.h,
                      backgroundColor: Colors.transparent,
                    ),
                    const Divider(
                      height: 1,
                      thickness: 2,
                      color: AppColors.grey,
                    ),
                    CupertinoButton(
                      child: const Text(
                        "Redo",
                        style: TextStyle(color: Colors.blue),
                      ),
                      onPressed: () {
                        provider.clearSignatureAndShowPopup(context, controller);
                      },
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  },
),

     
      SizedBox(
        height: 1.h,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
         SizedBox(
          width: 50.w,
          child: Consumer<ProofOfDeliveryProvider>(
            builder: (context, provider, _) => CustomButton(
              label: "Next",
              onPressed: () {
                if (provider.isTempValid &&
                    provider.isServiceTimeValid &&
                    provider.isLengthOfDeliveryValid &&
                    provider.isReceiverFirstNameValid &&
                    provider.isReceiverLastNameValid) {
                  if (provider.selectedDeliveryType == DeliveryType.full &&
                      (provider.palletValue < 5 || provider.cartonsValue < 5)) {
           showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    icon: SizedBox(
                      height: 20.w,
                      width: 20.w,
                      child: const Image(
                        image: AssetImage(AppImages.brakeWarning),
                      ),
                    ),
                    title: Text(
                      "You are missing 2 cartons. Please fix this mistake or change to “Partial Delivery”.",
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(fontWeight: FontWeight.w700),
                      textAlign: TextAlign.center,
                    ),
                    titlePadding: EdgeInsets.symmetric(
                      vertical: 1.h,
                      horizontal: 2.w,
                    ),
                    iconPadding: EdgeInsets.symmetric(vertical: 1.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.sp),
                    ),
                    backgroundColor: AppColors.white,
                    actions: <Widget>[
                      SizedBox(height: 2.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          CustomButton(
                            height: 5.h,
                            width: 30.w,
                            label: 'Edit',
                            backgroundColor: AppColors.white,
                            borderColor: AppColors.yellow,
                            foregroundColor: AppColors.black,
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    ],
                  );
                },
          );
        } else {
          // Provider.of<ProofOfDeliveryProvider>(context, listen: false)
          //     .saveData();
          //    // postData();
             Get.toNamed(AppRoutes.podphotos);
            
        
        }
      }
    },
      backgroundColor: provider.isTempValid &&
                      provider.isServiceTimeValid &&
                      provider.isLengthOfDeliveryValid &&
                      provider.isReceiverFirstNameValid &&
                      provider.isReceiverLastNameValid
                  ? AppColors.blue 
                  : AppColors.grey, 
              borderColor: provider.isTempValid &&
                      provider.isServiceTimeValid &&
                      provider.isLengthOfDeliveryValid &&
                      provider.isReceiverFirstNameValid &&
                      provider.isReceiverLastNameValid
                  ? AppColors.blue 
                  : AppColors.grey,
  ),
),

       
        )  ],
      ),
    
    ],
  ),

               if (provider.selectedDeliveryType == DeliveryType.partial)
                  Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        AppText.howManyDelivered,
        style: Theme.of(context).textTheme.headlineMedium,
      ),
      SizedBox(
        height: 1.h,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          PalletContainer(
            name: 'cartons',
            heading: AppText.cartons,
            icon: SvgPicture.asset(AppSvgs.pallet),
            hintText: '0',
            initialValue: 0,
            totalPallet: 5, onValueChanged: (value) {
              Provider.of<ProofOfDeliveryProvider>(context, listen: false)
                  .updateCartonsValue(value);
            },
          ),
           PalletContainer(
            name: 'pallets',
            heading: AppText.pallets,
            hintText: '0',
            initialValue: 0,
            totalPallet: 5,
             onValueChanged: (value) {
              Provider.of<ProofOfDeliveryProvider>(context, listen: false)
                  .updatePalletValue(value);
            },
          ),
        ],
      ),
         SizedBox(
        height: 3.h,
      ),
      Text(
        "Reason for partial delivery",
        style: Theme.of(context).textTheme.headlineMedium,
      ),

      SizedBox(
        height: 1.h,
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
        name: 'Reasonpartaial',
        hintText: "Lorem ipsum dolor sit amet consectetur. Leo laoreet malesuada eget ipsum.",
       
    
         onChanged: (value) {
           Provider.of<ProofOfDeliveryProvider>(context, listen: false).updateisReasonPartialValidity(value!.isNotEmpty);
   
   Provider.of<ProofOfDeliveryProvider>(context, listen: false)
    .updateDeliveryFormData(reasonpartialdelivery: value);
  },
      ),
            
          ),
        ],
      ),
      SizedBox(
        height: 3.h,
      ),
      Text(
        AppText.deliveryTemperature,
        style: Theme.of(context).textTheme.headlineMedium,
      ),
      SizedBox(
        height: 1.h,
      ),
      CustomTextField(
        name: 'temp',
        hintText: AppText.temperature,
        keyboardType: TextInputType.number,
        suffixIcon: Padding(
          padding:
              EdgeInsets.symmetric(vertical: 2.h, horizontal: 2.w),
          child: Text(
            AppText.celsius,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
        onChanged: (value) {
   Provider.of<ProofOfDeliveryProvider>(context, listen: false).updateTempValidity(value!.isNotEmpty);
    Provider.of<ProofOfDeliveryProvider>(context, listen: false)
      .updateDeliveryFormData(temperature: value);
  },
),
      SizedBox(
        height: 3.h,
      ),
      Text(
        AppText.serviceTime,
        style: Theme.of(context).textTheme.headlineMedium,
      ),
      SizedBox(
        height: 1.h,
      ),
     CustomTextField(
  name: 'serviceTime',
  keyboardType: TextInputType.number,
  readOnly: true,
  hintText:  '${Provider.of<TimeProvider>(context).startTime.h}:${Provider.of<TimeProvider>(context).startTime.m} - ${Provider.of<TimeProvider>(context).endTime.h}:${Provider.of<TimeProvider>(context).endTime.m}',
        controller:  serviceTimeController,
  onTap: () {
    Get.toNamed(AppRoutes.Stopwatch);
   
  },
  suffixIcon: Padding(
    padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 2.w),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
         Text(
          AppText.editHours,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.black.withOpacity(0.5),
            fontWeight: FontWeight.w500,
          ),
        ),
       
        Icon(
          Icons.arrow_forward_ios,
          size: 2.h,
          color: AppColors.black.withOpacity(0.5),
        )
      ],
    ),
  ),
     onChanged: (value) {
        Provider.of<ProofOfDeliveryProvider>(context, listen: false).updateServiceTimeValidity(value!.isNotEmpty);
   Provider.of<ProofOfDeliveryProvider>(context, listen: false)
    .updateDeliveryFormData(serviceTime: value);
  },
),

      SizedBox(
        height: 1.h,
      ),
      CustomTextField(
        name: 'lengthOfDelivery',
        hintText: AppText.lengthOfDelivery,
        keyboardType: TextInputType.number,
        suffixIcon: Padding(
          padding:
              EdgeInsets.symmetric(vertical: 2.h, horizontal: 2.w),
          child: Text(
            AppText.minutes,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
           onChanged: (value) {
             Provider.of<ProofOfDeliveryProvider>(context, listen: false).updateLengthOfDeliveryValidity(value!.isNotEmpty);
   Provider.of<ProofOfDeliveryProvider>(context, listen: false)
    .updateDeliveryFormData(lengthOfDelivery: value);
  },
      ),
      SizedBox(
        height: 3.h,
      ),
      Text(
        AppText.receiverConfirmation,
        style: Theme.of(context).textTheme.headlineMedium,
      ),
      SizedBox(
        height: 1.h,
      ),
       CustomTextField(
        name: 'receiverFirstName',
        hintText: AppText.receiverFirstName,
           onChanged: (value) {
             Provider.of<ProofOfDeliveryProvider>(context, listen: false).updateReceiverFirstNameValidity(value!.isNotEmpty);
   Provider.of<ProofOfDeliveryProvider>(context, listen: false)
    .updateDeliveryFormData(receiverFirstName: value);
  },
      ),
      SizedBox(
        height: 1.h,
      ),
       CustomTextField(
        name: 'receiverLastName',
        hintText: AppText.receiverLastName,
           onChanged: (value) {
           Provider.of<ProofOfDeliveryProvider>(context, listen: false).updateReceiverLastNameValidity(value!.isNotEmpty);
   Provider.of<ProofOfDeliveryProvider>(context, listen: false)
    .updateDeliveryFormData(receiverLastName: value);
  },
      ),
      SizedBox(
        height: 1.h,
      ),
Consumer<ProofOfDeliveryProvider>(
  builder: (context, provider, _) {
    return SizedBox(
      width: 90.w,
      child: GestureDetector(
        onTap: () {
          if (!provider.showSignature) {
            provider.setShowSignature(true);
            provider.showSignaturePopup(context, controller);
          }
        },
        child: Stack(
          children: [
            if (controller.isEmpty && !provider.showSignature)
              Container(
                height: 25.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.navyBlue),
                  borderRadius: BorderRadius.all(
                    Radius.circular(5.sp),
                  ),
                ),
                padding: EdgeInsets.symmetric(
                  vertical: 1.h,
                  horizontal: 2.w,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 50.sp,
                      height: 50.sp,
                      child: Image.asset(
                        AppImages.handWithPen,
                      ),
                    ),
                    Text(
                      AppText.tapHereToSign,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    )
                  ],
                ),
              ),
            if (provider.showSignature)
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.navyBlue),
                  borderRadius: BorderRadius.all(
                    Radius.circular(5.sp),
                  ),
                ),
                padding: EdgeInsets.symmetric(
                  vertical: 1.h,
                  horizontal: 2.w,
                ),
                child: Column(
                  children: [
                    Signature(
                      controller: controller,
                      width: 90.w,
                      height: 20.h,
                      backgroundColor: Colors.transparent,
                    ),
                    const Divider(
                      height: 1,
                      thickness: 2,
                      color: AppColors.grey,
                    ),
                    CupertinoButton(
                      child: const Text(
                        "Redo",
                        style: TextStyle(color: Colors.blue),
                      ),
                      onPressed: () {
                        provider.clearSignatureAndShowPopup(context, controller);
                      },
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  },
),
      SizedBox(
        height: 1.h,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(
            width: 50.w,
            child: CustomButton(label: "Next", onPressed: (){
              if (provider.isReasonPartialValid &&
                provider.isTempValid &&
                    provider.isServiceTimeValid &&
                    provider.isLengthOfDeliveryValid &&
                    provider.isReceiverFirstNameValid &&
                    provider.isReceiverLastNameValid
                    ) {
              // Provider.of<ProofOfDeliveryProvider>(context, listen: false).saveData();
              // postData();
              Get.toNamed(AppRoutes.podphotos)
              
              ;}},
            
            backgroundColor: provider.isReasonPartialValid &&
                      provider.isTempValid &&
                      provider.isServiceTimeValid &&
                      provider.isLengthOfDeliveryValid &&
                      provider.isReceiverFirstNameValid &&
                      provider.isReceiverLastNameValid
                  ? AppColors.blue 
                  : AppColors.grey, 
              borderColor:  provider.isReasonPartialValid &&
                      provider.isTempValid &&
                      provider.isServiceTimeValid &&
                      provider.isLengthOfDeliveryValid &&
                      provider.isReceiverFirstNameValid &&
                      provider.isReceiverLastNameValid
                  ? AppColors.blue 
                  : AppColors.grey, 
            ))
        ],
      ),

    ],
  ),
                 if (provider.selectedDeliveryType == DeliveryType.none)
                   Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        AppText.howManyDelivered,
        style: Theme.of(context).textTheme.headlineMedium,
      ),
      SizedBox(
        height: 1.h,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          PalletContainer(
            name: 'cartons',
            heading: AppText.cartons,
            icon: SvgPicture.asset(AppSvgs.pallet),
            hintText: '0',
            initialValue: 0,
            totalPallet: 5,
            isErrorState: true,
          ),
          const PalletContainer(
            name: 'pallets',
            heading: AppText.pallets,
            hintText: '0',
            initialValue: 0,
            totalPallet: 5,
            isErrorState: true,
          ),
        ],
      ),
      SizedBox(
        height: 3.h,
      ),
      Text(
        "Reason for non delivery",
        style: Theme.of(context).textTheme.headlineMedium,
      ),
      SizedBox(
        height: 1.h,
      ),
       Text(
        "Select a reason the delivery could not be completed. If you are unsure if you can complete the delivery please open the chat and message our admin staff.",
        style: Theme.of(context).textTheme.bodySmall,
      ),
      SizedBox(
        height: 3.h,
      ),
  Consumer<ProofOfDeliveryProvider>(
        builder: (context, provider, _) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
           
              CustomContainer(
                title: 'Wrong Address',
                description: 'Address is wrong or the location has closed',
              ),
              SizedBox(
      height: 3.h,
    ),
              CustomContainer(
                title: 'Receiver Not Open',
                description: 'The receiver is unable to receive goods',
              ),
              SizedBox(
      height: 3.h,
    ),
              CustomContainer(
     title: 'Temperature issue',
  description: 'The stock is not the correct temperature',
    ),
    SizedBox(
      height: 3.h,
    ),
    CustomContainer(
     title: 'Damaged Goods',
  description: 'The packaging or goods have been damaged',
    ),
    SizedBox(
      height: 3.h,
    ),
     CustomContainer(
      title: 'Other Rejection',
      description: 'The customer refused the goods ',
    )

            ]);}),


 
    

      SizedBox(
        height: 1.h,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(
            width: 50.w,
            child: CustomButton(label: "Submit POD", onPressed: (){
    postData();

            },backgroundColor: AppColors.red,borderColor: AppColors.red,)),
        ],
      ),
    ],
  ),
   
             SizedBox(
        height: 1.h,
      ),   ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

 class CustomContainer extends StatefulWidget {
  final String title;
  final String description;

  const CustomContainer({
    Key? key,
    required this.title,
    required this.description,
  }) : super(key: key);

  @override
  _CustomContainerState createState() => _CustomContainerState();
}

class _CustomContainerState extends State<CustomContainer> {
  @override
  Widget build(BuildContext context) {
    final provider =
        Provider.of<ProofOfDeliveryProvider>(context, listen: false);
    bool isChecked = provider.selectedOrderRejectionReasons.contains(widget.title);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (!isChecked) {
            provider.clearOrderRejectionReasons();
            provider.updateOrderRejectionReason(widget.title);
          } else {
            provider.updateOrderRejectionReason('');
          }
        });
      },
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.sp),
            decoration: BoxDecoration(
              color: AppColors.grey,
              borderRadius: BorderRadius.circular(10.sp),
              border: Border.all(
                color: isChecked ? AppColors.blue : Colors.transparent,
                width: 2.0,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                SizedBox(height: 1.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.description,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                       if (isChecked)
                  CircleAvatar(
                    radius: 8.sp,
                    backgroundColor: AppColors.blue,
                    child: Center(
                      child: Icon(
                        Icons.check,
                        color: AppColors.white,
                        size: 8.sp,
                      ),
                    ),
                  ),
                  ],
                ),
             
              ],
            ),
          ),
           if (isChecked && widget.title == 'Other Rejection')
             
      Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            SizedBox(
        height: 3.h,
      ),
      Text(
        "Order Rejection",
        style: Theme.of(context).textTheme.headlineMedium,
      ),
      
     
Text(
        "Please provide more detail",
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      SizedBox(
        height: 1.h,
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
                child:  CustomTextField(
                  borderColor: AppColors.white,
            name: 'Order rejection',
            hintText: "Lorem ipsum dolor sit amet consectetur. Leo laoreet malesuada eget ipsum.",
            
              
             onChanged: (value) {
             Provider.of<ProofOfDeliveryProvider>(context, listen: false)
              .updateDeliveryFormData(orderRejectionReason: value);
            },
          ),
              ),
            ],
          ),
        ],
      ),
      
        ],
      ),
    );
  }
}
