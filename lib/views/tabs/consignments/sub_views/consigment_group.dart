// ignore_for_file: deprecated_member_use
import 'dart:convert';
import 'package:coldxpress/export.dart';

class MyConsigmentGroup extends StatefulWidget {
  const MyConsigmentGroup({super.key});

  @override
  State<MyConsigmentGroup> createState() => _MyConsigmentGroupState();
}

class _MyConsigmentGroupState extends State<MyConsigmentGroup> {
  final ScrollController _scrollController = ScrollController();
  final List<dynamic> _consignments = [];
  List<int> consignmentIds = [];
  List<dynamic> selectedConsignments = [];
  

  @override
  void initState() {
    super.initState();
    _consignments.addAll(json.decode(json.encode(Get.arguments)));
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.transparent,
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
          AppText.group,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: SafeArea(
          child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: [
              CircleAvatar(
                radius: 9.w,
                backgroundColor: AppColors.greyWhite,
                child: SvgPicture.asset(
                  AppSvgs.groupBlack,
                  width: 10.w,
                  color: AppColors.blue,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 3.w,
                  vertical: 1.h,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomButton(
                        label: AppText.cancel.toUpperCase(),
                        borderColor: AppColors.belowMidGreyTwo,
                        backgroundColor: AppColors.white,
                        foregroundColor: AppColors.border.withOpacity(0.8),
                        width: 40.w,
                        height: 5.h,
                        onPressed: () {
                          Get.back();
                        }),
                    CustomButton(
                      width: 40.w,
                      height: 5.h,
                      label: AppText.group.toUpperCase(),
                      onPressed: () {
                        Map? groupedConsignment;
                        for (Map<String, dynamic> cons1
                            in selectedConsignments) {
                          if (cons1['total_grouped_consignments'] != 0) {
                            if (cons1['grouped_consignments'] != null) {
                              List groupedConsignments = json.decode(
                                cons1['grouped_consignments'],
                              );
                              for (Map<String, dynamic> cons2
                                  in selectedConsignments) {
                                if (cons2['id'] != cons1['id']) {
                                  cons1['carton'] =
                                      cons1['carton'] + cons2['carton'];
                                  cons1['pallet'] =
                                      cons1['pallet'] + cons2['pallet'];
                                  cons1['space'] =
                                      cons1['space'] + cons2['space'];
                                  cons1['weight'] =
                                      cons1['weight'] + cons2['weight'];
                                  groupedConsignments.add(cons2);
                                }
                              }
                              groupedConsignment = cons1;
                              groupedConsignment['grouped_consignments'] =
                                  jsonEncode(groupedConsignments);
                              break;
                            }
                          }
                        }
                        if (groupedConsignment == null) {
                          List groupedConsignments = selectedConsignments;
                          num totalCartons = 0;
                          num totalPallets = 0;
                          num totalSpace = 0;
                          num totalWeight = 0.0;
                          for (Map cons in groupedConsignments) {
                            totalCartons = totalCartons + cons['carton'];
                            totalPallets = totalPallets + cons['pallet'];
                            totalSpace = totalSpace + cons['space'];
                            totalWeight = totalWeight + cons['weight'];
                          }
                          groupedConsignment = selectedConsignments[0];
                          groupedConsignment!['grouped_consignments'] =
                              jsonEncode(groupedConsignments);
                          groupedConsignment['total_grouped_consignments'] =
                              groupedConsignments.length;
                          groupedConsignment['carton'] = totalCartons;
                          groupedConsignment['pallet'] = totalPallets;
                          groupedConsignment['space'] = totalSpace;
                          groupedConsignment['weight'] = totalWeight;
                        }
                        Get.offAndToNamed(
                          AppRoutes.singleConsigment,
                          arguments: groupedConsignment,
                        );
                      },
                    ),
                  ],
                ),
              ),
              for (int index = 0; index < _consignments.length; index++) ...{
                GestureDetector(
                  onTap: () {
                    if (consignmentIds.contains(_consignments[index]['id'])) {
                      setState(() {
                        consignmentIds.remove(_consignments[index]['id']);
                        selectedConsignments.remove(_consignments[index]);
                      });
                    } else {
                      if (selectedConsignments.isNotEmpty) {
                        Map productTypesFirst = json
                            .decode(selectedConsignments[0]['product_types']);
                        Map productTypesSecond =
                            json.decode(_consignments[index]['product_types']);
                        if (productTypesFirst['name'] ==
                                productTypesSecond['name'] &&
                            selectedConsignments[0]['consignment_type'] ==
                                _consignments[index]['consignment_type']) {
                          setState(() {
                            consignmentIds.add(_consignments[index]['id']);
                            selectedConsignments.add(_consignments[index]);
                          });
                        }
                      } else {
                        setState(() {
                          consignmentIds.add(_consignments[index]['id']);
                          selectedConsignments.add(_consignments[index]);
                        });
                      }
                    }
                  },
                  child: CustomConsignmentContainer(
                    consignment: _consignments[index],
                    isSelected: consignmentIds.contains(
                      _consignments[index]['id'],
                    ),
                  ),
                ),
              },
              _consignments.isEmpty
                  ? Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 4.h,
                      ),
                      child: SizedBox(
                        width: 60.w,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Image(
                              image: AssetImage(
                                AppImages.cardboard,
                              ),
                            ),
                            SizedBox(
                              height: 3.h,
                            ),
                            Text(
                              'Consignment Completed!',
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            Text(
                              'Get back safe, and remember to return your pallets.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    )
                  : GestureDetector(
                      onTap: () {
                        _scrollController.animateTo(
                          0.0,
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Text(
                        AppText.returnToTop,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.midBlue,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
              SizedBox(
                height: 6.h,
              ),
            ],
          ),
        ),
      )),
    );
  }
}
