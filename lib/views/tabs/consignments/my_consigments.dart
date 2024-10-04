import 'dart:convert';
import 'package:coldxpress/export.dart';

class MyConsigmentTab extends StatefulWidget {
  const MyConsigmentTab({super.key});

  @override
  State<MyConsigmentTab> createState() => _MyConsigmentTabState();
}

class _MyConsigmentTabState extends State<MyConsigmentTab> {
  late ConsignmentDatabase consignment;
  late PreCheckDatabase precheck;
  final ScrollController _scrollController = ScrollController();
  final _formKey = GlobalKey<FormBuilderState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = false;
  String? query;

  @override
  void initState() {
    super.initState();
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

  @override
  void dispose() {
    consignment.dispose();
    super.dispose();
  }

  Future<void> _refreshConsignmentData() async {
    if (!_isLoading) {
      setState(() {
        _isLoading = true;
      });

      try {
        final consignmentService = ConsignmentService(context.read<DatabaseProvider>().database);
        final state = BlocProvider.of<AuthenticationCubit>(context).state;
        if (state is Authenticated) {
          await consignmentService.fetchAndStore(state.token);
        }
      } catch (e) {
        debugPrint('Error refreshing consignments: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildRefreshButton() {
    return GestureDetector(
      onTap: _refreshConsignmentData,
      child: CircleAvatar(
        radius: 9.w,
        backgroundColor: AppColors.greyWhite,
        child: _isLoading
            ? CircularProgressIndicator(
                color: AppColors.blue,
              )
            : Image.asset(AppImages.refresh, width: 10.w),
      ),
    );
  }

  // Updated grouping method to filter out consignments without valid 'sort_app' values
// Updated grouping method to filter out duplicate 'sort_app' values
Map<String, List<Map<String, dynamic>>> _groupConsignmentsByDate(
  List<Map<String, dynamic>> consignments,
) {
  final Map<String, List<Map<String, dynamic>>> groupedByDate = {};

  // Use a set to track sort_app values for each date to prevent duplicates
  final Map<String, Set<int>> sortAppTracker = {};

  // Filter and group consignments, ensuring no duplicates based on 'sort_app'
  for (var consignment in consignments) {
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
      // Handle the duplicate case: remove the old consignment with same sort_app
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

  return groupedByDate;
}


  // Updated UI rendering method to display consignments in sorted order
List<Widget> _buildGroupedConsignments(
  Map<String, List<Map<String, dynamic>>> groupedConsignments,
  AsyncSnapshot precheckSnapshot,
) {
  List<Widget> widgets = [];

  groupedConsignments.forEach((date, consignments) {
    String formattedDate;
    if (date != 'Not Provided') {
      formattedDate = DateFormat('dd-MM-yyyy').format(DateFormat('yyyy-MM-dd').parse(date));
    } else {
      formattedDate = date;
    }

    widgets.add(
      Padding(
        padding: EdgeInsets.symmetric(vertical: 2.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              formattedDate,
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );

    widgets.addAll(
      consignments.map((consignment) {
        int index = consignments.indexOf(consignment) + 1;
        String sortAppValue = consignment['sort_app'].toString(); // Get sort_app value as a string

        return GestureDetector(
          onTap: () {
            if ((precheckSnapshot.data![0]['checklist'] == 0 &&
                precheckSnapshot.data![0]['outbound'] == 0)) {
              Map<String, dynamic> updatedArguments = Map.from(consignment);
              print(updatedArguments['status']);

              int status = int.tryParse(updatedArguments['status'].toString()) ?? -1;

              if (status == 10) {
                updatedArguments['consignment_type'] = 'delivery';
                debugPrint('Status is 10, consignment_type set to delivery.');
              } else if (status == 6) {
                updatedArguments['consignment_type'] = 'pickup';
                debugPrint('Status is 6, consignment_type set to pickup.');
              } else {
                debugPrint('Status is not 10, no changes made to consignment_type.');
              }

              Get.toNamed(
                AppRoutes.singleConsigment,
                arguments: {
                  ...updatedArguments,
                },
              );
            }
          },
          child: Column(
            children: [
              // Text(
              //         'Consignment ID: ${consignment['id']}',
              //         style: Theme.of(context).textTheme.bodyMedium,
              //       ),
              //       // Display the sort_app value
              //       Text(
              //         'Sort Order: $sortAppValue',
              //         style: Theme.of(context)
              //             .textTheme
              //             .bodyMedium
              //             ?.copyWith(color: AppColors.blue),
              //       ),
              CustomMyConsigmentContainer(
                consignment: consignment,
                isLoading: false,
                index: index,
                isPrecheckDone: (precheckSnapshot.data![0]['checklist'] == 1 &&
                    precheckSnapshot.data![0]['outbound'] == 1),
               
              ),
            ],
          ),
        );
      }).toList(),
    );
  });

  return widgets;
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
            context.read<BottomNavProvider>().changeTabView(1);
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
          AppText.myConsignment,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: SafeArea(
        child: FormBuilder(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: SingleChildScrollView(
              controller: _scrollController,
              child: StreamBuilder(
                stream: precheck.stream,
                builder: (context, precheckSnapshot) {
                  if (precheckSnapshot.hasData &&
                      precheckSnapshot.connectionState != ConnectionState.waiting) {
                    return StreamBuilder(
                      stream: consignment.stream,
                      builder: (context, consignmentSnapshot) {
                        if (consignmentSnapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.blue,
                            ),
                          );
                        } else if (consignmentSnapshot.hasData) {
                          List<Map<String, dynamic>> allConsignments = [];

                          if (query != null && query!.isNotEmpty) {
                            for (Map<String, dynamic> itr in consignmentSnapshot.data ?? []) {
                              Map deliveryAddresses = json.decode(itr['delivery_addresses']);
                              Map pickupAddresses = json.decode(itr['pickup_addresses']);

                              bool matchesQuery = itr['id']
                                      .toString()
                                      .toLowerCase()
                                      .contains(query!.toLowerCase()) ||
                                  itr['customer_reference']
                                      .toString()
                                      .toLowerCase()
                                      .contains(query!.toLowerCase()) ||
                                  (itr['consignment_type'] == 'delivery'
                                          ? (deliveryAddresses['customer_name']
                                                  ?.toString()
                                                  .toLowerCase() ??
                                              'Not Provided')
                                          : (pickupAddresses['customer_name']
                                                  ?.toString()
                                                  .toLowerCase() ??
                                              'Not Provided'))
                                      .toLowerCase()
                                      .contains(query!.toLowerCase()) ||
                                  (itr['consignment_type'] == 'delivery'
                                          ? (deliveryAddresses['company_name']
                                                  ?.toString()
                                                  .toLowerCase() ??
                                              'Not Provided')
                                          : (pickupAddresses['company_name']
                                                  ?.toString()
                                                  .toLowerCase() ??
                                              'Not Provided'))
                                      .toLowerCase()
                                      .contains(query!.toLowerCase());

                              if (matchesQuery) {
                                allConsignments.add(itr);
                              }
                            }
                          } else {
                            allConsignments.addAll(consignmentSnapshot.data ?? []);
                          }

                          // Group consignments by date and sort by 'sort_app' field
                          Map<String, List<Map<String, dynamic>>> groupedConsignments =
                              _groupConsignmentsByDate(allConsignments);

                          return Column(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                                decoration: BoxDecoration(
                                  color: AppColors.blue,
                                  borderRadius: BorderRadius.circular(8.sp),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 0.5.h),
                                    Text(
                                      AppText.todayConsignment,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineMedium
                                          ?.copyWith(color: AppColors.white),
                                    ),
                                    SizedBox(height: 1.5.h),
                                    Row(
                                      children: [
                                        Text(
                                          allConsignments.length.toString(),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.white,
                                              ),
                                        ),
                                        Text(
                                          AppText.consignmentRemaining,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: AppColors.white,
                                              ),
                                        ),
                                        SizedBox(width: 1.w),
                                        CircleAvatar(
                                          backgroundColor: AppColors.white,
                                          radius: 0.6.w,
                                        ),
                                        SizedBox(width: 1.w),
                                        Text(
                                          DateFormat('dd MMM, yyyy').format(DateTime.now()),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: AppColors.white,
                                              ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 2.h),
                                    CustomTextField(
                                      name: 'search',
                                      borderColor: AppColors.white,
                                      prefixIcon: Icon(
                                        Icons.search,
                                        color: AppColors.black.withOpacity(0.5),
                                      ),
                                      hintText: 'Search by ID, REF or Recipient',
                                      onChanged: (value) {
                                        setState(() {
                                          query = value;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 1.5.h),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  for (int i = 0; i < 4; i++) ...{
                                    Column(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            if (i == 0) {
                                              Get.toNamed(AppRoutes.consignmentMap);
                                            } else if (i == 1) {
                                              Get.toNamed(AppRoutes.consigmentReorder,
                                                  arguments: consignmentSnapshot.data);
                                            } else if (i == 2) {
                                              Get.toNamed(AppRoutes.consigmentGroup,
                                                  arguments: consignmentSnapshot.data);
                                            } else {
                                              _refreshConsignmentData();
                                            }
                                          },
                                          child: CircleAvatar(
                                            radius: 9.w,
                                            backgroundColor: AppColors.greyWhite,
                                            child: i == 0
                                                ? Image.asset(AppImages.path, width: 10.w)
                                                : i == 1
                                                    ? SvgPicture.asset(AppSvgs.reorderBlack, width: 10.w)
                                                    : i == 2
                                                        ? SvgPicture.asset(AppSvgs.groupBlack, width: 10.w)
                                                        : _buildRefreshButton(),
                                          ),
                                        ),
                                        Text(
                                          i == 0
                                              ? 'Map'
                                              : i == 1
                                                  ? 'Re-order'
                                                  : i == 2
                                                      ? 'Group'
                                                      : 'Refresh',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.darkGrey,
                                              ),
                                        ),
                                      ],
                                    ),
                                  },
                                ],
                              ),
                              SizedBox(height: 1.5.h),
                              ..._buildGroupedConsignments(groupedConsignments, precheckSnapshot),
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
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: AppColors.midBlue,
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        } else if (consignmentSnapshot.hasError) {
                          return Column(
                            children: [
                              Row(
                                children: [
                                  Text(
                                    AppText.todayConsignments.toUpperCase(),
                                    style: Theme.of(context).textTheme.headlineSmall,
                                  ),
                                ],
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                consignmentSnapshot.error.toString(),
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          );
                        }
                        return const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.blue,
                          ),
                        );
                      },
                    );
                  } else if (precheckSnapshot.hasError) {
                    return Center(
                      child: Text(
                        precheckSnapshot.error.toString(),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    );
                  }
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.blue,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
      endDrawer: const CustomDrawer(),
    );
  }
}
