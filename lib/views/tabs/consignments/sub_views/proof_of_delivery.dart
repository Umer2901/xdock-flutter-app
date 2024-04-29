import 'package:coldxpress/export.dart';

class ProofOfDeliveryView extends StatefulWidget {
  const ProofOfDeliveryView({super.key});

  @override
  State<ProofOfDeliveryView> createState() => _ProofOfDeliveryViewState();
}

class _ProofOfDeliveryViewState extends State<ProofOfDeliveryView> {
  final SignatureController controller = SignatureController(
    penStrokeWidth: 3,
    penColor: AppColors.black,
    exportBackgroundColor: AppColors.white,
  );
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
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              'Recipient: Drew Moran 830 Wellington road, Rowville',
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
                  const CustomDropdown(
                    name: 'deliveryType',
                    hintText: 'Please Select',
                    fillColor: AppColors.white,
                    items: [],
                  ),
                  SizedBox(
                    height: 2.h,
                  ),
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
                    onTap: () {},
                    suffixIcon: Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 2.h, horizontal: 2.w),
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
                    child: Stack(
                      children: [
                        if (controller.isEmpty)
                          Positioned(
                            left: 4.w,
                            right: 4.w,
                            top: 2.h,
                            bottom: 2.h,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 50.sp,
                                  height: 50.sp,
                                  child: const Image(
                                    image: AssetImage(AppImages.handWithPen),
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
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.navyBlue),
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
