import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:coldxpress/export.dart';
import 'package:http/http.dart' as http;

part 'tabs/inbound_pallet_count_tab.dart';
part 'tabs/inbound_signature_confirm_tab.dart';

class InboundPalletsScreen extends StatefulWidget {
  const InboundPalletsScreen({super.key});

  @override
  State<InboundPalletsScreen> createState() => _InboundPalletsScreenState();
}

class _InboundPalletsScreenState extends State<InboundPalletsScreen> {
  final StreamController<dynamic> _inboundStreamController =
      StreamController<dynamic>();
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    fetchData();
    _timer = Timer.periodic(
      const Duration(seconds: 30),
      (timer) {
        fetchData();
      },
    );
  }

  @override
  void dispose() {
    _inboundStreamController.close();
    _timer.cancel();
    super.dispose();
  }

  Future<void> fetchData() async {
    AuthenticationState state =
        BlocProvider.of<AuthenticationCubit>(context).state;
    if (state is Authenticated) {
      try {
        final response = await http.get(
          Uri.parse(AppHost.indexInboundPallet),
          headers: <String, String>{
            'Authorization': 'Bearer ${state.token}',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          final dynamic data = json.decode(response.body);
          _inboundStreamController.add(data);
        } else {
          _inboundStreamController.addError('Failed to fetch data');
        }
      } catch (e) {
        if (!_inboundStreamController.isClosed) {
          _inboundStreamController.addError(e.toString());
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.outInBoundHeaderGradient,
      ),
      child: Scaffold(
           
      key: _scaffoldKey,
 
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            onPressed: () {
              if (context.read<InboundProvider>().index == 0) {
                context.read<InboundProvider>().restoreToDefault();
                Get.back();
              } else {
                context
                    .read<InboundProvider>()
                    .setIndex(context.read<InboundProvider>().index - 1);
              }
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: AppColors.white,
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
                color: AppColors.white,
                size: 20.sp,
              ),
            )
          ],
          centerTitle: true,
          title: Text(
            AppText.pallets,
            style: Theme.of(context)
                .textTheme
                .headlineSmall!
                .copyWith(color: AppColors.white),
          ),
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              StreamBuilder(
                  stream: _inboundStreamController.stream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Expanded(
                        child: Consumer<InboundProvider>(
                          builder: (context, value, child) {
                            return value.index == 0
                                ? InboundPalletCountTab(data: snapshot.data)
                                : const InboundPalletSignatureConfirmationTab();
                          },
                        ),
                      );
                    } else {
                      return Expanded(
                        child: Column(
                          children: [
                            const CustomInBoundHeader(),
                            Expanded(
                              child: ClipRRect(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(30.sp),
                                    topRight: Radius.circular(30.sp),
                                  ),
                                  child: Shimmer.fromColors(
                                    baseColor: AppColors.greyWhite,
                                    highlightColor: AppColors.lightGrey,
                                    child: Container(
                                      width: double.maxFinite,
                                      height: 10.h,
                                      color: AppColors.greyWhite,
                                    ),
                                  )),
                            ),
                          ],
                        ),
                      );
                    }
                  }),
            ],
          ),
        ),
         endDrawer: const CustomDrawer(),
      ),
    );
  }
}
