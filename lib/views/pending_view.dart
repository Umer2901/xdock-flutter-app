import 'dart:convert';

import 'package:coldxpress/export.dart';

import '../widgets/core/custom-container.dart';

class PendingView extends StatefulWidget {
  const PendingView({super.key});

  @override
  State<PendingView> createState() => _PendingViewState();
}

class _PendingViewState extends State<PendingView> {
  late ConsignmentDatabase? consignment;
  late PreCheckDatabase precheck;
  bool _isLoading = false;
  String? query;
final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    AuthenticationState state =
        BlocProvider.of<AuthenticationCubit>(context).state;
    if (state is Authenticated) {
      consignment = ConsignmentDatabase(
        context.read<DatabaseProvider>().database,
        accessToken: state.token,
      );
    }
    precheck = PreCheckDatabase(context.read<DatabaseProvider>().database);
  }

  @override
  void dispose() {
    consignment?.dispose();
    super.dispose();
  }

  Future<void> _refreshConsignmentData() async {
    if (!_isLoading) {
      setState(() {
        _isLoading = true;
      });

      try {
        final consignmentService =
            ConsignmentService(context.read<DatabaseProvider>().database);
        final state = BlocProvider.of<AuthenticationCubit>(context).state;
        if (state is Authenticated) {
          await consignmentService.fetchAndStore(state.token);
        }
      } catch (e) {
        // Handle error if needed
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
        radius: 8.w,
        backgroundColor: AppColors.yellow,
        child: _isLoading
            ? const CircularProgressIndicator(
                color: AppColors.blue,
              )
            : Image.asset(
                AppImages.refreshicon,
                width: 8.w,
                height: 8.h,
              ),
      ),
    );
  }

  Map<String, List<Map<String, dynamic>>> _groupConsignmentsByDate(
      List<Map<String, dynamic>> consignments) {
    final Map<String, List<Map<String, dynamic>>> groupedByDate = {};

    for (var consignment in consignments) {
      final date = consignment['delivery_date'] ?? 'Not Provided';
      if (!groupedByDate.containsKey(date)) {
        groupedByDate[date] = [];
      }
      groupedByDate[date]!.add(consignment);
    }

    final sortedGroupedByDate =
        Map<String, List<Map<String, dynamic>>>.fromEntries(
      groupedByDate.entries.toList()
        ..sort((a, b) {
          if (a.key == 'Not Provided') return 1;
          if (b.key == 'Not Provided') return -1;

          DateTime dateA = DateFormat('yyyy-MM-dd').parse(a.key);
          DateTime dateB = DateFormat('yyyy-MM-dd').parse(b.key);

          return dateA.compareTo(dateB);
        }),
    );

    return sortedGroupedByDate;
  }

  List<Widget> _buildGroupedConsignments(
      Map<String, List<Map<String, dynamic>>> groupedConsignments,
      AsyncSnapshot precheckSnapshot) {
    List<Widget> widgets = [];

    groupedConsignments.forEach((date, consignments) {
      String formattedDate;
      if (date != 'Not Provided') {
        formattedDate = DateFormat('dd-MM-yyyy')
            .format(DateFormat('yyyy-MM-dd').parse(date));
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
          return GestureDetector(
            onTap: () {
              if ((precheckSnapshot.data![0]['checklist'] == 0 &&
                  precheckSnapshot.data![0]['outbound'] == 0)) {
                Get.toNamed(
                  AppRoutes.singleConsigment,
                  arguments: consignment,
                );
              }
            },
            child: Column(
              children: [
                CustomMyConsigmentContainer(
                  consignment: consignment,
                  isLoading: false,
                  index: index,
                  isPrecheckDone:
                      (precheckSnapshot.data![0]['checklist'] == 1 &&
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

  Map<String, dynamic> _decodeIfString(dynamic data) {
    if (data is String) {
      return json.decode(data) as Map<String, dynamic>;
    } else if (data is Map<String, dynamic>) {
      return data;
    } else if (data is int) {
      return {'value': data};
    } else {
      throw TypeError();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold( 
key: _scaffoldKey,
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _buildRefreshButton(),
        
          SizedBox(height: 1.7.h),
          FloatingActionButton(
            backgroundColor: AppColors.blue,
            shape: const CircleBorder(),
            onPressed: () async {
                                AuthenticationState state =
                                    BlocProvider.of<AuthenticationCubit>(
                                            context)
                                        .state;
                                if (state is Authenticated) {
                                  BlocProvider.of<AuthenticationCubit>(context)
                                      .logout(
                                    database: context
                                        .read<DatabaseProvider>()
                                        .database,
                                    token: state.token,
                                  );
                                }
                              },
            
            child: Image.asset(
              AppImages.upload,
              height: 30,
              width: 30,
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
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
          AppText.pending,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 10.0, left: 14, right: 14),
        child: Column(
          children: [
            StreamBuilder(
              stream: precheck.stream,
              builder: (context, precheckSnapshot) {
                if (precheckSnapshot.hasData &&
                    precheckSnapshot.connectionState !=
                        ConnectionState.waiting) {
                  return Container(
                    height: 83,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(0xffF4F4F4),
                      shape: BoxShape.rectangle,
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 12.0,
                          left: 15,
                          right: 15,
                          bottom: 12,
                        ),
                        child: CustomTextField(
                          maxLines: 1,
                          hight: 6.h,
                          name: 'search',
                          borderColor: AppColors.white,
                          prefixIcon: Icon(
                            Icons.search,
                            color: AppColors.black.withOpacity(0.5),
                          ),
                          hintText: 'Search',
                          onChanged: (value) {
                            setState(() {
                              query = value;
                            });
                          },
                        ),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
           
            SizedBox(height: 3.h),
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: consignment?.stream,
                builder: (context, consignmentSnapshot) {
                  if (consignmentSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.blue,
                      ),
                    );
                  } else if (consignmentSnapshot.hasData) {
                    List<Map<String, dynamic>> consignments =
                        consignmentSnapshot.data!;

                    // print('Consignments : $consignments');
                    // Iterate through each consignment
                    // for (var consignment in consignments) {
                    //   print(
                    //       ' consignment Type: ${consignment['consignment_type']}');
                    // }

                    // Filter consignments based on the search query
                    if (query != null && query!.isNotEmpty) {
                      consignments = consignments.where((itr) {
                        Map deliveryAddresses =
                            json.decode(itr['delivery_addresses']);
                        Map pickupAddresses =
                            json.decode(itr['pickup_addresses']);
                        return itr['id']
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
                                .contains(query!.toLowerCase());
                      }).toList();
                    }

                    Map<String, List<Map<String, dynamic>>>
                        groupedConsignments =
                        _groupConsignmentsByDate(consignments);

                    return ListView.builder(
                      itemCount: consignments.length,
                      itemBuilder: (context, index) {
                        Map<String, dynamic> itr = consignments[index];

                        //print('Itr Values : ${itr.values}');

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomContainer(
                              ontab: () {},
                              consignment: itr,
                            ),
                            SizedBox(height: 3.h),
                          ],
                        );
                      },
                    );
                  } else if (consignmentSnapshot.hasError) {
                    return Center(
                        child: Text("Error: ${consignmentSnapshot.error}"));
                  }
                  return const Center(child: Text("No Data Available"));
                },
              ),
            ),
          ],
        ),
      ),
endDrawer: const CustomDrawer(),
    );
  }
}