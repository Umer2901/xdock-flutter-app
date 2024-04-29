import 'dart:ffi';

import 'package:coldxpress/export.dart';

class CustomeMyConsigmentContainer extends StatefulWidget {
  const CustomeMyConsigmentContainer(
      {super.key,
      required this.count,
      required this.recipientName,
      required this.recipientAddress,
      required this.type,
      required this.time,
      required this.id,
      required this.supplier,
      required this.receiver,
      this.group,
      required this.ref,
      required this.cartons,
      required this.pallets,
      required this.spc});
  final int count;
  final String recipientName;
  final String recipientAddress;
  final String type;
  final String time;
  final int id;
  final String supplier;
  final String receiver;
  final int? group;
  final int ref;
  final int cartons;
  final int pallets;
  final int spc;
  @override
  State<CustomeMyConsigmentContainer> createState() =>
      _CustomeMyConsigmentContainerState();
}

class _CustomeMyConsigmentContainerState
    extends State<CustomeMyConsigmentContainer> {
  bool isExpanded = false;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 2.h),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.greyWhite,
          borderRadius: BorderRadius.circular(8.sp),
        ),
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.5.h),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.darkGrey,
                    borderRadius: BorderRadius.circular(8.sp),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 6.w,
                      vertical: 1.8.h,
                    ),
                    child: Text(
                      widget.count.toString(),
                      style:
                          Theme.of(context).textTheme.headlineLarge?.copyWith(
                                color: AppColors.white,
                              ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 46.w,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.recipientName,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      Text(
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        'Recipient: ${widget.recipientAddress}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {},
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 2.w,
                      vertical: 0.5.h,
                    ),
                    width: 11.5.w,
                    height: 5.h,
                    decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(50.sp),
                        border: Border.all()),
                    child: SvgPicture.asset(
                      AppSvgs.pallet,
                      color: AppColors.black,
                    ),
                  ),
                ),
                SizedBox(
                  width: 1.w,
                ),
              ],
            ),
            SizedBox(
              height: 2.h,
            ),
            CustomProductTypeAndTime(
              type: widget.type,
              time: widget.time,
              svgImage: widget.type == 'Chilled'
                  ? SvgPicture.asset(AppSvgs.pallet)
                  : SvgPicture.asset(AppSvgs.cardboardBox),
            ),
            SizedBox(height: 1.h),
            IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        CustomValueField(
                          title: AppText.id.toUpperCase(),
                          value: widget.id.toString(),
                        ),
                        SizedBox(
                          height: 1.5.h,
                        ),
                        CustomValueField(
                          title: AppText.supplier,
                          value: widget.supplier,
                        ),
                        SizedBox(
                          height: 1.5.h,
                        ),
                        CustomValueField(
                          title: AppText.receiver,
                          value: widget.receiver,
                        ),
                        SizedBox(
                          height: 1.5.h,
                        ),
                        CustomValueField(
                          title: AppText.group,
                          value: widget.group.toString() != 'null'
                              ? widget.group.toString()
                              : '-',
                          svgImage: GestureDetector(
                              onTap: () {
                                setState(() {
                                  isExpanded == false &&
                                          widget.group.toString() != 'null'
                                      ? isExpanded = true
                                      : isExpanded = false;
                                });
                              },
                              child: SvgPicture.asset(
                                AppSvgs.pallet,
                                color: widget.group.toString() != 'null'
                                    ? AppColors.lightBlue
                                    : AppColors.grey,
                              )),
                        ),
                      ],
                    ),
                  ),
                  const VerticalDivider(
                    color: AppColors.belowMidGreyTwo,
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        CustomValueField(
                          title: AppText.ref.toUpperCase(),
                          value: widget.ref.toString(),
                        ),
                        SizedBox(
                          height: 1.5.h,
                        ),
                        CustomValueField(
                          title: AppText.cartons,
                          value: widget.cartons.toString(),
                        ),
                        SizedBox(
                          height: 1.5.h,
                        ),
                        CustomValueField(
                          title: AppText.pallets,
                          value: widget.pallets.toString(),
                        ),
                        SizedBox(
                          height: 1.5.h,
                        ),
                        CustomValueField(
                          title: AppText.spc,
                          value: '${widget.ref.toString()} sqm',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            isExpanded
                ? Column(
                    children: [
                      SizedBox(height: 1.5.h),
                      const Divider(
                        color: AppColors.belowMidGreyTwo,
                      ),
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.belowMidGreyTwo,
                          radius: 8.w,
                          child: SvgPicture.asset(
                            AppSvgs.pallet,
                            height: 3.h,
                          ),
                        ),
                        title: Text(
                          '${AppText.supplier}: ',
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${AppText.id.toUpperCase()}: 123456',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.black.withOpacity(0.5),
                                      ),
                                ),
                                Text(
                                  '${AppText.ref.toUpperCase()}: 123456',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.black.withOpacity(0.5),
                                      ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${AppText.ctn.toUpperCase()}: 1',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.black,
                                      ),
                                ),
                                Text(
                                  '${AppText.plt.toUpperCase()}: 1',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.black,
                                      ),
                                ),
                                Text(
                                  '${AppText.spc.toUpperCase()}: 1',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.black,
                                      ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
