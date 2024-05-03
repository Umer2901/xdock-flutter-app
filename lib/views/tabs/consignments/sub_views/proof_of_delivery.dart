import 'package:flutter/material.dart';
import 'package:coldxpress/export.dart';
import 'package:coldxpress/views/tabs/consignments/sub_views/clock.dart';

enum DeliveryType { full, partial, none }

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
 bool showSignature = false; 
DeliveryType selectedDeliveryType = DeliveryType.full; 
  int palletValue = 0;
  int cartonsValue = 0;

  void updatePalletValue(int value) {
    setState(() {
      palletValue = value;
    });
  }

  void updateCartonsValue(int value) {
    setState(() {
      cartonsValue = value;
    });
  }
final TextEditingController serviceTimeController = TextEditingController();

@override
void initState() {
  super.initState();
  WidgetsBinding.instance!.addPostFrameCallback((_) {
    serviceTimeController.text =
        '${Provider.of<TimeProvider>(context).startTime.h}:${Provider.of<TimeProvider>(context).startTime.m} - ${Provider.of<TimeProvider>(context).endTime.h}:${Provider.of<TimeProvider>(context).endTime.m}';
  });
}


@override
void didChangeDependencies() {
  super.didChangeDependencies();
  serviceTimeController.text =
      '${Provider.of<TimeProvider>(context).startTime.h}:${Provider.of<TimeProvider>(context).startTime.m} - ${Provider.of<TimeProvider>(context).endTime.h}:${Provider.of<TimeProvider>(context).endTime.m}';
}


 
 void _showSignaturePopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          backgroundColor: Colors.white,
          child: Transform.rotate(
            angle: 90 * 3.14159 / 180,
            child: Container(
              height: 47.h,
              width: 80.w,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CupertinoButton(
                        child: const Text(
                          "Cancel",
                          style: TextStyle(color: Colors.blue),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      Text(
                        "Signature",
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      CupertinoButton(
                        child: const Text(
                          "Done",
                          style: TextStyle(color: Colors.blue),
                        ),
                        onPressed: () {
                          setState(() {
                            showSignature = true; 
                            Navigator.pop(context);
                          });
                        },
                      ),
                    ],
                  ),
                  Center(
                    child: Container(
                      height: 24.h,
                      width: 90.w,
                      alignment: Alignment.center,
                      child: Signature(
                        controller: controller,
                        width: 85.w,
                        height: 20.h,
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Center(
                        child: Divider(
                          height: 1,
                          thickness: 2,
                          color: AppColors.grey,
                        ),
                      ),
                      CupertinoButton(
                        child: const Text(
                          "Clear",
                          style: TextStyle(color: Colors.blue),
                        ),
                        onPressed: () {
                          setState(() {
                            controller.clear();
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
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
                    value: selectedDeliveryType,
                    onChanged: (newValue) {
                      setState(() {
                        selectedDeliveryType = newValue!;
                      });
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
                        child:  Row(
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
                       )),
                    ],
                  ),
                  SizedBox(
                    height: 2.h,
                  ),
                 if (selectedDeliveryType == DeliveryType.full)
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
                              initialValue: cartonsValue, 
                              totalPallet: 5,
                              onValueChanged: (value) {
                               
                                updateCartonsValue(value);
                              },
                            ),
           PalletContainer(
                              name: 'pallets',
                              heading: AppText.pallets,
                              hintText: '0',
                              initialValue: palletValue,
                              totalPallet: 5,
                              onValueChanged: (value) {
                                
                                updatePalletValue(value);
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
      const CustomTextField(
        name: 'receiverFirstName',
        hintText: AppText.receiverFirstName,
      ),
      SizedBox(
        height: 1.h,
      ),
      const CustomTextField(
        name: 'receiverLastName',
        hintText: AppText.receiverLastName,
      ),
      SizedBox(
        height: 1.h,
      ),
       SizedBox(
  width: 90.w,
  child: GestureDetector(
    onTap: () {
      if (!showSignature) { 
        _showSignaturePopup(context);
      }
    },
    child: Stack(
      children: [
        if (controller.isEmpty && !showSignature)
          
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
        if (showSignature)
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
                    setState(() {
                      controller.clear();
                      showSignature = false; 
                      _showSignaturePopup(context);
                    });
                  },
                ),
              ],
            ),
          ),
      ],
    ),
  ),
),
      SizedBox(
        height: 1.h,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(
            width: 50.w,
            child: CustomButton(label: "Next",onPressed: () {
  if (selectedDeliveryType == DeliveryType.full &&
      (palletValue < 5 || cartonsValue < 5)) { 
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
    Get.toNamed(AppRoutes.podphotos);
  }
},backgroundColor: AppColors.grey,borderColor: AppColors.grey,)),
        ],
      ),
    ],
  ),

               if (selectedDeliveryType == DeliveryType.partial)
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
          ),
          const PalletContainer(
            name: 'pallets',
            heading: AppText.pallets,
            hintText: '0',
            initialValue: 0,
            totalPallet: 5,
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
            child: const CustomTextField(
              borderColor: AppColors.white,
      name: 'receiverLastName',
      hintText: "Lorem ipsum dolor sit amet consectetur. Leo laoreet malesuada eget ipsum.",
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
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => EditTime(),
    //   ),
    // );
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
      const CustomTextField(
        name: 'receiverFirstName',
        hintText: AppText.receiverFirstName,
      ),
      SizedBox(
        height: 1.h,
      ),
      const CustomTextField(
        name: 'receiverLastName',
        hintText: AppText.receiverLastName,
      ),
      SizedBox(
        height: 1.h,
      ),
   SizedBox(
  width: 90.w,
  child: GestureDetector(
    onTap: () {
      if (!showSignature) { 
        _showSignaturePopup(context);
      }
    },
    child: Stack(
      children: [
        if (controller.isEmpty && !showSignature)
          
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
        if (showSignature)
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
                    setState(() {
                      controller.clear();
                      showSignature = false; 
                      _showSignaturePopup(context);
                    });
                  },
                ),
              ],
            ),
          ),
      ],
    ),
  ),
),

      SizedBox(
        height: 1.h,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(
            width: 50.w,
            child: CustomButton(label: "Next", onPressed: (){ Get.toNamed(AppRoutes.podphotos);},backgroundColor: AppColors.grey,borderColor: AppColors.grey,)),
        ],
      ),
    ],
  ),
                 if (selectedDeliveryType == DeliveryType.none)
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
          ),
          const PalletContainer(
            name: 'pallets',
            heading: AppText.pallets,
            hintText: '0',
            initialValue: 0,
            totalPallet: 5,
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
   const CustomContainer(
  title: 'Wrong Address',
  description: 'Address is wrong or the location has closed',
),
 SizedBox(
        height: 3.h,
      ),
   const CustomContainer(
  title: 'Receiver Not Open',
  description: 'The receiver is unable to receive goods',
),
SizedBox(
        height: 3.h,
      ),
   const CustomContainer(
  title: 'Temperature Issue',
  description: 'The stock is not the correct temperature',
),
 SizedBox(
        height: 3.h,
      ),
   const CustomContainer(
  title: 'Damaged Goods',
  description: 'The packaging or goods have been damaged',
),
 SizedBox(
        height: 3.h,
      ),
   const CustomContainer(
  title: 'Other Rejection',
  description: 'The customer refused the goods ',
),
 
    
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
            child: const CustomTextField(
              borderColor: AppColors.white,
      name: 'receiverLastName',
      hintText: "Lorem ipsum dolor sit amet consectetur. Leo laoreet malesuada eget ipsum.",
            ),
          ),
        ],
      ),
      SizedBox(
        height: 1.h,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(
            width: 50.w,
            child: CustomButton(label: "Submit POD", onPressed: (){},backgroundColor: AppColors.red,borderColor: AppColors.red,)),
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
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isChecked = !isChecked;
        });
      },
      child: Container(
        width: double.infinity ,
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
                child: Center(child: Icon(Icons.check, color: AppColors.white,size: 8.sp,))),
              ],
            ),
           
          ],
        ),
      ),
    );
  }
}
