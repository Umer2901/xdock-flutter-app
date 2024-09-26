import 'dart:convert';

import 'package:coldxpress/export.dart';

import '../widgets/core/custom_pod_history_container.dart';

class PodHistory extends StatefulWidget {
  const PodHistory({super.key});

  @override
  State<PodHistory> createState() => _PodHistoryState();
}

class _PodHistoryState extends State<PodHistory> {
  TaskSyncDatabase? taskDatabase;
  late PreCheckDatabase precheck;
  Stream<List<Map<String, dynamic>>>? taskStream;
  String? query = ''; // This will store the search query

  @override
  void initState() {
    super.initState();
    _startSync(); // Initialize the database and stream
  }

  void _startSync() async {
    Database database = await context.read<DatabaseProvider>().database;
    taskDatabase = TaskSyncDatabase(database);
    precheck = PreCheckDatabase(database); // Initialize precheck

    if (taskDatabase != null) {
      setState(() {
        taskStream = taskDatabase!.stream; // Initialize the task stream
      });
    } else {
      print('Error: TaskSyncDatabase is null.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.blue,
        shape: const CircleBorder(),
        onPressed: () {},
        child: Image.asset(AppImages.upload, height: 30, width: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop(); // Navigate back
          },
          icon: Icon(
            Icons.arrow_back_ios,
            size: 15.sp,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // Handle more actions here
            },
            icon: Icon(
              Icons.more_horiz,
              size: 20.sp,
            ),
          ),
        ],
        centerTitle: true,
        title: Text(
          AppText.podHoistory, // Assuming AppText contains text constants
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 10.0, left: 14, right: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search bar
              StreamBuilder<List<Map<String, dynamic>>>(
                  stream: taskStream,
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
                              hintText: 'Search by ID or Company Name',
                              onChanged: (value) {
                                setState(() {
                                  query = value; // Update the search query
                                });
                              },
                            ),
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }),
              SizedBox(
                height: 3.h,
              ),
              // Display tasks in a ListView with search filtering applied to the stream
              StreamBuilder<List<Map<String, dynamic>>>(
                stream: taskStream?.map((tasks) {
                  // Apply search filter on the stream data
                  if (query != null && query!.isNotEmpty) {
                    return tasks.where((task) {
                      // Convert consignment_id to String for comparison
                      String taskId = task['data']['consignment_id']
                          .toString(); // Convert to String

                      print("Task ID INSIDE POD HISTORY: $taskId");
                      print(
                          "Delivery Addresses INSIDE POD HISTORY: ${task['data']['delivery_addresses']}");
                      print(
                          "Pickup Addresses INSIDE POD HISTORY: ${task['data']['pickup_addresses']}");

                      // Now you can safely use toLowerCase() on taskId
                      bool matchesId = taskId.contains(query!.toLowerCase());

                      String companyName = '';

                      // Extract company name from delivery or pickup addresses
                      if (task['data']['consignment_type'] == 'delivery') {
                        Map? deliveryAddresses =
                            task['data']['delivery_addresses'] != null
                                ? json.decode(task['delivery_addresses'])
                                : null;
                        companyName = deliveryAddresses != null &&
                                deliveryAddresses['company_name'] != null
                            ? deliveryAddresses['company_name']
                                .toString()
                                .toLowerCase()
                            : '';
                      } else {
                        Map? pickupAddresses =
                            task['data']['pickup_addresses'] != null
                                ? json.decode(task['data']['pickup_addresses'])
                                : null;
                        companyName = pickupAddresses != null &&
                                pickupAddresses['company_name'] != null
                            ? pickupAddresses['company_name']
                                .toString()
                                .toLowerCase()
                            : '';
                      }

                      // Filter tasks by ID or Company Name
                      return matchesId ||
                          companyName.contains(query!.toLowerCase());
                      //return taskId.contains(query!.toLowerCase()) || companyName.contains(query!.toLowerCase());
                    }).toList();
                  }
                  return tasks; // Return unfiltered tasks if query is empty
                }),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.blue,
                      ),
                    );
                  } else if (snapshot.hasData) {
                    List<Map<String, dynamic>> tasks = snapshot.data!;

                    // Display filtered tasks
                    if (tasks.isEmpty) {
                      return const Center(child: Text('No results found'));
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        Map<String, dynamic> task = tasks[index];

                        return CustomPodHistoryContainer(
                          consignment: task,
                          ontab: () {
                            Get.toNamed(AppRoutes.podhistoryview,
                                arguments: task);
                          },
                        );
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text("Error: ${snapshot.error}"),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
