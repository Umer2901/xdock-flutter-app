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
    // Retrieve arguments and print them for debugging
    final arguments = json.decode(json.encode(Get.arguments));
    _consignments.addAll(arguments);
    print("Initial Consignments: $_consignments");

    // Group consignments by date and sort them using 'sort_app'
    groupedConsignments = _groupConsignmentsByDate();
    print("Grouped Consignments: $groupedConsignments");
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
                            print(
                                "Final Consignments before sending to API: $finalConsignments");
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
                                content: Text('No reordering changes were made.')),
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

                                print(
                                    "Reordered Consignments for date $date: ${reorderedConsignmentsByDate[date]}");
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

  // Group consignments by date and sort them by 'sort_app'
// Group consignments by date and sort them by 'sort_app' and date in ascending order
Map<String, List<dynamic>> _groupConsignmentsByDate() {
  final Map<String, List<dynamic>> groupedByDate = {};

  // Use a set to track sort_app values for each date to prevent duplicates
  final Map<String, Set<int>> sortAppTracker = {};

  for (var consignment in _consignments) {
    final date = consignment['delivery_date'] ?? 'Not Provided';
    final sortAppValue = int.tryParse(consignment['sort_app'].toString());

    // Skip consignments without a valid sort_app value
    if (sortAppValue == null) continue;

    // If the date is not in the group, initialize it
    if (!groupedByDate.containsKey(date)) {
      groupedByDate[date] = [];
      sortAppTracker[date] = <int>{};
    }

    // Check if this sort_app value is already present for this date
    if (!sortAppTracker[date]!.contains(sortAppValue)) {
      // Add the consignment to the group and track the sort_app value
      groupedByDate[date]!.add(consignment);
      sortAppTracker[date]!.add(sortAppValue);
    } else {
      // Handle the duplicate case: remove the old consignment with the same sort_app
      // and keep the latest consignment.
      groupedByDate[date] = groupedByDate[date]!
          .where((existing) => int.tryParse(existing['sort_app'].toString()) != sortAppValue)
          .toList();
      groupedByDate[date]!.add(consignment);
    }
  }

  // Sort consignments within each date group by the 'sort_app' field
  groupedByDate.forEach((date, consignments) {
    consignments.sort((a, b) {
      int sortA = int.tryParse(a['sort_app'].toString()) ?? 0;
      int sortB = int.tryParse(b['sort_app'].toString()) ?? 0;
      return sortA.compareTo(sortB);
    });
  });

  // Sort dates in the grouped consignments map in ascending order (oldest dates first)
  final sortedGroupedByDate = Map<String, List<dynamic>>.fromEntries(
    groupedByDate.entries.toList()
      ..sort((a, b) {
        if (a.key == 'Not Provided') return 1;
        if (b.key == 'Not Provided') return -1;

        // Parse the dates in ascending order to show older dates first
        DateTime dateA = DateFormat('yyyy-MM-dd').parse(a.key); // Adjust the format if needed
        DateTime dateB = DateFormat('yyyy-MM-dd').parse(b.key);
        return dateA.compareTo(dateB); // Ascending order: older dates first
      }),
  );

  print("Grouped Consignments after sorting by date (oldest first): $sortedGroupedByDate");

  return sortedGroupedByDate;
}


Future<void> sendReorderedConsignments(
    Map<String, List<int>> finalConsignments, String accessToken) async {
  try {
    print("Sending Reordered Consignments to API: $finalConsignments");
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
      String message = responseData['msg'] ?? 'Operation successful';
      print("Reorder API Response: ${response.body}");

      if (status == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
        print("Reorder successful");
      } else {
        print('Reorder failed with status: $status, Message: $message');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } else {
      var responseData = json.decode(response.body);
      String message = responseData['msg'] ?? 'Something went wrong';
      print(
          'Reorder API failed with status code: ${response.statusCode} and response: ${response.body}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  } catch (e) {
    print('Error during reorder API call: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text(
              'An error occurred during the operation. Please try again.')),
    );
  }
}

}
