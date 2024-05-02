import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:coldxpress/export.dart';

class MyConsigmentReorder extends StatefulWidget {
  const MyConsigmentReorder({super.key});

  @override
  State<MyConsigmentReorder> createState() => _MyConsigmentReorderState();
}

class _MyConsigmentReorderState extends State<MyConsigmentReorder> {
  final ScrollController _scrollController = ScrollController();
  final StreamController<dynamic> _consignmentStreamController =
      StreamController<dynamic>();
  late Timer _timer;
  List<dynamic>? _consignments;
  @override
  void initState() {
    super.initState();
    fetchConsignment();
    _timer = Timer.periodic(
      const Duration(seconds: 30),
      (timer) {
        fetchConsignment();
      },
    );
  }

  @override
  void dispose() {
    _consignmentStreamController.close();
    _timer.cancel();
    super.dispose();
  }

  Future<void> fetchConsignment() async {
    AuthenticationState state =
        BlocProvider.of<AuthenticationCubit>(context).state;
    if (state is Authenticated) {
      try {
        final response = await http.get(
          Uri.parse(AppHost.consignments),
          headers: <String, String>{
            'Authorization': 'Bearer ${state.token}',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        );
        if (response.statusCode == 200) {
          final dynamic data = json.decode(response.body);
          if (data['status'] == 'success') {
            _consignmentStreamController.add(data);
          } else {
            _consignmentStreamController.addError(data['message']);
          }
        } else {
          _consignmentStreamController.addError('Failed to fetch data');
        }
      } catch (e) {
        if (!_consignmentStreamController.isClosed) {
          _consignmentStreamController.addError(e.toString());
        }
      }
    }
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
          AppText.reorder,
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
                        onPressed: () {}),
                    CustomButton(
                        width: 40.w,
                        height: 5.h,
                        label: AppText.save.toUpperCase(),
                        onPressed: () {}),
                  ],
                ),
              ),
              StreamBuilder(
                  stream: _consignmentStreamController.stream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      _consignments = snapshot.data['data']['2024-04-04'] ==
                              null
                          ? []
                          : snapshot.data['data']['2024-04-04']['consignments'];

                      return Column(
                        children: [
                          if (_consignments != null)
                            ReorderableListView(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              onReorder: (oldIndex, newIndex) {
                                setState(() {
                                  if (newIndex > oldIndex) {
                                    newIndex -= 1;
                                  }
                                  final item =
                                      _consignments!.removeAt(oldIndex);
                                  _consignments!.insert(newIndex, item);
                                });
                              },
                              children: List.generate(
                                _consignments!.length,
                                (index) {
                                  final consignment = _consignments![index];
                                  return CustomConsignmentContainer(
                                    key: ValueKey(consignment['id']),
                                    consignment: consignment,
                                    icon: const Icon(Icons.drag_handle),
                                  );
                                },
                              ),
                            ),
                          snapshot.data['data'].containsKey('2024-04-04') ==
                                  false
                              ? Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: 4.h,
                                  ),
                                  child: SizedBox(
                                    width: 60.w,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
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
                                              ?.copyWith(
                                                  fontWeight: FontWeight.w700),
                                        ),
                                        Text(
                                          'Get back safe, and remember to return your pallets.',
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                  fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : GestureDetector(
                                  onTap: () {
                                    _scrollController.animateTo(
                                      0.0,
                                      duration:
                                          const Duration(milliseconds: 500),
                                      curve: Curves.easeInOut,
                                    );
                                  },
                                  child: Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 2.h),
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
                    }
                    if (snapshot.hasError) {
                      return SizedBox(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  AppText.todayConsignments.toUpperCase(),
                                  style:
                                      Theme.of(context).textTheme.headlineSmall,
                                ),
                              ],
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              snapshot.error.toString(),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(color: AppColors.red),
                            ),
                          ],
                        ),
                      );
                    } else {
                      return SizedBox(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              for (int i = 0; i < 10; i++) ...{
                                const CustomConsignmentContainer(
                                  isLoading: true,
                                  icon: Icon(Icons.drag_handle),
                                ),
                              }
                            ],
                          ),
                        ),
                      );
                    }
                  }),
            ],
          ),
        ),
      )),
    );
  }
}
