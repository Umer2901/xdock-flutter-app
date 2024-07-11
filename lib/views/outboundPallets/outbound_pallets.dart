import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:coldxpress/export.dart';
import 'package:http/http.dart' as http;

part 'tabs/outbound_pallet_count_tab.dart';
part 'tabs/outbound_signature_confirm_tab.dart';

class OutboundPalletsScreen extends StatefulWidget {
  const OutboundPalletsScreen({super.key});

  @override
  State<OutboundPalletsScreen> createState() => _OutboundPalletsScreenState();
}

class _OutboundPalletsScreenState extends State<OutboundPalletsScreen> {
  final StreamController<dynamic> _outboundStreamController =
      StreamController<dynamic>();

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
    _outboundStreamController.close();
    _timer.cancel();
    super.dispose();
  }

  Future<void> fetchData() async {
    AuthenticationState state =
        BlocProvider.of<AuthenticationCubit>(context).state;
    if (state is Authenticated) {
      try {
        final response = await http.get(
          Uri.parse(AppHost.indexOutboundPallet),
          headers: <String, String>{
            'Authorization': 'Bearer ${state.token}',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          final dynamic data = json.decode(response.body);
          _outboundStreamController.add(data);
        } else {
          _outboundStreamController.addError('Failed to fetch data');
        }
      } catch (e) {
        if (!_outboundStreamController.isClosed) {
          _outboundStreamController.addError(e.toString());
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
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            onPressed: () {
              if (context.read<OutboundProvider>().index == 0) {
                context.read<OutboundProvider>().restoreToDefault();
                Get.back();
              } else {
                context.read<OutboundProvider>().setIndex(
                      context.read<OutboundProvider>().index - 1,
                    );
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
              onPressed: () {},
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
                stream: _outboundStreamController.stream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Expanded(
                      child: Consumer<OutboundProvider>(
                        builder: (context, value, child) {
                          return value.index == 0
                              ? OutboundPalletCountTab(data: snapshot.data)
                              : const OutboundPalletSignatureConfirmationTab();
                        },
                      ),
                    );
                  } else {
                    return Expanded(
                      child: Column(
                        children: [
                          const CustomOutBoundHeader(),
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
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
