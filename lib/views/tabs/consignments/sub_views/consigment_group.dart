// import 'dart:convert';
// import 'package:coldxpress/export.dart';

// class MyConsigmentGroup extends StatefulWidget {
//   const MyConsigmentGroup({super.key});

//   @override
//   State<MyConsigmentGroup> createState() => _MyConsigmentGroupState();
// }

// class _MyConsigmentGroupState extends State<MyConsigmentGroup> {
//   final ScrollController _scrollController = ScrollController();
//   final List<dynamic> _consignments = [];
//   List<int> consignmentIds = [];
//   List<dynamic> selectedConsignments = [];
//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
//   Map<String, List<dynamic>> groupedConsignmentsByDate = {};
//  late PreCheckDatabase precheck;
//  late ConsignmentDatabase consignment;
//   @override
//   void initState() {
//     super.initState();
//     _consignments.addAll(json.decode(json.encode(Get.arguments)));
//     _groupConsignmentsByDate();
//       AuthenticationState state =
//         BlocProvider.of<AuthenticationCubit>(context).state;
//     if (state is Authenticated) {
//       consignment = ConsignmentDatabase(
//         context.read<DatabaseProvider>().database,
//         accessToken: state.token,
//       );
//       precheck = PreCheckDatabase(
//         context.read<DatabaseProvider>().database,
//         accessToken: state.token,
//       );
//     }
//   }

//   void _groupConsignmentsByDate() {
//     Map<String, List<dynamic>> tempGroupedConsignments = {};
//     for (var consignment in _consignments) {

//        final date = consignment['delivery_date'] ?? 'Not Provided';
//       if (!tempGroupedConsignments.containsKey(date)) {
//         tempGroupedConsignments[date] = [];
//       }
//       tempGroupedConsignments[date]!.add(consignment);
//     }
//     setState(() {
//       groupedConsignmentsByDate = tempGroupedConsignments;
//     });
//   }

  
// void _groupSelectedConsignments() async {
//   Map<String, dynamic> precheckStatus = await precheck.getPrecheckStatus();
//   if (selectedConsignments.isEmpty || precheckStatus['checklist'] != 1 || precheckStatus['outbound'] != 1) {
//     Get.snackbar(
//       'Action Restricted',
//       'Please fill the Checklist and Outbound to continue',
//       backgroundColor: Colors.red,
//       colorText: Colors.white,
//     );
//     return;
//   }

//   print('Selected Consignment IDs: $consignmentIds');

//   final date = jsonDecode(selectedConsignments[0]['run_sheets'])['date'] ?? 'Not Provided';
//   final String selectedProductTypeName = jsonDecode(selectedConsignments[0]['product_types'])['name'] ?? 'Unknown';
//   final List<dynamic> groupedConsignments = [];
//   final List<String> consignmentNames = [];
//   final List<String> companyNames = [];

//   for (var consignment in selectedConsignments) {
//     final consignmentDate = jsonDecode(consignment['run_sheets'])['date'] ?? 'Not Provided';
//     final String consignmentProductTypeName = jsonDecode(consignment['product_types'])['name'] ?? 'Unknown';
      
//     if (consignmentDate == date && consignmentProductTypeName == selectedProductTypeName) {
//       groupedConsignments.add(consignment);
//       consignmentNames.add(consignment['name'] ?? 'Unnamed');
//       Map? deliveryAddresses = json.decode(consignment['delivery_addresses']);
//       Map? pickupAddresses = json.decode(consignment['pickup_addresses']);
//       final companyName = consignment['consignment_type'] == 'delivery'
//           ? (deliveryAddresses?['company_name'] ?? 'Not Provided')
//           : (pickupAddresses?['company_name'] ?? 'Not Provided');
//       companyNames.add(companyName);
//     } else {
//       Get.snackbar(
//         'Error',
//         'Cannot group consignments of different product types or dates.',
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//       return;
//     }
//   }

//   if (groupedConsignments.isNotEmpty) {
//     final totalCartons = groupedConsignments.fold<int>(0, (prev, element) => prev + (element['carton'] as int? ?? 0));
//     final totalPallets = groupedConsignments.fold<int>(0, (prev, element) => prev + (element['pallet'] as int? ?? 0));
//     final totalSpace = groupedConsignments.fold<int>(0, (prev, element) => prev + (element['space'] as int? ?? 0));
//     final totalWeight = groupedConsignments.fold<double>(0.0, (prev, element) => prev + (element['weight'] as double? ?? 0.0));

//     Map<String, dynamic> groupedConsignment = selectedConsignments[0];
//     groupedConsignment['grouped_consignments'] = jsonEncode(groupedConsignments);
//     groupedConsignment['total_grouped_consignments'] = groupedConsignments.length;
//     groupedConsignment['carton'] = totalCartons;
//     groupedConsignment['pallet'] = totalPallets;
//     groupedConsignment['space'] = totalSpace;
//     groupedConsignment['weight'] = totalWeight;
//     groupedConsignment['consignment_names'] = consignmentNames;
//     groupedConsignment['company_names'] = companyNames;

//     Get.offAndToNamed(
//       AppRoutes.singleConsigment,
//       arguments: groupedConsignment,
//     );
//   }
// }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       key: _scaffoldKey,
//       backgroundColor: AppColors.white,
//       appBar: AppBar(
//         surfaceTintColor: Colors.transparent,
//         backgroundColor: Colors.transparent,
//         leading: IconButton(
//           onPressed: () {
//             Get.back();
//           },
//           icon: Icon(
//             Icons.arrow_back_ios,
//             size: 15.sp,
//           ),
//         ),
//         actions: [
//           IconButton(
//             onPressed: () {
//               _scaffoldKey.currentState?.openEndDrawer();
//             },
//             icon: Icon(
//               Icons.more_horiz,
//               size: 20.sp,
//             ),
//           ),
//         ],
//         centerTitle: true,
//         title: Text(
//           AppText.group,
//           style: Theme.of(context).textTheme.headlineSmall,
//         ),
//       ),
  

//       body: SafeArea(
//         child: Padding(
//           padding: EdgeInsets.symmetric(horizontal: 4.w),
//           child: SingleChildScrollView(
//             controller: _scrollController,
//             child: Column(
//               children: [
//                 CircleAvatar(
//                   radius: 9.w,
//                   backgroundColor: AppColors.greyWhite,
//                   child: SvgPicture.asset(
//                     AppSvgs.groupBlack,
//                     width: 10.w,
//                     color: AppColors.blue,
//                   ),
//                 ),
//                 Padding(
//                   padding: EdgeInsets.symmetric(
//                     horizontal: 3.w,
//                     vertical: 1.h,
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       CustomButton(
//                         label: AppText.cancel.toUpperCase(),
//                         borderColor: AppColors.belowMidGreyTwo,
//                         backgroundColor: AppColors.white,
//                         foregroundColor: AppColors.border.withOpacity(0.8),
//                         width: 40.w,
//                         height: 5.h,
//                         onPressed: () {
//                           Get.back();
//                         },
//                       ),
//                       CustomButton(
//                         width: 40.w,
//                         height: 5.h,
//                         label: AppText.group.toUpperCase(),
//                         onPressed: _groupSelectedConsignments,
//                       ),
//                     ],
//                   ),
//                 ),
//                 for (var date in groupedConsignmentsByDate.keys) ...[
//                   Padding(
//                     padding: EdgeInsets.symmetric(vertical: 2.h),
//                     child: Text(
//                       date,
//                       style: Theme.of(context)
//                           .textTheme
//                           .headlineMedium
//                           ?.copyWith(fontWeight: FontWeight.bold),
//                     ),
//                   ),
//                   for (var consignment in groupedConsignmentsByDate[date]!) ...[
//                     GestureDetector(
//                       onTap: () {
//                         final String consignmentType = consignment['consignment_type'] ?? 'Unknown';
//                         final Map productTypes = jsonDecode(consignment['product_types']);
//                         final String consignmentProductTypeName = productTypes?['name'] ?? 'Unknown';
//                         print('Product Type Name: $consignmentProductTypeName');
//                         print('Consignment Type: $consignmentType');
//                         print('Product Type: $productTypes');
                        
//                         if (consignmentIds.contains(consignment['id'])) {
//                           setState(() {
//                             consignmentIds.remove(consignment['id']);
//                             selectedConsignments.remove(consignment);
//                           });
//                         } else {
//                           if (selectedConsignments.isNotEmpty) {
//                             final String selectedDate = jsonDecode(selectedConsignments[0]['run_sheets'])['date'] ?? 'Not Provided';
//                             final String consignmentDate = jsonDecode(consignment['run_sheets'])['date'] ?? 'Not Provided';
//                             final String selectedType = selectedConsignments[0]['consignment_type'] ?? 'Unknown';
//                             final String selectedProductTypeName = jsonDecode(selectedConsignments[0]['product_types'])['name'] ?? 'Unknown';

//                             if (selectedDate == consignmentDate && selectedType == consignmentType && selectedProductTypeName == consignmentProductTypeName) {
//                               setState(() {
//                                 consignmentIds.add(consignment['id']);
//                                 selectedConsignments.add(consignment);
//                               });
//                             } else {
                            
//                               Get.snackbar(
//                                 'Error',
//                                 'Cannot group consignments of different types or dates.',
//                                 backgroundColor: Colors.red,
//                                 colorText: Colors.white,
//                               );
//                             }
//                           } else {
//                             setState(() {
//                               consignmentIds.add(consignment['id']);
//                               selectedConsignments.add(consignment);
//                             });
//                           }
//                         }
//                       },
//                       child: CustomConsignmentContainer(
//                         consignment: consignment,
//                         isSelected: consignmentIds.contains(consignment['id']),
//                       ),
//                     ),
//                   ],
//                 ],
//                 _consignments.isEmpty
//                     ? Padding(
//                         padding: EdgeInsets.symmetric(
//                           vertical: 4.h,
//                         ),
//                         child: SizedBox(
//                           width: 60.w,
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.center,
//                             children: [
//                               const Image(
//                                 image: AssetImage(
//                                   AppImages.cardboard,
//                                 ),
//                               ),
//                               SizedBox(
//                                 height: 3.h,
//                               ),
//                               Text(
//                                 'Consignment Completed!',
//                                 textAlign: TextAlign.center,
//                                 style: Theme.of(context)
//                                     .textTheme
//                                     .headlineSmall
//                                     ?.copyWith(fontWeight: FontWeight.w700),
//                               ),
//                               Text(
//                                 'Get back safe, and remember to return your pallets.',
//                                 textAlign: TextAlign.center,
//                                 style: Theme.of(context)
//                                     .textTheme
//                                     .bodyMedium
//                                     ?.copyWith(fontWeight: FontWeight.w500),
//                               ),
//                             ],
//                           ),
//                         ),
//                       )
//                     : GestureDetector(
//                         onTap: () {
//                           _scrollController.animateTo(
//                             0.0,
//                             duration: const Duration(milliseconds: 500),
//                             curve: Curves.easeInOut,
//                           );
//                         },
//                         child: Text(
//                           AppText.returnToTop,
//                           style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                                 color: AppColors.midBlue,
//                                 fontWeight: FontWeight.w700,
//                               ),
//                         ),
//                       ),
//                 SizedBox(
//                   height: 6.h,
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//       endDrawer: const CustomDrawer(),
//     );
//   }
// }
import 'dart:convert';
import 'package:coldxpress/export.dart';
import 'package:intl/intl.dart'; // Import for date formatting

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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Map<String, List<dynamic>> groupedConsignmentsByDate = {};
  late PreCheckDatabase precheck;
  late ConsignmentDatabase consignment;

  @override
  void initState() {
    super.initState();
    _consignments.addAll(json.decode(json.encode(Get.arguments)));
    _groupConsignmentsByDate();
    AuthenticationState state = BlocProvider.of<AuthenticationCubit>(context).state;
    if (state is Authenticated) {
      consignment = ConsignmentDatabase(
        context.read<DatabaseProvider>().database,
        accessToken: state.token,
      );
      precheck = PreCheckDatabase(
        context.read<DatabaseProvider>().database,
        accessToken: state.token,
      );
    }
  }

  void _groupConsignmentsByDate() {
    Map<String, List<dynamic>> tempGroupedConsignments = {};
    for (var consignment in _consignments) {
      final date = consignment['delivery_date'] ?? 'Not Provided';

      if (date != 'Not Provided') {
        final formattedDate = DateFormat('dd-MM-yyyy').format(DateFormat('yyyy-MM-dd').parse(date));
        if (!tempGroupedConsignments.containsKey(formattedDate)) {
          tempGroupedConsignments[formattedDate] = [];
        }
        tempGroupedConsignments[formattedDate]!.add(consignment);
      } else {
        if (!tempGroupedConsignments.containsKey(date)) {
          tempGroupedConsignments[date] = [];
        }
        tempGroupedConsignments[date]!.add(consignment);
      }
    }

    final sortedGroupedConsignments = Map<String, List<dynamic>>.fromEntries(
      tempGroupedConsignments.entries.toList()
        ..sort((a, b) {
          if (a.key == 'Not Provided') return 1;
          if (b.key == 'Not Provided') return -1;

          DateTime dateA = DateFormat('dd-MM-yyyy').parse(a.key);
          DateTime dateB = DateFormat('dd-MM-yyyy').parse(b.key);
          return dateA.compareTo(dateB); 
        }),
    );

    setState(() {
      groupedConsignmentsByDate = sortedGroupedConsignments;
    });
  }

  void _groupSelectedConsignments() async {
    Map<String, dynamic> precheckStatus = await precheck.getPrecheckStatus();
    if (selectedConsignments.isEmpty || precheckStatus['checklist'] != 1 || precheckStatus['outbound'] != 1) {
      Get.snackbar(
        'Action Restricted',
        'Please fill the Checklist and Outbound to continue',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    print('Selected Consignment IDs: $consignmentIds');

    final date = jsonDecode(selectedConsignments[0]['run_sheets'])['date'] ?? 'Not Provided';
    final String selectedProductTypeName = jsonDecode(selectedConsignments[0]['product_types'])['name'] ?? 'Unknown';
    final List<dynamic> groupedConsignments = [];
    final List<String> consignmentNames = [];
    final List<String> companyNames = [];

    for (var consignment in selectedConsignments) {
      final consignmentDate = jsonDecode(consignment['run_sheets'])['date'] ?? 'Not Provided';
      final String consignmentProductTypeName = jsonDecode(consignment['product_types'])['name'] ?? 'Unknown';

      if (consignmentDate == date && consignmentProductTypeName == selectedProductTypeName) {
        groupedConsignments.add(consignment);
        consignmentNames.add(consignment['name'] ?? 'Unnamed');
        Map? deliveryAddresses = json.decode(consignment['delivery_addresses']);
        Map? pickupAddresses = json.decode(consignment['pickup_addresses']);
        final companyName = consignment['consignment_type'] == 'delivery'
            ? (deliveryAddresses?['company_name'] ?? 'Not Provided')
            : (pickupAddresses?['company_name'] ?? 'Not Provided');
        companyNames.add(companyName);
      } else {
        Get.snackbar(
          'Error',
          'Cannot group consignments of different product types or dates.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }
    }

    if (groupedConsignments.isNotEmpty) {
      final totalCartons = groupedConsignments.fold<int>(0, (prev, element) => prev + (element['carton'] as int? ?? 0));
      final totalPallets = groupedConsignments.fold<int>(0, (prev, element) => prev + (element['pallet'] as int? ?? 0));
      final totalSpace = groupedConsignments.fold<int>(0, (prev, element) => prev + (element['space'] as int? ?? 0));
      final totalWeight = groupedConsignments.fold<double>(0.0, (prev, element) => prev + (element['weight'] as double? ?? 0.0));

      Map<String, dynamic> groupedConsignment = selectedConsignments[0];
      groupedConsignment['grouped_consignments'] = jsonEncode(groupedConsignments);
      groupedConsignment['total_grouped_consignments'] = groupedConsignments.length;
      groupedConsignment['carton'] = totalCartons;
      groupedConsignment['pallet'] = totalPallets;
      groupedConsignment['space'] = totalSpace;
      groupedConsignment['weight'] = totalWeight;
      groupedConsignment['consignment_names'] = consignmentNames;
      groupedConsignment['company_names'] = companyNames;
       groupedConsignment['is_group'] = 'parent';

      Get.offAndToNamed(
        AppRoutes.singleConsigment,
        arguments: groupedConsignment,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
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
                        },
                      ),
                      CustomButton(
                        width: 40.w,
                        height: 5.h,
                        label: AppText.group.toUpperCase(),
                        onPressed: _groupSelectedConsignments,
                      ),
                    ],
                  ),
                ),
                for (var date in groupedConsignmentsByDate.keys) ...[
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    child: Text(
                      date,
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  for (var consignment in groupedConsignmentsByDate[date]!) ...[
                    GestureDetector(
                      onTap: () {
                        final String consignmentType = consignment['consignment_type'] ?? 'Unknown';
                        final Map productTypes = jsonDecode(consignment['product_types']);
                        final String consignmentProductTypeName = productTypes?['name'] ?? 'Unknown';
                        print('Product Type Name: $consignmentProductTypeName');
                        print('Consignment Type: $consignmentType');
                        print('Product Type: $productTypes');

                        if (consignmentIds.contains(consignment['id'])) {
                          setState(() {
                            consignmentIds.remove(consignment['id']);
                            selectedConsignments.remove(consignment);
                          });
                        } else {
                          if (selectedConsignments.isNotEmpty) {
                            final String selectedDate = jsonDecode(selectedConsignments[0]['run_sheets'])['date'] ?? 'Not Provided';
                            final String consignmentDate = jsonDecode(consignment['run_sheets'])['date'] ?? 'Not Provided';
                            final String selectedType = selectedConsignments[0]['consignment_type'] ?? 'Unknown';
                            final String selectedProductTypeName = jsonDecode(selectedConsignments[0]['product_types'])['name'] ?? 'Unknown';

                            if (selectedDate == consignmentDate && selectedType == consignmentType && selectedProductTypeName == consignmentProductTypeName) {
                              setState(() {
                                consignmentIds.add(consignment['id']);
                                selectedConsignments.add(consignment);
                              });
                            } else {
                              Get.snackbar(
                                'Error',
                                'Cannot group consignments of different types or dates.',
                                backgroundColor: Colors.red,
                                colorText: Colors.white,
                              );
                            }
                          } else {
                            setState(() {
                              consignmentIds.add(consignment['id']);
                              selectedConsignments.add(consignment);
                            });
                          }
                        }
                      },
                      child: CustomConsignmentContainer(
                        consignment: consignment,
                        isSelected: consignmentIds.contains(consignment['id']),
                      ),
                    ),
                  ],
                ],
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
        ),
      ),
      endDrawer: const CustomDrawer(),
    );
  }
}
