import 'dart:convert';
import 'package:coldxpress/export.dart';

class MyConsigmentReorder extends StatefulWidget {
  const MyConsigmentReorder({super.key});

  @override
  State<MyConsigmentReorder> createState() => _MyConsigmentReorderState();
}

class _MyConsigmentReorderState extends State<MyConsigmentReorder> {
 
  final ScrollController _scrollController = ScrollController();
  final List<dynamic> _consignments = [];
  Map<String, List<dynamic>> groupedConsignments = {};
  List<int> consignmentIds = [];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    final arguments = json.decode(json.encode(Get.arguments));
    _consignments.addAll(arguments);
    groupedConsignments = _groupConsignmentsByDate();
    _updateConsignmentIds();
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
                      width: 40.w,
                      height: 5.h,
                      label: AppText.save.toUpperCase(),
                      onPressed: () {
                        if (consignmentIds.isNotEmpty) {
                          AuthenticationState authState =
                              BlocProvider.of<AuthenticationCubit>(context)
                                  .state;
                          if (authState is Authenticated) {
                            ConsignmentService(
                                    context.read<DatabaseProvider>().database)
                                .reorderConsignments(
                              consignmentIds,
                              authState.token,
                            );
                            Get.back();
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
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
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            onReorder: (oldIndex, newIndex) {
                              setState(() {
                                if (newIndex > oldIndex) {
                                  newIndex -= 1;
                                }
                                final item = consignments.removeAt(oldIndex);
                                consignments.insert(newIndex, item);
                                _updateConsignmentIdsFromConsignments();
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

  void _updateConsignmentIds() {
    final List<dynamic> allConsignments = [];
    groupedConsignments.forEach((key, value) {
      allConsignments.addAll(value);
    });
    consignmentIds = allConsignments.map((consignment) => consignment['id'] as int).toList();
  }

  void _updateConsignmentIdsFromConsignments() {
    final List<dynamic> allConsignments = [];
    groupedConsignments.forEach((key, value) {
      allConsignments.addAll(value);
    });
    consignmentIds = allConsignments.map((consignment) => consignment['id'] as int).toList();
  }

  Map<String, List<dynamic>> _groupConsignmentsByDate() {
    final Map<String, List<dynamic>> groupedByDate = {};

    for (var consignment in _consignments) {
      final date = consignment['delivery_date'] ?? 'Not Provided';
      if (!groupedByDate.containsKey(date)) {
        groupedByDate[date] = [];
      }
      groupedByDate[date]!.add(consignment);
    }

    return groupedByDate;
  }
}
