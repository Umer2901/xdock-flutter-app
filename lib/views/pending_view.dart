import 'dart:convert';

import 'package:coldxpress/export.dart';
import 'package:coldxpress/providers/task_sync_provider.dart';
import 'package:coldxpress/widgets/core/custom_pod_history.dart';

import '../widgets/core/custom-container.dart';

class PendingView extends StatefulWidget {
  const PendingView({super.key});

  @override
  State<PendingView> createState() => _PendingViewState();
}

class _PendingViewState extends State<PendingView> {
  TaskSyncDatabase? taskDatabase;
  Stream<List<Map<String, dynamic>>>? taskStream;
  String? query = '';
  bool _isLoading = false;
  late PreCheckDatabase precheck;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _startSync();

    AuthenticationState state =
        BlocProvider.of<AuthenticationCubit>(context).state;

    precheck = PreCheckDatabase(context.read<DatabaseProvider>().database);
  }

  void _startSync() async {
    Database database = await context.read<DatabaseProvider>().database;
    taskDatabase = TaskSyncDatabase(database);

    if (taskDatabase != null) {
      setState(() {
        taskStream = taskDatabase!.stream;
      });
    } else {
      print('Error: TaskSyncDatabase is null.');
    }
  }

  Map<String, dynamic>? _getDataField(dynamic dataField) {
    if (dataField is Map<String, dynamic>) {
      return dataField;
    }

    if (dataField is String) {
      try {
        return json.decode(dataField) as Map<String, dynamic>?;
      } catch (e) {
        debugPrint('Error decoding JSON: $e');
        return null;
      }
    }

    // If it's neither, return null
    return null;
  }
Future<void> _refreshConsignmentData() async {
  if (!_isLoading) {
    setState(() {
      _isLoading = true;
    });

    try {
      // Retrieve the database instance from the DatabaseProvider
      Database database = await context.read<DatabaseProvider>().database;

      // Initialize the TaskSyncDatabase if not already
      if (taskDatabase == null) {
        taskDatabase = TaskSyncDatabase(database);
      }

      // Fetch the unsynced tasks from the local database
      final unsyncedTasks = await taskDatabase?.readForSync() ?? [];

      // Create an instance of TaskSyncProvider and pass the database
      final taskSyncProvider = TaskSyncProvider();

      // Call the startSync method to ensure connectivity is checked
      taskSyncProvider.startSync(database, context);

      // Iterate through each unsynced task and call `postDataToApi` using TaskSyncProvider instance
      for (var task in unsyncedTasks) {
        final Map<String, dynamic> taskData = json.decode(task['data']);
        final taskId = task['id'];
        final accessToken = taskData['access_token'];

        if (accessToken != null) {
          // Call the postDataToApi function using the TaskSyncProvider instance
          await taskSyncProvider.postDataToApi(taskId, accessToken, taskData, context);
        } else {
          print('Access token is null for task: $taskId');
        }
      }

      print('All unsynced tasks have been processed.');

    } catch (e) {
      print('Error during sync: $e');
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
        radius: 7.w,
        backgroundColor: AppColors.yellow,
        child: _isLoading
            ? const CircularProgressIndicator(
                color: AppColors.blue,
              )
            : Image.asset(
                AppImages.refreshicon,
                width: 7.w,
                height: 7.h,
              ),
      ),
    );
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
            Navigator.of(context).pop();
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
          AppText.podHoistory,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 10.0, left: 14, right: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
              SizedBox(
                height: 3.h,
              ),
              Expanded(
                child: StreamBuilder<List<Map<String, dynamic>>>(
                  stream: taskStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.blue,
                        ),
                      );
                    } else if (snapshot.hasData) {
                      // Filter tasks with is_sync set to false
                      List<Map<String, dynamic>> tasks = snapshot.data!
                          .where((task) => task['is_sync'] == 'false')
                          .toList();

                      // Apply search query filter
                      if (query != null && query!.isNotEmpty) {
                        tasks = tasks.where((task) {
                          final data = _getDataField(task['data']);
                          if (data == null) return false;

                          final taskId = data['consignment_id']?.toString().toLowerCase() ?? '';
                          final consignmentType = data['consignment_type'];
                          String companyName = data['company_name']?.toString().toLowerCase() ?? '';
                          return taskId.contains(query!.toLowerCase()) ||
                              companyName.contains(query!.toLowerCase());
                        }).toList();
                      }

                      // Display filtered tasks
                      if (tasks.isEmpty) {
                        return const Center(child: Text('No results found'));
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          Map<String, dynamic> task = tasks[index];

                          return GestureDetector(
                            onTap: () {
                              Get.toNamed(AppRoutes.podhistoryview,
                                  arguments: task);
                            },
                            child: CustomPodHistoryContainer(
                              consignment: task,
                              ontab: () {
                                Get.toNamed(AppRoutes.podhistoryview,
                                    arguments: task);
                              },
                            ),
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
              ),
            ],
          ),
        ),
      ),
      endDrawer: const CustomDrawer(),
    );
  }
}
