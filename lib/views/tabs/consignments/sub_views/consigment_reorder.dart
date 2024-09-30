// import 'dart:convert';
// import 'package:coldxpress/export.dart';

// class MyConsigmentReorder extends StatefulWidget {
//   const MyConsigmentReorder({super.key});

//   @override
//   State<MyConsigmentReorder> createState() => _MyConsigmentReorderState();
// }

// class _MyConsigmentReorderState extends State<MyConsigmentReorder> {
//   final ScrollController _scrollController = ScrollController();
//   final List<dynamic> _consignments = [];
//   Map<String, List<dynamic>> groupedConsignments = {};
//   Map<String, List<int>> reorderedConsignmentsByDate = {};
//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

//   @override
//   void initState() {
//     super.initState();
//     final arguments = json.decode(json.encode(Get.arguments));
//     _consignments.addAll(arguments);
//     groupedConsignments = _groupConsignmentsByDate();
//   }

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
//         centerTitle: true,
//         title: Text(
//           AppText.reorder,
//           style: Theme.of(context).textTheme.headlineSmall,
//         ),
//       ),
//       body: SafeArea(
//         child: Padding(
//           padding: EdgeInsets.symmetric(horizontal: 4.w),
//           child: Column(
//             children: [
//               CircleAvatar(
//                 radius: 9.w,
//                 backgroundColor: AppColors.greyWhite,
//                 child: SvgPicture.asset(
//                   AppSvgs.reorderBlack,
//                   width: 10.w,
//                   color: AppColors.blue,
//                 ),
//               ),
//               Padding(
//                 padding: EdgeInsets.symmetric(
//                   horizontal: 3.w,
//                   vertical: 1.h,
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     CustomButton(
//                       label: AppText.cancel.toUpperCase(),
//                       borderColor: AppColors.belowMidGreyTwo,
//                       backgroundColor: AppColors.white,
//                       foregroundColor: AppColors.border.withOpacity(0.8),
//                       width: 40.w,
//                       height: 5.h,
//                       onPressed: () {
//                         Get.back();
//                       },
//                     ),
//                     CustomButton(
//                       width: 40.w,
//                       height: 5.h,
//                       label: AppText.save.toUpperCase(),
//                       onPressed: () async {
//                         if (reorderedConsignmentsByDate.isNotEmpty) {
//                           AuthenticationState authState =
//                               BlocProvider.of<AuthenticationCubit>(context)
//                                   .state;
//                           if (authState is Authenticated) {
//                             for (var date in reorderedConsignmentsByDate.keys) {
//                               final consignmentIds = reorderedConsignmentsByDate[date]!;
//                               await ConsignmentService(
//                                       context.read<DatabaseProvider>().database)
//                                   .reorderConsignments(
//                                 date,
//                                 consignmentIds,
//                                 authState.token,
//                               );
//                               print('Sent reorder for $date: $consignmentIds');
//                             }
//                             Get.back();
//                           }
//                         } else {
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             SnackBar(content: Text('No reordering changes were made.')),
//                           );
//                         }
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//               Expanded(
//                 child: SingleChildScrollView(
//                   child: Column(
//                     children: groupedConsignments.entries.map((entry) {
//                       final date = entry.key;
//                       final consignments = entry.value;

//                       return Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Padding(
//                             padding: EdgeInsets.symmetric(vertical: 2.h),
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Text(
//                                   date,
//                                   style: Theme.of(context)
//                                       .textTheme
//                                       .headlineMedium
//                                       ?.copyWith(fontWeight: FontWeight.bold),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           ReorderableListView(
//                             key: PageStorageKey<String>(date),
//                             physics: const NeverScrollableScrollPhysics(),
//                             shrinkWrap: true,
//                             onReorder: (oldIndex, newIndex) {
//                               setState(() {
//                                 if (newIndex > oldIndex) {
//                                   newIndex -= 1;
//                                 }
//                                 final item = consignments.removeAt(oldIndex);
//                                 consignments.insert(newIndex, item);

//                                 // Track reordered consignments for this specific date
//                                 reorderedConsignmentsByDate[date] = consignments
//                                     .map((consignment) => consignment['id'] as int)
//                                     .toList();
//                               });
//                             },
//                             children: List.generate(
//                               consignments.length,
//                               (index) {
//                                 final consignment = consignments[index];
//                                 return CustomConsignmentContainer(
//                                   key: ValueKey(consignment['id']),
//                                   consignment: consignment,
//                                   icon: const Icon(Icons.drag_handle),
//                                 );
//                               },
//                             ),
//                           ),
//                         ],
//                       );
//                     }).toList(),
//                   ),
//                 ),
//               ),
//               GestureDetector(
//                 onTap: () {
//                   _scrollController.animateTo(
//                     0.0,
//                     duration: const Duration(milliseconds: 500),
//                     curve: Curves.easeInOut,
//                   );
//                 },
//                 child: Padding(
//                   padding: EdgeInsets.symmetric(vertical: 2.h),
//                   child: Text(
//                     AppText.returnToTop,
//                     style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                           color: AppColors.midBlue,
//                           fontWeight: FontWeight.w700,
//                         ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//       endDrawer: const CustomDrawer(),
//     );
//   }

//   Map<String, List<dynamic>> _groupConsignmentsByDate() {
//     final Map<String, List<dynamic>> groupedByDate = {};

//     for (var consignment in _consignments) {
//       final date = consignment['delivery_date'] ?? 'Not Provided';
//       if (date != 'Not Provided') {
//         final formattedDate = DateFormat('dd-MM-yyyy').format(DateFormat('yyyy-MM-dd').parse(date));

//         if (!groupedByDate.containsKey(formattedDate)) {
//           groupedByDate[formattedDate] = [];
//         }
//         groupedByDate[formattedDate]!.add(consignment);
//       } else {
//         if (!groupedByDate.containsKey(date)) {
//           groupedByDate[date] = [];
//         }
//         groupedByDate[date]!.add(consignment);
//       }
//     }

//     final sortedGroupedByDate = Map<String, List<dynamic>>.fromEntries(
//       groupedByDate.entries.toList()..sort((a, b) {
//         if (a.key == 'Not Provided') return 1;
//         if (b.key == 'Not Provided') return -1;

//         DateTime dateA = DateFormat('dd-MM-yyyy').parse(a.key);
//         DateTime dateB = DateFormat('dd-MM-yyyy').parse(b.key);
//         return dateA.compareTo(dateB);
//       }),
//     );

//     return sortedGroupedByDate;
//   }
// }
import 'dart:convert';

import 'package:coldxpress/export.dart';
import 'package:http/http.dart' as http;

class MyConsigmentReorder extends StatefulWidget {
  const MyConsigmentReorder({super.key});

  @override
  State<MyConsigmentReorder> createState() => _MyConsigmentReorderState();
}

class _MyConsigmentReorderState extends State<MyConsigmentReorder> {
  final ScrollController _scrollController = ScrollController();
  final List<dynamic> _consignments = [];
  Map<String, List<dynamic>> groupedConsignments = {};
  Map<String, List<int>> reorderedConsignmentsByDate = {};
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    final arguments = json.decode(json.encode(Get.arguments));
    _consignments.addAll(arguments);
    groupedConsignments = _groupConsignmentsByDate();
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
        centerTitle: true,
        title: Text(
          AppText.reorder,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Column(
            children: [
              CircleAvatar(
                radius: 9.w,
                backgroundColor: AppColors.greyWhite,
                child: SvgPicture.asset(
                  AppSvgs.reorderBlack,
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
                      isLoading: isLoading,
                      width: 40.w,
                      height: 5.h,
                      label: AppText.save.toUpperCase(),
                      onPressed: () async {
                        setState(() {
                          isLoading = true;
                        });
                        if (reorderedConsignmentsByDate.isNotEmpty) {
                          AuthenticationState authState =
                              BlocProvider.of<AuthenticationCubit>(context)
                                  .state;
                          if (authState is Authenticated) {
                            // Prepare final payload for API
                            Map<String, List<int>> finalConsignments = {};

                            // Combine reordered consignments and the original ones that weren't changed
                            for (var date in groupedConsignments.keys) {
                              if (reorderedConsignmentsByDate
                                  .containsKey(date)) {
                                // Use the updated consignments
                                finalConsignments[date] =
                                    reorderedConsignmentsByDate[date]!;
                              } else {
                                // Use the original consignments for dates that were not reordered
                                finalConsignments[date] =
                                    groupedConsignments[date]!
                                        .map((consignment) =>
                                            consignment['id'] as int)
                                        .toList();
                              }
                            }
                            await sendReorderedConsignments(
                              finalConsignments,
                              authState.token,
                            );
                            setState(() {
                              isLoading = false;
                            });
                            Get.back();
                          }
                        } else {
                          setState(() {
                            isLoading = false;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                duration: Duration(seconds: 1),
                                content:
                                    Text('No reordering changes were made.')),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    children: groupedConsignments.entries.map((entry) {
                      final date = entry.key;
                      final consignments = entry.value;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 2.h),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  date,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          ReorderableListView(
                            key: PageStorageKey<String>(date),
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            onReorder: (oldIndex, newIndex) {
                              setState(() {
                                if (newIndex > oldIndex) {
                                  newIndex -= 1;
                                }
                                final item = consignments.removeAt(oldIndex);
                                consignments.insert(newIndex, item);

                                // Track reordered consignments for this specific date
                                reorderedConsignmentsByDate[date] = consignments
                                    .map((consignment) =>
                                        consignment['id'] as int)
                                    .toList();
                              });
                            },
                            children: List.generate(
                              consignments.length,
                              (index) {
                                final consignment = consignments[index];
                                return CustomConsignmentContainer(
                                  key: ValueKey(consignment['id']),
                                  consignment: consignment,
                                  icon: const Icon(Icons.drag_handle),
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  _scrollController.animateTo(
                    0.0,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  child: Text(
                    AppText.returnToTop,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.midBlue,
                          fontWeight: FontWeight.w700,
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

  Map<String, List<dynamic>> _groupConsignmentsByDate() {
    final Map<String, List<dynamic>> groupedByDate = {};

    for (var consignment in _consignments) {
      final date = consignment['delivery_date'] ?? 'Not Provided';
      if (date != 'Not Provided') {
        final formattedDate = DateFormat('dd-MM-yyyy')
            .format(DateFormat('yyyy-MM-dd').parse(date));

        if (!groupedByDate.containsKey(formattedDate)) {
          groupedByDate[formattedDate] = [];
        }
        groupedByDate[formattedDate]!.add(consignment);
      } else {
        if (!groupedByDate.containsKey(date)) {
          groupedByDate[date] = [];
        }
        groupedByDate[date]!.add(consignment);
      }
    }

    final sortedGroupedByDate = Map<String, List<dynamic>>.fromEntries(
      groupedByDate.entries.toList()
        ..sort((a, b) {
          if (a.key == 'Not Provided') return 1;
          if (b.key == 'Not Provided') return -1;

          DateTime dateA = DateFormat('dd-MM-yyyy').parse(a.key);
          DateTime dateB = DateFormat('dd-MM-yyyy').parse(b.key);
          return dateA.compareTo(dateB);
        }),
    );

    return sortedGroupedByDate;
  }

  Future<void> sendReorderedConsignments(
      Map<String, List<int>> finalConsignments, String accessToken) async {
    try {
      final response = await http.post(
        Uri.parse(AppHost.reorderConsignments),
        body: jsonEncode(finalConsignments),
        headers: <String, String>{
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('Reorder API response code: ${response.statusCode}');

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        String status = responseData['status'];

        if (status == 'success') {
        } else {
          print(
              'Reorder failed with status: $status, Message: ${responseData['msg']}');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'Access Denied! You cannot sort the run as the loadsheets are printed.')),
          );
        }
      } else {
        print(
            'Reorder API failed with status code: ${response.statusCode} and response: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Access Denied! You cannot sort the run as the loadsheets are printed.')),
        );
      }
    } catch (e) {
      print('Error during reorder API call: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Access Denied! You cannot sort the run as the loadsheets are printed.')),
      );
    }
  }
}
