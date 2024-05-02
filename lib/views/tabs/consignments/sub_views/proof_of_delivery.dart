import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:coldxpress/export.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

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

  DeliveryType selectedDeliveryType =
      DeliveryType.full; // Default delivery type
  void _showSignaturePopup(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return Container(
          height: double.infinity,
          width: 85.w,
          child: RotationTransition(
            turns: AlwaysStoppedAnimation(90 / 360),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextButton(
                      child: Text(
                        "Cancel",
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(color: AppColors.blue),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    Text(
                      "Signature",
                      style: Theme.of(context)
                          .textTheme
                          .headlineLarge
                          ?.copyWith(color: AppColors.black),
                    ),
                    TextButton(
                      child: Text(
                        "Done",
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(color: AppColors.blue),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 25.h,
                    width: 95.w, // Adjust width as needed
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.navyBlue),
                      borderRadius: BorderRadius.circular(5),
                    ),

                    child: Signature(
                      controller: controller,
                      width: 75.w,
                      height: 24.h,
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextButton(
                      child: Text(
                        "Clear",
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(color: AppColors.blue),
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
        );
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
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
                            Text('Full Delivery'),
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
                            Text('Partial Delivery'),
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
                              Text('No Delivery'),
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
                            padding: EdgeInsets.symmetric(
                                vertical: 2.h, horizontal: 2.w),
                            child: Text(
                              AppText.celsius,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
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
                          onTap: () {
                            Get.toNamed(AppRoutes.Stopwatch);
                          },
                          suffixIcon: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 2.h, horizontal: 2.w),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  AppText.editHours,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
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
                            padding: EdgeInsets.symmetric(
                                vertical: 2.h, horizontal: 2.w),
                            child: Text(
                              AppText.minutes,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
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
                              _showSignaturePopup(
                                  context); // Show the popup when tapped
                            },
                            child: Stack(
                              children: [
                                if (controller.isEmpty)
                                  Positioned(
                                    left: 4.w,
                                    right: 4.w,
                                    top: 2.h,
                                    bottom: 2.h,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                              ?.copyWith(
                                                  fontWeight: FontWeight.w700),
                                        )
                                      ],
                                    ),
                                  ),
                                Container(
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: AppColors.navyBlue),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(5.sp),
                                    ),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      vertical: 1.h, horizontal: 2.w),
                                  child: Signature(
                                    controller: controller,
                                    width: 90.w,
                                    height: 20.h,
                                    backgroundColor: Colors.transparent,
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
                                child: CustomButton(
                                  label: "Next",
                                  onPressed: () {},
                                  backgroundColor: AppColors.grey,
                                  borderColor: AppColors.grey,
                                )),
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
                            padding: EdgeInsets.symmetric(
                                vertical: 2.h, horizontal: 2.w),
                            child: Text(
                              AppText.celsius,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
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
                          onTap: () {
                            Get.toNamed(AppRoutes.Stopwatch);
                          },
                          suffixIcon: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 2.h, horizontal: 2.w),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  AppText.editHours,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
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
                            padding: EdgeInsets.symmetric(
                                vertical: 2.h, horizontal: 2.w),
                            child: Text(
                              AppText.minutes,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
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
                              _showSignaturePopup(
                                  context); // Show the popup when tapped
                            },
                            child: Stack(
                              children: [
                                if (controller.isEmpty)
                                  Positioned(
                                    left: 4.w,
                                    right: 4.w,
                                    top: 2.h,
                                    bottom: 2.h,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                              ?.copyWith(
                                                  fontWeight: FontWeight.w700),
                                        )
                                      ],
                                    ),
                                  ),
                                Container(
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: AppColors.navyBlue),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(5.sp),
                                    ),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      vertical: 1.h, horizontal: 2.w),
                                  child: Signature(
                                    controller: controller,
                                    width: 90.w,
                                    height: 20.h,
                                    backgroundColor: Colors.transparent,
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
                                child: CustomButton(
                                  label: "Next",
                                  onPressed: () {},
                                  backgroundColor: AppColors.grey,
                                  borderColor: AppColors.grey,
                                )),
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
                          description:
                              'Address is wrong or the location has closed',
                        ),
                        SizedBox(
                          height: 3.h,
                        ),
                        const CustomContainer(
                          title: 'Receiver Not Open',
                          description:
                              'The receiver is unable to receive goods',
                        ),
                        SizedBox(
                          height: 3.h,
                        ),
                        const CustomContainer(
                          title: 'Temperature Issue',
                          description:
                              'The stock is not the correct temperature',
                        ),
                        SizedBox(
                          height: 3.h,
                        ),
                        const CustomContainer(
                          title: 'Damaged Goods',
                          description:
                              'The packaging or goods have been damaged',
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
                                hintText:
                                    "Lorem ipsum dolor sit amet consectetur. Leo laoreet malesuada eget ipsum.",
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
                                child: CustomButton(
                                  label: "Submit POD",
                                  onPressed: () {},
                                  backgroundColor: AppColors.red,
                                  borderColor: AppColors.red,
                                )),
                          ],
                        ),
                      ],
                    ),
                  SizedBox(
                    height: 1.h,
                  ),
                ],
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
                      ))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
